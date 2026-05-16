const { contextBridge, ipcRenderer } = require("electron");

contextBridge.exposeInMainWorld("spotify", {
  onUpdate: (cb) =>
    ipcRenderer.on("spotify-update", (_, data) => cb(data)),
  onSettingsChanged: (cb) =>
    ipcRenderer.on("settings-changed", (_, settings) => cb(settings))
});

contextBridge.exposeInMainWorld("electronAPI", {
  getSettings: () => ipcRenderer.invoke("get-settings"),
  saveSettings: (settings) => ipcRenderer.invoke("save-settings", settings),
  startAuth: () => ipcRenderer.invoke("start-auth"),
  disconnectSpotify: () => ipcRenderer.invoke("disconnect-spotify"),
  getVoicemeeterDevices: () => ipcRenderer.invoke("get-voicemeeter-devices"),
  getDesktopSources: () => ipcRenderer.invoke("get-desktop-sources"),
  getPlatform: () => process.platform,
  previewSettings: (partial) => ipcRenderer.invoke("preview-settings", partial),
  sendAudioData: (data) => ipcRenderer.send("audio-data", data),
  onSpotifyPlaying: (cb) => ipcRenderer.on("spotify-playing", (_, playing) => cb(playing)),
  uninstallVorb: (options) => ipcRenderer.invoke("uninstall-vorb", options),
  openUrl: (url) => ipcRenderer.send("open-url", url)
});
