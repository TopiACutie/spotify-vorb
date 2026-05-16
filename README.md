# Spotify VORB — Visualized Oscillation Radio Ball

A translucent floating orb that sits on your screen showing what you're playing on Spotify — album art, title, artist — with a reactive circular waveform that pulses to the music. Doubles as an OBS browser source for streaming.

![Version](https://img.shields.io/github/v/release/TopiACutie/spotify-vorb)
![License](https://img.shields.io/github/license/TopiACutie/spotify-vorb)
![Platform](https://img.shields.io/badge/platform-Windows-blue)

## Features

- **Glass orb UI** with frosted glass effect and smooth animations
- **Real-time audio visualizer** — circular waveform reacting to music via VoiceMeeter or any audio input
- **Spotify integration** — shows track title, artist, album, cover art, and playback progress
- **OBS browser source** — same visuals streamed at 60fps via local SSE relay
- **System tray** — runs in the background with quick access to settings and controls
- **Auto-updates** — downloads and installs new versions silently on quit
- **Customizable** — colors, display toggles, visualizer sensitivity, audio source, and more

## Quick Start

### Prerequisites

- **Node.js** v18 or newer
- **Spotify Developer App** (free) — [create one here](https://developer.spotify.com/dashboard)
- **VoiceMeeter** (optional) — for audio visualization, [download here](https://vb-audio.com/Voicemeeter/)

### Install & Run

```bash
npm install
npm start
```

On first launch, enter your Spotify Client ID and Client Secret in Settings, then click Connect.

### Build Installer

```bash
npm run build
```

Creates `dist/Spotify VORB Setup X.X.X.exe` — a Windows NSIS installer.

## OBS Setup

1. Add a **Browser** source in OBS
2. URL: `http://127.0.0.1:3001`
3. Size: 460 × 460
4. Check "Refresh browser when scene becomes active"

## Configuration

All settings are stored in `%APPDATA%\Spotify VORB\config.json`. Spotify credentials (Client ID, Client Secret, tokens) are stored locally and never transmitted anywhere except directly to Spotify's API.

## Auto-Updates

Set your update URL in Settings > Updates. The app checks `latest.yml` at that URL on startup and downloads new versions silently.

## License

MIT — see [LICENSE](LICENSE) for details.

## Disclaimer

This software is provided as-is. See [WARRANTY](WARRANTY) for full terms. Not affiliated with or endorsed by Spotify AB.
