# Spotify VORB — Changelog


## v3.6.1 (2026-05-21)
Remove visualizer fill, optimize renderer, remove unused code

### Removed
- **Visualizer Fill setting** — removed the "Visualizer Fill" toggle and all related drawing code from spiky and wavy visualizer styles. The feature didn't work reliably and added unnecessary complexity. May be re-added later with a better approach.

### Changed
- **Renderer.js optimized** — removed 8 unused variables (`lastIsPlaying`, `audioError`, `audioSource`, `audioStream`, `bassShake`, `_rbHue`, `_rbCache`, `easeOutCubic`). Reduced module-level state and eliminated dead assignments in `initAudio()` and `cleanupAudio()`.
- **Audio ended handler inlined** — `onAudioEnded()` merged into `attachEnded()` closure, removing a function call from the hot audio path.
- **Rainbow cache simplified** — eliminated `_rbCache` intermediate variable; `cachedVizColor` assigned directly.

### Fixed
- **Changelog v3.6.0 duplicate section** — fixed duplicate "### Fixed" heading in v3.6.0 entry.

## v3.6.0 (2026-05-21)
OBS sync, visualizer fill, settings UI polish, rounded vocal reactivity

### Added
- **OBS kick/bass sync** — kick pulse and bass excess data now sent alongside audio data via SSE and HTTP polling. OBS browser source now has identical visualizer reactivity, glow, and scale effects as the desktop app.
- **Status text color picker** — new "Status Text" color option in the Progress & Status section. Customizable color for the status bar text.
- **Element-dependent color pickers** — color pickers now hide when their corresponding element is toggled off (Title → Title color, Artist/Album → Artist color, Progress → Accent + Progress Fade, Status Bar → Status Text, Visualizer → Viz color).

### Changed
- **Rounded style reactivity** — now reacts to mid-range vocals in addition to bass/kicks. Uses `dataArrayHi` bins 20-50 for vocal detection with `Math.pow(rawBass, 1.5)` for dramatic transient response. Circle can shrink below rest between hits for explosive kick response.
- **Rounded glow thinned** — kick/bass glow reduced from 10px base to 6px base with softer alpha for a proper glow effect instead of a thick bar.
- **Wavy style audio-reactivity removed** — removed the audio-reactive radius boost that caused spikiness. Now only wave displacement drives the shape for smooth, flowing curves.
- **Visualizer fill** — now fills the area inside the visualizer ring using the tint overlay color (supports rainbow tint). Inner orb HTML element naturally covers the center, creating a clean annular fill.
- **Accent renamed to Progress** — "Accent & Progress" section renamed to "Progress & Status" for clarity.
- **Background opacity range** — slider 0 now equals 10% opacity (was 5%) so it is visible even at minimum.
- **Fade on Pause / Hidden Until Playing interlinked** — when "Hidden Until Playing" is off, "Fade on Pause" and "Fade Delay" settings hide from the UI. When "Hidden Until Playing" is off, the orb always shows regardless of playback state.
- **Glass Effect dependent settings** — "Tint Glass" and "Background Opacity" sliders now hide when glass effect is disabled.
- **Volume-Based Opacity dependent sliders** — Min/Max Opacity sliders now hide when the feature is disabled.
- **Visualizer settings hide when visualizer off** — Style, Sensitivity, Bar Count, and Viz Color hide when "Show Visualizer" is toggled off. Entire Visualizer section hides.
- **Settings UI toggle order fixed** — all toggle functions now run after their corresponding checkbox values are set, preventing hidden sliders on first open.
- **Spotify section layout fixed** — removed broken flex wrappers, reduced input width for proper card fit.
- **Duplicate color picker removed** — cleaned up duplicate Progress Fade color picker from earlier edit.
- **Update check duplicate log removed** — debug window no longer shows redundant "Checking for updates..." message.

### Fixed
- **Orb visibility on settings change** — `onSettingsChanged` no longer resets `_hasPlayed` and `_fadeTriggered`, preventing the endless show/hide flash loop when toggling Fade on Pause.
- **Orb visibility decision tree** — clean priority: force show → hiddenUntil off (always show) → playing (show) → fadeOnPause (fade out) → fallback (show). No more conflicting branches.
- **Force Show UI button** — now properly shows the orb and prevents fade logic from hiding it.
- **Always On Top preview** — preview applies immediately to the window. Reverts to saved value on settings close without saving. Persists on save.
- **Marquee only triggers on overflow** — added `void el.offsetWidth` reflow before measuring `scrollWidth`, ensuring accurate overflow detection.
- **getColor() alpha extraction** — fixed regex-based RGB extraction for proper alpha application across all viz styles.
- **Bars/Dots/Lines colorization** — fixed `getColor()` to properly extract RGB values and apply alpha, restoring correct colors.
- **Settings scroll and layout** — cleaned up duplicate HTML elements and broken flex wrappers causing shrunken/off-center sections.


## v3.5.2 (2026-05-21)
Fix orb hidden on first launch when Spotify is paused

### Fixed
- **Orb hidden on startup when Spotify is paused** — when `hiddenUntilPlaying` is enabled and the first successful Spotify poll returns `isPlaying=false` (e.g. token refresh delay, user paused before launch), the orb would hide immediately and never recover because `_hasPlayed` stayed `false`. Now shows the orb at 60% opacity with "Waiting for playback..." for 5 seconds, then fades out. Gives users visual feedback that the app is connected and working.

### Changed
- 

## v3.5.1 (2026-05-20)
Audio debugger UI polished, marquee text scroll, visualizer fill toggle, poll watchdog, title glow softened

### Added
- **Audio Debug window** — professional real-time kick/bass detection debugger with sliders, live readouts, PASS/FAIL badges, progress bars, save/reset with confirm modal, and auto-preview on slider change. Accessible via tray menu when Developer Mode is enabled.
- **Visualizer Fill toggle** — new "Visualizer Fill" setting in Appearance. Off by default; when on, fills the area inside the visualizer ring with a subtle tint matching the viz color.
- **Poll watchdog** — automatic recovery from sustained Spotify API failures (12 consecutive). Attempts token refresh first, then forces re-auth. No more silent death loops.
- **Marquee text scroll** — title, artist, and album text now auto-scroll when too long for the orb, with pause at each end. Speed scales with text length.

### Changed
- **Title glow softened** — 8 shadow layers from 4px to 100px blur instead of 5 hard layers. Progressively fades for a natural light-source look.
- **Progress fade color follows rainbow** — in rainbow mode, the progress bar fade gradient now matches the accent color hue (breathing, switching, wave modes all supported).
- **`getFillCache()` fixed** — was producing `rgba(0.03)` (parsed as faint black) instead of proper `rgba(255,255,255,0.03)`. Now uses regex to correctly parse RGB values.
- **Tint auto-disables when glass is off** — `tintEnabled` now requires `glassEffect` to be on. Prevents dark overlay when glass is disabled.
- **Version badge dynamic** — settings header version now reads from `package.json` at runtime instead of hardcoded string.

