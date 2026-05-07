# AlgoForce AI Backend

Production backend for the AlgoForce AI Startup Execution Operating System.

## Run

```powershell
docker compose up -d postgres redis
copy .env.example .env
npm install
npx prisma migrate dev
npm run dev
```

API: `http://localhost:4000`
WebSocket: `ws://localhost:4000/ws`

Testing mode is open by default. Without a bearer token, the API uses persisted testing users and allows broad access so product flows can be exercised quickly. Set `AUTH_REQUIRED=true` to re-enable strict JWT and RBAC behavior.

## Implemented Systems

- `POST /auth/register`, `POST /auth/login`, `GET /auth/me`
- `POST /startup`, `GET /startup`, `GET /startup/:id`, `PUT /startup/:id`, `DELETE /startup/:id`
- `POST /task`, `GET /task/:startupId`, `PUT /task/:id`, `DELETE /task/:id`
- `POST /task/:id/evidence` multipart upload with local file storage
- `POST /invest`, `GET /portfolio/:investorId`
- `GET /events`
- `GET /builder-profile`, `PUT /builder-profile/me`, `GET /builder/tasks`
- `GET /notifications`

Every write creates an `EventLog` record and broadcasts over WebSockets. Startup scoring is rule-based and computed from persisted startup, task, evidence, investment, market, and team data.
