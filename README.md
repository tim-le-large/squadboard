# SquadBoard

Team workspace with **Kanban tickets** and **live team chat** — built with Flutter and Firebase.

**Live:** [squadboard.lelarge.dev](https://squadboard.lelarge.dev)

## Features

- Email sign up / sign in (Firebase Auth)
- Create or join a workspace via invite code
- Kanban board (To Do → In Progress → Done) with drag & drop
- Tickets with title, description, priority, assignee
- Ticket comments (thread per ticket)
- Real-time team chat (Firestore snapshots)
- **FCM push notifications** for new chat messages and ticket assignments
- Security rules: workspace members only
- **Live demo** button (shared workspace, auto-seeded)

## Setup

### 1. Firebase project

1. Create a project at [console.firebase.google.com](https://console.firebase.google.com)
2. Enable **Authentication** → Email/Password
3. Create a **Firestore** database (production mode)
4. Deploy rules & indexes:
   ```bash
   firebase deploy --only firestore:rules,firestore:indexes
   ```
   (from `firebase/` config — or paste `firebase/firestore.rules` in the console)
5. Register a **Web app** and copy the config values

### 2. Local credentials

```bash
cp dart_defines.example.json dart_defines.json
# fill in Firebase web app credentials
```

Run:

```bash
flutter pub get
flutter run -d chrome --dart-define-from-file=dart_defines.json
```

Or use the **SquadBoard (Chrome)** launch config in VS Code/Cursor.

### Demo account (portfolio)

Create once in **Firebase Auth**:

- Email: `demo@squadboard.lelarge.dev`
- Password: `SquadBoardDemo2026!`

Add `DEMO_EMAIL` and `DEMO_PASSWORD` to `dart_defines.json`. **Try live demo** signs in and seeds tickets + chat if the workspace is empty.

### Push notifications (FCM)

1. Firebase Console → **Project settings** → **Cloud Messaging** → **Web Push certificates** → generate key pair
2. Add `FIREBASE_VAPID_KEY` to `dart_defines.json` and GitHub Actions secrets
3. Deploy Cloud Functions (requires Blaze plan):
   ```bash
   cd firebase/functions && npm install && cd ../..
   firebase deploy --only functions
   ```
4. In the app, tap the **bell icon** to enable notifications (browser permission on web)

Triggers: new team chat message → notify other members; ticket assigned → notify assignee.

### 3. Try it

1. Sign up → create a workspace → copy invite code
2. Open in another browser/incognito → sign up → join with code
3. Create tickets, drag between columns, chat in real time

## Tech

| Layer | Choice |
|-------|--------|
| UI | Flutter, Material 3 |
| State | Riverpod |
| Auth | Firebase Auth |
| Database | Cloud Firestore (realtime) |
| Push | Firebase Cloud Messaging + Cloud Functions |
| Deploy | GitHub Pages |

## Deploy (GitHub Pages)

See **[DEPLOY.md](DEPLOY.md)**.

GitHub Actions secrets: `FIREBASE_*`, `FIREBASE_VAPID_KEY`, `DEMO_EMAIL`, `DEMO_PASSWORD`

## Roadmap

- @mentions in chat
- Activity feed
- Multiple boards per workspace

## Disclaimer

Portfolio demo — not intended for production team use without hardening.
