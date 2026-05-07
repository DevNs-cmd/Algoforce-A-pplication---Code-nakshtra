require('dotenv').config();

const crypto = require('crypto');
const fs = require('fs');
const http = require('http');
const path = require('path');

const bcrypt = require('bcryptjs');
const cors = require('cors');
const express = require('express');
const jwt = require('jsonwebtoken');
const multer = require('multer');
const Redis = require('ioredis');
const { PrismaClient } = require('@prisma/client');
const { WebSocketServer } = require('ws');

const prisma = new PrismaClient();
const app = express();
const server = http.createServer(app);
const wss = new WebSocketServer({ server, path: '/ws' });
const port = Number(process.env.PORT || 4000);
const jwtSecret = process.env.JWT_SECRET || 'replace-with-production-secret';
const uploadRoot = path.join(__dirname, '..', 'uploads');
const redisUrl = process.env.REDIS_URL || 'redis://localhost:6379';
const testMode = process.env.AUTH_REQUIRED !== 'true';

fs.mkdirSync(uploadRoot, { recursive: true });

let redis = null;
try {
  redis = new Redis(redisUrl, {
    lazyConnect: true,
    maxRetriesPerRequest: 1,
    enableOfflineQueue: false,
  });
  redis.connect().catch(() => {
    redis = null;
  });
} catch (_) {
  redis = null;
}

const upload = multer({
  storage: multer.diskStorage({
    destination: (_, __, cb) => cb(null, uploadRoot),
    filename: (_, file, cb) => {
      const ext = path.extname(file.originalname || '');
      cb(null, `${Date.now()}-${crypto.randomBytes(8).toString('hex')}${ext}`);
    },
  }),
  limits: { fileSize: 10 * 1024 * 1024 },
});

app.use(cors());
app.use(express.json({ limit: '1mb' }));
app.use('/uploads', express.static(uploadRoot));

function signAccessToken(user) {
  return jwt.sign(
    { sub: user.id, role: user.role, email: user.email, trustScore: user.trustScore },
    jwtSecret,
    { expiresIn: '15m' },
  );
}

function signRefreshToken(user) {
  return jwt.sign({ sub: user.id, type: 'refresh' }, jwtSecret, { expiresIn: '14d' });
}

async function devActor(role = 'admin') {
  return prisma.user.upsert({
    where: { email: `testing-${role}@algoforce.ai` },
    update: { role },
    create: {
      name: `Testing ${role}`,
      email: `testing-${role}@algoforce.ai`,
      passwordHash: await bcrypt.hash('testing', 8),
      role,
      trustScore: 99,
    },
  });
}

function auth(requiredRoles = []) {
  return async (req, res, next) => {
    const token = (req.headers.authorization || '').replace(/^Bearer\s+/i, '');
    if (!token && testMode) {
      const requestedRole = String(req.headers['x-test-role'] || req.query.asRole || 'admin');
      const role = ['founder', 'investor', 'builder', 'admin'].includes(requestedRole) ? requestedRole : 'admin';
      const user = await devActor(role);
      req.user = { sub: user.id, role: user.role, email: user.email, trustScore: user.trustScore };
      return next();
    }
    try {
      req.user = jwt.verify(token, jwtSecret);
      if (!testMode && requiredRoles.length && !requiredRoles.includes(req.user.role)) {
        return res.status(403).json({ error: 'RBAC_DENIED', requiredRoles });
      }
      return next();
    } catch (_) {
      return res.status(401).json({ error: 'UNAUTHENTICATED' });
    }
  };
}

function pageArgs(req) {
  const page = Math.max(1, Number(req.query.page || 1));
  const pageSize = Math.min(50, Math.max(1, Number(req.query.pageSize || 20)));
  return { skip: (page - 1) * pageSize, take: pageSize, page, pageSize };
}

function broadcast(message) {
  const payload = JSON.stringify(message);
  for (const client of wss.clients) {
    if (client.readyState === 1) client.send(payload);
  }
  if (redis) redis.publish('algoforce-events', payload).catch(() => {});
}

async function emitEvent(type, payload, actorId, startupId) {
  const event = await prisma.eventLog.create({
    data: { type, payload, actorId, startupId },
  });
  broadcast({ channel: 'events', type, event });
  return event;
}

async function notify(userId, type, message, payload = {}) {
  if (!userId) return null;
  const notification = await prisma.notification.create({
    data: { userId, type, message, payload },
  });
  broadcast({ channel: 'notifications', notification });
  return notification;
}

async function clearStartupCache() {
  if (redis) {
    const keys = await redis.keys('startup:list:*').catch(() => []);
    if (keys.length) await redis.del(keys).catch(() => {});
  }
}

