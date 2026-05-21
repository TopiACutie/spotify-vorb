# Spotify VORB

> **V**isualized **O**scillation **R**adio **B**all — A reactive circular audio visualizer for Spotify.

![Version](https://img.shields.io/github/v/release/TopiACutie/spotify-vorb?label=version)
![Platform](https://img.shields.io/badge/platform-windows-lightgrey)
![License](https://img.shields.io/badge/license-Restricted-red)

A translucent floating orb that sits on top of your screen and shows what song you're playing on Spotify — album art, title, artist — with a reactive circular waveform that pulses to the music. Doubles as an OBS browser source for streaming.

## ⚠️ License

This software is **source-available, not open source**. You may view, modify, and compile it for personal use only. Redistribution, commercial use, or publishing modified versions requires explicit written permission from the author. See [LICENSE](LICENSE) for full terms.

## Features

- **Real-time audio visualization** — 6 visualizer styles (Spiky, Wavy, Rounded, Bars, Dots, Lines) with kick-reactive smooth curves
- **Spotify integration** — OAuth2 auth, auto-polling, track info, album art, progress bar
- **Rainbow modes** — Static, Breathing, Switching, Wave — each bar gets a unique color
- **Granular color control** — Title, Artist, Visualizer, Progress, Status, Overlay — all independently customizable
- **OBS browser source** — Identical visuals with zero lag via SSE at 60fps
- **Draggable overlay** — Click and drag anywhere to reposition
- **Invisible until music plays** — Fades in on playback, fades out on pause
- **Auto-updates** — Published via GitHub Releases, users update automatically

## Quick Start

### Prerequisites

- **Node.js** v18 or newer ([download](https://nodejs.org/))
- **Spotify Developer App** ([dashboard](https://developer.spotify.com/dashboard))
- **VoiceMeeter** (optional, for audio visualization) ([download](https://vb-audio.com/Voicemeeter/))

### Install & Run

```bash
git clone https://github.com/TopiACutie/spotify-vorb.git
cd spotify-vorb
npm install
npm start
```

### First Launch

1. Open Settings (tray icon → Settings)
2. Enter your Spotify Client ID and Client Secret
3. Click "Connect" — authorize in your browser
4. Play music on Spotify — the orb appears

## Commands

| Command | Description |
|---|---|
| `npm start` | Launch the desktop app |
| `npm run build` | Package into Inno Setup installer |
| `npm run build:publish` | Build and publish to GitHub Releases |
| `npm run obs` | OBS-only server (no desktop window) |

## OBS Setup

1. Add a **Browser** source in OBS
2. URL: `http://127.0.0.1:3001`
3. Width: `520`, Height: `520`
4. Check "Refresh browser when scene becomes active"

## Architecture

```
main.js              → Electron main process (tray, IPC, window, auto-updater)
preload.js           → Context bridge (spotify.*, electronAPI.*)
ui/renderer.js       → ALL overlay logic (visualizer, audio, UI, OBS mode)
ui/settings.html     → Settings panel
core/spotify.js      → Spotify OAuth, polling, token refresh
core/settings.js     → Config persistence
core/logger.js       → File-based debug logger
core/voicemeeter.js  → VoiceMeeter detection helper
server/ui-server.js  → Express HTTP/SSE server for OBS
```

## Tech Stack

- **Electron 28** — Desktop framework
- **Vanilla JS** — No frameworks, no build tools
- **Web Audio API** — Real-time audio analysis
- **Canvas 2D** — 60fps visualizer rendering
- **Express** — Local HTTP/SSE server for OBS
- **electron-updater** — GitHub Releases auto-updates

## Contributing

This project is **not accepting unsolicited contributions**. If you wish to submit changes or request permission to publish a modified version, contact the author at **sossiwastaken0202@gmail.com**.

## License

**Restricted Source License** — see [LICENSE](LICENSE) for full terms. Copyright © 2026 Sossi. All rights reserved.

## Author

[Sossi](https://github.com/TopiACutie)
