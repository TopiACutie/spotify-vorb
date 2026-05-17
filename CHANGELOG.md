# Spotify VORB — Changelog

## v3.0.0 (2026-05-17)
Complete v3 release — major visualizer overhaul, granular color control, rainbow modes, draggable window, OBS improvements, and production-ready polish

### Added
- **Granular color controls**: Six independent color settings — Title Text, Artist/Album Text, Visualizer, Accent/Progress, Background, and Secondary Text. Each element can be customized separately without affecting others.
- **Rainbow mode overrides**: When enabled, rainbow colors override ALL UI elements (title, artist, visualizer, accent, secondary text) automatically. No more manual color fighting.
- **Four rainbow styles**: Static (fixed rainbow spectrum per bar), Breathing (slow continuous color shift), Switching (instant palette changes every 1.5s), Wave (rainbow flows around the circle).
- **Version badge in settings**: Shows current app version in the settings header for easy identification.
- **OBS fallback message**: When the VORB desktop app isn't running, OBS browser source shows a brief "VORB not running" notification that fades after 3 seconds and only appears once per tab load.

### Changed
- **Visualizer reactivity decoupled from Spotify state**: The waveform now reacts to captured audio independently of whether Spotify confirms playback. Spotify state only controls UI fade in/out, not visualizer activity.
- **Spiky visualizer peak handling**: High-energy bars (v > 0.6) now use sharp `lineTo` instead of `quadraticCurveTo`, maintaining crisp spikes instead of rounding into a circle during peaks.
- **Sensitivity applied to all visualizer styles**: Spiky, dots, and lines now respect the sensitivity slider, not just wavy and rounded.
- **Rainbow CSS updates throttled**: CSS variable updates limited to 10fps to prevent layout thrashing and visible background flashing. Canvas color updates remain per-frame.
- **Audio initialization rewritten**: Complete fallback chain — tries configured source (desktop → custom → voicemeeter), falls back to default device. Every path either succeeds or shows a clear error message.
- **AudioContext auto-resume**: Explicit `resume()` call after `getUserMedia` to handle Chromium's autoplay policy.
- **Window starts click-through, becomes draggable when visible**: `setIgnoreMouseEvents(true)` on init, switches to `false` when music plays, back to `true` when hidden.
- **Orb starts hidden, appears only when music plays**: `class="hidden"` default. Fades in on playback, fades out after pause delay.
- **DXGI error suppression triple-layered**: Main process stderr/stdout filtering + preload.js console patching + `did-finish-load` injection into all windows.

### Fixed
- **Visualizer not reacting to audio**: Root cause was `isSpotifyPlaying` gate in `drawVisualizer()`. Removed the gate — visualizer reacts whenever audio device is active.
- **Window not draggable on inner content**: Removed `-webkit-app-region:no-drag` from `#innerOrb`. Entire window is now draggable.
- **Rainbow static mode slowly breathing**: Fixed `getRainbowHue()` to return 0 for static mode. Per-bar rainbow spectrum is position-based, not time-based.
- **UI flashing/glowing in rainbow mode**: Throttled `applyRainbow()` CSS updates from 60fps to 10fps. Canvas color updates remain per-frame (zero DOM impact).
- **Settings color override**: Renamed `primary` → `titleColor`, added `artistColor`, `vizColor` for precise per-element control.
- **Duplicate `createSettingsWindow` function**: Removed duplicate definition in `main.js`.
- **Duplicate architecture diagram in AGENTS.md**: Removed orphaned code block.

### Architecture
- **Version bumped to 3.0.0**: Major release reflecting complete visualizer overhaul, new color system, rainbow modes, and production-ready polish.
- **Auto-update configured for GitHub Releases**: `build:publish` script publishes directly to GitHub Releases. Users receive updates automatically via `electron-updater` with GitHub provider.

## v2.13.20 (2026-05-17)
Fix window visibility: dom-ready show, remove CSS hidden default, update AGENTS.md build order

### Fixed
- **Window wouldn't show after draggable changes**: The root cause was a combination of issues: (1) The `#orb` element in `index.html` had `class="hidden"` by default, which set `opacity: 0` via CSS. Even though the window was created with `show: true`, the content was invisible. Changed the default class to `visible` so the orb is visible from the start. (2) The window creation used `show: true` but then immediately called `setAlwaysOnTop` and `setVisibleOnAllWorkspaces`, which could cause the window to be hidden behind other windows on Windows. Changed to `show: false` and moved all window property calls into a `dom-ready` event listener, followed by `win.center()` and `win.show()`. Added a 4-second fallback timeout in case `dom-ready` doesn't fire. (3) The `alwaysOnTop` setting is now read from settings and applied in the `dom-ready` handler instead of the constructor, avoiding conflicts.

