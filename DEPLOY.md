# Deploy SquadBoard to GitHub Pages

## Prerequisites

- GitHub repo `tim-le-large/squadboard` (or your fork)
- Firebase web app configured (see README)
- Domain `squadboard.lelarge.dev` (optional)

## 1. GitHub Actions secrets

Repository → Settings → Secrets and variables → Actions:

| Secret | Firebase config field |
|--------|----------------------|
| `FIREBASE_API_KEY` | apiKey |
| `FIREBASE_AUTH_DOMAIN` | authDomain |
| `FIREBASE_PROJECT_ID` | projectId |
| `FIREBASE_STORAGE_BUCKET` | storageBucket |
| `FIREBASE_MESSAGING_SENDER_ID` | messagingSenderId |
| `FIREBASE_APP_ID` | appId |
| `FIREBASE_VAPID_KEY` | Web Push key pair (Cloud Messaging) |
| `DEMO_EMAIL` | *(optional)* defaults to `demo@squadboard.lelarge.dev` |
| `DEMO_PASSWORD` | *(optional)* defaults to portfolio demo password in `DemoConfig` |

## Push notifications

1. Firebase Console → Project settings → Cloud Messaging → **Web Push certificates** → Generate key pair → copy as `FIREBASE_VAPID_KEY`
2. Deploy Cloud Functions (Blaze plan required):
   ```bash
   firebase login
   cd firebase/functions && npm install && cd ../..
   firebase deploy --only functions
   ```
3. Users enable push via the **bell icon** in the app toolbar.

## 2. Enable GitHub Pages

Settings → Pages → Source: **GitHub Actions**

Optional custom domain: `squadboard.lelarge.dev` (CNAME file is in `web/CNAME`)

## 3. Firebase Auth authorized domains

Firebase Console → Authentication → Settings → Authorized domains:

- `localhost`
- `squadboard.lelarge.dev`
- `tim-le-large.github.io` (if using default Pages URL)

## 4. DNS (Cloudflare)

| Type | Name | Target |
|------|------|--------|
| CNAME | squadboard | `tim-le-large.github.io` |

## 5. Deploy

Push to `main` or run the workflow manually.

```bash
git push origin main
```

## Firestore indexes

If tickets query fails, deploy indexes from `firebase/firestore.indexes.json` or follow the link in the Firebase console error.
