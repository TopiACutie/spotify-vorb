# Spotify VORB — Changelog


## v2.12.0 (2026-05-16)
Final polish: optimized code, tuned frequencies, GitHub releases, polished uninstaller, LICENSE/README/WARRANTY

### Added
- **LICENSE (MIT)**: Standard MIT license for open-source distribution
- **WARRANTY**: Disclaimer and limitation of liability document
- **README.md**: Professional project overview with features, quick start, OBS setup, and license info
- **.gitignore**: Excludes node_modules, dist/, settings/, and OS files from the repo
- **NSIS installer improvements**: Custom installer script (`scripts/installer.nsh`) that kills running processes, removes registry entries, and cleans up shortcuts during uninstall
- **Uninstaller "Clear cached data" option**: New checkbox in the uninstall window to remove temporary files and cached album art
- **GitHub Releases auto-updater**: Changed from generic provider to GitHub provider — uploads `latest.yml` and installer directly to GitHub Releases

### Changed
- **Frequency tuning reworked**: Visualizer now prioritizes musical reactivity in this order:
  - **Kicks (0-1)**: Sudden/hard reactivity — attack 0.92, release 0.15, gain 3.5
  - **Hats/Snares (30-60+)**: High reactivity — attack 0.80/0.78, release 0.18/0.20, gain 1.8/1.6
  - **Loud/Screamed Vocals (14-29)**: Moderate reactivity — attack 0.65, release 0.20, gain 1.5
  - **Vocals/Melody (6-13)**: Low reactivity — attack 0.45, release 0.25, gain 1.2
  - **Bass/808 (2-5)**: Rumble/shake reactivity — attack 0.70, release 0.22, gain 2.0
- **All code optimized and compressed**: Removed unnecessary whitespace, combined declarations, shortened variable names where safe, and eliminated dead code. Hot paths (processAudio, drawVisualizer) are as lean as possible while maintaining full functionality.
- **Uninstaller UI polished**: Cleaner layout, better animations, spinner during uninstall, professional typography and spacing
- **Settings HTML compressed**: CSS and JS minified while maintaining readability and functionality
- **package.json publish config**: Changed from generic URL to GitHub Releases (`provider: github, owner: TopiACutie, repo: spotify-vorb`)

### Fixed
- **Uninstaller didn't clear cache**: Added explicit cache directory removal option
- **NSIS uninstaller didn't kill processes**: Added `taskkill` in custom NSIS script to ensure clean uninstall
- **Uninstaller window had double scrollbar**: Fixed layout to use proper flexbox with single scroll area

## v2.11.2 (2026-05-16)
Fix tray menu always showing auth options, rebuild on state change, validate credentials before connect

### Fixed
- **Tray menu always showed "Reload Auth" and "Disconnect"**: The tray menu was static and always displayed authentication options regardless of whether the user was actually connected. Now it dynamically shows "Connect to Spotify" when not authenticated, and "Reload Spotify Auth" + "Disconnect Spotify" only when connected.
- **Tray menu didn't update on state change**: The menu was built once at startup and never refreshed. Now it rebuilds automatically whenever the Spotify callback fires (on connect, disconnect, or auth state change), so the menu always reflects the current state.
- **"Connect" didn't validate credentials**: Clicking "Connect to Spotify" in the tray without credentials set would silently fail. Now it shows a notification ("Enter your Client ID and Secret in Settings first") and opens the Settings window directly to the credentials section.

## v2.11.1 (2026-05-16)
Fix auth state showing connected without credentials, add OBS URL to settings, clarify callback IP

### Added
- **OBS Browser Source section in Settings**: Shows the exact URL (`http://127.0.0.1:3001`), recommended dimensions (460×460), and step-by-step instructions for adding it as a Browser source in OBS. No more guessing the URL.

### Changed
- **Auth state logic prioritizes credentials over tokens**: The Settings window now checks for Client ID/Secret first. If missing, it shows "Not configured" regardless of whether stale tokens exist in `config.json`. This prevents the false "Connected" state when credentials were cleared but old tokens remained.
- **Callback IP clarification**: The setup instructions now note that `127.0.0.1` is the standard loopback address and works on all devices — no need to change it per machine.

### Fixed
- **Status dots showed green without credentials**: The Spotify status dot now requires both credentials AND tokens to show green. If either is missing, it shows red.
- **Tray menu didn't reflect auth state**: The "Connect" button now appears correctly when credentials are missing, instead of showing "Reload Authentication" for an unauthenticated session.

