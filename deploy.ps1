# Swara Pilot: push to GitHub and deploy to Firebase Hosting.
# Run from this folder:  powershell -ExecutionPolicy Bypass -File .\deploy.ps1
# Safe to run again later: it reuses the existing GitHub repo and Firebase project.
$ErrorActionPreference = "Stop"
Set-Location -Path $PSScriptRoot
$Repo = "swara-pilot"

function Need($cmd, $hint) {
  if (-not (Get-Command $cmd -ErrorAction SilentlyContinue)) {
    Write-Host "`n'$cmd' is not installed. $hint" -ForegroundColor Yellow; exit 1
  }
}
Need git      "Install it from https://git-scm.com/download/win, then run this script again."
Need gh       "Install it with:  winget install --id GitHub.cli   then open a new PowerShell window and run this script again."
Need firebase "Install it with:  npm install -g firebase-tools   (needs Node.js from https://nodejs.org), then run this script again."

# This folder was created from another environment; let Windows git trust it.
git config --global --add safe.directory ($PWD.Path -replace '\\','/') 2>$null

# ---------- GitHub ----------
Write-Host "`n== GitHub ==" -ForegroundColor Cyan
gh auth status 2>$null | Out-Null
if ($LASTEXITCODE -ne 0) { Write-Host "Sign in to GitHub in the browser window that opens..."; gh auth login --web --git-protocol https }
$hasOrigin = (git remote) -contains "origin"
if (-not $hasOrigin) {
  gh repo create $Repo --public --source . --remote origin --push --description "Song Key Finder: find a song's key and train your ear"
} else {
  git push -u origin main
}
$RepoUrl = gh repo view --json url -q .url

# ---------- Firebase ----------
Write-Host "`n== Firebase ==" -ForegroundColor Cyan
firebase login   # opens the browser if you're not signed in yet
if (Test-Path .firebaserc) {
  $ProjectId = (Get-Content .firebaserc | ConvertFrom-Json).projects.default
} else {
  $ProjectId = "$Repo-" + (Get-Random -Minimum 1000 -Maximum 9999)
  Write-Host "Creating Firebase project $ProjectId ..."
  firebase projects:create $ProjectId --display-name "Swara Pilot"
  if ($LASTEXITCODE -ne 0) {
    Write-Host "Couldn't create the project. If this is your first Firebase project, open https://console.firebase.google.com once to accept the terms, then run this script again." -ForegroundColor Yellow; exit 1
  }
  "{`n  `"projects`": { `"default`": `"$ProjectId`" }`n}" | Set-Content -Encoding utf8 .firebaserc
  git add .firebaserc; git commit -m "Add Firebase project $ProjectId" | Out-Null; git push | Out-Null
}
firebase deploy --only hosting --project $ProjectId
if ($LASTEXITCODE -ne 0) {
  Write-Host "Setting up the Hosting site and retrying..."
  firebase hosting:sites:create $ProjectId --project $ProjectId
  firebase deploy --only hosting --project $ProjectId
}

Write-Host "`nDone!" -ForegroundColor Green
Write-Host "GitHub:   $RepoUrl"
Write-Host "Live app: https://$ProjectId.web.app"
