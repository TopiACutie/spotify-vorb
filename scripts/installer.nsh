; Spotify VORB — NSIS Installer Customization
; Works with electron-builder's NSIS template

!macro customInstall
  ; Write registry for Add/Remove Programs
  WriteRegStr SHCTX "Software\Spotify VORB" "InstallDir" "$INSTDIR"
  WriteRegStr SHCTX "Software\Spotify VORB" "Version" "${VERSION}"
!macroend

!macro customUnInstall
  ; Kill running processes before uninstall
  nsExec::Exec 'taskkill /F /IM "Spotify VORB.exe" /T'
  Sleep 500

  ; Remove registry entries
  DeleteRegKey SHCTX "Software\Spotify VORB"

  ; Remove shortcuts
  Delete "$DESKTOP\Spotify VORB.lnk"
  Delete "$SMPROGRAMS\Spotify VORB\Spotify VORB.lnk"
  Delete "$SMPROGRAMS\Spotify VORB\Uninstall.lnk"
  RMDir "$SMPROGRAMS\Spotify VORB"

  ; Remove auto-start registry if present
  DeleteRegValue SHCTX "Software\Microsoft\Windows\CurrentVersion\Run" "Spotify VORB"
!macroend

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

!macro customInstallMode
  ; Force per-machine install
  SetShellVarContext all
!macroend