async function computeStartupScore(startupId) {
  const startup = await prisma.startup.findUnique({
    where: { id: startupId },
    include: { tasks: true, investments: true, founder: true },
  });
  if (!startup) return null;
  const taskCount = startup.tasks.length;
  const doneCount = startup.tasks.filter((task) => task.status === 'DONE').length;
  const evidenceCount = startup.tasks.filter((task) => Boolean(task.evidenceUrl)).length;
  const executionProgress = taskCount ? Math.round((doneCount / taskCount) * 100) : 0;
  const evidenceScore = taskCount ? Math.round((evidenceCount / taskCount) * 100) : 0;
  const ideaClarity = Math.min(100, Math.round(((startup.name.length + startup.idea.length) / 180) * 100));
  const capitalSignal = Math.min(100, Math.round(startup.investments.reduce((sum, item) => sum + item.amount, 0) / 10000));
  const score = Math.round(
    startup.marketScore * 0.24 +
      ideaClarity * 0.18 +
      executionProgress * 0.24 +
      startup.teamStrength * 0.18 +
      evidenceScore * 0.10 +
      capitalSignal * 0.06,
  );
  return {
    startupId,
    score,
    risk: score >= 76 ? 'low' : score >= 52 ? 'medium' : 'high',
    marketScore: startup.marketScore,
    ideaClarity,
    executionProgress,
    teamStrength: startup.teamStrength,
    evidenceScore,
    capitalSignal,
    recommendation:
      score >= 76
        ? 'Scale fundraising and enterprise validation'
        : score >= 52
          ? 'Increase execution evidence before scaling'
          : 'Clarify market and complete core execution tasks',
  };
}

app.get('/health', async (_, res) => {
  await prisma.$queryRaw`SELECT 1`;
  res.json({ ok: true, service: 'AlgoForce AI', database: 'postgresql', realtime: 'websocket', redis: Boolean(redis), authRequired: !testMode });
});

app.post('/auth/register', async (req, res) => {
  const { name, email, password, role } = req.body;
  if (!name || !email || !password || !role) return res.status(400).json({ error: 'MISSING_REQUIRED_FIELDS' });
  if (!['founder', 'investor', 'builder', 'admin'].includes(role)) return res.status(400).json({ error: 'INVALID_ROLE' });
  const passwordHash = await bcrypt.hash(password, 12);
  const user = await prisma.user.create({ data: { name, email, passwordHash, role } });
  if (role === 'builder') {
    await prisma.builderProfile.create({ data: { userId: user.id, skills: [], rating: 0 } });
  }
  await emitEvent('USER_CREATED', { userId: user.id, email, role }, user.id);
  res.status(201).json({ user, accessToken: signAccessToken(user), refreshToken: signRefreshToken(user) });
});

app.post('/auth/login', async (req, res) => {
  const { email, password } = req.body;
  const user = await prisma.user.findUnique({ where: { email } });
  if (!user || !(await bcrypt.compare(password || '', user.passwordHash))) {
    return res.status(401).json({ error: 'INVALID_CREDENTIALS' });
  }
  await emitEvent('USER_LOGGED_IN', { userId: user.id, role: user.role }, user.id);
  res.json({ user, accessToken: signAccessToken(user), refreshToken: signRefreshToken(user) });
});

app.get('/auth/me', auth(), async (req, res) => {
  const user = await prisma.user.findUnique({
    where: { id: req.user.sub },
    include: { builderProfile: true },
  });
  res.json(user);
});

app.post('/startup', auth(['founder', 'admin']), async (req, res) => {
  const { name, idea, status = 'ACTIVE', fundingStage = 'BOOTSTRAPPED', marketScore = 50, teamStrength = 50 } = req.body;
  const startup = await prisma.startup.create({
    data: {
      founderId: req.user.sub,
      name,
      idea,
      status,
      fundingStage,
      marketScore: Number(marketScore),
      teamStrength: Number(teamStrength),
    },
    include: { tasks: true, investments: true, founder: true },
  });
  await clearStartupCache();
  await emitEvent('STARTUP_CREATED', { startupId: startup.id, name }, req.user.sub, startup.id);
  broadcast({ channel: 'startups', action: 'created', startup });
  res.status(201).json(startup);
});

