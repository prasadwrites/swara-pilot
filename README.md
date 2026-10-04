# Swara Pilot · Song Key Finder

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