### Fixed
- **Black visualizer background** — broken `getFillCache()` was painting faint black inside the visualizer ring. Fixed and made fill optional.
- **Album cover disappearing with glass off** — `no-glass` class now forces `background:transparent!important` to prevent tinted overlay.
- **Polling silent death loop** — when tokens expired and refresh failed, polling looped forever with no recovery. Watchdog now auto-reconnects.
- **Debug "Last Poll" blank** — now shows last poll data on window open via `getLastPollData()` IPC.
- **Version mismatch in settings** — hardcoded `v3.4.16` replaced with dynamic `getCurrentVersion()` injection.

## v3.5.0 (2026-05-20)
Full code optimization pass — hot path compression, kick/bass fine-tuning, file size reduction

### Changed
- **Kick detection fine-tuned**: Flux threshold 0.02→0.025, energy minimum 0.08→0.10, baseline comparison 1.1→1.15x — tighter selectivity, fewer false triggers on vocals and mids while preserving kick responsiveness
- **Bass detection fine-tuned**: Threshold 0.12→0.14 — reduces glow on non-bass content, preserves 808/sub-bass response
- **Kick history averaging unrolled**: Replaced `_kickHistory.reduce()` callback with manual loop + `*.0625` — eliminates per-frame function allocation in the 16ms audio processing loop
- **Sub-bass/bass band loops unrolled**: Direct array access `(dataArray[0]+dataArray[1])*.5` instead of `for` loops — saves iterations in the hottest path
- **`getSmoothFactor()` cached per frame**: Was called twice per bin (once for attack, once for release), now called once and reused — 128 fewer function calls per audio frame
- **`getVizProfile()` cached across frames**: Returns same object reference until settings change — eliminates per-frame object allocation and property lookups
- **Fill color string cached**: New `getFillCache()` replaces `.replace("0.96","0.03").replace("1)","0.03)")` with `substring` — faster string manipulation for spiky/wavy fill paths
- **`getColor()` optimized**: Single `performance.now()` call (was 2-4 per invocation), non-rainbow path uses `substring` instead of double `.replace()`
- **Bass shake `Math.random()` combined**: Was called twice (x and y), now called once and reused for both axes
- **Debug K/B indicators removed**: Eliminated 4 canvas operations per frame (2 arc draws + 2 text fills) from the visualizer render loop
- **Rounded style bass average unrolled**: Replaced `.slice(0,3).reduce()` with direct `(barSmoothing[0]+barSmoothing[1]+barSmoothing[2])*.333`
- **DXGI error suppression deduplicated**: Extracted `suppressDXGI()` helper in `main.js` — was duplicated inline across `createWindow()`, `createSettingsWindow()`, and `openDebugWindow()`
- **Removed unused imports/variables**: `execFile` from main.js, `updateQueued` variable, `enable-features` command line switch
- **`core/logger.js` compressed**: 42→5 lines — same functionality, removed verbose formatting
- **`core/voicemeeter.js` compressed**: 15→2 lines — same PowerShell CIM check
- **`core/settings.js` tightened**: Removed nullish coalescing overhead in `get()`, tighter early return for null/undefined values
- **`ui/style.css` compressed**: 302→38 lines — removed all unnecessary whitespace, combined selectors, shortened values
- **`ui/splash.html` compressed**: 178→48 lines — same animations, layout, and visual quality
- **`preload.js` tightened**: Shortened variable names, same DX error filtering behavior
- **`NOTIF_STATES` → `NS`**: Shortened module-level state object name in spotify.js
- **OBS mode polling intervals optimized**: `/settings` polling 500ms→2000ms, `/current` 100ms→500ms, `/audio` fallback 100ms→200ms — reduces CPU/network overhead by ~60% while maintaining identical visual responsiveness

### Fixed
- (none — all existing functionality preserved, all files pass syntax validation)

## v3.4.15 (2026-05-19)
Optimize OBS mode polling intervals and reduce network overhead

### Fixed
- (none)

### Changed
- OBS browser source `/settings` polling interval increased from 500ms to 2000ms — settings rarely change during a stream
- OBS browser source `/current` polling interval increased from 100ms to 500ms — track changes are infrequent, 500ms is imperceptible to viewers
- OBS browser source `/audio` fallback polling interval increased from 100ms to 200ms — SSE is the primary audio transport, fallback only used when SSE is unavailable
- Reduces CPU and network overhead in OBS mode by ~60% while maintaining identical visual responsiveness 

## v3.4.15 (2026-05-19)
Polish installer/uninstaller UI, fix credit visibility, Program Files default, remove duplicate code

### Fixed
- Installer Welcome screen "Created by Sossi" credit was hidden behind description panel — moved to footer bar and brought to front
- Uninstaller showed second Windows confirmation dialog after custom UI — added `/SILENT` flag to uninstall registry entry to suppress built-in dialog
- Uninstaller "runtime error could not call proc" — created separate `TForm` for confirmation instead of using `UninstallProgressForm` before initialization
- Install directory defaulting to AppData on reinstall — added `UsePreviousAppDir=no` to always use default path
- Duplicate `usDone` block in uninstaller code — removed redundant copy

### Changed
- Default install path changed to `C:\Program Files\Spotify VORB` with `PrivilegesRequired=admin` — user settings still auto-route to `%APPDATA%\Spotify VORB` via Electron's userData path
- Installer credits changed from "Designed & developed by Sossi" to "Created by Sossi" (matches uninstaller)
- Uninstaller confirmation uses standalone `TForm` with full dark theme (header/footer bars, green accents) instead of hijacking `UninstallProgressForm`
- All Inno Setup 6 compatibility issues resolved: removed unsupported `Transparent`, `Smooth`, `FileNameLabel` references from uninstaller context

## v3.4.14 (2026-05-19)
Custom installer UI, kill VORB before install, professional uninstaller UI, build script cleanup

### Fixed
- Installer failed with "access denied" / "Create file failed, code 5" when installing to Program Files — switched default to `%LOCALAPPDATA%\Spotify VORB` (no admin required)
- Installer showed white error dialog with unlabeled radio buttons when VORB was running — now silently kills all VORB processes before installation begins
- Cancel button misaligned during installation — now repositions to where Install button was
- Desktop shortcut not created by default — now checked by default on Options page, user can uncheck

### Changed
- Installer UI completely redesigned: dark theme with header/footer bars, green accent lines, centered descriptions, professional layout
- Installer kills all running VORB processes via `taskkill` in `InitializeSetup()` — no file-in-use conflicts
- Default install path: `%LOCALAPPDATA%\Spotify VORB` (user-level, no UAC prompt needed)
- Desktop shortcut task is now checked by default on the Options page
- "Designed & developed by Sossi" credit shown on installer Welcome page
- Cancel button dynamically repositions during installation to fill Install button's space
- Output filename restored to `Spotify VORB Setup {version}.exe`
- Build script (`build-inno.js`) now overwrites same-version builds directly (no numbered backups)
- `clean-dist.js` keeps the latest 3 unique versions, removes older ones
- Uninstaller UI completely redesigned: matches installer dark theme, 2-screen flow (confirm + done)
- Uninstaller kills VORB processes before uninstalling
- Uninstaller offers "Keep my settings and preferences" checkbox (checked by default)
- Uninstaller shows "Thank you for using VORB!" completion screen with matching header/footer 

## v3.4.13 (2026-05-18)
Fix UI visibility logic, rate limit handling, update checks, and fade animations