app.get('/startup', auth(), async (req, res) => {
  const { skip, take, page, pageSize } = pageArgs(req);
  const where = {};
  if (req.query.q) {
    where.OR = [
      { name: { contains: String(req.query.q), mode: 'insensitive' } },
      { idea: { contains: String(req.query.q), mode: 'insensitive' } },
    ];
  }
  if (req.query.fundingStage) where.fundingStage = String(req.query.fundingStage);
  const cacheKey = `startup:list:${JSON.stringify({ where, skip, take, role: req.user.role, user: req.user.sub })}`;
  if (redis) {
    const cached = await redis.get(cacheKey).catch(() => null);
    if (cached) return res.json(JSON.parse(cached));
  }
  const scopedWhere = !testMode && req.user.role === 'founder' ? { ...where, founderId: req.user.sub } : where;
  const [items, total] = await Promise.all([
    prisma.startup.findMany({
      where: scopedWhere,
      skip,
      take,
      orderBy: { updatedAt: 'desc' },
      include: { tasks: true, investments: true, founder: true },
    }),
    prisma.startup.count({ where: scopedWhere }),
  ]);
  const result = { items, page, pageSize, total };
  if (redis) await redis.set(cacheKey, JSON.stringify(result), 'EX', 20).catch(() => {});
  res.json(result);
});

app.get('/startup/:id', auth(), async (req, res) => {
  const startup = await prisma.startup.findUnique({
    where: { id: req.params.id },
    include: { tasks: { include: { assignee: true } }, investments: true, founder: true, events: { orderBy: { timestamp: 'desc' }, take: 30 } },
  });
  if (!startup) return res.status(404).json({ error: 'STARTUP_NOT_FOUND' });
  if (!testMode && req.user.role === 'founder' && startup.founderId !== req.user.sub) return res.status(403).json({ error: 'RBAC_DENIED' });
  if (req.user.role === 'investor') {
    await emitEvent('INVESTOR_VIEWED_STARTUP', { startupId: startup.id }, req.user.sub, startup.id);
  }
  res.json({ ...startup, analytics: await computeStartupScore(startup.id) });
});

app.get('/startup/:id/analytics', auth(), async (req, res) => {
  const analytics = await computeStartupScore(req.params.id);
  if (!analytics) return res.status(404).json({ error: 'STARTUP_NOT_FOUND' });
  res.json(analytics);
});

app.put('/startup/:id', auth(['founder', 'admin']), async (req, res) => {
  const existing = await prisma.startup.findUnique({ where: { id: req.params.id } });
  if (!existing) return res.status(404).json({ error: 'STARTUP_NOT_FOUND' });
  if (!testMode && req.user.role === 'founder' && existing.founderId !== req.user.sub) return res.status(403).json({ error: 'RBAC_DENIED' });
  const startup = await prisma.startup.update({
    where: { id: req.params.id },
    data: {
      name: req.body.name,
      idea: req.body.idea,
      status: req.body.status,
      fundingStage: req.body.fundingStage,
      marketScore: req.body.marketScore == null ? undefined : Number(req.body.marketScore),
      teamStrength: req.body.teamStrength == null ? undefined : Number(req.body.teamStrength),
    },
    include: { tasks: true, investments: true, founder: true },
  });
  await clearStartupCache();
  await emitEvent('STARTUP_UPDATED', { startupId: startup.id, patch: req.body }, req.user.sub, startup.id);
  if (req.body.status || req.body.fundingStage) await notify(startup.founderId, 'STARTUP_STATUS_CHANGED', `${startup.name} status changed`, { startupId: startup.id });
  broadcast({ channel: 'startups', action: 'updated', startup });
  res.json(startup);
});

app.delete('/startup/:id', auth(['founder', 'admin']), async (req, res) => {
  const existing = await prisma.startup.findUnique({ where: { id: req.params.id } });
  if (!existing) return res.status(404).json({ error: 'STARTUP_NOT_FOUND' });
  if (!testMode && req.user.role === 'founder' && existing.founderId !== req.user.sub) return res.status(403).json({ error: 'RBAC_DENIED' });
  await prisma.startup.delete({ where: { id: req.params.id } });
  await clearStartupCache();
  await emitEvent('STARTUP_DELETED', { startupId: req.params.id, name: existing.name }, req.user.sub);
  broadcast({ channel: 'startups', action: 'deleted', startupId: req.params.id });
  res.status(204).end();
});