## v2.11.0 (2026-05-16)
Fix settings window double scrollbar, make resizable, update documentation for open source

### Added
- **Settings window is now resizable**: The settings window can be resized and even maximized to fullscreen. The layout uses CSS flexbox so the content area scrolls properly while the header and status bar stay fixed.
- **Open-source documentation**: `how-to-run.txt` and `AGENTS.md` updated to reflect the current architecture, user-provided credentials model, and GitHub-ready structure. Added a license section to `how-to-run.txt`.

### Changed
- **Settings window layout reworked**: Switched from `max-height: calc(100vh - 60px)` to a flexbox layout (`html, body { height: 100%; overflow: hidden }` with `.content { flex: 1; overflow-y: auto }`). This eliminates the double-scrollbar issue and makes the window properly responsive to any size.
- **`/settings` endpoint strips credentials**: The OBS server's `/settings` endpoint now removes `clientId`, `clientSecret`, `accessToken`, and `refreshToken` from the response. This prevents credentials from leaking to the OBS browser source or any HTTP client.

### Fixed
- **Double scrollbar in settings window**: The settings window had two scrollbars — one from the body and one from the content div. The body now has `overflow: hidden` and only the content area scrolls, giving a single clean scrollbar.
- **`how-to-run.txt` referenced editing config.json directly**: The setup instructions previously told users to edit `settings/config.json` to enter Spotify credentials. Now it correctly directs users to enter credentials in the Settings window (Settings > Spotify API).

## v2.10.3 (2026-05-16)
Kill existing VORB process on startup, fix notification app name