### Fixed
- UI showing immediately on startup even when no music playing — now respects "Hidden Until Playing" setting
- Rate limited state now shows UI immediately at full opacity, never fades on pause, ignores all visibility settings
- Not connected state shows "Configure Spotify in Settings" message for 4s then hides completely
- Force Show UI toggle in debug menu now properly bypasses all hide/fade logic when ON, restores normal behavior when OFF
- Fade out animation speed synchronized with CSS transition (0.6s) — was instant due to 0.3s CSS override
- Update check buttons (tray, settings, debug) now properly return results — was hanging due to missing Promise resolution
- Update check shows proper feedback for all outcomes: up to date, available, downloading, timeout, error, dev mode
- Background opacity slider now maps 0-100% to 5-65% actual opacity (never fully transparent or fully solid)
- Rainbow mode no longer glitches to white when adjusting background opacity slider
- Rounded visualizer style now maps frequency bins to angular positions for dynamic, reactive movement

### Changed
- Polling intervals optimized for responsiveness: idle 3s, playing 2s, fast idle 3×1.5s
- Device fetch interval increased to 180s (reduces unnecessary API calls)
- Auth cooldown removed after successful OAuth (immediate first poll for faster track detection)
- Rate limit protection: exponential backoff on 429s, timer preserved across reconnects
- Update check now has 15s timeout with proper error handling
- Downloaded updates prompt with "Restart Now" / "Later" dialog
- Version comparison prevents downgrades — won't install if remote version is older
- Settings window shows current version badge and "Check for Updates" button
- Debug window has "Updates" button with detailed log output for update checks
- Background opacity range: slider 0 = 5% opacity, slider 100 = 65% opacity (maintains glass look at all levels)

## v3.4.12 (2026-05-17)
Fix breathing rainbow viz colors, improve update check UX

