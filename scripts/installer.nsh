!macro customInstall
  WriteRegStr SHCTX "Software\Spotify VORB" "InstallDir" "$INSTDIR"
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
  RMDir "$SMPROGRAMS\Spotify VORB"

  ; Remove OBS server port registration if any
  DeleteRegValue SHCTX "Software\Microsoft\Windows\CurrentVersion\Run" "Spotify VORB"
!macroend
