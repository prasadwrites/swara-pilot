# Swara Pilot

A single-page web app with two parts:

- **Key finder**: upload an MP3, M4A or AAC song and get its key (C to B, major or minor). Audio is analyzed in the browser with the Web Audio API and a chroma + Krumhansl–Kessler key profile match; nothing is uploaded.
- **Ear trainer**: a game where a random instrument plays one note and you name it. Right answers lift your parachutist, wrong ones drop you toward the sea.

Everything lives in `public/index.html` (no build step).

## Run locally

Open `public/index.html` in a browser, or run `npx serve public`.

## Deploy to Firebase Hosting

```bash
npm install -g firebase-tools
firebase login
firebase use --add            # pick your Firebase project
firebase deploy --only hosting
```

## Login and the player list

The hosted site asks everyone to sign in (Google, or email and password) and only lets in emails on your player list.

**One-time setup in the [Firebase console](https://console.firebase.google.com) (project `swara-pilot-9337`):**

1. **Build > Authentication > Get started.** Under *Sign-in method*, enable **Google** (pick a support email) and **Email/Password**.
2. **Build > Firestore Database > Create database.** Choose *production mode* and a location near you (for example `us-central1`).
3. Run `deploy.ps1`. It now also uploads `firestore.rules`, which keeps the player list private.

**Add a player:** Firestore Database > *Start collection* (first time) or open `allowedUsers` > *Add document*.
Set **Document ID** to the player's email in lowercase (for example `kid@gmail.com`), add any field (for example `name` = `Asha`), and save.
Add your own email too. **Remove a player:** delete their document.

- Email-and-password players must click the verification link Firebase emails them before they can get in.
- Google players get in as soon as their email is on the list.
- The sign-in screen only works on the Firebase site (`*.web.app`), not when opening `index.html` from your computer.
