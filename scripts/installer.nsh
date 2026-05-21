; Spotify VORB — NSIS Installer Customization
; Works with electron-builder's NSIS template

!macro customInit
  ; Check if already installed
  ReadRegStr $0 SHCTX "Software\Spotify VORB" "InstallDir"
  ${If} $0 != ""
    MessageBox MB_YESNO|MB_ICONQUESTION "Spotify VORB is already installed.$\r$\n$\r$\nWould you like to reinstall/upgrade?" IDYES continue IDNO quit
    continue:
    quit:
      Abort
  ${EndIf}
!macroend

!macro customInstall
  ; Write registry for Add/Remove Programs
  WriteRegStr SHCTX "Software\Spotify VORB" "InstallDir" "$INSTDIR"
  WriteRegStr SHCTX "Software\Spotify VORB" "Version" "${VERSION}"
!macroend

!macro customUnInstall
  ; Kill running processes before uninstall
  nsExec::Exec 'taskkill /F /IM "Spotify VORB.exe" /T'
  Sleep 500

  ; Remove shortcuts
  Delete "$DESKTOP\Spotify VORB.lnk"
  Delete "$SMPROGRAMS\Spotify VORB\Spotify VORB.lnk"
  Delete "$SMPROGRAMS\Spotify VORB\Uninstall.lnk"
  RMDir "$SMPROGRAMS\Spotify VORB"

  ; Remove auto-start registry if present
  DeleteRegValue SHCTX "Software\Microsoft\Windows\CurrentVersion\Run" "Spotify VORB"

  ; Ask about settings
  MessageBox MB_YESNO|MB_ICONQUESTION "Do you want to keep your settings and preferences?$\r$\n$\r$\n(Recommended if you plan to reinstall)" IDYES keepSettings IDNO removeSettings
  keepSettings:
    Delete "$APPDATA\Spotify VORB\*.log"
    Delete "$APPDATA\Spotify VORB\*.tmp"
    Goto askCache
  removeSettings:
    RMDir /r "$APPDATA\Spotify VORB"
  askCache:
    MessageBox MB_YESNO|MB_ICONQUESTION "Clear cached data (album art, temp files)?$\r$\n$\r$\nThis will free up disk space but art will re-download on next launch." IDYES clearCache IDNO done
    clearCache:
      RMDir /r "$LOCALAPPDATA\spotify-vorb-updater"
      RMDir /r "$APPDATA\Spotify VORB\Cache"
      RMDir /r "$APPDATA\Spotify VORB\GPUCache"
  done:

  ; Remove registry entries (always)
  DeleteRegKey SHCTX "Software\Spotify VORB"
!macroend

!macro customInstallMode
  ; Force per-machine install
  SetShellVarContext all
!macroend
