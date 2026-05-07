# AlgoForce AI

**Build. Govern. Scale.**

AlgoForce AI is a Flutter-first Startup Execution Operating System for founders, investors, builders, and admins. The app is API-driven: startups, tasks, investments, builder profiles, notifications, uploads, and events come from the Node/PostgreSQL backend.

## Flutter App

```powershell
flutter pub get
flutter run
```

Build APK:

```powershell
flutter build apk --release
```

Release output:

- `build/app/outputs/flutter-apk/app-release.apk`

## Backend

```powershell
cd backend
docker compose up -d postgres redis
npm install
copy .env.example .env
npx prisma migrate dev
npm run dev
```

The app defaults to **Local MVP mode** for testing, so it works without Postgres, Docker, or API connectivity. To test against the backend, run Flutter with:

```powershell
flutter run --dart-define=USE_REMOTE_API=true --dart-define=API_BASE_URL=http://localhost:4000
```

The backend runs on `http://localhost:4000` and exposes WebSockets at `ws://localhost:4000/ws`.

Testing mode is open by default: the app shows one-tap Founder, Investor, Builder, and Admin entry chips, and the backend accepts unauthenticated requests using persisted testing users. Set `AUTH_REQUIRED=true` in `backend/.env` when you want strict JWT and RBAC enforcement again.

## Functional Scope

- Real JWT register/login/me with DB-stored roles and RBAC
- Startup CRUD persisted in PostgreSQL
- Task CRUD with persisted status, assignee, evidence upload, and live WebSocket sync
- Investor deal creation and portfolio reads
- Builder profile creation/update and assigned task reads
- EventLog audit trail for every write action
- Notification records plus realtime push
- Rule-based startup scoring from persisted startup, task, evidence, investment, market, and team data

## Brand

The product name is **AlgoForce AI**.