### Changed
- **AGENTS.md updated with explicit build order**: Added a clear "ORDER MATTERS" warning explaining that the changelog must be filled in BEFORE running `npm run build`. The build reads the version from `package.json` and creates `latest.yml` for auto-updates. Building before filling the changelog means users won't know what changed. The correct order is now explicitly documented: **code changes → bump version → fill changelog → build**.

## v2.13.19 (2026-05-17)
Add DXGI error suppression to all window console-message listeners

### Fixed
- **DXGI error still appearing when opening settings**: The error was being printed by the renderer process (Chromium's DevTools console) when `desktopCapturer.getSources()` was called to enumerate desktop audio sources. The previous stderr/stdout filter only caught main process output. Added `console-message` event listeners to ALL BrowserWindow instances (main overlay, settings, debug, uninstall) that intercept and suppress any renderer console messages matching the DXGI error pattern. The error is now blocked at both the main process (stderr/stdout) and renderer process (console-message) levels.

## v2.13.18 (2026-05-17)
Fix window showing reliably and correct app metadata

### Fixed
- **Window still not showing reliably**: Changed the window creation from `show: false` to `show: true` so the window appears immediately when created. The transparent CSS (`opacity: 0` on `#orb.hidden`) hides the content visually until the splash screen fades, but the window itself exists from the start. Added `setVisibleOnAllWorkspaces(true)` and `setAlwaysOnTop(true, "screen-saver", 1)` to ensure the window stays above everything and appears on all virtual desktops. Removed the problematic `setTimeout` that was trying to show the window after a delay.
- **Right-click context menu showed "Electron" instead of "Spotify VORB"**: The `app.setAppUserModelId()` was set to `"Spotify VORB"` but Windows expects a reverse-DNS format for proper app identification. Changed to `"com.spotify-vorb.app"`. Also cleaned up `package.json` metadata: shortened description to `"Spotify VORB - Desktop audio visualizer and overlay"`, simplified author to `"Sossi"`, added `copyright` field, and added `publisherName` to the Windows build config. These changes ensure the installed app shows "Spotify VORB" everywhere — taskbar, context menus, Add/Remove Programs, and file properties.

## v2.13.17 (2026-05-17)
Fix window not showing and debug connection status tracking

### Fixed
- **Window still wouldn't show after splash**: Replaced the unreliable `dom-ready` + `setTimeout` approach with a single 4-second timeout that explicitly centers and shows the window. Splash closes at 3.5s, window shows at 4s. No event listeners, no race conditions — just deterministic timing.
- **Debug window showed "Disconnected" even when connected**: The connection status wasn't being tracked globally, so when the debug window opened it only saw the initial `false` state from `getDebugInit()`. Added `spotifyConnected` and `spotifyStatusText` module-level variables that are updated whenever Spotify connects or disconnects. When the debug window opens, it now receives the current connection state immediately.

## v2.13.16 (2026-05-17)
Fix UI window not showing after splash screen

### Fixed
- **Window never appeared after splash screen**: The `ready-to-show` event listener was registered AFTER `createWindow()` was called, meaning the event could fire before the listener was attached. Replaced with `dom-ready` listener inside `createWindow()` itself — this fires reliably when the page DOM is loaded, then waits 3 seconds (showing the splash) before revealing the window. Splash closes at 3.5s. Clean, deterministic timing with no race conditions.

## v2.13.15 (2026-05-17)
Fix window not showing and suppress dev update warning

### Fixed
- **Overlay window wouldn't show after draggable changes**: The window's `ready-to-show` handler was conflicting with the splash screen timing, leaving the window hidden. Fixed by adding a 5-second fallback timeout that forces the window to show if it hasn't appeared yet, regardless of splash state. The splash still closes gracefully after 3 seconds if present.
- **"checkForUpdates called, application is not packed" warning**: The auto-updater was calling `checkForUpdatesAndNotify()` even in development mode, which electron-updater doesn't support. Wrapped the call in `app.isPackaged` so it only runs when the app is built and packaged. The "Auto-check on startup" toggle still works — it just does nothing during development, which is the correct behavior.

## v2.13.14 (2026-05-17)
Strengthen DXGI error suppression with regex and stdout filter

### Fixed
- **DXGI 10-bit format error still appearing in console**: The previous stderr filter only checked for exact string matches and didn't handle Buffer chunks or stdout output. Strengthened by: (1) using a case-insensitive regex (`/IDXGI|dxgi_output|format is 10|RGBA \(8 bit\)/i`) that catches all variations of the error, (2) converting Buffer chunks to strings before testing, (3) adding the same filter to `process.stdout` in case the error leaks there, and (4) adding a `console-message` listener on the renderer's webContents to suppress any renderer-side output of the same error. The error is now blocked at every possible output path.

## v2.13.13 (2026-05-17)
Make window draggable, fix visualizer bounds, improve OBS sync

### Changed
- **Window is now draggable**: The overlay window can be grabbed from anywhere on the orb and dragged to any position on screen. The inner content area (cover art, text, progress bar) remains non-draggable so it doesn't interfere with any future interactive elements. Hovering over the orb changes the cursor to a grab hand. Window size increased from 460×460 to 520×520 to give the visualizer more room.
- **Visualizer bounds properly clamped**: All visualizer styles now clamp their radius to stay within the canvas bounds. The wavy style's wave amplitude is capped at 35px regardless of sensitivity setting, preventing it from exploding into the inner circle or going out of bounds. The rounded style's circle and glow are also clamped to the max radius.
- **Rounded style centered correctly**: Fixed the `path.arc()` calls to use `(cx,cy)` instead of `(0,0)`, so the expanding circle is properly centered on the orb regardless of the scale transform.

### Fixed
- **OBS visualizer out of sync with desktop**: The OBS browser source was using its own `AnalyserNode` for smoothing instead of receiving the already-smoothed data from the Electron app. Fixed by having OBS read the smoothed `dataArray` directly from the SSE stream (`/audio-stream`) and HTTP endpoint (`/audio`), applying the same values the desktop app uses. No double-smoothing, no lag.

## v2.13.12 (2026-05-17)
Add six visualizer styles and rainbow compatibility

### Added
- **Six visualizer styles**: Spiky (default, smooth curves with sharp peaks), Wavy (organic sine wave distortion), Rounded (expanding circle glow), Bars (individual radial bars), Dots (positioned dots with size based on energy), Lines (perpendicular lines with length based on energy).
- **Rainbow mode compatibility**: All six visualizer styles support rainbow color modes. Per-bar styles (bars, dots, lines) use position-based hue mapping. Unified styles (spiky, wavy, rounded) use time-based hue cycling.

### Fixed
- **Status dots removed from overlay and settings**: Moved all status indicators to the debug window (gated behind Developer Mode) and a single indicator in the settings window. The overlay is now clean — just the orb, cover art, and track info.

## v2.13.11 (2026-05-17)
Reduce polling latency, fix status indicator logic

### Changed
- **Spotify polling intervals reduced**: Idle polling from 5s to 3s, playing polling from 5s to 1.5s. Fast idle polling (first 3 polls) at 1.5s for quick detection when music starts. Maximum poll gap reset to 20s to prevent stale `retryAfter` values. These changes reduce latency between pressing play and the orb appearing, without triggering Spotify rate limits.

### Fixed
- **Status indicators showing incorrect state**: The three status dots (Connected, Playing, Audio) were showing red even when the app was functioning correctly. Fixed by properly initializing the dot states based on actual connection and audio status, and ensuring they update in real-time without blocking or looping.

## v2.13.10 (2026-05-17)
Add debug window with real-time connection monitoring

### Added
- **Debug window**: Accessible via tray menu when Developer Mode is enabled. Shows real-time Spotify connection status, token validity, polling health, auth test button, and force reconnect. Three status cards (Credentials, Token, Connection) with color-coded indicators. Live log panel showing auth events and poll results.

### Changed
- **Developer Mode toggle**: Added to Settings > Behavior. When enabled, shows "Spotify Debug" option in the system tray menu. Disabled by default to keep the UI clean for regular users.

## v2.13.9 (2026-05-17)
Replace taskkill with single instance lock, fix settings save

### Changed
- **Single instance lock replaces taskkill**: Instead of using `taskkill /F /IM "Spotify VORB.exe"` on startup (which caused race conditions and port conflicts), the app now uses `app.requestSingleInstanceLock()`. If another instance is running, the new instance exits immediately. The existing instance is brought to the foreground via the `second-instance` event. This is cleaner, safer, and doesn't require spawning external processes.

### Fixed
- **Settings save wiping Spotify tokens**: The `save-settings` IPC handler was replacing the entire settings object, which deleted `accessToken` and `refreshToken` if they weren't included in the save payload. Fixed by preserving existing tokens when saving: if the new settings don't include `accessToken` or `refreshToken`, the existing values are retained.
- **Null value crash in settings deep merge**: The `dm()` (deep merge) function was crashing when encountering `null` values from the settings UI. Fixed by skipping `null` and `undefined` values during merge, preserving existing values instead of overwriting them.
- **`updateUrl` reference error**: The settings save handler referenced `n.updateUrl` which doesn't exist in the new settings structure. Fixed to use `n.update?.url`.