app.post('/task', auth(['founder', 'builder', 'admin']), async (req, res) => {
  const startup = await prisma.startup.findUnique({ where: { id: req.body.startupId } });
  if (!startup) return res.status(404).json({ error: 'STARTUP_NOT_FOUND' });
  if (!testMode && req.user.role === 'founder' && startup.founderId !== req.user.sub) return res.status(403).json({ error: 'RBAC_DENIED' });
  const task = await prisma.task.create({
    data: {
      startupId: req.body.startupId,
      title: req.body.title,
      status: req.body.status || 'TODO',
      assignedTo: req.body.assignedTo || null,
    },
    include: { assignee: true },
  });
  await emitEvent('TASK_CREATED', { taskId: task.id, startupId: startup.id, assignedTo: task.assignedTo }, req.user.sub, startup.id);
  if (task.assignedTo) await notify(task.assignedTo, 'TASK_ASSIGNED', `You were assigned: ${task.title}`, { taskId: task.id, startupId: startup.id });
  broadcast({ channel: 'tasks', action: 'created', task });
  res.status(201).json(task);
});

app.get('/task/:startupId', auth(), async (req, res) => {
  const { skip, take, page, pageSize } = pageArgs(req);
  const startup = await prisma.startup.findUnique({ where: { id: req.params.startupId } });
  if (!startup) return res.status(404).json({ error: 'STARTUP_NOT_FOUND' });
  if (!testMode && req.user.role === 'founder' && startup.founderId !== req.user.sub) return res.status(403).json({ error: 'RBAC_DENIED' });
  const where = { startupId: req.params.startupId };
  const [items, total] = await Promise.all([
    prisma.task.findMany({ where, skip, take, include: { assignee: true }, orderBy: { updatedAt: 'desc' } }),
    prisma.task.count({ where }),
  ]);
  res.json({ items, page, pageSize, total });
});

app.get('/builder/tasks', auth(['builder']), async (req, res) => {
  const { skip, take, page, pageSize } = pageArgs(req);
  const where = testMode ? {} : { assignedTo: req.user.sub };
  const [items, total] = await Promise.all([
    prisma.task.findMany({ where, skip, take, include: { startup: true }, orderBy: { updatedAt: 'desc' } }),
    prisma.task.count({ where }),
  ]);
  res.json({ items, page, pageSize, total });
});

app.put('/task/:id', auth(['founder', 'builder', 'admin']), async (req, res) => {
  const existing = await prisma.task.findUnique({ where: { id: req.params.id }, include: { startup: true } });
  if (!existing) return res.status(404).json({ error: 'TASK_NOT_FOUND' });
  const isFounderOwner = req.user.role === 'founder' && existing.startup.founderId === req.user.sub;
  const isAssignedBuilder = req.user.role === 'builder' && existing.assignedTo === req.user.sub;
  if (!testMode && !isFounderOwner && !isAssignedBuilder && req.user.role !== 'admin') return res.status(403).json({ error: 'RBAC_DENIED' });
  const task = await prisma.task.update({
    where: { id: req.params.id },
    data: {
      title: req.body.title,
      status: req.body.status,
      assignedTo: req.body.assignedTo === undefined ? undefined : req.body.assignedTo || null,
      evidenceUrl: req.body.evidenceUrl,
    },
    include: { assignee: true, startup: true },
  });
  await emitEvent('TASK_UPDATED', { taskId: task.id, patch: req.body }, req.user.sub, task.startupId);
  if (req.body.assignedTo && req.body.assignedTo !== existing.assignedTo) {
    await notify(req.body.assignedTo, 'TASK_ASSIGNED', `You were assigned: ${task.title}`, { taskId: task.id, startupId: task.startupId });
  }
  broadcast({ channel: 'tasks', action: 'updated', task });
  res.json(task);
});

app.delete('/task/:id', auth(['founder', 'admin']), async (req, res) => {
  const existing = await prisma.task.findUnique({ where: { id: req.params.id }, include: { startup: true } });
  if (!existing) return res.status(404).json({ error: 'TASK_NOT_FOUND' });
  if (!testMode && req.user.role === 'founder' && existing.startup.founderId !== req.user.sub) return res.status(403).json({ error: 'RBAC_DENIED' });
  await prisma.task.delete({ where: { id: req.params.id } });
  await emitEvent('TASK_DELETED', { taskId: req.params.id }, req.user.sub, existing.startupId);
  broadcast({ channel: 'tasks', action: 'deleted', taskId: req.params.id, startupId: existing.startupId });
  res.status(204).end();
});