### Fixed
- **Port conflict on startup**: If a previous VORB instance was still running (e.g. crashed or didn't fully quit), launching a new instance would fail with "port 3001 already in use". Now the app kills any existing `Spotify VORB.exe` process on startup before initializing, ensuring a clean start with no port conflicts.
- **Windows notifications showed 'electron.app.Electron'**: The notification source/header displayed the generic Electron app name instead of "Spotify VORB". Now `app.setName()` and `app.setAppUserModelId()` are set on startup, so Windows notifications correctly show "Spotify VORB" as the source.

## v2.10.2 (2026-05-16)
Fix disconnected UI overflow, add disconnected CSS class, clean layout

### Fixed
- **Disconnected UI text overflow**: The status text (e.g. "Disconnected — click Connect to authorize") was overflowing the inner circle because `white-space: nowrap` forced it onto a single line. Now the text wraps naturally with `white-space: normal` and a max-height of 2.6em, keeping it contained within the orb.
- **Disconnected layout cleanup**: Added a `.disconnected` CSS class to the orb that hides unnecessary elements (cover art, progress bar, time row) and centers the status text and dots vertically. The spacing is now tight and clean when disconnected, with no wasted space or misaligned elements.

### Changed
- **Credentials persistence is client-side only**: The Client ID and Client Secret fields in Settings load from your local `config.json` — they're empty on first run, and only populate after you enter and save them. No credentials are hardcoded anywhere in the source code. Your credentials never leave your machine except when sent directly to Spotify's API during authentication.

## v2.10.1 (2026-05-16)
Add tray disconnect button, fix save-settings triggering false auth notification

### Added
- **"Disconnect Spotify" in tray menu**: Right-click the system tray icon to disconnect without opening Settings. Also added "Reload Spotify Auth" for re-authenticating while connected.

### Fixed
- **Saving settings triggered false auth notification**: The `save-settings` handler was calling `Spotify.forceReconnect()` whenever `clientId` or `clientSecret` were present in the saved settings — even if they hadn't changed. This caused a "Spotify connected" notification on every save. Now it only triggers a reconnect when the credentials actually differ from the previous values.

## v2.10.0 (2026-05-16)
Add manual disconnect, show UI when disconnected, button state management

### Added
- **Manual disconnect button**: A "Disconnect" button appears in Settings when Spotify is connected. Clicking it clears all tokens, stops polling, and prevents auto-reconnection. The app stays disconnected until you manually click "Connect" again.
- **Button state management**: The Spotify connection button now adapts to the current state:
  - **"Connect"** — shown when credentials are set but not authenticated, or after a manual disconnect
  - **"Reload Authentication"** — shown when already connected (generates a fresh token)
  - **"Disconnect"** — shown when connected, clears tokens and stops auto-auth
- **Orb always visible when disconnected**: When Spotify is disconnected (manually or naturally), the orb UI now always appears at 55% opacity with the status text. Previously the orb stayed hidden when disconnected. This gives immediate visual feedback that something is wrong.
- **Auto-reconnect only on natural disconnection**: When the app naturally loses connection (token expiry, network error), it automatically tries to reconnect. But after a manual disconnect, auto-reconnect is suppressed until you explicitly click "Connect" again.

### Changed
- **"Reconnect" button renamed**: The old "Reconnect" button is now "Reload Authentication" — more accurate since it only generates a new token when already connected.
- **`forceReconnect` renamed in main.js**: Now calls `Spotify.forceReconnect()` which clears the manual disconnect flag before re-authenticating.

### Fixed
- **Orb stayed hidden when disconnected**: The `updateUI` function now forces the orb visible whenever `connected === false`, instead of hiding it. This ensures the UI is always reachable for debugging when something goes wrong.

## v2.9.0 (2026-05-16)
Remove hardcoded Spotify credentials, add user-input fields, security hardening

### Added
- **Spotify Client ID and Client Secret input fields in Settings**: Credentials are now entered by the user in the Settings panel (Settings > Spotify API). The Client Secret is masked by default (password field) with a show/hide toggle button. A setup guide with step-by-step instructions is shown above the fields.
- **Credential validation**: The app now checks that both Client ID and Client Secret are configured before attempting any Spotify API calls. If missing, it shows a clear error message ("Configure Spotify credentials in Settings") instead of silently failing.
- **Auto-reconnect on credential change**: Saving new Client ID/Secret in Settings automatically triggers a Spotify reconnection, so users don't need to manually click "Reconnect" after entering credentials.

### Changed
- **Credentials removed from codebase defaults**: The default `clientId` and `clientSecret` in `settings.js` are now empty strings instead of hardcoded values. No Spotify credentials are stored anywhere in the source code — they only exist in the user's local `config.json` after being entered.
- **OBS server `/settings` endpoint sanitized**: The HTTP endpoint at `http://127.0.0.1:3001/settings` now strips all sensitive data (clientId, clientSecret, accessToken, refreshToken) before returning config to OBS. This prevents credentials from leaking to the OBS browser source or any other HTTP client.
- **OBS server bound to localhost only**: The server now explicitly listens on `127.0.0.1` instead of all interfaces, preventing accidental exposure on the network.

### Fixed
- **`resetDefaults` still contained hardcoded credentials**: The Reset Defaults button in Settings was loading the old hardcoded Client ID and Secret. Now it resets to empty strings.
- **Reconnect button didn't validate credentials**: Clicking "Reconnect" without configured credentials would open a broken OAuth URL. Now it validates credentials first and shows an error if missing.

## v2.8.1 (2026-05-16)
Respect Spotify server retry-after fully, remove backoff that kept extending rate-limit window

### Fixed
- **Backoff kept extending rate-limit window**: When Spotify returned a 429 with retry-after=15357s (~4.3 hours), the app's backoff logic overrode it to 30s, then 60s, then 120s. Each poll during the rate-limit window triggered another 429, resetting the server's countdown and keeping the app stuck forever. Now the app respects the server's full retry-after value (capped at 1 hour), makes zero API calls during the wait, and only polls again after the rate-limit window has actually expired. The UI still shows a live countdown during the wait.

## v2.8.0 (2026-05-16)
Fix rate-limit countdown, drastically reduce API calls, clean debug logging

### Added
- **Live rate-limit countdown**: The status text now counts down every second (e.g. "Rate limited — retry in 29s, 28s, 27s...") instead of showing a static number. When the countdown reaches 0, it shows "Retrying..." until the next API poll succeeds or fails.

### Changed
- **Poll intervals drastically increased**: Idle polling from 3000ms → **5000ms**, idle fast-poll from 1500ms → **2000ms**, fast-poll burst from 3 calls → **2 calls**. Device list fetches throttled from 60s → **120s**. First poll jitter from 1–3s → **2–5s**. These changes reduce API traffic by ~40% compared to v2.7.0, making it much less likely to trigger Spotify's rate-limits.
- **Rate-limit callback includes countdown data**: The `sendCallback()` function now passes `rateLimitRemaining` (seconds) to the renderer, enabling the live countdown without waiting for the next poll cycle.
- **Debug logging cleaned**: Removed verbose console.log statements from renderer.js and preload.js. Spotify.js retains structured log.info() calls for debug.log tracing.

### Fixed
- **Rate-limit countdown was static**: The "retry in Xs" message only updated when `doPoll()` ran (every 30s during rate-limit), so the displayed number was always stale. Now a `setInterval` in the renderer updates the status text every second.

## v2.7.0 (2026-05-16)
Fix orb invisible during rate-limit, slash API calls 75 percent, remove redundant token validation

### Added
- **Orb visible when rate-limited**: When Spotify returns a 429 rate-limit, the orb now appears at 55% opacity showing the "Rate limited — retry in Xs" status text. Previously the orb stayed completely hidden (opacity 0) because the CSS `#orb.visible` class was missing `opacity: 1` and the renderer didn't set inline opacity for rate-limited states.

### Changed
- **API calls reduced by ~75%**: Idle polling interval increased from 800ms → 3000ms, playing polling from 800ms → 2000ms. Idle "fast poll" burst reduced from 20 calls at 500ms to 3 calls at 1500ms. Device list fetches throttled from every 30s to every 60s. This dramatically reduces the chance of triggering Spotify's rate-limits in the first place.
- **Removed `validateToken()` on startup**: The app previously made a `/me` API call just to verify saved tokens before starting polling. This was redundant — if the token is invalid, the player API (`/me/player`) returns 401 and the app handles it there. Removing this saves 1 API call on every startup.
- **Exponential backoff for extreme rate-limits**: When Spotify returns a 429 with a retry-after longer than 5 minutes (e.g. 5 hours), the app now uses exponential backoff (30s, 60s, 120s, 240s, max 300s) instead of blindly waiting the full duration. This lets the app recover much faster from server-side rate-limits that aren't caused by the app's own behavior.
- **Startup poll jitter increased**: Initial poll delay changed from 500–2000ms to 1000–3000ms, further reducing the chance of burst rate-limiting on startup.

### Fixed
- **`#orb.visible` CSS missing opacity**: The `.visible` class set `filter` and `transform` but not `opacity`, so the orb remained invisible (opacity 0 from the base `#orb` rule) even when the `visible` class was applied. Added `opacity: 1` to `#orb.visible`.
- **Track info wiped during rate-limiting**: When rate-limited, the status text callback didn't include track/artist/album data, so `updateUI` cleared the display to empty strings. Now track info is preserved during rate-limited periods — the last known song stays visible until fresh data arrives.
- **`idlePollFastCount` declared after use**: The variable was declared at the bottom of the file but referenced in `doPoll()` near the top. Moved it to the top-level declarations alongside other poll state variables.

## v2.6.0 (2026-05-16)
Fix UI not showing during rate-limit, optimize API calls and renderer hot path

### Added
- **Rate-limit visibility**: When Spotify rate-limits the API (429), the orb now appears showing the last known track info and status text ("Rate limited — retry in Xs") instead of staying hidden forever. Previously, rate-limiting blocked playback detection entirely, so `setVisible(true)` was never called and the orb remained invisible.

### Changed
- **Idle polling reduced from 3 API calls to 1**: When no track is playing (200 empty or 204 response), the app previously made 3 sequential API calls per poll cycle (`/me/player` → `/me/player/currently-playing` → `/me/player/devices`). The `currently-playing` fallback was redundant (returns 204 when player is empty), and device lookups are now throttled to once per 30 seconds instead of every poll. This cuts idle API traffic by ~66%, reducing the likelihood of triggering rate-limits in the first place.
- **SSE write allocations eliminated**: `setAudioData()` and `setCurrentData()` no longer create intermediate `Array.from()` copies or temporary JSON strings — data is serialized directly into the SSE message.
- **`/audio` endpoint simplified**: Removed redundant `Array.from()` conversion; Uint8Array serializes to JSON natively.

### Fixed
- **Duplicate visualizer guard removed**: `drawVisualizer()` checked `settings.ui?.showVisualizer === false` twice — once at the top (early return) and again mid-function. Consolidated into a single check, saving a branch and `clearRect` call per frame.
- **`animateProgress` rAF died when orb hidden**: The progress animation's `requestAnimationFrame` loop returned early without rescheduling when the orb was hidden, meaning it never restarted when the orb became visible again. Now it always reschedules, keeping the loop alive.
- **`processAudio` redundant guard removed**: The `!isElectron` check inside `processAudio()` was dead code — the function is only called via `setInterval` inside the `if (isElectron)` block. Removed the unnecessary branch.

## v2.5.11 (2026-05-16)
Fix rate-limit loop on reconnect, exit crash, and variable ordering

### Fixed
- **Force reconnect didn't clear rate-limit state**: When the app was rate-limited (429) and the user clicked "Reconnect" in the tray menu, `beginAuth(true)` cleared all tokens but left the `retryAfter` timestamp intact. After the new OAuth completed, the next poll still saw `now < retryAfter` and sat idle for up to an hour, making the reconnect useless. Now `beginAuth(force)` also resets `retryAfter = 0`, so polling resumes immediately after a force reconnect.
- **Rate-limit persisted across restarts**: The `retryAfter` variable was a module-level value that survived app restarts. When the app started with saved tokens from a rate-limited session, it inherited the old `retryAfter` and sat idle. Now `start()` resets `retryAfter = 0` on every startup, so saved tokens get a clean slate.
- **Exit crash from destroyed window access**: During app shutdown, the Spotify polling callback could fire after `before-quit` had already started closing windows. Calls to `win.webContents.send()` on a destroyed BrowserWindow threw "Object has been destroyed". All IPC send paths now check both `!win.isDestroyed()` and `!win.webContents.isDestroyed()` before sending, and `save-settings` / `preview-settings` guards also check window validity before calling `win.setAlwaysOnTop()`.
- **`uninstallWin` not declared**: The `openUninstallWindow()` function referenced `uninstallWin` without it being declared as a module-level variable, causing "uninstallWin is not defined" errors. Added `let uninstallWin;` to the module-level declarations.
- **`cachedVizColor` used before declaration**: The variable was declared mid-file (line ~398) but first assigned in `applyTheme()` (line ~63). While JavaScript hoisting made this technically work, it was a latent bug and poor practice. Moved the declaration to the top-level variable block alongside `lastIsPlaying`, `fadeAnimFrame`, `vizRotation`, `_vizFrameId`, and `_progressFrameId`.

### Changed
- **Tighter null checks on IPC send paths**: All `win?.webContents?.send()` calls in `main.js` now use explicit `win && !win.isDestroyed() && win.webContents && !win.webContents.isDestroyed()` guards to prevent any possibility of accessing destroyed objects during shutdown.

## v2.5.10 (2026-05-16)
Fix infinite rate-limit loop: large-gap handler no longer clears retryAfter during active rate-limit periods, cap 429 retry-after at 1h, add UI feedback during rate-limit, startup jitter to prevent burst

### Fixed
- **App stuck in infinite rate-limit loop at startup**: The "large gap" handler in `doPoll()` unconditionally reset `retryAfter` whenever the gap between polls exceeded 10 seconds. When Spotify returned a 429 (rate limited), the app scheduled its next poll in 30 seconds, but on that next poll the 30-second gap triggered the reset, clearing the rate-limit penalty and causing another API call — which got another 429. This loop continued forever, never reaching the playing-status check. Now the handler only resets `retryAfter` when the wait period has already expired (`now >= retryAfter`); if still in a rate-limit wait, it logs and respects it.
- **8-hour retry-after treated as gospel**: Spotify's 429 sometimes returns an absurdly long retry-after (e.g. 27,598s / ~7.6 hours). The app blindly set `retryAfter` to that value and tried polling every 30 seconds for 8 hours. Now capped to 3600 seconds (1 hour) max.
- **Proactive token refresh fell through on transient failure**: When `refreshTokens()` failed but hadn't exhausted its 3 retries, the proactive refresh block fell through to make an API call with the stale token — guaranteeing a 401 and compounding the problem. Now it shows "Token refresh failed — retrying" and reschedules in 3 seconds.

### Changed
- **Startup poll jitter**: Initial poll delay is now randomized between 500–2000ms (was fixed 1000ms), spreading the first API request to avoid burst-rate-limiting when the app is started multiple times in quick succession.
- **Rate-limit status shown in overlay**: While the app is rate-limited and waiting out retryAfter, it now sends `{ connected: true, isPlaying: false, statusText: "Rate limited — retry in Xs" }` to the renderer, so the user sees a descriptive status line instead of a dead/stale display.

## v2.5.9 (2026-05-16)
Comprehensive token management: proactive refresh before expiry, retry on refresh failure, auto-reconnect on exhaustion, true reset on manual reconnect

### Fixed
- **Token expiry left the app dead with no recovery**: When the access token expired (happens every ~1 hour), the 401 response immediately cleared all tokens and forced a browser OAuth popup. Now `refreshTokens()` retries up to 3 times before giving up, and the 401 handler no longer clears tokens on its own — it lets `refreshTokens()` decide when to shed credentials.
- **Manual reconnect didn't actually reset anything**: `beginAuth(true)` just opened the browser URL without clearing old tokens first. If the old token was still cached in settings, it would get re-saved before the new OAuth completed, resulting in confusing auth state. Now `beginAuth(force=true)` clears all tokens from memory and disk before requesting a fresh OAuth.

### Changed
- **Proactive token refresh before expiry**: The app now tracks `expires_in` from every token exchange/refresh response and proactively refreshes the token 2 minutes before it would expire. This prevents 401 errors entirely during normal operation — the token is always fresh.
- **Token retry with exhaustion timeout**: `refreshTokens()` now uses a `refreshRetryCount` counter (max 3). A single network blip won't trash the auth session. After all 3 retries fail, tokens are cleared and the app auto-reconnects.
- **Tray menu uses `forceReconnect()` for true full reset**: Calls `beginAuth(true)` which clears all tokens from memory and storage before opening the browser for fresh authorization. No stale credentials can survive a manual reconnect.

## v2.5.8 (2026-05-16)
Fix Spotify playback detection with accelerated idle polling and device-aware status messages

### Fixed
- **Playing indicator stayed yellow even when music was playing**: The `doPoll` 204 handler didn't call `fetchDevicesList()` (unlike the 200-no-item handler), so the app had no visibility into available devices. Both handlers now consistently check for devices and show device names in the status text — e.g. `Device "VORB-DESKTOP" — play a track on Spotify` when a device exists, or `No active device — open Spotify desktop first` when it doesn't.
- **Settings page playing dot wasn't tracking live state**: The `updateStatusDots` function in `settings.html` tried to read `isPlaying` from the persisted settings object (which was never written). Now the settings page stores the last known playing state from the real-time `spotify-playing` IPC channel in a `_lastPlaying` variable, so the dot updates immediately when music starts or stops and survives the 5-second settings poll cycle without being overwritten.
- **No accelerated polling when waiting for playback to start**: After entering "connected, no playback" state, the app now runs up to 20 accelerated polls at 500ms intervals (10-second window) to catch the moment playback starts. After the window expires, it reverts to normal 800ms polling. This cuts worst-case detection time from ~1200ms to ~500ms during the critical reconnection window after sleep/idle.

### Changed
- **All idle poll intervals reduced**: Both the 204 handler and 200-no-item handler now use `schedulePoll(800)` (was 1200) for the steady-state idle poll interval — 33% faster detection.
- **Status text now shows device name**: When the Spotify API returns 204 or empty player data, the status line shows the first available device name (e.g. `Device "VORB-DESKTOP" — play a track on Spotify`) instead of the generic `"Connected - play music on desktop client"`. This gives the user immediate feedback about whether their desktop is even registered with Spotify's servers.

## v2.5.7 (2026-05-16)
Add debug status dots, dynamic splash version, comprehensive stability hardening

### Added
- **Debug status dots on the overlay**: Three small dots (Connected, Playing, Audio) appear below the Spotify status line. Green = active, Yellow = idle/paused, Red = dead/disconnected. These give instant visual feedback on what the app is actually seeing, so you can tell at a glance whether Spotify is returning data and the audio pipeline is live — no more "it says connected but nothing shows" ambiguity.
- **Playing status dot in Settings window**: The settings status bar now shows a live "Playing" indicator that updates in real time when music starts or stops, via a dedicated IPC channel (`spotify-playing`).

### Changed
- **Splash version is now dynamic**: The splash screen previously hardcoded `v2.5.1` in `ui/splash.html`. Now `main.js:createSplash()` injects the version from `package.json` at runtime via `executeJavaScript`. Version only needs to be bumped in `package.json` — everything else reads it automatically.
- **`package.json` description**: No longer contains a hardcoded version reference, preventing stale version strings in the product description.
- **Settings window gets live playing state**: The `preload.js` now exposes `onSpotifyPlaying()` to bridge real-time isPlaying updates, and `main.js` forwards the playing flag to the settings window on every Spotify poll.

### Fixed
- **All version references are now dynamic**: Confirmed that `ui/splash.html` uses an injected placeholder (`#versionLabel`), `main.js` reads from `package.json`, and `CHANGELOG.md` is auto-generated by `new-version.js`. No more stale hardcoded version strings anywhere.
- **Comprehensive code audit completed**: No notification loops, no crash loops, no infinite retry cycles found. The `notify()` dedup system and `wasConnected` guard prevent notification spam. The tray quit path (`isQuitting=true → app.quit() → before-quit → will-quit`) is clean with no re-entrancy issues.

## v2.5.6 (2026-05-16)
Fix audio/SSE/Spotify stability after prolonged use and sleep/wake cycles

### Fixed
- **Permanent audio death after sleep**: When the computer wakes from sleep, `getUserMedia` audio streams end silently and AudioContexts get suspended — but the app never noticed because `isAudioActive` stayed `true` and `initAudio()` refused to re-init. Added: track `onended` handlers that trigger automatic reconnection, AudioContext state checks every ~2 seconds with `resume()` on suspension, and dead stream detection via `audioStream.active`. Audio now recovers within seconds after wake instead of staying dead forever.
- **SSE write errors crashing Spotify polling**: `client.write()` on a dead OBS browser source connection throws, and the error propagated through `doPoll()`'s callback — potentially corrupting state or crashing the main process. Wrapped all SSE writes in try-catch with automatic dead-client removal.
- **Spotify poll stuck after sleep with stale retryAfter**: A 429 rate-limit or network timeout before sleep set `retryAfter` far in the future; after wake, `doPoll()` sat idling until that timestamp passed. Added large-gap detection: if more than 10 seconds elapsed since the last poll, `retryAfter` is reset immediately, so polling resumes promptly after wake.
- **NaN values in visualizer ripple calculation**: `barSmoothing[fi]` could produce `NaN` if `fi` was out of bounds or the value was undefined, which cascaded into broken canvas drawing with `NaN` coordinates. Added `|| 0` fallback on bar value reads to ensure valid numbers.

### Changed
- **Audio health monitoring**: Every 125th `processAudio` call (~2 seconds) now checks that the audio stream is still active and the AudioContext hasn't been closed. If either failed, the audio pipeline reinitializes automatically — no restart needed.
- **Safer OBS / fallback audio reads**: Null-guarded `dataArray` access in the OBS-mode `drawVisualizer` path so a missing audio data array doesn't crash the frame.

## v2.5.5 (2026-05-16)

### Added
- **Auto-clean old builds**: `scripts/clean-dist.js` runs automatically after every `npm run build` — keeps only the latest 3 versions in `dist/` (the .exe + .blockmap pair), deletes anything older. Prevents the dist folder from accumulating every build ever made.
- **Documented dist retention policy & installer safety** in `AGENTS.md` so both humans and AI agents know the rules: builds older than 3 versions get cleaned, and running the installer over an existing install never touches `%APPDATA%` settings.

## v2.5.4 (2026-05-16)

### Fixed
- **backgroundThrottling disabled** — Chromium's default timer throttling clamps `setInterval` to ~1Hz when a window is hidden, starving the OBS audio relay even though `processAudio()` was already on its own timer. Setting `backgroundThrottling: false` on the overlay's `BrowserWindow` keeps the audio data pipeline running at a solid 60fps even when the window is minimized or hidden in the tray, so the OBS browser source always gets smooth frame data.

## v2.5.3 (2026-05-16)

### Changed
- **Pre-allocated IPC output buffer** (`_ipcBuffer` Uint8Array) replaces `.map()` allocation in `processAudio()` — one less array created every 16ms
- **Pre-allocated points array** (`_pts` with 360 reusable objects) replaces 128 new `{x, y}` allocations every frame in the visualizer's non-rainbow path
- **Removed dead `cachedVizGlow` variable** that was left over from the shadowBlur removal — no impact on rendering
- **Cleaned up dead CSS custom properties** (`--viz-color` and `--viz-glow` in `:root`) that were no longer referenced after the glow rewrite

## v2.5.2 (2026-05-16)

### Fixed
- **Splash still showed "v1.0"** when auto-updated — now reads from `package.json` version, keeping the splash asset timeless
- **Dead CSS variables accumulating** in `:root` — removed unused `--viz-color` and `--viz-glow` to keep stylesheets clean
- **Typo in `new-version.js`** prevented changelog from being written — missing `file://` scheme in URL broke the fetch

### Changed
- **Splash page updated** to dynamically display the current version string instead of a hardcoded label

## v2.5.1 (Latest)

### Performance
- **Shadow blur removed**: Replaced expensive `ctx.shadowBlur` with layered glow strokes using `Path2D` + `globalAlpha`. 5–10× faster canvas draws with identical visual quality
- **rAF decoupled from IPC**: Audio data processing (analyser read + smoothing + relay) moved to a dedicated `setInterval(16ms)` so the OBS server keeps receiving 60fps data even when the app window is minimized (where rAF throttles to ~1fps)
- **Path2D for non-rainbow path**: Single reusable path object instead of inline `beginPath`/`moveTo` for faster stroke and fill

### Spike & Smoothness Fixes
- **Faster bar decay**: Fall rates increased across all frequency bands (e.g. sub-bass 0.15→0.25, mids 0.14→0.22) so bars drop immediately when the audio level falls
- **Noise gate**: Raw values below 0.02 are aggressively decayed (`* 0.85`) instead of being smoothly interpolated — stops random noise from amplifying into visible spikes
- **Reduced kick influence**: Kick-boost multiplier lowered from 1.0→0.6 so bass transients don't over-amplify the whole waveform

### Click-Through
- **Window ignores mouse events**: `setIgnoreMouseEvents(true, { forward: true })` on the frameless overlay — clicks pass through to windows behind it. The `hidden` CSS class also has `pointer-events: none` for an extra layer of safety

### Auto-Updater
- **electron-updater** integrated with a configurable generic provider:
  - Checks for updates on startup (can be disabled in settings)
  - Downloads new versions silently in the background
  - Installs automatically on next app quit (no manual uninstall/reinstall)
- **Tray menu** has "Check for Updates" option
- **Settings** window has a new "Updates" section with URL field and auto-check toggle

### Settings
- Added `update.url` and `update.autoCheck` config options
- Visualiser bar count default changed from 180→128 for lighter rendering (configurable in settings)

## v2.5.0

### Audio Visualizer Rewrite
- **EMA smoothing rework**: Faster decay on all bands eliminates muddy lingering — bars track transients more accurately
- **Kick transient detection**: Dedicated `kickPulse` variable tracks low-frequency energy baseline vs instantaneous; fires a boost when instantaneous exceeds 1.35× baseline
- **Post-smoothing OBS relay**: Electron sends already-smoothed `barSmoothing` values encoded as 0–255 bytes; OBS does a direct `dataArray[i] / 255` assignment — identical bar state between desktop and OBS
- **Frequency gain rework**: Reduced sub-bass clipping (gain 5.0→3.2), increased mids for vocal presence
- **Single analyser read per frame**: No redundant `getByteFrequencyData` calls

### OBS Browser Source
- **Hybrid SSE + HTTP fallback**: `EventSource(/audio-stream)` as primary 60fps path, HTTP `/audio` poll every 100ms as silent backup — SSE failure never breaks the page
- **Hardened polling**: `/current` every 100ms, `/audio` every 100ms, `/settings` every 500ms
- **OBS‑only mode**: Run `npm run obs` for just the HTTP server without the Electron UI
- Initial poll rate reduced from 80ms → 33ms for audio data relay

### Cover Art Layout Fix
- `.no-cover` CSS class keeps title, artist, and album centered when cover art is hidden:
  ```css
  #orb.no-cover #meta { justify-content: center; padding-top: 24px; }
  ```

### Settings
- Added Rainbow Mode (static / breathing / switching)
- Visualiser bar count now configurable (60–360)
- Configurable `visualizerSensitivity` (0.2× to 3.0×)

## v1.0.0 (Initial Release)

### Features
- **Spotify Auto-Authentication**: Silent token-based auth with auto-refresh
- **Token Persistence**: Saved tokens survive app restarts
- **Audio Visualizer**: Circular waveform around the orb UI
  - VoiceMeeter audio capture support
  - Fallback synthetic animation when no audio source
  - Sensitivity and bar count controls
- **Song Info Display**: Album art (circular), title (with glow), artist, album
- **Playback Progress**: Live time counter with progress bar
- **Volume-Based Opacity**: UI opacity scales with Spotify volume
- **Fade In/Out**: Auto-hides when playback stops, reappears on resume
- **System Tray**: Background operation with right-click menu
  - Show/Hide overlay
  - Settings window
  - Reconnect Spotify
  - Quit
- **Settings Window**: Full customization UI
  - Color pickers (primary, accent, background, secondary text)
  - Display toggles (cover, title, artist, album, progress, visualizer)
  - Audio source selection (Voicemeeter, default, custom)
  - Visualizer sensitivity and bar count sliders
  - Volume opacity and fade delay controls
- **OBS Browser Source**: Local HTTP server on port 3001
- **Single Instance Enforcement**: Prevents duplicate processes
- **Desktop Notifications**: Auth status updates (pending, success, error)
- **Clean Exit**: No hanging processes on quit

### Known Issues (v1.0.0)
- Audio capture requires VoiceMeeter (or compatible virtual audio device)
- Spotify redirect uses `http://127.0.0.1:8888/callback` (must be added to Spotify app)

### Setup Requirements
- Node.js 18+
- Spotify Developer App (free tier)
- VoiceMeeter (optional, for audio visualizer)
- OBS Studio (optional, for streaming)
