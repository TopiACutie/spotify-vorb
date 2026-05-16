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
- **No mouse clicks get through** — the window forwards all mouse events so you can click right through it to whatever's behind.
- **Updates** — built-in auto-updater via `electron-updater`. Build → upload installer + `latest.yml` → users get it silently.
- **Credentials are user-provided** — Spotify Client ID and Client Secret are entered by the user in Settings. No hardcoded credentials exist in the codebase. All credentials stay client-side and are never transmitted except directly to Spotify's API.

### The visualizer (how it works)

Audio comes in from VoiceMeeter (or any mic/loopback) → Web Audio API AnalyserNode splits it into 128 frequency bins → each bin gets smoothed with fast-attack/slow-decay → the smoothed values drive the height of 128 points around a circle → canvas draws a smooth wavy ring using `Path2D` and quadratic curves.

Kicks (bass hits) get special treatment — the app tracks a rolling baseline of low-end energy and boosts the visualizer when a kick is detected, giving it that pumping club feel.

### Versioning

- **Major** (2.0.0 → 3.0.0): complete rewrites, architecture changes
- **Minor** (2.0.0 → 2.1.0): big features, significant refactors
- **Patch** (2.5.0 → 2.5.1): bug fixes, small additions, performance tweaks

### When you make changes

**Every time** you modify code, you MUST do all four:

1. **Determine the change type** — is it a full revamp (major), a big feature (minor), or a bug fix / small addition (patch)?
2. **Bump the version & insert changelog entry**:
   ```
   npm run new-version patch "Fix spike sticking in visualizer"
   ```
   This bumps `package.json` and inserts a blank template at the top of `CHANGELOG.md`.
3. **Fill in CHANGELOG.md** — replace the placeholder dashes under each heading with real prose. Keep it human-friendly: explain *what* changed and *why*, not just what files were touched.
4. **Rebuild** — run `npm run build` so the installer + `latest.yml` are current.

This keeps the changelog accurate and ensures auto-updates work properly.

---

## Agent Guide

### Premise
VORB is the continuation of **Media Overlay**: a frameless, always-on-top Electron desktop overlay that shows the currently playing Spotify track (title, artist, album art) inside a circular glass orb with a real-time circular audio waveform visualizer around it. It runs in the system tray, captures audio via Web Audio API (VoiceMeeter, desktop loopback, or any input device), and doubles as an OBS Browser Source via a local HTTP/SSE server.

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
  ├── Creates BrowserWindow (frameless, transparent, alwaysOnTop)
  ├── Kills existing VORB process on startup (prevents port conflicts)
  ├── Spotify polling (core/spotify.js) → sends updates to renderer + UIServer
  ├── Audio data relay: renderer IPC → main → UIServer.setAudioData()
  └── Auto-updater (electron-updater, generic provider)

preload.js              — contextBridge (spotify.*, electronAPI.*)

ui/
  index.html            — Single-page overlay (orb, canvas, meta elements)
  renderer.js           — ALL overlay logic in one file:
                           • Audio capture via getUserMedia → AnalyserNode
                           • EMA smoothing + noise gate
                           • Circular bar visualizer (Path2D, layered glow)
                           • Spotify data update handler
                           • OBS mode (SSE + HTTP polling)
                           • Theme/rainbow application
  style.css             — Glassmorphic orb styling (CSS custom properties)
  settings.html         — Settings window (Spotify API credentials, colors,
                           display, audio, viz, behavior, updates)
  splash.html           — Startup splash with animated rings

core/
  settings.js           — Deep-merge defaults + config.json persistence
  spotify.js            — OAuth2 Authorization Code flow, token refresh,
                           player polling (2-5s), manual disconnect support
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
  config.json           — Auto-generated persistent settings
  debug.log             — Auto-generated debug log
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
getSmoothFactor(i, rising) — per-bin attack/release (musical reactivity):
  Sub-bass (0-1):   attack 0.92, release 0.15  ← Kicks: sudden/hard reactivity
  Bass (2-5):       attack 0.70, release 0.22  ← Bass/808: rumble/shake reactivity
  Low-mid (6-13):   attack 0.45, release 0.25  ← Vocals/Melody: low reactivity (smooth)
  Mid (14-29):      attack 0.65, release 0.20  ← Loud/Screamed Vocals: moderate reactivity
  High-mid (30-59): attack 0.80, release 0.18  ← Hats/Snares: high reactivity
  High (60+):       attack 0.78, release 0.20  ← Hats/Snares: high reactivity

getBinGain(i) — frequency gain compensation:
  0-1:   3.5    ← Sub-bass kicks (punchy, dominant)
  2-5:   2.0    ← Bass/808 (strong rumble)
  6-13:  1.2    ← Vocals/Melody (subtle, smooth)
  14-29: 1.5    ← Loud/Screamed Vocals (moderate presence)
  30-59: 1.8    ← Hats/Snares (bright, reactive)
  60+:   1.6    ← High hats/cymbals (crisp reactivity)

Noise gate: raw < 0.02 → barSmoothing *= 0.85 (immediate decay)

Kick detection:
  lowAvg = mean(barSmoothing[0..5])
  lowEnergyBaseline += (lowAvg - baseline) * 0.006
  if lowAvg > baseline * 1.35 && lowAvg > 0.06 → kickPulse = 1.0
  kickPulse *= 0.90 each frame
  kickBoost = 1 + kickPulse * 0.6
