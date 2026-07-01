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
- Security rules: workspace members only

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
| Deploy | GitHub Pages |

## Deploy (GitHub Pages)

See **[DEPLOY.md](DEPLOY.md)**.

GitHub Actions secrets: `FIREBASE_API_KEY`, `FIREBASE_AUTH_DOMAIN`, `FIREBASE_PROJECT_ID`, `FIREBASE_STORAGE_BUCKET`, `FIREBASE_MESSAGING_SENDER_ID`, `FIREBASE_APP_ID`

## Roadmap

- FCM push notifications on assignment / mention
- @mentions in chat
- Activity feed
- Multiple boards per workspace

## Disclaimer

Portfolio demo — not intended for production team use without hardening.
