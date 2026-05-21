# VORB — Visualized Oscillation Radio Ball

> **For humans:** A quick overview of what this thing is and where everything lives.
> **For AI / opencode:** Scroll down to the **[Agent Guide](#agent-guide)** for the full technical breakdown.

---

## ⚠️ KNOWLEDGE SOURCES — READ THIS FIRST (ALL AGENTS, HUMAN OR AI)

All important, relevant, and authoritative information about this software lives in exactly four places:

| File | What it contains |
|---|---|
| **`AGENTS.md`** (this file) | Architecture, design decisions, optimization rules, workflow procedures — the permanent knowledge base |
| **`CHANGELOG.md`** | Every change ever made, chronologically ordered, explaining **what** changed and **why** |
| **`settings/debug.log`** | Real-time runtime state — what the app is doing right now, errors, auth status (auto-generated, append-only) |
| **`how-to-run.txt`** | Setup, OBS config, building, troubleshooting — for human end-users |

### The rule

If you are an agent (human or AI) who needs to understand, modify, debug, or extend this software:
1. **Start here** (AGENTS.md) for the permanent architecture and rules.
2. **Read the top of CHANGELOG.md** for what changed recently and why.
3. **Tail debug.log** for what the app is doing right now.
4. **Point a human at how-to-run.txt** if they need setup instructions.

Nothing else is guaranteed to be authoritative. If something in a source code comment contradicts these files, these files win.

---

## For Humans

### What is this?

A translucent floating circle that sits on top of your screen and shows what song you're playing on Spotify — album art, title, artist — with a reactive circular waveform that pulses to the music. It looks like a glass orb.

It also doubles as an OBS browser source so your stream can show the exact same thing.

### What's here?

| File | What it does |
|---|---|
| `main.js` | The main brains — creates the window, system tray, handles Spotify auth, relays audio data |
| `preload.js` | Tiny bridge between the app and the web page |
| `ui/renderer.js` | **The whole overlay** — drawing the orb, the visualizer, handling audio capture, all in one file |
| `ui/index.html` | The overlay page itself |
| `ui/style.css` | How the orb looks — frosted glass, shadows, layout |
| `ui/settings.html` | The settings panel (colors, display toggles, audio source, Spotify credentials, etc.) |
| `ui/splash.html` | Startup splash screen |
| `core/spotify.js` | Talks to Spotify's API — auth, polling for current track |
| `core/settings.js` | Reads/writes config.json |
| `core/logger.js` | Writes debug.log |
| `core/voicemeeter.js` | Checks if VoiceMeeter is installed |
| `server/ui-server.js` | Local web server for OBS (port 3001) |

### How to run

```bash
npm install            # first time
npm start              # launch the desktop app
npm run build          # package into an installer (.exe)
npm run obs            # OBS-only server (no desktop window)
```

### The vibe

- **Vanilla everything** — no React, no build tools, no TypeScript. Just plain HTML + CSS + JS on the frontend, Node.js on the backend, and Electron to glue it together.
- **One file rules them all** — all the visualizer / UI logic lives in `ui/renderer.js`. Don't split it up.
- **Same code works in OBS** — the OBS browser source loads the exact same `index.html` and `renderer.js`. An `isElectron` flag switches between direct Web Audio capture (desktop) and SSE/HTTP polling (OBS).
- **Invisible until music plays** — the orb starts hidden and fades in only when Spotify confirms playback. Fades out after a configurable delay when music pauses.
- **Draggable window** — click and drag anywhere on the orb to reposition it. Clicks pass through when the orb is hidden.
- **Auto-updates via GitHub Releases** — every build published to GitHub triggers automatic updates for all users. No manual download needed.
- **Credentials are user-provided** — Spotify Client ID and Client Secret are entered by the user in Settings. No hardcoded credentials exist in the codebase. All credentials stay client-side and are never transmitted except directly to Spotify's API.

### The visualizer (how it works)

Audio comes in from VoiceMeeter (or any mic/loopback) → Web Audio API AnalyserNode splits it into 128 frequency bins → each bin gets smoothed with fast-attack/slow-decay → the smoothed values drive the height of 128 points around a circle → canvas draws a smooth wavy ring using `Path2D` and quadratic curves.

Kicks (bass hits) get special treatment — the app tracks a rolling baseline of low-end energy and boosts the visualizer when a kick is detected, giving it that pumping club feel.

### Versioning

- **Major** (2.0.0 → 3.0.0): complete rewrites, architecture changes
- **Minor** (3.0.0 → 3.1.0): big features, significant refactors
- **Patch** (3.0.0 → 3.0.1): bug fixes, small additions, performance tweaks

### Recent Changes (v3.5.1)

- **Audio Debug window**: Real-time kick/bass detection debugger with sliders, live readouts, PASS/FAIL badges, save/reset with confirm modal. Auto-preview on slider change. Tray menu entry (Developer Mode required).
- **Visualizer Fill toggle**: New "Visualizer Fill" setting in Appearance. Off by default; fills area inside viz ring when on.
- **Poll watchdog**: Auto-recovery from 12+ consecutive Spotify API failures. Token refresh → force re-auth. No more silent death loops.
- **Marquee text scroll**: Title/artist/album auto-scroll when too long, with pause at each end. Speed scales with text length.
- **Title glow softened**: 8 shadow layers (4px→100px) for natural light-source look instead of boxy edges.
- **Progress fade follows rainbow**: Progress bar fade gradient now matches accent hue in all rainbow modes.
- **`getFillCache()` fixed**: Was producing faint black (`rgba(0.03)`) instead of proper white tint. Now uses regex.
- **Tint auto-disables when glass off**: Prevents dark overlay when glass effect is disabled.
- **Version badge dynamic**: Settings header reads `package.json` at runtime — no more hardcoded version strings.
- **Black visualizer background fixed**: Broken fill color + tinted overlay when glass off. Both resolved.

### Recent Changes (v3.5.0)

- **Full code optimization pass**: Hot path compression across all files — kick/bass detection fine-tuned, per-frame allocations eliminated, DXGI suppression deduplicated
- **Kick detection tightened**: Flux 0.02→0.025, energy 0.08→0.10, baseline 1.1→1.15x — fewer false triggers on vocals/mids
- **Bass detection tightened**: Threshold 0.12→0.14 — reduces glow on non-bass content
- **processAudio() optimized**: Unrolled sub-bass/bass loops, replaced reduce() with manual loop, cached getSmoothFactor()
- **drawVisualizer() optimized**: Cached getVizProfile(), cached fill colors, combined bass shake random(), removed debug indicators
- **File size reduction**: logger.js 42→5 lines, voicemeeter.js 15→2 lines, style.css 302→38 lines, splash.html 178→48 lines

### Recent Changes (v3.4.15)

- **Installer defaults to Program Files**: `C:\Program Files\Spotify VORB` with admin privileges, user settings auto-route to `%APPDATA%`
- **Installer Welcome credits**: "Created by Sossi" now visible on Welcome screen footer
- **Uninstaller no secondary popup**: `/SILENT` flag suppresses built-in Windows confirmation, custom UI handles confirmation only
- **Uninstaller runtime error fixed**: Uses separate `TForm` for confirmation instead of uninitialized `UninstallProgressForm`
- **Install path memory cleared**: `UsePreviousAppDir=no` forces default path on every install
- **Inno Setup 6 compatibility**: Removed unsupported `Transparent`, `Smooth`, `FileNameLabel` references from uninstaller
- **Duplicate code removed**: Redundant `usDone` block in uninstaller eliminated

### When you make changes

**Every time** you modify code, you MUST do all four:

1. **Determine the change type** — is it a full revamp (major), a big feature (minor), or a bug fix / small addition (patch)?
2. **Bump the version & insert changelog entry**:
   ```
   npm run new-version patch "Fix spike sticking in visualizer"
   ```
   This bumps `package.json` and inserts a blank template at the top of `CHANGELOG.md`.
3. **Fill in CHANGELOG.md** — replace the placeholder dashes under each heading with real prose. Keep it human-friendly: explain *what* changed and *why*, not just what files were touched.
4. **Rebuild and publish** — run `npm run build:publish` to build and push to GitHub Releases. This triggers auto-updates for all users.

> **⚠️ ORDER MATTERS:** Always fill in the changelog BEFORE running `npm run build`. The build reads the version from `package.json` and creates `latest.yml` for auto-updates. If you build before filling in the changelog, users won't know what changed. The correct order is: **code changes → bump version → fill changelog → build → publish**.

> **⚠️ MANDATORY — NO EXCEPTIONS:** Every single change, no matter how small, requires a changelog entry. This is not optional. Skipping it breaks the auto-update pipeline and leaves users in the dark. If you are an AI agent, this is part of your task completion criteria — do not declare a task done without updating the changelog.

> **⚠️ CHANGELOG PRESERVATION — NEVER DELETE HISTORY:** The changelog is an append-only historical record. When adding new entries, **always insert at the top** and **never delete, overwrite, or truncate** existing entries. The `npm run new-version` script handles this correctly by inserting a template at the top. If you ever need to edit CHANGELOG.md manually, only ever add new content — never remove old versions. The entire version history from v1.0.0 onward must be preserved indefinitely. If you accidentally lose history, you MUST restore it from backups, git history, or GitHub Releases before proceeding.

> **⚠️ AUTO-UPDATES ARE LIVE:** Every `npm run build:publish` pushes a new release to GitHub. All users with the app installed will receive the update automatically on next launch. **Never publish untested or broken builds.** Test locally first (`npm start`), then build (`npm run build`), test the installer, then publish (`npm run build:publish`).

> **For AI agents:** When you're done with changes and before declaring the task complete, bump the version, fill in the changelog, and rebuild. Do not skip it — it's part of the task, not an afterthought.

### Version Must Be Updated Everywhere

The canonical version lives in `package.json` → `version`. All other version references are **dynamic** and read from it at runtime:

| File | How version is set |
|---|---|
| `main.js` | `createSplash()` injects `pkg.version` into `ui/splash.html` via `executeJavaScript` — dynamic, no manual update needed |
| `ui/splash.html` | `<span id="versionLabel">` — content set by `main.js`, leave the placeholder as-is |
| `ui/settings.html` | `<span id="versionBadge">` — set dynamically or statically, matches package.json |
| `package.json` | `description` field — keep it clean, no hardcoded version |
| `CHANGELOG.md` | `npm run new-version` inserts a template at the top automatically |

**Never hardcode a version number anywhere.** If you need to display the version in a new place, read `package.json` and inject it dynamically.

---

## Agent Guide

### Premise
VORB is a frameless, always-on-top Electron desktop overlay that shows the currently playing Spotify track (title, artist, album art) inside a circular glass orb with a real-time circular audio waveform visualizer around it. It runs in the system tray, captures audio via Web Audio API (VoiceMeeter, desktop loopback, or any input device), and doubles as an OBS Browser Source via a local HTTP/SSE server.

### Goal
Make the desktop overlay and the OBS browser source show **identical visuals** with **zero perceptible lag**, render the visualizer at **solid 60fps** with professional kick-reactive smooth curves, and never capture mouse clicks or block interaction with windows behind it.

**Every line of code must be as OPTIMIZED, LIGHTWEIGHT, and COMPRESSED as possible while holding ALL functionality and features.** There is no acceptable trade-off between brevity and capability — the code should do everything it needs to do in the fewest, fastest bytes possible. If you can make it smaller and faster without removing a feature, do it.

### Optimization Principle
Every change must keep the app lean. That means: no unnecessary allocations in hot paths (the `processAudio()` loop runs every 16ms, the visualizer every frame), no new dependencies unless they replace something heavier, no redundant canvas draws, no extra IPC calls. If a feature adds overhead, offset it somewhere else. The bar is solid 60fps on modest hardware — don't lower it.

> ⚠️ **This is non-negotiable.** Compact, performant code is a feature, not a nice-to-have. Bloated, slow code will be rejected.

## Architecture

```
main.js                 — Electron main process
  ├── Tray + menu (show/hide, settings, reload auth, disconnect, updates, quit)
  ├── IPC handlers (settings, audio-data, auth, disconnect, sources)
  ├── Creates BrowserWindow (frameless, transparent, alwaysOnTop, draggable)
  ├── Single instance lock (prevents port conflicts)
  ├── Spotify polling (core/spotify.js) → sends updates to renderer + UIServer
  ├── Audio data relay: renderer IPC → main → UIServer.setAudioData()
  └── Auto-updater (electron-updater, GitHub Releases provider)

preload.js              — contextBridge (spotify.*, electronAPI.*)
                          + DXGI error console filtering

ui/
  index.html            — Single-page overlay (orb, canvas, meta elements)
  renderer.js           — ALL overlay logic in one file:
                           • Audio capture via getUserMedia → AnalyserNode
                           • EMA smoothing + noise gate
                           • Circular bar visualizer (6 styles, Path2D)
                           • Spotify data update handler
                           • OBS mode (SSE + HTTP polling + fallback msg)
                           • Theme/rainbow application
  style.css             — Glassmorphic orb styling (CSS custom properties)
  settings.html         — Settings window (Spotify API credentials, colors,
                           display, audio, viz, behavior, updates)
  splash.html           — Startup splash with animated rings

core/
  settings.js           — Deep-merge defaults + config.json persistence
  spotify.js            — OAuth2 Authorization Code flow, token refresh,
                           player polling (1.5-3s), manual disconnect support
  voicemeeter.js        — PowerShell CIM check for VoiceMeeter presence
  logger.js             — Appends to %APPDATA%/Spotify VORB/debug.log

server/
  ui-server.js          — Express on port 3001 (bound to 127.0.0.1 only):
                           • /current — Spotify track data JSON
                           • /audio — Latest 128 smoothed bar bytes
                           • /audio-stream — SSE at 60fps
                           • /spotify-stream — SSE for track changes
                           • /settings — Config.json (credentials STRIPPED)
                           • Static files (ui/*.html, *.js, *.css)

%APPDATA%/Spotify VORB/
  config.json           — Persistent settings (auto-generated)
  debug.log             — Debug log (auto-generated, cleared on startup)
```

## Audio Relay Chain (critical path)

```
VoiceMeeter/device → getUserMedia → AnalyserNode (fftSize=256)
  → processAudio() via setInterval(16ms)  ← independent of rAF!
    → EMA smoothing + noise gate + gain
    → ipcRenderer.send("audio-data", Uint8Array(128))
      → main.js ipcMain.on → UIServer.setAudioData()
        → SSE push to OBS clients + HTTP /audio response

drawVisualizer() via requestAnimationFrame
  → reads barSmoothing[] (written by processAudio)
  → pure canvas draw (no analyser read, no IPC send)
```

Key: Audio processing runs on `setInterval(16)` so it keeps sending data to OBS at 60fps even when the Electron window is minimized (where rAF throttles to ~1fps). **However**, Chromium throttles `setInterval` too when the window is *hidden*. This is prevented by `backgroundThrottling: false` in `main.js` → `webPreferences` — without it the OBS feed freezes when the overlay tray-hides.

## Smoothing System

```
getSmoothFactor(i, rising) — per-bin attack/release (reactivity hierarchy):
  Sub-bass (0):     attack 0.95, release 0.08  ← Kicks: MOST bounce, sudden/hard reactivity
  Bass (1-2):       attack 0.90, release 0.10  ← Bass/808: strong rumble, glow trigger
  Low-mid (3-5):    attack 0.82, release 0.14  ← Upper bass: medium reactivity
  Low-mid (6-13):   attack 0.60, release 0.20  ← Melody/Soft Vocals: LEAST bounce, smooth
  Mid (14-29):      attack 0.72, release 0.15  ← Loud Vocals: medium-low reactivity
  High-mid (30-59): attack 0.85, release 0.10  ← Snares/Mids: MEDIUM bounce, reactive
  High (60+):       attack 0.78, release 0.12  ← High Hats: subtle, crisp

getBinGain(i) — frequency gain compensation (bounce hierarchy):
  0:     3.5    ← Kicks: MOST bounce (punchy, dominant)
  1-2:   2.8/2.0 ← Bass/808: strong rumble (glow trigger)
  3-5:   2.0→1.2 ← Upper bass transition
  6-13:  1.2    ← Melody/Soft Vocals: LEAST bounce (smooth, subtle)
  14-29: 1.5    ← Loud Vocals: medium-low presence
  30-59: 1.8    ← Snares/Mids: MEDIUM bounce (bright, reactive)
  60+:   1.3    ← High Hats: subtle, crisp

Noise gate: raw < 0.02 → barSmoothing *= 0.82 (immediate decay)

Kick detection (onset detection on raw FFT, bins 0-1 = 0-344Hz):
  kickEnergy = mean(raw[0..1])
  kickFlux = kickEnergy - prevKickEnergy
  if kickFlux > 0.025 && kickEnergy > 0.10 && kickEnergy > kickAvg*1.15 → kickPulse = 1.0
  kickPulse *= 0.88 each frame
  kickScale = 1 + kickPulse * 0.025  ← quick outward "kick"

Bass detection (running average on raw FFT, bins 0-2 = 0-516Hz):
  bassAvg = mean(raw[0..2])
  if bassAvg > 0.14 → bassExcess tracks upward with 0.2 smoothing
  bassExcess *= 0.92 each frame (slow decay for sustained 808)
  bassScale = 1 + (bassExcess > 0.03 ? bassExcess * 0.15 : 0)  ← sustained glow/vibration

Combined scale = kickScale * bassScale (max ~1.05, subtle)

Style-specific responses:
  Spiky/Wavy: glow alpha +0.10/+0.08 on kick/bass, lineWidth +6/+5 on kick/bass
  Rounded: glow radius +10/+12, alpha +0.15/+0.12, lineWidth +10/+12
  Bars/Dots/Lines: radius offset +6/+7, alpha +0.15 on kick/bass
```

## Canvas Rendering

- **Non-rainbow path** (default): `Path2D` with 128 control points, `quadraticCurveTo` for smooth curves. One wide low-opacity glow stroke, one thin main stroke, one subtle fill.
- **Rainbow path** (bars/dots/lines): Individual `beginPath`/`moveTo`/`lineTo`/`stroke` per bar (128 separate paths) with position-based hue mapping.
- Both paths: `shadowBlur` is 0 — glow is achieved via layered `globalAlpha` strokes, 5-10x faster than shadow blur.
- **Peak handling** (spiky): Bars with v > 0.6 use `lineTo` for sharp spikes instead of `quadraticCurveTo`, preventing rounding during high energy.

## OBS Browser Source

- URL: `http://127.0.0.1:3001`
- The browser source runs the same `index.html` + `renderer.js` in "OBS mode" (no `electronAPI`)
- SSE (`/audio-stream`) pushes 128 smoothed byte values at ~60fps
- HTTP polling (`/audio`) every 200ms as silent fallback
- `/current` polled every 500ms for track data
- `/settings` polled every 2000ms for theme/display changes
- Bar smoothing happens ONLY on the Electron side: `barSmoothing.map(v => Math.round(v*255))` is sent, OBS does `barSmoothing[i] = dataArray[i] / 255` (direct assignment, no re-smoothing)
- **Fallback message**: If VORB desktop app isn't running, OBS shows "VORB desktop app is not running" for 3 seconds, then fades out. Only shown once per tab load (sessionStorage).

## Versioning Scheme

- **Major** (1→2→3): Huge revamps, architecture rewrites
- **Minor** (3.0→3.1→3.2): Big updates, new features, significant refactors
- **Patch** (3.0.0→3.0.1): Small additions, bug fixes, performance tweaks

## Updating Version & Changelog ⚠️ MANDATORY

Hey, seriously — every time you change anything in here, bump the version and update the changelog. Doesn't matter if it's one line or a hundred. Skip it and auto-updates break (wrong `latest.yml`) and nobody knows what happened. Not great.

Here's the drill:

1. **Determine the change type**:
   - A few lines in one file → `patch` (bug fix, small addition, perf tweak)
   - A new feature across multiple files → `minor` (big update, new capability)
   - Architecture rewrite, breaking changes → `major` (huge revamp)

2. **Bump the version**:
   ```
   npm run new-version patch "Brief description of what changed"
   ```
   This updates `package.json` and inserts a blank entry at the top of `CHANGELOG.md`.

3. **Fill in CHANGELOG.md** — replace the placeholder dashes under each heading with real prose. Follow the existing style: concise, user-friendly prose explaining *what* changed and *why*, not just what files were touched.

4. **Rebuild and publish** — run `npm run build:publish` so `dist/latest.yml` matches the new version AND the release is pushed to GitHub for auto-updates.

> **⚠️ ORDER MATTERS:** Always fill in the changelog BEFORE running `npm run build`. The build reads the version from `package.json` and creates `latest.yml` for auto-updates. If you build before filling in the changelog, users won't know what changed. The correct order is: **code changes → bump version → fill changelog → build → publish**.

> **⚠️ AUTO-UPDATES ARE LIVE:** Every `npm run build:publish` pushes a new release to GitHub. All users with the app installed will receive the update automatically on next launch. **Never publish untested or broken builds.** Test locally first (`npm start`), then build (`npm run build`), test the installer, then publish (`npm run build:publish`).

> **For AI agents:** When you're done with changes and before declaring the task complete, bump the version, fill in the changelog, and rebuild. Do not skip it — it's part of the task, not an afterthought.

## Build Output

```
dist/
  Spotify VORB Setup X.X.X.exe    — Inno Setup installer (custom branded)
  win-unpacked/                    — portable unpacked build (intermediate)
  builder-debug.yml                — electron-builder debug info
```

### Dist Retention Policy

`npm run build` automatically runs `scripts/clean-dist.js` after the build finishes. It keeps only the **latest 3 unique versions** (.exe files). Older builds are deleted. This prevents `dist/` from accumulating every build ever made.

**Same-version overwrite:** Building the same version multiple times overwrites the existing `.exe` directly. The clean-dist script counts unique versions, not total files.

If you need to keep a specific build archive, copy it elsewhere before running build.

### Installer Safety

The Inno Setup installer installs to `%LOCALAPPDATA%\Spotify VORB\` (no admin required) but **never touches** `%APPDATA%\Spotify VORB\` (config.json, debug.log, auth tokens). Running an installer over an existing install is safe — settings survive.

The installer automatically kills any running VORB processes before installing to prevent file-in-use errors.

The uninstaller (accessible via Add/Remove Programs or tray menu) features a custom dark-themed UI matching the installer:
1. **Confirm screen** — "Are you sure you want to uninstall Spotify VORB?" with a "Keep my settings and preferences" checkbox (checked by default)
2. **Complete screen** — "Spotify VORB has been uninstalled successfully" with "Thank you for using VORB!"

A custom Inno Setup script (`scripts/installer.iss`) handles installation, shortcuts, registry entries, and the custom uninstaller UI.

### Build Requirements

- **Inno Setup 6** — required for building installers. Install via `winget install JRSoftware.InnoSetup` or download from https://jrsoftware.org/isdl.php
- The build script (`scripts/build-inno.js`) automatically detects Inno Setup in common locations
- NSIS script (`scripts/installer.nsh`) is kept as backup; use `npm run build:nsis` to build with NSIS instead

## Auto-Updates

Configured via `electron-updater` with a `generic` provider pointing to GitHub Releases (`https://github.com/TopiACutie/spotify-vorb/releases/latest/download/`). On startup, the app fetches `latest.yml` from the latest release, compares versions, and downloads the new installer automatically. Installs on next quit.

**How it works:**
1. App fetches `latest.yml` from GitHub Releases
2. Parses version, SHA512 hash, and file size
3. If version > current, downloads the `.exe` from the same release
4. Verifies SHA512 hash matches
5. Runs the installer silently on quit

This works with **any installer type** (Inno Setup, NSIS, etc.) — the updater only cares about the `latest.yml` metadata.

**Publishing a new release:**
```bash
npm run build:publish
```
This builds the installer, generates `latest.yml`, creates/updates the GitHub Release, and uploads both files. All users receive the update automatically.

> **⚠️ Requires GitHub CLI (`gh`):** Install from https://cli.github.com/ or run `winget install GitHub.cli`. Alternatively, set `GH_TOKEN` env var, or upload files manually via the GitHub web UI.

> **Manual upload:** Go to https://github.com/TopiACutie/spotify-vorb/releases/new → create tag `vX.X.X` → upload `Spotify VORB Setup X.X.X.exe` + `latest.yml`.

**⚠️ CRITICAL:** Never run `build:publish` without testing first. Auto-updates are irreversible for end users.

## What to Focus On (if continuing)

1. **Performance**: The inner loop (pts array + cos/sin per bar) is the hottest path. Pre-computing trig tables or switching to WebGL via a simple vertex shader would be the next leap.
2. **Rainbow path**: The per-bar `beginPath/stroke` could be batched into a single path for the rainbow mode too.
3. **Log rotation**: `logger.js` appends forever to `debug.log` — add size-based rotation if it becomes an issue.
4. **Audio device switching**: The `processAudio()` interval keeps running across device switches because it references module-level `analyser`/`dataArray` which get reassigned. This works but is implicit — a reset/restart mechanism would be cleaner.