```

## Canvas Rendering

- **Non-rainbow path** (default): `Path2D` with 128 control points, `quadraticCurveTo` for smooth curves. One wide low-opacity glow stroke, one thin main stroke, one subtle fill.
- **Rainbow static path**: Individual `beginPath`/`moveTo`/`lineTo`/`stroke` per bar (128 separate paths) — slightly slower but only active when rainbow mode is enabled.
- Both paths: `shadowBlur` is 0 — glow is achieved via layered `globalAlpha` strokes, 5-10x faster than shadow blur.

## OBS Browser Source

- URL: `http://127.0.0.1:3001`
- The browser source runs the same `index.html` + `renderer.js` in "OBS mode" (no `electronAPI`)
- SSE (`/audio-stream`) pushes 128 smoothed byte values at ~60fps
- HTTP polling (`/audio`) every 100ms as silent fallback
- `/current` polled every 100ms for track data
- `/settings` polled every 500ms for theme/display changes
- Bar smoothing happens ONLY on the Electron side: `barSmoothing.map(v => Math.round(v*255))` is sent, OBS does `barSmoothing[i] = dataArray[i] / 255` (direct assignment, no re-smoothing)

## Versioning Scheme

- **Major** (1→2→3): Huge revamps, architecture rewrites
- **Minor** (2.0→2.1→2.2): Big updates, new features, significant refactors
- **Patch** (2.5.0→2.5.1): Small additions, bug fixes, performance tweaks

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

4. **Rebuild** — run `npm run build` so `dist/latest.yml` matches the new version

> **For AI agents:** When you're done with changes and before declaring the task complete, bump the version, fill in the changelog, and rebuild. Do not skip it — it's part of the task, not an afterthought.

### Version Must Be Updated Everywhere

The canonical version lives in `package.json` → `version`. All other version references are **dynamic** and read from it at runtime:

| File | How version is set |
|---|---|
| `main.js:419` | `createSplash()` injects `pkg.version` into `ui/splash.html` via `executeJavaScript` — dynamic, no manual update needed |
| `ui/splash.html:138` | `<span id="versionLabel">` — content set by `main.js`, leave the placeholder as-is |
| `package.json:4` | `description` field no longer contains a hardcoded version string — keep it that way |
| `CHANGELOG.md` | `npm run new-version` inserts a template at the top automatically |

**Never hardcode a version number anywhere.** If you need to display the version in a new place, read `package.json` and inject it dynamically (same pattern as `main.js:createSplash()`). The one exception is `CHANGELOG.md`, where the version heading is auto-generated.

**If the splash version shows "v..."** instead of a real number, it means the `executeJavaScript` injection in `main.js` isn't reaching the splash page. Check that `createSplash()` requires `./package.json` and that the `did-finish-load` event fires.

## Should They Have Said That, Anyway?

### What causes still doesn't quite make sense but the app works now

After the v2.5.6 fixes the root cause is understood: the app silently decays after sleep/wake cycles due to three compounding failures (dead audio stream, SSE write crashes, stale retryAfter). With the fixes above, none of these are permanent anymore — the app self-heals from every one of them within seconds.

### Status Lights on the Overlay

Three small dots appear below the Spotify status line:

| Dot | Green | Yellow | Red |
|---|---|---|---|
| Connected | Spotify API connected | — | No token / disconnected |
| Playing | Music is actively playing | Connected but paused | Not connected |
| Audio | Audio stream is live | — | Audio device lost or error |

These are purely visual debug indicators. They update in real-time and never block or loop.

## Build Output

```
dist/
  Spotify VORB Setup X.X.X.exe    — NSIS installer
  latest.yml                       — electron-updater metadata
  win-unpacked/                    — portable unpacked build
```

### Dist Retention Policy

`npm run build` automatically runs `scripts/clean-dist.js` after `electron-builder` finishes. It keeps only the **latest 3 versions** (the .exe + .blockmap pair for each). Older builds are deleted. This prevents `dist/` from accumulating every build ever made. If you need to keep a specific build archive it elsewhere before running build.

### Installer Safety

The NSIS installer replaces app binaries in `Program Files\` but **never touches** `%APPDATA%\Spotify VORB\` (config.json, debug.log, auth tokens). Running an installer over an existing install is safe — settings survive.

The uninstaller (accessible via Add/Remove Programs or tray menu) offers options to:
- **Keep settings** — preserves config.json, auth tokens, and logs for future reinstalls
- **Clear cached data** — removes temporary files and cached album art
- **Submit feedback** — optional feedback textarea shown during uninstall

A custom NSIS script (`scripts/installer.nsh`) handles cleanup of registry entries, shortcuts, and ensures the running process is killed before file removal.

## Auto-Updates

Configured via `electron-updater` with a `generic` provider. The user sets the update URL in Settings > Updates. On startup, the app checks for a newer `latest.yml` + installer at that URL. If found, it downloads silently and installs on next quit.

For GitHub Releases: set the update URL to your GitHub release assets URL (e.g. `https://github.com/TopiACutie/spotify-vorb/releases/latest/download/`). Upload `latest.yml` and the `.exe` installer to each release.

## What to Focus On (if continuing)

1. **Performance**: The inner loop (pts array + cos/sin per bar) is the hottest path. Pre-computing trig tables or switching to WebGL via a simple vertex shader would be the next leap.
2. **Rainbow path**: The per-bar `beginPath/stroke` could be batched into a single path for the rainbow mode too.
3. **Log rotation**: `logger.js` appends forever to `debug.log` — add size-based rotation if it becomes an issue.
4. **Audio device switching**: The `processAudio()` interval keeps running across device switches because it references module-level `analyser`/`dataArray` which get reassigned. This works but is implicit — a reset/restart mechanism would be cleaner.
