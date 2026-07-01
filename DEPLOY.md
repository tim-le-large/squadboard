# Deploy SquadBoard to GitHub Pages

## Prerequisites

- GitHub repo `tim-le-large/squadboard` (or your fork)
- Firebase web app configured (see README)
- Domain `squad.lelarge.dev` (optional)

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

## 2. Enable GitHub Pages

Settings → Pages → Source: **GitHub Actions**

Optional custom domain: `squad.lelarge.dev` (CNAME file is in `web/CNAME`)

## 3. Firebase Auth authorized domains

Firebase Console → Authentication → Settings → Authorized domains:

- `localhost`
- `squad.lelarge.dev`
- `tim-le-large.github.io` (if using default Pages URL)

## 4. DNS (Cloudflare)

| Type | Name | Target |
|------|------|--------|
| CNAME | squad | `tim-le-large.github.io` |

## 5. Deploy

Push to `main` or run the workflow manually.

```bash
git push origin main
```

## Firestore indexes

If tickets query fails, deploy indexes from `firebase/firestore.indexes.json` or follow the link in the Firebase console error.