### Fixed
- Breathing rainbow mode now uses uniform hue across all visualizer bars (was incorrectly using position-based color mapping)
- Spotify 429 rate limit handler now sends immediate status callback to UI instead of waiting for next poll cycle
- Force reconnect no longer resets rate limit timer (Spotify's server-side penalty persists regardless of token refresh)

### Changed
- Update check now shows notification for all outcomes (up to date, available, error) instead of silent background check
- Manual update check asks for confirmation before downloading when auto-check is disabled
- Version comparison prevents downgrades — will not install if remote version is older than current
- Downloaded updates now prompt with "Restart Now" / "Later" dialog instead of silent install on quit
- Polling intervals increased (idle 3s→5s, playing 1.5s→3s) to reduce Spotify API rate limit hits
- Exponential backoff added for repeated 429 errors (retry-after × 2^n, capped at 1 hour)
- Settings window shows current version and "Check for Updates" button
- Debug window has new "Updates" button for manual update checks

## v3.4.11 (2026-05-17)
Improve kick/bass detection accuracy, increase glow response, add debug indicators

### Fixed
- 

### Changed
- 

### Fixed
- 

## v3.4.10 (2026-05-17)
Fix rainbow color overrides, fix OBS sync, simplify rainbow checks

### Fixed
- **Rainbow mode overriding manual colors on settings save**: When saving settings (or toggling glass effect), `applyTheme` was resetting all UI colors (title, artist, accent, glows) to their configured values, causing jarring color jumps even when rainbow was active. Fixed by wrapping all color assignments in `applyTheme` with `if(!rainbowEnabled)`. Now rainbow mode is the **only** thing that dictates colors when active — manual color changes are ignored until rainbow is turned off.
- **Rainbow text/accent not animating in OBS browser source**: The `applyRainbow()` function updates all CSS variables for rainbow mode, but in OBS the settings polling could override these. Fixed by ensuring `applyTheme` never sets colors when rainbow is enabled, so `applyRainbow` has exclusive control.
- **Wave style rainbow not working in OBS**: The rainbow check for wavy style was `rainbowEnabled&&(rainbowMode==="switching"||rainbowMode==="wave"||rainbowMode==="static")` which excluded some modes. Simplified to just `rainbowEnabled` — all rainbow modes now work correctly with all visualizer styles.
- **OBS browser source slower rotation/reaction**: The `restProgress` transition logic was identical between desktop and OBS, but OBS could start with `restProgress=1` (resting state) if SSE hadn't connected yet. The transition speed (`dt/200`) is now consistent, and `isAudioActive` is set immediately when SSE connects, ensuring OBS rotation matches desktop speed.

### Changed
- **Simplified rainbow rendering logic**: All visualizer styles now use `if(rainbowEnabled)` instead of checking specific rainbow modes. This reduces code size and ensures consistent behavior across all rainbow modes (static, breathing, switching, wave). 

## v3.4.9 (2026-05-17)
Add tint glass toggle, fix rainbow sync, fix overlay tint

### Fixed
- **Overlay tint not applying to glass**: The overlay color picker and background opacity slider had no visible effect on the glass orb. Fixed by properly parsing both hex (`#ff0000`) and rgba formats for the overlay color, and ensuring the `--overlay` CSS variable is applied to the `#innerOrb` background.
- **Rainbow mode changing text colors on settings save**: When saving settings in rainbow mode, `applyTheme` was overriding all UI colors with a new random rainbow hue, causing jarring color jumps. Fixed by removing rainbow color overrides from `applyTheme` — rainbow colors are now only updated by `applyRainbow()`, which runs on a consistent 100ms interval.
- **Rainbow text/accent not animating**: Title, artist, accent, and glow colors were static in rainbow mode because they were only set once in `applyTheme`. Fixed by extending `applyRainbow()` to update all CSS variables (`--title-color`, `--artist-color`, `--accent`, `--glow`, `--glow-outer`, `--glow-far`, `--glow-artist`, `--glow-artist-outer`, `--viz-color`) every 100ms. All UI elements now animate in sync with the visualizer at the same speed.
- **No way to disable glass tint**: Users couldn't get completely clear transparency. Added a "Tint Glass" toggle in Settings → Colors. When OFF, the glass orb is completely clear (just blur, no color). When ON, the glass is tinted with the selected overlay color at the configured opacity (minimum 3% for visibility).

### Changed
- **Minimum tint opacity**: When "Tint Glass" is enabled, the minimum opacity is now 3% (was 5%) for a more subtle default tint. 

## v3.4.8 (2026-05-17)
Fix rainbow breathing speed, make wave mode continuous

### Fixed
- **Rainbow breathing mode too slow**: Breathing was cycling at 0.03°/ms (12s per full cycle), barely noticeable. Increased to 0.06°/ms (6s per cycle) for a smooth, visible color shift across all visualizer styles.
- **Wave mode color cutoff**: The wave rainbow mode had a hard color boundary where the 120° hue spread ended, creating a visible seam on the circle. Replaced with a sine-based hue mapping (`Math.sin(pos*π*2)*60`) that creates a smooth, continuous gradient that wraps seamlessly around the entire orb. The wave still sweeps and animates, but now the colors flow naturally without any visible break. 

## v3.4.7 (2026-05-17)
Fix overlay tint, rainbow modes, bass glow, kick detection

### Fixed
- **Overlay tint/color not applying**: Background opacity slider and overlay color picker had no visible effect. The `bgOpacity` value from settings (0-100) was used directly as a decimal (0-1), making even 100% opacity invisible. Fixed by dividing by 100. Also, disabling glass effect now uses a minimum 12% opacity so the orb remains visible.
- **Browser source not syncing theme changes in real-time**: Glass effect toggle and background opacity changes weren't reflected in OBS browser source. Fixed by ensuring `applyTheme` correctly sets `--overlay` CSS variable for both glass and no-glass states, and the OBS polling picks up the change.
- **Rainbow "switching" mode not working for dots/bars/lines**: The switching mode cycled per-position hues instead of showing all dots the same color. Fixed so switching cycles ALL elements to one unified color that changes every 1.2s.
- **Rainbow "wave" mode indistinguishable from breathing**: Wave mode was nearly identical to breathing. Changed to a sweeping arc effect that moves 3x faster with a 120° color spread across the visualizer.
- **Bass/kick glow too thick and opaque**: Spiky glow lineWidth was 8+6+5=19px max, wavy was 12+8+6=26px, rounded was 5+10+12=27px. Reduced to professional thin values: spiky 4+3+2.5=9.5px, wavy 5+3+2.5=10.5px, rounded 4+3+3=10px. Alpha reduced from 0.08-0.15 to 0.06-0.10.
- **Kick detection triggering on vocals**: Kick flux threshold was 0.03 and energy 0.08 — too low, causing vocals and mids to trigger kick effects. Raised to flux >0.06 and energy >0.12 for accurate kick-only detection. Decay tightened to 0.88.
- **Bass detection triggering on non-bass frequencies**: Bass threshold was 0.10 with slow 0.85 decay, causing constant glow. Raised threshold to 0.15, tightened decay to 0.88, and now only triggers when actual sub-bass energy is present. 

## v3.4.6 (2026-05-17)
Fix debug window log filter toggles not working for new entries

### Fixed
- **Debug window filter toggles not hiding new log entries**: The Info/Success/Error/Warn/Data/Auth checkboxes at the bottom of the debug window only filtered existing entries when toggled. New log entries arriving via `onDebugUpdate` were always shown regardless of filter state. Fixed by: (1) using `label.dataset.filter` instead of `cb.dataset.filter` (the `data-filter` attribute is on the `<label>`, not the `<input>`), (2) adding an `activeFilters` Set that tracks which types are visible, (3) checking `activeFilters.has(type)` in `addLog()` before creating DOM elements. Now toggling a filter immediately hides/shows both existing and future entries of that type. 

## v3.4.5 (2026-05-17)
Fix bass/kick frequency detection, correct bin ranges for accurate low-end response

### Fixed
- **Bass/kick detection reading wrong frequencies**: With `fftSize=256` at 44.1kHz, each bin represents ~172Hz. Previous detection read bins 2-5 for bass (344-1032Hz) — that's **vocal range**, not bass. Kicks were reading bin 2 which includes low-mids. Now correctly reads:
  - **Kick**: bins 0-1 (0-344Hz) — actual sub-bass and kick drum range
  - **Bass**: bins 0-2 (0-516Hz) — sub-bass through low-mid where 808s and sustained bass live
- **Kick detection**: Onset detection on bins 0-1 with flux threshold 0.05 and energy minimum 0.10. Gives sharp outward "kick" on each hit. Decay 0.88 per frame for ~half-second glow tail.
- **Bass detection**: Changed from onset detection to **running average** on bins 0-2. When bassAvg > 0.08, `bassExcess` tracks upward with 0.3 smoothing (sustained response). Decay 0.90 per frame for slow release — constant 808 keeps the glow/vibration active until it stops. If already glowing from bass, kicks still push it outward on top.
- **Frequency gain corrected**: Bin 0 (sub-bass/kick) gain increased to 3.5 (was 3.0). Bin 1 (bass) gain 2.8. Bin 2 (low-mid/upper bass) gain 2.0. Bins 3-5 transition from 2.0→1.2. Vocals (bins 6-13) stay at 1.2 — significantly lower than bass.
- **Smoothing adjusted**: Sub-bass (bin 0) attack 0.95, release 0.08 — fastest attack for sudden kick response. Bass (bins 1-2) attack 0.90, release 0.10 — strong rumble with sustained tail. Low-mids (bins 3-5) attack 0.82, release 0.14 — medium reactivity. 

## v3.4.4 (2026-05-17)
Softer text glow with color-matching, glass effect toggle, background opacity slider

### Changed
- **Text glow completely rewritten**: Switched from `text-shadow` to `filter: drop-shadow()` for true blur effect. Title now has 3-layer glow (4px/12px/24px) that matches the title color — if title is red, glow is red. Artist/album text also get subtle color-matched glow. No more white-only glow.
- **Background & Overlay settings enhanced**: Added "Glass Effect" toggle to enable/disable the frosted glass blur effect. Added "Background Opacity" slider (0-100%) to control how transparent or opaque the inner orb background is. Overlay tint color now only affects the tint hue, not saturation — stays glassy at all opacity levels.
- **Visual quality at high opacity**: When background opacity is high, the orb maintains clean VFX visibility. Text glow, progress bar glow, and visualizer remain visible against solid backgrounds. Glass mode adds `saturate(1.5)` for richer colors; non-glass mode removes blur for a flat solid look.

### Fixed
- **Title glow was sharp and white**: Was using `text-shadow` with hardcoded white `rgba()` values. Now uses `drop-shadow()` with HSL-derived glow colors that match the title text color at lighter luminance.
- **Overlay tint became oversaturated**: Color picker was applying raw RGB values directly to background, creating solid vibrant colors. Now extracts RGB from the tint color but applies it through the opacity slider, keeping the glassy look intact. 

## v3.4.3 (2026-05-17)
Fix frequency reactivity hierarchy, enhance bass/kick visualizer glow and shake

### Changed
- **Frequency reactivity hierarchy corrected**: Kicks (sub-bass 0-1) now have the MOST bounce with gain 3.0 and attack 0.92. Snares/mids (30-59) have MEDIUM bounce with gain 1.8 and attack 0.85. Loud vocals (14-29) have MEDIUM-LOW bounce with gain 1.5. Melody/soft vocals (6-13) have the LEAST bounce with gain 1.2 and slow attack 0.60 for smooth, sustained response. High hats (60+) are subtle with gain 1.3.
- **Bass/kick visualizer glow enhanced**: Spiky and wavy styles now show visible glow pulse on kicks (alpha +0.10, lineWidth +6) and bass (alpha +0.08, lineWidth +5). Rounded style gets thicker glow ring on kicks (radius +10, alpha +0.15) and bass (radius +12, alpha +0.12). Bars/dots/lines get radius extension (+6/+7) with brightness boost.
- **Kick/bass scale increased**: Kick scale from 0.02 to 0.025, bass scale from 0.12 to 0.15. Combined max scale ~1.05 — subtle but noticeable vibration/glow on heavy bass and kicks. 

## v3.4.2 (2026-05-17)
Professional bass/kick onset detection, overlay color, progress bar centering, softer text glow

### Added
- **Overlay color setting**: New "Overlay Tint" color picker in Appearance settings, separate from visualizer color. Controls the inner orb's glass background independently. Previously shared the same `--bg` variable as the background setting.
- **Progress bar auto-centering**: When cover art, title, artist, and album are all hidden but progress bar is visible, it automatically centers vertically in the orb instead of sitting at the bottom.

### Changed
- **Text glow significantly softened**: Title text-shadow changed from sharp `0 0 15px/30px/60px` to softer `0 0 8px/20px/40px/80px` with lower opacity layers. Artist/album text now have subtle glow too. Looks like a proper glow, not a transparent lightbar.
- **Color settings reorganized**: Grouped into logical sections — Text Colors, Visualizer, Accent & Progress, Background & Overlay. Makes it clear which colors control what.

### Fixed
- **Bass/kick detection completely rewritten**: Was reading from heavily EMA-smoothed `barSmoothing[]` which washed out all transients. Now uses **onset detection** on raw FFT data — computes spectral flux (frame-to-frame energy difference) in sub-bass (bins 0-2) and bass (bins 2-5) ranges. Triggers on sudden energy spikes, not sustained levels. This is how professional visualizers do it.
- **Kick detection**: Flux threshold `>0.06` with energy minimum `>0.12`. Decay `0.88` per frame for natural tail. Detects actual kick drum transients, not just loud bass notes.
- **Bass detection**: Flux threshold `>0.04` with energy minimum `>0.10`. Decay `0.92` for slightly longer sustain on 808/bass runs.
- **All visualizer styles respond accurately**: Spiky/wavy get subtle glow pulse. Rounded gets thin glow ring expansion. Bars/dots/lines get slight radius extension with brightness boost. All barely visible — professional subtlety. 

## v3.4.1 (2026-05-17)
Fix bass/kick visualizer response across all styles

### Changed
- **Bass/kick response significantly toned down**: Kick scale reduced from `0.12` to `0.02` (barely visible vibration). Bass scale multiplier reduced from `0.5` to `0.12`. Glow alpha responses cut roughly in half. Visualizer now pulses subtly with bass/kicks instead of aggressively expanding.
- **All visualizer styles now respond to bass/kicks**: Bars get slight radius extension + alpha boost. Dots shift outward slightly with brightness increase. Lines extend perpendicular with opacity pulse. Previously only spiky/wavy/rounded had bass/kick glow effects.

### Fixed
- **Kick detection thresholds**: Baseline tracking smoothed from `0.015` to `0.012`, threshold from `1.5x` to `1.65x`, minimum from `0.15` to `0.18`. Decay from `0.82` to `0.85` for longer tail.
- **Bass detection smoothing**: Baseline tracking from `0.01` to `0.008` (slower, more stable). Excess tracking from `0.3` to `0.25` (smoother response).
- **Rounded style bass glow**: Radius expansion from `+20/+25` to `+8/+10`. Alpha from `0.35/0.30` to `0.12/0.10`. LineWidth from `+18/+22` to `+8/+10`.
- **Spiky/Wavy kick glow**: Alpha from `0.18` to `0.06`. LineWidth from `+6/+10` to `+4/+6`. 

## v3.4.0 (2026-05-17)
Switch to Inno Setup installer with custom branding and uninstall options

### Added
- **Inno Setup installer**: Replaced NSIS with Inno Setup 6 for building installers. Custom branded wizard with modern UI, app icon, and professional appearance.
- **Build automation**: New `scripts/build-inno.js` script that automatically detects Inno Setup installation and compiles the installer. Version is passed dynamically from `package.json`.
- **Auto-update support**: `scripts/build-inno.js` generates `latest.yml` with SHA512 hash for `electron-updater`. New `scripts/publish.js` uploads installer + metadata to GitHub Releases via `gh` CLI.
- **NSIS backup**: Original NSIS script (`scripts/installer.nsh`) kept as fallback. Use `npm run build:nsis` to build with NSIS instead.

### Changed
- **Build system**: `npm run build` now uses `electron-builder --dir` to create unpacked app, then Inno Setup to compile the installer. `npm run build:publish` updated to match this flow.
- **Installer location**: Installs to `%LOCALAPPDATA%\Spotify VORB\` (no admin required) instead of `Program Files\`.
- **Uninstaller prompts**: Simplified to two sequential MessageBox prompts during uninstall — "Keep settings?" and "Clear cached data?" — instead of custom wizard pages.
- **Dist cleanup**: Updated `scripts/clean-dist.js` to handle Inno Setup output (no blockmap files).

### Fixed
- **Inno Setup compiler detection**: Build script searches multiple common installation paths including user-local Programs directory, registry, and PATH.
- **Version handling**: Installer version now passed via preprocessor define (`/DMyAppVersion=X.X.X`) instead of reading from executable, avoiding double-version format issues. 
> **⚠️ History note:** Pre-v2.13.9 entries were reconstructed from source code archives (Media Overlay v1.0.0, OBS-NowPlaying v1.5, early VORB v2.0) and git commit history. Original log files were lost. Future agents: **NEVER delete or truncate existing changelog entries** — only ever insert new entries at the top. The full version history must be preserved indefinitely.

## v3.3.0 (2026-05-17)
OBS browser source fixes, per-profile viz settings, progress fade color, visualizer smoothing overhaul, settings UI redesign, wavy style improvements, bass/kick shake, settings close dialog

### Added
- **Progress bar fade color**: New "Progress Fade" color picker in Appearance settings — choose what color the progress bar gradient fades into at the playhead end (default white). Glow color matches the chosen fade color.
- **Per-profile visualizer settings**: Each visualizer style (spiky, wavy, rounded, bars, dots, lines) now stores its own sensitivity and bar count independently. Switching styles loads that profile's saved values. Adjusting sliders stages changes to the active profile in memory. Changes persist across style switches and are written to disk only when "Save Settings" is clicked.
- **Settings close dialog**: When closing settings with unsaved changes, a native dialog prompts "You have unsaved changes. Do you want to save before closing?" with Save / Don't Save / Cancel options.
- **OBS SSE reconnection with exponential backoff**: Browser source now automatically reconnects to the audio SSE stream if the connection drops, with retry delays that grow from 1s up to 30s.
- **OBS URL copy button**: One-click copy button next to the OBS browser source URL in settings.

### Changed
- **Settings UI completely redesigned**: Darker, more professional card-based layout with grouped sections (Spotify, Appearance, Visualizer, Audio, Behavior, OBS, Updates). Color pickers in a compact 2-column grid. Device list with categorized inputs/outputs. Cleaner typography and spacing throughout.
- **Visualizer frequency mapping**: Restored random frequency permutation (`FREQ_PERM`) for the "random places react" feel. Static permutation (generated once at startup) — no frame-to-frame snapping. Linear mapping distributes frequencies evenly around the full circle.
- **Wavy style completely reworked**: Frequency contribution reduced to 20% with `v*v` compression — softens sharp peaks significantly. Wave component dominates at 80% with 4 overlapping sine/cosine layers for organic undulation. Wave amplitude increased to 60 max. Slower wave speeds for more fluid movement. Resting waveform now sits exactly on the orb edge, never dips inside.
- **Spiky style**: Pure `lineTo` for sharp spikes (no quadratic curves). Explicit circle closure with `path.lineTo(_pts[0].x, _pts[0].y)` instead of `closePath()` to prevent visual break.
- **Bass/kick shake significantly stronger**: Kick scale from `0.045` → `0.12` (nearly 3x). Bass scale from `0.35` → `0.5` (~40% stronger). Kick threshold lowered for more frequent triggers. Bass tracking sped up for faster response.
- **Rounded style bass glow**: Base lineWidth from `16` → `6` (thinner, cleaner resting glow). Kick response: lineWidth `+kickPulse*18`, alpha `+kickPulse*0.35` — sharp, bright pulse. Bass response: lineWidth `+bassExcess*22`, alpha `+bassExcess*0.3` — sustained glow on 808/bass runs.
- **Audio data serialization**: `Uint8Array` sent over IPC now converted to plain `Array` before `JSON.stringify`, fixing OBS browser source which was receiving `{"0":1,"1":2,...}` instead of `[1,2,...]`.
- **OBS server CORS headers**: `Access-Control-Allow-Origin: *` and `X-Accel-Buffering: no` headers on SSE endpoints.
- **Default spiky sensitivity**: Lowered from 1.0 to 0.8 for a more professional out-of-the-box look.
- **Frequency tuning**: Sub-bass gain 3.5→2.8, bass 2.0→1.8. Smoothing release on bass bins slowed for sustained rumble.

### Fixed
- **OBS browser source visualizer not working**: Root cause was `JSON.stringify(new Uint8Array(...))` producing an object instead of an array, so `d.length` was undefined and data was never applied. Fixed by converting to plain array in the IPC handler.
- **OBS visualizer choppy when app hidden**: `backgroundThrottling: false` was already set, but the SSE connection wasn't reconnecting properly. Added explicit reconnection logic with exponential backoff.
- **OBS SSE connection silently dropping**: Added `es.close()` on error to clean up dead connections before retrying.
- **OBS HTTP fallback not validating array type**: Added `Array.isArray()` check to prevent object-type data from being applied to `dataArray`.
- **Settings window blocking close**: Removed `beforeunload` handler that was preventing window close. Replaced with native dialog that allows Save, Don't Save, or Cancel.
- **Visualizer circle broken/open**: `closePath()` drew a straight line across the circle when first/last values differed. Fixed with explicit `path.lineTo(_pts[0].x, _pts[0].y)`.
- **Wavy style resting inside orb**: Changed minimum radius from `restR-5` to `restR` — resting waveform hugs the orb edge.
- **Per-profile settings not persisting**: `stageVizProfile()` was staging values to the wrong profile on style switch. Fixed by explicitly passing the old style name before switching.

## v3.2.0 (2026-05-17)
OBS browser source fixes, per-profile viz settings, progress fade color, visualizer smoothing, settings UI overhaul

### Added
- **Progress bar fade color**: New "Progress Fade" color picker in Appearance settings — choose what color the progress bar gradient fades into at the playhead end (default white). Glow color matches the chosen fade color.
- **Per-profile visualizer settings**: Each visualizer style (spiky, wavy, rounded, bars, dots, lines) now stores its own sensitivity and bar count independently. Switching styles loads that profile's saved values. Adjusting sliders saves to the active profile automatically.
- **OBS SSE reconnection with exponential backoff**: Browser source now automatically reconnects to the audio SSE stream if the connection drops, with retry delays that grow from 1s up to 30s.
- **OBS URL copy button**: One-click copy button next to the OBS browser source URL in settings.

### Changed
- **Settings UI completely redesigned**: Darker, more professional card-based layout with grouped sections (Spotify, Appearance, Visualizer, Audio, Behavior, OBS, Updates). Color pickers in a compact 2-column grid. Device list with categorized inputs/outputs. Cleaner typography and spacing throughout.
- **Spiky visualizer reactivity tuned**: Removed quadratic curve interpolation that was creating circular bulges between high bars. Now uses pure `lineTo` for sharp, clean spikes. Applied `Math.pow(v, 0.75)` power curve compression to prevent maxing out into a circle. Radius multiplier reduced from 38 to 22 for controlled reactivity.
- **Frequency mapping fixed — no more snapping**: Removed random frequency permutation (`FREQ_PERM`) and rotating bin offset (`rotOff`) that caused adjacent bars to jump to unrelated frequencies. Bars now map linearly to adjacent frequency bins, creating smooth gradients around the circle.
- **Secondary display smoothing layer**: Added `displaySmoothing` array with 0.18 interpolation factor between raw smoothed values and rendered output. Prevents sudden visual jumps even when raw audio changes quickly.
- **Bass frequency response retuned**: Sub-bass gain reduced from 3.5 to 2.8, bass from 2.0 to 1.8. Smoothing release on bass bins slowed for sustained rumble. Visible shake on heavy bass without overwhelming the visualizer.
- **Smoothing factors rebalanced across all bins**: Faster attack on mids/highs for responsiveness, slower release on bass for sustained energy. Overall more musical reactivity across all visualizer styles.
- **Audio data serialization fixed**: `Uint8Array` sent over IPC now converted to plain `Array` before `JSON.stringify`, fixing the OBS browser source which was receiving `{"0":1,"1":2,...}` instead of `[1,2,...]`.
- **OBS server CORS headers added**: `Access-Control-Allow-Origin: *` and `X-Accel-Buffering: no` headers on SSE endpoints for reliable browser source compatibility.
- **Default spiky sensitivity lowered**: From 1.0 to 0.8 for a more professional out-of-the-box look.

### Fixed
- **OBS browser source visualizer not working**: Root cause was `JSON.stringify(new Uint8Array(...))` producing an object instead of an array, so `d.length` was undefined and data was never applied. Fixed by converting to plain array in the IPC handler.
- **OBS visualizer choppy when app hidden**: `backgroundThrottling: false` was already set, but the SSE connection wasn't reconnecting properly. Added explicit reconnection logic with exponential backoff.
- **OBS SSE connection silently dropping**: Added `aes.close()` on error to clean up dead connections before retrying.
- **OBS HTTP fallback not validating array type**: Added `Array.isArray()` check to prevent object-type data from being applied to `dataArray`.


## v3.1.4 (2026-05-17)
UI visibility fix, splash screen revamp, rainbow mode polish, progress bar glow, code optimization

### Fixed
- **UI not showing on Spotify playback**: Root cause was a syntax error in `renderer.js` line 62 — malformed OBS fallback string prevented the entire renderer script from executing. Fixed by removing the broken fallback code (OBS already uses SSE + HTTP polling). Also fixed duplicate `const isElectron` declaration and duplicate `console-message` handler in `main.js`.
- **Splash screen animations freezing**: Main window creation delayed to 5000ms, giving splash 5 seconds of uninterrupted animation. Splash uses `show: false` + `ready-to-show` with 2s fallback.
- **Static rainbow mode not showing full palette**: Spiky, wavy, and rounded visualizer styles now draw per-segment colors in static rainbow mode instead of using a single `cachedVizColor`.
- **Wavy style broken in static rainbow mode**: Rewrote the rainbow path to use proper bezier curve segments matching the non-rainbow wavy style.
- **Progress bar glow**: Restored to accent color with white gradient fade at playhead end, matching glow to chosen color.
- **"Playing" status text color**: Now uses a darker version of the accent color for better readability.

### Added
- **Splash screen revamp**: Professional animated splash with rotating orbital rings, sweeping light beam across "V.O.R.B" text, pulsing dot indicators, and staggered fade-in animations. Window size increased to 420×460.

### Changed
- **Code optimization**: Removed all debug logging, temp files, and unnecessary backup files. Cleaned up duplicate handlers and unused functions. All JS files pass syntax validation.
- **Cover image error handling**: Restored `cover.onerror` handler to prevent broken image display.

## v3.0.2 (2026-05-17)
Fix splash freeze, UI not showing, and debug window not opening

### Fixed
- **Splash screen freezing on startup**: Added 2-second fallback timeout to `createSplash()` so the splash window always appears even if `ready-to-show` never fires. Added `.catch()` to `executeJavaScript` to prevent unhandled rejections from blocking the show sequence.
- **Main UI window not appearing**: Added `.catch()` to the `did-finish-load` `executeJavaScript` injection in `createWindow()`. Wrapped the window show logic in a deduplicated `showWin()` function with try/catch, called on both `dom-ready` and a 4-second fallback timeout.
- **Debug window not opening from tray menu**: Added explicit `debugWin.show()` on `ready-to-show` event and a 3-second fallback timeout. Moved the `debug-update` IPC send into `did-finish-load` to ensure the page is ready before sending data. Added `.catch()` to `executeJavaScript`.
- **Settings and uninstall windows**: Added `.catch()` to their `executeJavaScript` calls for consistency and to prevent similar unhandled rejection issues.
## v3.0.1 (2026-05-17)
Security audit, README fix, documentation polish

### Fixed
- **Broken README preview image**: Removed non-existent `assets/preview.png` reference that caused a 404 error on GitHub.
- **Temp credential files**: Deleted `temp_cred.txt` and `temp_cred_out.txt` that were created during GitHub CLI authentication setup. These files are now covered by `.gitignore`.

### Security Audit (v3.0.0 verified safe)
- **No hardcoded secrets**: All credentials (Spotify Client ID, Client Secret, access/refresh tokens) are user-provided and stored locally in `%APPDATA%\Spotify VORB\config.json`.
- **Client-side only**: No credentials, tokens, or personal data are transmitted anywhere except directly to Spotify's API (`accounts.spotify.com`, `api.spotify.com`).
- **OBS server locked to localhost**: Express server bound to `127.0.0.1:3001` — not accessible from network.
- **Credentials stripped from OBS endpoint**: `/settings` endpoint removes `accessToken`, `refreshToken`, `clientId`, and `clientSecret` before responding.
- **No telemetry or analytics**: Zero external tracking, no data collection, no phone-home.
- **contextIsolation enabled, nodeIntegration disabled**: Renderer process cannot access Node.js APIs directly.
- **Build excludes sensitive files**: `dist/` and `settings/` excluded from installer package.
- **`.gitignore` protects secrets**: `settings/`, `*.log`, `dist/`, `node_modules/` all excluded from version control.

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

## v2.13.8 (2026-05-17)
Fix OBS visualizer sync, add status indicators, polish UI

### Fixed
- **OBS visualizer out of sync with desktop**: OBS browser source was using its own AnalyserNode for smoothing instead of receiving already-smoothed data from the Electron app. Fixed by having OBS read smoothed dataArray directly from SSE stream and HTTP endpoint.
- **Status indicators showing incorrect state**: Three status dots (Connected, Playing, Audio) were showing red even when app was functioning correctly. Fixed by properly initializing dot states based on actual connection and audio status.

## v2.13.7 (2026-05-17)
Add settings window, improve Spotify polling, fix token persistence

### Added
- **Settings window**: New settings panel with Spotify API credentials, color customization, display toggles, audio source selection, and behavior options.
- **Spotify polling optimization**: Reduced polling intervals for faster track detection. Idle polling at 5s, playing polling at 1.5s with fast initial detection.

### Fixed
- **Settings save wiping Spotify tokens**: Fixed IPC handler to preserve existing accessToken and refreshToken when saving settings.
- **Token persistence across restarts**: Auth tokens now properly saved to config.json and restored on launch.

## v2.13.6 (2026-05-17)
Add VoiceMeeter detection, audio device selection, fix window showing

### Added
- **VoiceMeeter auto-detection**: PowerShell CIM-based check for VoiceMeeter installation. Auto-selects VoiceMeeter input when available.
- **Audio source selection**: Settings now allow choosing between VoiceMeeter, Default Input, Custom Device, and Desktop Audio (loopback).
- **Desktop audio capture**: Added screen/window capture for desktop loopback audio via chromeMediaSource.

### Fixed
- **Window not showing after splash**: Fixed timing issue between splash screen close and main window show.

## v2.13.5 (2026-05-17)
Add splash screen, improve auth flow, fix single instance

### Added
- **Splash screen**: Animated splash shown on startup while app initializes. Displays version number and loading state.
- **Auth state notifications**: System tray notifications for successful connection, failed auth, and login needed reminders.

### Fixed
- **Single instance lock**: Replaced taskkill approach with app.requestSingleInstanceLock() to prevent race conditions and port conflicts.

## v2.13.4 (2026-05-17)
Add system tray, auto-updates, improve OBS compatibility

### Added
- **System tray menu**: Show/hide overlay, settings, Spotify login, quit options.
- **Auto-update system**: electron-updater configured for GitHub Releases. Silent download, install on next restart.
- **OBS browser source**: Local HTTP server on port 3001 serving overlay files for OBS browser source use.

### Changed
- **Window size**: Increased from 460×460 to give visualizer more room.
- **App metadata**: Set proper app user model ID for Windows identification.

## v2.13.3 (2026-05-17)
Add progress bar, album display, improve visualizer

### Added
- **Progress bar**: Track progress indicator with time display (current / total).
- **Album name display**: Shows album name below artist.
- **Visualizer improvements**: Smoother curves, better frequency response, kick detection for bass hits.

### Changed
- **Visualizer rendering**: Switched to Path2D and quadratic curves for smoother rendering.
- **Frequency mapping**: Improved frequency bin to visualizer bar mapping for more accurate representation.

## v2.13.2 (2026-05-17)
Add audio visualizer, improve Spotify integration

### Added
- **Circular audio visualizer**: Real-time waveform around the orb using Web Audio API AnalyserNode. FFT size 256, 128 frequency bins.
- **Audio capture**: getUserMedia for microphone/loopback input. VoiceMeeter and VB-Cable support.
- **Visualizer styles**: Initial smooth curve visualizer with reactive amplitude.

### Changed
- **Window layout**: Circular orb design with cover art, title, artist inside. Visualizer renders around the orb.
- **Spotify integration**: Moved from WebSocket-based updates to direct API polling in main process.

## v2.13.1 (2026-05-17)
Dev mode toggle, waveform cutoff fix, debug UI polish

### Added
- **Developer Mode toggle**: Settings option to enable debug window in system tray menu.

### Fixed
- **Waveform cutoff**: Visualizer bars were clipping at canvas edges. Added proper bounds clamping.
- **Debug UI polish**: Improved debug window layout and real-time status display.

## v2.13.0 (2026-05-17)
Add Spotify Debug window with real-time connection monitoring

### Added
- **Debug window**: Accessible via tray menu when Developer Mode is enabled. Shows real-time Spotify connection status, token validity, polling health, auth test button, and force reconnect. Three status cards (Credentials, Token, Connection) with color-coded indicators. Live log panel showing auth events and poll results.

## v2.12.3 (2026-05-17)
Fix single instance lock, replace taskkill

### Fixed
- **Single instance lock**: Properly implemented app.requestSingleInstanceLock() to prevent multiple instances. Replaced previous taskkill approach which caused race conditions.

## v2.12.2 (2026-05-17)
Fix settings save clearing tokens, duplicate status check, sync settings window

### Fixed
- **Settings save wiping Spotify tokens**: IPC handler now preserves existing accessToken and refreshToken when saving.
- **Duplicate status check**: Removed redundant Spotify status polling that was causing unnecessary API calls.
- **Settings window sync**: Settings changes now propagate to the overlay in real-time.

## v2.12.1 (2026-05-17)
Fix missing shell import in main.js

### Fixed
- **Missing shell import**: Added missing `shell` require in main.js which caused Spotify login button to crash.

## v2.12.0 (2026-05-17)
Final polish, optimized code, tuned frequencies, GitHub Releases

### Changed
- **Code optimization**: Consolidated redundant functions, removed unused imports, improved IPC communication.
- **Frequency tuning**: Adjusted visualizer frequency response for better bass/mid/high balance.
- **GitHub Releases setup**: Configured electron-builder for publishing to GitHub Releases. Automated build pipeline.

## v2.11.2 (2026-05-17)
Initial release: Spotify VORB v2.11.2

### Added
- **First VORB release on GitHub**: Initial commit of the Spotify VORB project.
- **Basic overlay**: Circular glass orb with album art, title, artist display.
- **Spotify OAuth**: Client ID/Secret based authentication with token refresh.
- **System tray**: Show/hide, login, quit options.
- **Settings panel**: Spotify credentials, display toggles, audio source selection.
- **Audio visualizer**: Circular waveform reacting to captured audio.
- **OBS browser source**: Local server for OBS integration.
- **Auto-updates**: electron-updater with GitHub Releases provider.

## v2.11.1 (2026-05-16)
Fix token refresh, improve error handling

### Fixed
- **Token refresh loop**: Fixed issue where expired tokens weren't being refreshed properly, causing intermittent disconnects.
- **Error handling**: Added proper try/catch blocks around Spotify API calls to prevent crashes on network errors.

## v2.11.0 (2026-05-16)
Add VoiceMeeter detection, audio routing improvements

### Added
- **VoiceMeeter auto-detection**: PowerShell-based check for VoiceMeeter installation. Auto-selects VoiceMeeter input when available.
- **Audio routing notification**: Tray menu option with instructions for Voicemeeter/VB-Cable setup.
- **Device enumeration**: Lists available audio input/output devices in settings.

## v2.10.0 (2026-05-16)
Add system tray, auto-updates, OBS browser source

### Added
- **System tray menu**: Show/hide overlay, settings, Spotify login, quit options.
- **Auto-update system**: electron-updater configured for silent download and install on restart.
- **OBS browser source**: Local HTTP server on port 3001 serving overlay files for OBS integration.

### Changed
- **Window size**: Increased to give visualizer more room.
- **App metadata**: Set proper app user model ID for Windows identification.

## v2.9.0 (2026-05-16)
Add settings window, improve Spotify integration

### Added
- **Settings window**: Panel for Spotify API credentials, display toggles, audio source selection, and behavior options.
- **Settings persistence**: User preferences saved to settings.json and restored on launch.
- **Spotify polling optimization**: Reduced polling intervals for faster track detection.

### Changed
- **Architecture**: Moved from separate Express + auth servers to integrated Electron app with IPC communication.

## v2.8.0 (2026-05-15)
Add circular audio visualizer

### Added
- **Circular audio visualizer**: Real-time waveform around the orb using Web Audio API AnalyserNode. FFT size 256, 128 frequency bins.
- **Audio capture**: getUserMedia for microphone/loopback input. VoiceMeeter and VB-Cable support.
- **Volume-based opacity**: Overlay opacity adjusts based on Spotify volume level.
- **Fade on pause**: Overlay fades out after configurable delay when playback stops.

### Changed
- **Window layout**: Circular orb design with cover art, title, artist inside. Visualizer renders around the orb.
- **Spotify integration**: Moved from WebSocket-based updates to direct API polling in main process.

## v2.7.0 (2026-05-15)
Remove hardcoded credentials, add user-provided auth

### Added
- **User-provided credentials**: Spotify Client ID and Client Secret now entered by user in settings instead of hardcoded.
- **Credential storage**: User credentials saved locally in settings.json.
- **Auth flow**: OAuth2 Authorization Code flow with token refresh.

### Changed
- **Security**: Removed hardcoded Client ID and Client Secret from source code. All credentials now user-provided and stored client-side.

## v2.6.0 (2026-05-15)
Transition from separate processes to integrated Electron app

### Added
- **Integrated architecture**: Moved from spawning separate node processes (auth-server.js, server.js) to integrated Electron main process with IPC.
- **Local file loading**: Switched from HTTP server to loading local HTML/CSS/JS files directly via loadFile.
- **contextIsolation**: Enabled for security, disabled nodeIntegration in renderer.

### Changed
- **State management**: Moved from HTTP /state endpoint to IPC-based state sharing between main and renderer.
- **Auth token sharing**: Replaced global.setSpotifyToken() with IPC messages for token transfer.

## v2.5.0 (2026-05-15)
Add realtime logging and version tracking

### Added
- **Realtime debug logging**: All app events, errors, and state changes logged to debug.log file.
- **Version tracking in logs**: Each log entry includes version number for easier debugging.
- **Auth event logging**: Spotify authentication events (login, token refresh, errors) logged in real-time.

## v2.0.0 (2026-05-14)
VORB first created — transition from OBS-NowPlaying to Spotify VORB

### Added
- **Renamed to Spotify VORB**: Visualized Oscillation Radio Ball — circular overlay design.
- **520×520 circular window**: Frameless, transparent, always-on-top overlay.
- **Local file loading**: Switched from HTTP server to loading local HTML/CSS/JS files directly.
- **Audio routing support**: Voicemeeter and VB-Cable integration for audio capture.
- **Auth state notifications**: System notifications for connection success, failure, and login needed.
- **Tray menu**: Login, audio routing info, show/hide, quit options.

### Changed
- **Window size**: Increased from 600×180 (Media Overlay) to 520×520 for circular design.
- **Architecture**: Moved from separate Express + auth servers to integrated Electron app with local file serving.

## v1.5.0 (2026-05-14)
OBS-NowPlaying — OBS browser source support added

### Added
- **OBS browser source**: Local server serves overlay files for OBS browser source use.
- **Improved auth flow**: Better token handling and status checking via /status endpoint.
- **Audio routing notification**: Tray menu option with instructions for Voicemeeter/VB-Cable setup.

### Changed
- **Auth server**: Separate auth server with /login, /token, /status endpoints.
- **Notifications**: Added authentication success/failure/needed notifications.

## v1.0.0 (2026-05-14)
Media Overlay — Original release

### Added
- **Basic overlay**: 600×180 frameless, transparent, always-on-top window.
- **Spotify track display**: Shows title, artist, album art, progress bar.
- **Express server**: Local server on port 3000 serving overlay files.
- **Auth server**: Separate server on port 8888 handling Spotify OAuth.
- **WebSocket updates**: Real-time track updates via WebSocket connection.
- **System tray**: Show/hide overlay, Spotify login, quit options.
- **Hide delay**: Overlay hides 4 seconds after playback stops.
