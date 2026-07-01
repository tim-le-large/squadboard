# SquadBoard

Team workspace with **Kanban tickets**, **real-time chat**, and **FCM push notifications** — Flutter + Firebase.

| | |
|---|---|
| **Live demo** | [squadboard.lelarge.dev](https://squadboard.lelarge.dev) |
| **Portfolio** | [lelarge.dev](https://lelarge.dev) |
| **Author** | [Tim Le Large](https://github.com/tim-le-large) |

Click **Try live demo** on the login screen — shared workspace, no sign-up required.

---

## What this demo shows

- **Realtime collaboration:** Firestore snapshots for Kanban board and team chat
- **Multi-user UX:** Demo workspace with synthetic teammates (assignees, chat authors, comments)
- **Push notifications:** FCM tokens + Cloud Functions for chat messages and ticket assignments
- **Production patterns:** Security rules, composite indexes, invite codes, GitHub Pages deploy

Good reference for **startup-style team apps** — the kind of product clients often ask for.

---

## Features

| Area | Details |
|------|---------|
| **Auth** | Email sign-up / sign-in (Firebase Auth) |
| **Workspaces** | Create or join via 6-character invite code |
| **Board** | Kanban (To Do → In Progress → Done), drag & drop (mouse on web, long-press on mobile) |
| **Tickets** | Title, description, priority, assignee, status |
| **Comments** | Thread per ticket |
| **Chat** | Real-time team chat with multi-user demo conversation |
| **Push** | FCM for new messages + ticket assignments (Cloud Functions) |
| **Demo** | Shared account seeds 14 tickets, 18 chat messages, 4 synthetic teammates |
| **Security** | Firestore rules — workspace members only |

---

## Architecture

```
lib/
  config/           # Firebase + demo credentials (dart-define)
  data/             # Demo tickets, chat, team personas
  models/           # Ticket, Workspace, ChatMessage, …
  providers/        # Riverpod (auth, tickets, workspace)
  repositories/     # Firestore CRUD, demo seeding
  services/         # FCM push token sync
  screens/          # Board, chat, ticket detail, workspace setup
  widgets/          # Kanban column, draggable tickets, cards
firebase/
  firestore.rules   # Member-only access
  firestore.indexes.json
  functions/        # Push triggers (chat + assignment)
```

**Data flow:** UI → Riverpod → repositories → Firestore. Demo login runs `DemoSeedRepository.ensureDemoReady()` — reseeds when `demoSeedVersion < 2` or ticket count is low.

---

## Quick start

### 1. Firebase

1. Create a project at [console.firebase.google.com](https://console.firebase.google.com)
2. Enable **Authentication** → Email/Password
3. Create **Firestore** (production mode)
4. Deploy rules & indexes:
   ```bash
   firebase deploy --only firestore:rules,firestore:indexes
   ```
5. Register a **Web app** and copy config values

### 2. Credentials

```bash
cp dart_defines.example.json dart_defines.json
# fill in FIREBASE_* and DEMO_EMAIL / DEMO_PASSWORD
```

### 3. Run

```bash
flutter pub get
flutter run -d chrome --dart-define-from-file=dart_defines.json
```

Or use the **SquadBoard (Chrome)** launch config in `.vscode/launch.json`.

### Demo account

Create once in **Firebase Auth**:

- Email: `demo@squadboard.lelarge.dev`
- Password: `SquadBoardDemo2026!`

### Push notifications (FCM)

1. Firebase Console → **Cloud Messaging** → **Web Push certificates** → generate key pair
2. Add `FIREBASE_VAPID_KEY` to `dart_defines.json` and GitHub Actions secrets
3. Deploy Cloud Functions (requires Blaze plan):
   ```bash
   cd firebase/functions && npm install && cd ../..
   firebase deploy --only functions
   ```
4. In the app, tap the **bell icon** to enable notifications

Triggers: new chat message → notify other members; ticket assigned → notify assignee.

### Try with a second user

1. Sign up → create workspace → copy invite code
2. Open incognito → sign up → join with code
3. Create tickets, drag between columns, chat in real time

---

## Tech stack

| Layer | Choice |
|-------|--------|
| UI | Flutter, Material 3 |
| State | Riverpod |
| Auth | Firebase Auth |
| Database | Cloud Firestore (realtime) |
| Push | FCM + Cloud Functions |
| Deploy | GitHub Pages |

---

## Deploy

See **[DEPLOY.md](DEPLOY.md)** for GitHub Actions secrets and custom domain setup.

Required secrets: `FIREBASE_*`, `FIREBASE_VAPID_KEY`, `DEMO_EMAIL`, `DEMO_PASSWORD`

---

## Roadmap

- @mentions in chat
- Activity feed
- Reorder tickets within a column

---

## Disclaimer

Portfolio demo — not intended for production team use without hardening.