app.post('/task/:id/evidence', auth(['founder', 'builder', 'admin']), upload.single('file'), async (req, res) => {
  const existing = await prisma.task.findUnique({ where: { id: req.params.id }, include: { startup: true } });
  if (!existing) return res.status(404).json({ error: 'TASK_NOT_FOUND' });
  const isFounderOwner = req.user.role === 'founder' && existing.startup.founderId === req.user.sub;
  const isAssignedBuilder = req.user.role === 'builder' && existing.assignedTo === req.user.sub;
  if (!testMode && !isFounderOwner && !isAssignedBuilder && req.user.role !== 'admin') return res.status(403).json({ error: 'RBAC_DENIED' });
  if (!req.file) return res.status(400).json({ error: 'FILE_REQUIRED' });
  const evidenceUrl = `/uploads/${req.file.filename}`;
  const task = await prisma.task.update({ where: { id: req.params.id }, data: { evidenceUrl }, include: { assignee: true } });
  await emitEvent('TASK_EVIDENCE_UPLOADED', { taskId: task.id, evidenceUrl }, req.user.sub, task.startupId);
  broadcast({ channel: 'tasks', action: 'evidence_uploaded', task });
  res.json(task);
});

app.post('/invest', auth(['investor', 'admin']), async (req, res) => {
  const { startupId, amount } = req.body;
  const startup = await prisma.startup.findUnique({ where: { id: startupId } });
  if (!startup) return res.status(404).json({ error: 'STARTUP_NOT_FOUND' });
  const investment = await prisma.investment.create({ data: { investorId: req.user.sub, startupId, amount: Number(amount) }, include: { startup: true, investor: true } });
  await emitEvent('INVESTMENT_CREATED', { investmentId: investment.id, startupId, amount: investment.amount }, req.user.sub, startupId);
  await notify(startup.founderId, 'INVESTMENT_CREATED', `New investment intent: ${investment.amount}`, { investmentId: investment.id, startupId });
  broadcast({ channel: 'investments', action: 'created', investment });
  res.status(201).json(investment);
});

app.get('/portfolio/:investorId', auth(['investor', 'admin']), async (req, res) => {
  if (!testMode && req.user.role === 'investor' && req.user.sub !== req.params.investorId) return res.status(403).json({ error: 'RBAC_DENIED' });
  const { skip, take, page, pageSize } = pageArgs(req);
  const where = { investorId: req.params.investorId };
  const [items, total] = await Promise.all([
    prisma.investment.findMany({ where, skip, take, include: { startup: true }, orderBy: { createdAt: 'desc' } }),
    prisma.investment.count({ where }),
  ]);
  res.json({ items, page, pageSize, total });
});

app.get('/events', auth(['founder', 'investor', 'builder', 'admin']), async (req, res) => {
  const { skip, take, page, pageSize } = pageArgs(req);
  const [items, total] = await Promise.all([
    prisma.eventLog.findMany({ skip, take, orderBy: { timestamp: 'desc' }, include: { actor: true, startup: true } }),
    prisma.eventLog.count(),
  ]);
  res.json({ items, page, pageSize, total });
});

app.get('/builder-profile', auth(['builder', 'founder', 'admin']), async (req, res) => {
  const { skip, take, page, pageSize } = pageArgs(req);
  const where = !testMode && req.user.role === 'builder' ? { userId: req.user.sub } : {};
  const [items, total] = await Promise.all([
    prisma.builderProfile.findMany({ where, skip, take, include: { user: true }, orderBy: { updatedAt: 'desc' } }),
    prisma.builderProfile.count({ where }),
  ]);
  res.json({ items, page, pageSize, total });
});

app.put('/builder-profile/me', auth(['builder']), async (req, res) => {
  const skills = Array.isArray(req.body.skills)
    ? req.body.skills
    : String(req.body.skills || '').split(',').map((item) => item.trim()).filter(Boolean);
  const profile = await prisma.builderProfile.upsert({
    where: { userId: req.user.sub },
    update: { skills, rating: Number(req.body.rating || 0) },
    create: { userId: req.user.sub, skills, rating: Number(req.body.rating || 0) },
    include: { user: true },
  });
  await emitEvent('BUILDER_PROFILE_UPDATED', { userId: req.user.sub, skills }, req.user.sub);
  broadcast({ channel: 'builders', action: 'updated', profile });
  res.json(profile);
});

app.get('/notifications', auth(), async (req, res) => {
  const { skip, take, page, pageSize } = pageArgs(req);
  const where = { userId: req.user.sub };
  const [items, total] = await Promise.all([
    prisma.notification.findMany({ where, skip, take, orderBy: { createdAt: 'desc' } }),
    prisma.notification.count({ where }),
  ]);
  res.json({ items, page, pageSize, total });
});

wss.on('connection', (socket) => {
  socket.send(JSON.stringify({ channel: 'system', message: 'Connected to AlgoForce AI realtime gateway' }));
});

server.listen(port, async () => {
  await prisma.$connect();
  console.log(`AlgoForce AI backend running on http://localhost:${port}`);
});
