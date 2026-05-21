; Spotify VORB — Installer Script
#define MyAppName "Spotify VORB"
#ifndef MyAppVersion
#define MyAppVersion "3.5.1"
#endif
#define MyAppPublisher "Sossi"
#define MyAppURL "https://github.com/TopiACutie/spotify-vorb"
#define MyAppExeName "Spotify VORB.exe"
#define AppId "com.spotify-vorb.app-v2"

[Setup]
AppId={#AppId}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppVerName={#MyAppName}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={commonpf}\{#MyAppName}
DefaultGroupName={#MyAppName}
AllowNoIcons=yes
OutputDir=..\dist
OutputBaseFilename=Spotify VORB Setup {#MyAppVersion}
SetupIconFile=..\assets\icon.ico
UninstallDisplayIcon={app}\{#MyAppExeName}
VersionInfoVersion={#MyAppVersion}
VersionInfoDescription=Spotify VORB Installer v{#MyAppVersion}
VersionInfoCopyright=Copyright (C) {#MyAppPublisher}
VersionInfoProductName=Spotify VORB
VersionInfoProductVersion={#MyAppVersion}
Compression=lzma2/ultra64
SolidCompression=yes
PrivilegesRequired=admin
ArchitecturesInstallIn64BitMode=x64compatible
WizardStyle=classic
CloseApplications=no
RestartApplications=no
DisableWelcomePage=no
DisableFinishedPage=yes
DisableReadyPage=yes
DisableProgramGroupPage=yes
DirExistsWarning=no
UsePreviousAppDir=no

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "Create a desktop shortcut"
Name: "autoStart"; Description: "Launch on Windows startup"; Flags: unchecked
Name: "launchApp"; Description: "Launch Spotify VORB after installation"; Flags: unchecked

[Files]
Source: "..\dist\win-unpacked\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{group}\{cm:UninstallProgram,{#MyAppName}}"; Filename: "{uninstallexe}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Run]

[Registry]
Root: HKCU; Subkey: "Software\Microsoft\Windows\CurrentVersion\Run"; ValueType: string; ValueName: "{#MyAppName}"; ValueData: """{app}\{#MyAppExeName}"""; Tasks: autoStart; Flags: uninsdeletevalue

[Code]
var
  HeaderBar, FooterBar: TPanel;
  TitleLbl, VersionLbl, StepLbl, DisclaimerLbl, CreditLbl: TLabel;
  DescPanel: TPanel;
  DescLbl: TLabel;
  ReadyPanel: TPanel;
  ReadyLbl, ReadyIcon: TLabel;
  DirNoteLbl: TLabel;
  GreenTop, GreenBottom: TPanel;
  CustomBrowseBtn: TNewButton;
  UninstKeepSettings: Boolean;
  { Uninstaller UI controls (shared between InitializeUninstall and CurUninstallStepChanged) }
  UHeaderBar, UFooterBar, UGreenTop, UGreenBottom: TPanel;
  UTitleLbl, UVersionLbl, UDisclaimerLbl, UCreditLbl: TLabel;

function InitializeSetup(): Boolean;
var
  ResultCode: Integer;
begin
  { Kill any running VORB processes before installation }
  Exec('taskkill', '/F /IM "Spotify VORB.exe" /T', '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
  Result := True;
end;

procedure StyleBtn(btn: TNewButton);
begin
  btn.Font.Name := 'Segoe UI';
  btn.Font.Size := 9;
end;

procedure CustomBrowseClick(Sender: TObject);
var
  Dir: String;
begin
  Dir := WizardForm.DirEdit.Text;
  if BrowseForFolder('Choose install location:', Dir, False) then begin
    WizardForm.DirEdit.Text := Dir;
  end;
end;

procedure InitializeWizard();
var
  CW, CH, FooterTop: Integer;
begin
  CW := WizardForm.ClientWidth;
  CH := WizardForm.ClientHeight;
  FooterTop := CH - 50;

  { Dark everything }
  WizardForm.Color := $00111111;
  WizardForm.MainPanel.Color := $00111111;
  WizardForm.InnerPage.Color := $00111111;

  { Hide default wizard elements }
  WizardForm.WizardBitmapImage.Visible := False;
  WizardForm.WizardBitmapImage.SetBounds(-5000, 0, 0, 0);
  WizardForm.WizardBitmapImage2.Visible := False;
  WizardForm.WizardBitmapImage2.SetBounds(-5000, 0, 0, 0);
  if Assigned(WizardForm.WizardSmallBitmapImage) then begin WizardForm.WizardSmallBitmapImage.Visible := False; WizardForm.WizardSmallBitmapImage.SetBounds(-5000, 0, 0, 0); end;
  WizardForm.Bevel.Visible := False;
  WizardForm.Bevel1.Visible := False;
  if Assigned(WizardForm.PageNameLabel) then begin WizardForm.PageNameLabel.Visible := False; WizardForm.PageNameLabel.SetBounds(-5000, 0, 0, 0); end;
  if Assigned(WizardForm.PageDescriptionLabel) then begin WizardForm.PageDescriptionLabel.Visible := False; WizardForm.PageDescriptionLabel.SetBounds(-5000, 0, 0, 0); end;

  { Neutralize default labels }
  if Assigned(WizardForm.WelcomeLabel1) then begin WizardForm.WelcomeLabel1.Caption := ''; WizardForm.WelcomeLabel1.Visible := False; WizardForm.WelcomeLabel1.SetBounds(-5000, 0, 0, 0); end;
  if Assigned(WizardForm.WelcomeLabel2) then begin WizardForm.WelcomeLabel2.Caption := ''; WizardForm.WelcomeLabel2.Visible := False; WizardForm.WelcomeLabel2.SetBounds(-5000, 0, 0, 0); end;
  if Assigned(WizardForm.SelectDirLabel) then begin WizardForm.SelectDirLabel.Caption := ''; WizardForm.SelectDirLabel.Visible := False; WizardForm.SelectDirLabel.SetBounds(-5000, 0, 0, 0); end;
  if Assigned(WizardForm.SelectTasksLabel) then begin WizardForm.SelectTasksLabel.Caption := ''; WizardForm.SelectTasksLabel.Visible := False; WizardForm.SelectTasksLabel.SetBounds(-5000, 0, 0, 0); end;
  if Assigned(WizardForm.ReadyLabel) then begin WizardForm.ReadyLabel.Caption := ''; WizardForm.ReadyLabel.Visible := False; WizardForm.ReadyLabel.SetBounds(-5000, 0, 0, 0); end;
  if Assigned(WizardForm.FinishedLabel) then begin WizardForm.FinishedLabel.Caption := ''; WizardForm.FinishedLabel.Visible := False; WizardForm.FinishedLabel.SetBounds(-5000, 0, 0, 0); end;
  if Assigned(WizardForm.LicenseLabel1) then begin WizardForm.LicenseLabel1.Caption := ''; WizardForm.LicenseLabel1.Visible := False; WizardForm.LicenseLabel1.SetBounds(-5000, 0, 0, 0); end;

  { Dark pages }
  if Assigned(WizardForm.WelcomePage) then WizardForm.WelcomePage.Color := $00111111;
  if Assigned(WizardForm.LicensePage) then WizardForm.LicensePage.Color := $00111111;
  if Assigned(WizardForm.SelectDirPage) then begin WizardForm.SelectDirPage.Color := $00111111; WizardForm.SelectDirPage.Visible := True; end;
  if Assigned(WizardForm.SelectTasksPage) then WizardForm.SelectTasksPage.Color := $00111111;
  if Assigned(WizardForm.ReadyPage) then WizardForm.ReadyPage.Color := $00111111;
  if Assigned(WizardForm.InstallingPage) then WizardForm.InstallingPage.Color := $00111111;
  if Assigned(WizardForm.FinishedPage) then WizardForm.FinishedPage.Color := $00111111;

  { === HEADER BAR === }
  HeaderBar := TPanel.Create(WizardForm);
  HeaderBar.Parent := WizardForm;
  HeaderBar.SetBounds(0, 0, CW, 48);
  HeaderBar.Color := $00141414;
  HeaderBar.BevelOuter := bvNone;
  HeaderBar.BevelInner := bvNone;
  HeaderBar.Caption := '';

  GreenTop := TPanel.Create(WizardForm);
  GreenTop.Parent := WizardForm;
  GreenTop.SetBounds(0, 48, CW, 2);
  GreenTop.Color := $001DB954;
  GreenTop.BevelOuter := bvNone;
  GreenTop.BevelInner := bvNone;
  GreenTop.Caption := '';

  TitleLbl := TLabel.Create(WizardForm);
  TitleLbl.Parent := HeaderBar;
  TitleLbl.SetBounds(24, 14, 200, 20);
  TitleLbl.Caption := 'Spotify VORB';
  TitleLbl.Font.Name := 'Segoe UI';
  TitleLbl.Font.Size := 14;
  TitleLbl.Font.Style := [fsBold];
  TitleLbl.Font.Color := $001DB954;
  TitleLbl.Transparent := True;

  VersionLbl := TLabel.Create(WizardForm);
  VersionLbl.Parent := HeaderBar;
  VersionLbl.SetBounds(CW - 100, 28, 80, 14);
  VersionLbl.Alignment := taRightJustify;
  VersionLbl.Caption := 'v' + '{#MyAppVersion}';
  VersionLbl.Font.Name := 'Segoe UI';
  VersionLbl.Font.Size := 8;
  VersionLbl.Font.Color := $00555555;
  VersionLbl.Transparent := True;

  StepLbl := TLabel.Create(WizardForm);
  StepLbl.Parent := HeaderBar;
  StepLbl.SetBounds(CW - 100, 10, 80, 16);
  StepLbl.Alignment := taRightJustify;
  StepLbl.Caption := '';
  StepLbl.Font.Name := 'Segoe UI';
  StepLbl.Font.Size := 9;
  StepLbl.Font.Color := $00888888;
  StepLbl.Transparent := True;

  { === FOOTER BAR === }
  FooterBar := TPanel.Create(WizardForm);
  FooterBar.Parent := WizardForm;
  FooterBar.SetBounds(0, FooterTop, CW, 50);
  FooterBar.Color := $00141414;
  FooterBar.BevelOuter := bvNone;
  FooterBar.BevelInner := bvNone;
  FooterBar.Caption := '';

  GreenBottom := TPanel.Create(WizardForm);
  GreenBottom.Parent := WizardForm;
  GreenBottom.SetBounds(0, FooterTop - 1, CW, 2);
  GreenBottom.Color := $001DB954;
  GreenBottom.BevelOuter := bvNone;
  GreenBottom.BevelInner := bvNone;
  GreenBottom.Caption := '';

  WizardForm.BackButton.Parent := FooterBar;
  WizardForm.NextButton.Parent := FooterBar;
  WizardForm.CancelButton.Parent := FooterBar;

  StyleBtn(WizardForm.BackButton);
  StyleBtn(WizardForm.NextButton);
  StyleBtn(WizardForm.CancelButton);

  with WizardForm.BackButton do SetBounds(16, 4, 80, 28);
  with WizardForm.CancelButton do SetBounds(CW - 190, 4, 80, 28);
  with WizardForm.NextButton do SetBounds(CW - 100, 4, 80, 28);

  DisclaimerLbl := TLabel.Create(WizardForm);
  DisclaimerLbl.Parent := FooterBar;
  DisclaimerLbl.SetBounds(0, 34, CW - 20, 14);
  DisclaimerLbl.Caption := 'Not affiliated with Spotify AB.';
  DisclaimerLbl.Font.Name := 'Segoe UI';
  DisclaimerLbl.Font.Size := 8;
  DisclaimerLbl.Font.Color := $00444444;
  DisclaimerLbl.Transparent := True;
  DisclaimerLbl.Alignment := taRightJustify;

  CreditLbl := TLabel.Create(WizardForm);
  CreditLbl.Parent := FooterBar;
  CreditLbl.SetBounds(0, 2, CW, 20);
  CreditLbl.Caption := 'Created by Sossi';
  CreditLbl.Font.Name := 'Segoe UI';
  CreditLbl.Font.Size := 9;
  CreditLbl.Font.Color := $00555555;
  CreditLbl.Transparent := True;
  CreditLbl.Alignment := taCenter;
  CreditLbl.Visible := False;

  { === DESCRIPTION & READY PANELS === }
  DescPanel := TPanel.Create(WizardForm);
  DescPanel.Parent := WizardForm;
  DescPanel.Color := $00111111;
  DescPanel.BevelOuter := bvNone;
  DescPanel.BevelInner := bvNone;
  DescPanel.Caption := '';
  DescPanel.Visible := False;

  DescLbl := TLabel.Create(WizardForm);
  DescLbl.Parent := DescPanel;
  DescLbl.Font.Name := 'Segoe UI';
  DescLbl.Font.Size := 12;
  DescLbl.Font.Color := $00CCCCCC;
  DescLbl.Transparent := True;
  DescLbl.AutoSize := False;
  DescLbl.WordWrap := True;
  DescLbl.Alignment := taCenter;

  ReadyPanel := TPanel.Create(WizardForm);
  ReadyPanel.Parent := WizardForm;
  ReadyPanel.Color := $00111111;
  ReadyPanel.BevelOuter := bvNone;
  ReadyPanel.BevelInner := bvNone;
  ReadyPanel.Caption := '';
  ReadyPanel.Visible := False;

  ReadyLbl := TLabel.Create(WizardForm);
  ReadyLbl.Parent := ReadyPanel;
  ReadyLbl.Font.Name := 'Segoe UI';
  ReadyLbl.Font.Size := 14;
  ReadyLbl.Font.Style := [fsBold];
  ReadyLbl.Font.Color := $00FFFFFF;
  ReadyLbl.Transparent := True;
  ReadyLbl.AutoSize := False;
  ReadyLbl.WordWrap := True;
  ReadyLbl.Alignment := taCenter;

  ReadyIcon := TLabel.Create(WizardForm);
  ReadyIcon.Parent := ReadyPanel;
  ReadyIcon.Font.Name := 'Segoe UI';
  ReadyIcon.Font.Size := 16;
  ReadyIcon.Font.Style := [fsBold];
  ReadyIcon.Font.Color := $001DB954;
  ReadyIcon.Transparent := True;
  ReadyIcon.AutoSize := False;
  ReadyIcon.Alignment := taCenter;

  { === LOCATION PAGE CONTROLS === }
  { Note: WizardForm.DirLabel, DirEdit, DirBrowseButton are styled below }

  DirNoteLbl := TLabel.Create(WizardForm);
  DirNoteLbl.Parent := WizardForm;
  DirNoteLbl.SetBounds(24, 120, CW - 48, 16);
  DirNoteLbl.Caption := 'App data & settings are stored automatically in %APPDATA%\Spotify VORB';
  DirNoteLbl.Font.Name := 'Segoe UI';
  DirNoteLbl.Font.Size := 8;
  DirNoteLbl.Font.Color := $00666666;
  DirNoteLbl.Transparent := True;
  DirNoteLbl.Visible := False;

  { Custom browse button - placed in footer }
  CustomBrowseBtn := TNewButton.Create(WizardForm);
  CustomBrowseBtn.Parent := FooterBar;
  CustomBrowseBtn.SetBounds(100, 4, 80, 28);
  CustomBrowseBtn.Caption := 'Browse...';
  CustomBrowseBtn.Font.Name := 'Segoe UI';
  CustomBrowseBtn.Font.Size := 9;
  CustomBrowseBtn.Visible := False;
  CustomBrowseBtn.OnClick := @CustomBrowseClick;
  if Assigned(WizardForm.DirEdit) then begin
    WizardForm.DirEdit.Top := 85;
    WizardForm.DirEdit.Left := 24;
    WizardForm.DirEdit.Width := CW - 110;
    WizardForm.DirEdit.Height := 24;
    WizardForm.DirEdit.Color := $001A1A1A;
    WizardForm.DirEdit.Font.Name := 'Segoe UI';
    WizardForm.DirEdit.Font.Size := 10;
    WizardForm.DirEdit.Font.Color := $00CCCCCC;
    WizardForm.DirEdit.Visible := True;
    WizardForm.DirEdit.Enabled := True;
    WizardForm.DirEdit.BringToFront;
  end;
  if Assigned(WizardForm.DirBrowseButton) then begin
    WizardForm.DirBrowseButton.Top := 83;
    WizardForm.DirBrowseButton.Left := CW - 80;
    WizardForm.DirBrowseButton.Width := 60;
    WizardForm.DirBrowseButton.Height := 28;
    WizardForm.DirBrowseButton.Font.Name := 'Segoe UI';
    WizardForm.DirBrowseButton.Font.Size := 9;
    WizardForm.DirBrowseButton.Caption := 'Browse';
    WizardForm.DirBrowseButton.Visible := True;
    WizardForm.DirBrowseButton.Enabled := True;
    WizardForm.DirBrowseButton.BringToFront;
  end;

  { Style tasks list }
  if Assigned(WizardForm.TasksList) then begin
    WizardForm.TasksList.Left := 24;
    WizardForm.TasksList.Width := CW - 48;
    WizardForm.TasksList.Font.Name := 'Segoe UI';
    WizardForm.TasksList.Font.Size := 10;
    WizardForm.TasksList.Font.Color := $00DDDDDD;
    WizardForm.TasksList.Color := $00111111;
  end;
  if Assigned(WizardForm.LicenseMemo) then begin
    WizardForm.LicenseMemo.Left := 24;
    WizardForm.LicenseMemo.Width := CW - 48;
    WizardForm.LicenseMemo.Color := $001A1A1A;
    WizardForm.LicenseMemo.Font.Color := $00CCCCCC;
  end;
  { Style installing page labels (text above progress bar) }
  if Assigned(WizardForm.StatusLabel) then begin
    WizardForm.StatusLabel.Font.Name := 'Segoe UI';
    WizardForm.StatusLabel.Font.Size := 11;
    WizardForm.StatusLabel.Font.Color := $00FFFFFF;
    WizardForm.StatusLabel.Font.Style := [fsBold];
    WizardForm.StatusLabel.SetBounds(24, 60, CW - 48, 30);
    WizardForm.StatusLabel.WordWrap := True;
  end;
  if Assigned(WizardForm.FilenameLabel) then begin
    WizardForm.FilenameLabel.Font.Name := 'Segoe UI';
    WizardForm.FilenameLabel.Font.Size := 9;
    WizardForm.FilenameLabel.Font.Color := $00AAAAAA;
    WizardForm.FilenameLabel.SetBounds(24, 95, CW - 48, 20);
  end;
  if Assigned(WizardForm.ProgressGauge) then begin
    WizardForm.ProgressGauge.Top := 120;
    WizardForm.ProgressGauge.Left := 24;
    WizardForm.ProgressGauge.Width := CW - 48;
  end;
  { Style location page labels }
  if Assigned(WizardForm.SelectDirBrowseLabel) then begin
    WizardForm.SelectDirBrowseLabel.Font.Name := 'Segoe UI';
    WizardForm.SelectDirBrowseLabel.Font.Size := 10;
    WizardForm.SelectDirBrowseLabel.Font.Color := $00FFFFFF;
    WizardForm.SelectDirBrowseLabel.Alignment := taCenter;
    WizardForm.SelectDirBrowseLabel.SetBounds(24, 58, CW - 110, 24);
  end;
  if Assigned(WizardForm.SelectDirLabel) then begin
    WizardForm.SelectDirLabel.Font.Name := 'Segoe UI';
    WizardForm.SelectDirLabel.Font.Size := 10;
    WizardForm.SelectDirLabel.Font.Color := $00FFFFFF;
  end;
  if Assigned(WizardForm.DiskSpaceLabel) then begin
    WizardForm.DiskSpaceLabel.Font.Name := 'Segoe UI';
    WizardForm.DiskSpaceLabel.Font.Size := 9;
    WizardForm.DiskSpaceLabel.Font.Color := $00AAAAAA;
    WizardForm.DiskSpaceLabel.SetBounds(24, 115, CW - 48, 16);
  end;
  if Assigned(WizardForm.RunList) then begin
    WizardForm.RunList.Left := 24;
    WizardForm.RunList.Width := CW - 48;
  end;
end;

procedure CurPageChanged(CurPageID: Integer);
var
  ContentLeft, ContentTop, ContentWidth, ContentHeight: Integer;
begin
  ContentLeft := 120;
  ContentTop := 55;
  ContentWidth := WizardForm.ClientWidth - 240;
  ContentHeight := WizardForm.ClientHeight - 55 - 50 - 10;

  if CurPageID = wpWelcome then begin
    StepLbl.Caption := 'Welcome';
    WizardForm.NextButton.Caption := 'Install';
    WizardForm.BackButton.Visible := False;
    DisclaimerLbl.Visible := True;
    TitleLbl.Visible := True;
    CreditLbl.Visible := True;
    CreditLbl.SetBounds(0, 2, WizardForm.ClientWidth, 20);
    DescPanel.Visible := True;
    DescPanel.SetBounds(ContentLeft, ContentTop + (ContentHeight - 80) / 2, ContentWidth, 80);
    DescLbl.SetBounds(0, 0, ContentWidth, 80);
    DescLbl.Caption := 'Audio Reactive Orb — Visualize your music in real-time with a beautiful circular waveform overlay.';
    CreditLbl.BringToFront;
    ReadyPanel.Visible := False;
    DirNoteLbl.Visible := False;
    CustomBrowseBtn.Visible := False;
  end
  else if CurPageID = wpSelectDir then begin
    StepLbl.Caption := 'Location';
    WizardForm.NextButton.Caption := 'Next >';
    WizardForm.BackButton.Visible := True;
    DisclaimerLbl.Visible := True;
    TitleLbl.Visible := True;
    CreditLbl.Visible := False;
    DescPanel.Visible := False;
    ReadyPanel.Visible := False;
    DirNoteLbl.Visible := True;
    DirNoteLbl.BringToFront;
    CustomBrowseBtn.Visible := True;
    CustomBrowseBtn.BringToFront;
  end
  else if CurPageID = wpSelectTasks then begin
    StepLbl.Caption := 'Options';
    WizardForm.NextButton.Caption := 'Install';
    WizardForm.BackButton.Visible := True;
    DisclaimerLbl.Visible := True;
    TitleLbl.Visible := True;
    CreditLbl.Visible := False;
    DescPanel.Visible := False;
    ReadyPanel.Visible := False;
    DirNoteLbl.Visible := False;
    CustomBrowseBtn.Visible := False;
  end
  else if CurPageID = wpReady then begin
    StepLbl.Caption := 'Ready';
    WizardForm.NextButton.Caption := 'Install';
    WizardForm.BackButton.Visible := True;
    DisclaimerLbl.Visible := True;
    TitleLbl.Visible := True;
    CreditLbl.Visible := False;
    DescPanel.Visible := False;
    ReadyPanel.Visible := True;
    ReadyPanel.SetBounds(ContentLeft, ContentTop + (ContentHeight - 100) / 2, ContentWidth, 100);
    ReadyPanel.BringToFront;
    ReadyLbl.SetBounds(0, 0, ContentWidth, 55);
    ReadyLbl.Caption := 'Are you ready to install the best Spotify visualizer?';
    ReadyLbl.BringToFront;
    ReadyIcon.SetBounds(0, 58, ContentWidth, 28);
    ReadyIcon.Caption := 'Spotify VORB';
    ReadyIcon.BringToFront;
    DirNoteLbl.Visible := False;
    CustomBrowseBtn.Visible := False;
  end
  else if CurPageID = wpInstalling then begin
    StepLbl.Caption := 'Installing...';
    WizardForm.NextButton.Visible := False;
    WizardForm.BackButton.Visible := False;
    WizardForm.CancelButton.SetBounds(WizardForm.ClientWidth - 100, 4, 80, 28);
    DisclaimerLbl.Visible := False;
    TitleLbl.Visible := True;
    CreditLbl.Visible := False;
    DescPanel.Visible := False;
    ReadyPanel.Visible := False;
    DirNoteLbl.Visible := False;
    CustomBrowseBtn.Visible := False;
  end
  else if CurPageID = wpFinished then begin
    StepLbl.Caption := 'Complete';
    WizardForm.NextButton.Caption := 'Finish';
    WizardForm.BackButton.Visible := False;
    WizardForm.NextButton.Visible := True;
    WizardForm.CancelButton.SetBounds(WizardForm.ClientWidth - 190, 4, 80, 28);
    DisclaimerLbl.Visible := True;
    TitleLbl.Visible := True;
    CreditLbl.Visible := False;
    DescPanel.Visible := False;
    ReadyPanel.Visible := False;
    DirNoteLbl.Visible := False;
    CustomBrowseBtn.Visible := False;
  end
  else begin
    StepLbl.Caption := '';
    WizardForm.NextButton.Caption := 'Next >';
    WizardForm.BackButton.Visible := True;
    WizardForm.NextButton.Visible := True;
    WizardForm.CancelButton.SetBounds(WizardForm.ClientWidth - 190, 4, 80, 28);
    DisclaimerLbl.Visible := True;
    TitleLbl.Visible := True;
    CreditLbl.Visible := False;
    DescPanel.Visible := False;
    ReadyPanel.Visible := False;
    DirNoteLbl.Visible := False;
    CustomBrowseBtn.Visible := False;
  end;
end;

function InitializeUninstall(): Boolean;
var
  ConfirmForm: TForm;
  CW, CH, FooterTop, ContentWidth: Integer;
  ResultCode: Integer;
  HeaderBar, FooterBar, GreenTop, GreenBottom: TPanel;
  TitleLbl, VersionLbl, ConfirmLbl, DisclaimerLbl, CreditLbl, KeepSettingsLbl: TLabel;
  KeepSettingsCheck: TCheckBox;
  UninstallBtn, CancelBtn: TButton;
begin
  { Kill any running VORB processes }
  Exec('taskkill', '/F /IM "Spotify VORB.exe" /T', '', SW_HIDE, ewWaitUntilTerminated, ResultCode);

  UninstKeepSettings := False;

  { Create a separate confirmation form - UninstallProgressForm isn't ready yet }
  ConfirmForm := TForm.Create(nil);
  try
    CW := 500;
    CH := 280;
    FooterTop := CH - 50;
    ContentWidth := CW - 80;

    ConfirmForm.SetBounds(0, 0, CW, CH);
    ConfirmForm.Position := poScreenCenter;
    ConfirmForm.BorderStyle := bsNone;
    ConfirmForm.Color := $00111111;
    ConfirmForm.Caption := 'Uninstall Spotify VORB';

    { === HEADER BAR === }
    HeaderBar := TPanel.Create(ConfirmForm);
    HeaderBar.Parent := ConfirmForm;
    HeaderBar.SetBounds(0, 0, CW, 48);
    HeaderBar.Color := $00141414;
    HeaderBar.BevelOuter := bvNone;
    HeaderBar.BevelInner := bvNone;
    HeaderBar.Caption := '';

    GreenTop := TPanel.Create(ConfirmForm);
    GreenTop.Parent := ConfirmForm;
    GreenTop.SetBounds(0, 48, CW, 2);
    GreenTop.Color := $001DB954;
    GreenTop.BevelOuter := bvNone;
    GreenTop.BevelInner := bvNone;
    GreenTop.Caption := '';

    TitleLbl := TLabel.Create(ConfirmForm);
    TitleLbl.Parent := HeaderBar;
    TitleLbl.SetBounds(24, 14, 200, 20);
    TitleLbl.Caption := 'Spotify VORB';
    TitleLbl.Font.Name := 'Segoe UI';
    TitleLbl.Font.Size := 14;
    TitleLbl.Font.Style := [fsBold];
    TitleLbl.Font.Color := $001DB954;
    TitleLbl.Transparent := True;

    VersionLbl := TLabel.Create(ConfirmForm);
    VersionLbl.Parent := HeaderBar;
    VersionLbl.SetBounds(CW - 100, 14, 80, 20);
    VersionLbl.Alignment := taRightJustify;
    VersionLbl.Caption := 'v' + '{#MyAppVersion}';
    VersionLbl.Font.Name := 'Segoe UI';
    VersionLbl.Font.Size := 8;
    VersionLbl.Font.Color := $00555555;
    VersionLbl.Transparent := True;

    { === FOOTER BAR === }
    FooterBar := TPanel.Create(ConfirmForm);
    FooterBar.Parent := ConfirmForm;
    FooterBar.SetBounds(0, FooterTop, CW, 50);
    FooterBar.Color := $00141414;
    FooterBar.BevelOuter := bvNone;
    FooterBar.BevelInner := bvNone;
    FooterBar.Caption := '';

    GreenBottom := TPanel.Create(ConfirmForm);
    GreenBottom.Parent := ConfirmForm;
    GreenBottom.SetBounds(0, FooterTop - 1, CW, 2);
    GreenBottom.Color := $001DB954;
    GreenBottom.BevelOuter := bvNone;
    GreenBottom.BevelInner := bvNone;
    GreenBottom.Caption := '';

    DisclaimerLbl := TLabel.Create(ConfirmForm);
    DisclaimerLbl.Parent := FooterBar;
    DisclaimerLbl.SetBounds(0, 34, CW - 20, 14);
    DisclaimerLbl.Caption := 'Not affiliated with Spotify AB.';
    DisclaimerLbl.Font.Name := 'Segoe UI';
    DisclaimerLbl.Font.Size := 8;
    DisclaimerLbl.Font.Color := $00444444;
    DisclaimerLbl.Transparent := True;
    DisclaimerLbl.Alignment := taRightJustify;

    CreditLbl := TLabel.Create(ConfirmForm);
    CreditLbl.Parent := ConfirmForm;
    CreditLbl.SetBounds(0, FooterTop - 22, CW, 20);
    CreditLbl.Caption := 'Created by Sossi';
    CreditLbl.Font.Name := 'Segoe UI';
    CreditLbl.Font.Size := 9;
    CreditLbl.Font.Color := $00555555;
    CreditLbl.Transparent := True;
    CreditLbl.Alignment := taCenter;

    { === CONFIRM TEXT === }
    ConfirmLbl := TLabel.Create(ConfirmForm);
    ConfirmLbl.Parent := ConfirmForm;
    ConfirmLbl.SetBounds(40, 90, ContentWidth, 40);
    ConfirmLbl.Caption := 'Are you sure you want to uninstall Spotify VORB?';
    ConfirmLbl.Font.Name := 'Segoe UI';
    ConfirmLbl.Font.Size := 14;
    ConfirmLbl.Font.Style := [fsBold];
    ConfirmLbl.Font.Color := $00FFFFFF;
    ConfirmLbl.Transparent := True;
    ConfirmLbl.AutoSize := False;
    ConfirmLbl.WordWrap := True;
    ConfirmLbl.Alignment := taCenter;

    KeepSettingsCheck := TCheckBox.Create(ConfirmForm);
    KeepSettingsCheck.Parent := ConfirmForm;
    KeepSettingsCheck.SetBounds((CW - 300) / 2, 145, 24, 24);
    KeepSettingsCheck.Checked := True;

    KeepSettingsLbl := TLabel.Create(ConfirmForm);
    KeepSettingsLbl.Parent := ConfirmForm;
    KeepSettingsLbl.SetBounds((CW - 300) / 2 + 28, 148, 280, 20);
    KeepSettingsLbl.Caption := 'Keep my settings and preferences';
    KeepSettingsLbl.Font.Name := 'Segoe UI';
    KeepSettingsLbl.Font.Size := 10;
    KeepSettingsLbl.Font.Color := $00CCCCCC;
    KeepSettingsLbl.Transparent := True;

    { === BUTTONS === }
    UninstallBtn := TButton.Create(ConfirmForm);
    UninstallBtn.Parent := FooterBar;
    UninstallBtn.SetBounds(CW - 190, 10, 80, 28);
    UninstallBtn.Caption := 'Uninstall';
    UninstallBtn.Font.Name := 'Segoe UI';
    UninstallBtn.Font.Size := 9;
    UninstallBtn.ModalResult := mrYes;

    CancelBtn := TButton.Create(ConfirmForm);
    CancelBtn.Parent := FooterBar;
    CancelBtn.SetBounds(CW - 100, 10, 80, 28);
    CancelBtn.Caption := 'Cancel';
    CancelBtn.Font.Name := 'Segoe UI';
    CancelBtn.Font.Size := 9;
    CancelBtn.ModalResult := mrCancel;
    CancelBtn.Cancel := True;

    { Show form and get result }
    if ConfirmForm.ShowModal = mrYes then begin
      UninstKeepSettings := KeepSettingsCheck.Checked;
      Result := True;
    end else begin
      Result := False;
    end;
  finally
    ConfirmForm.Free;
  end;
end;

procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
var
  SettingsPath: String;
  CW, CH, FooterTop: Integer;
begin
  if CurUninstallStep = usUninstall then begin
    { Style the progress view }
    with UninstallProgressForm do begin
      CW := ClientWidth;
      CH := ClientHeight;
      FooterTop := CH - 50;

      Color := $00111111;
      BorderStyle := bsNone;
      Caption := 'Uninstalling Spotify VORB';

      { Hide default elements }
      if Assigned(Bevel) then Bevel.Visible := False;
      if Assigned(Bevel1) then Bevel1.Visible := False;
      if Assigned(PageNameLabel) then PageNameLabel.Visible := False;
      if Assigned(PageDescriptionLabel) then PageDescriptionLabel.Visible := False;
      if Assigned(InnerNotebook) then InnerNotebook.Visible := False;
      if Assigned(OuterNotebook) then OuterNotebook.Visible := False;

      { === HEADER BAR === }
      UHeaderBar := TPanel.Create(UninstallProgressForm);
      UHeaderBar.Parent := UninstallProgressForm;
      UHeaderBar.SetBounds(0, 0, CW, 48);
      UHeaderBar.Color := $00141414;
      UHeaderBar.BevelOuter := bvNone;
      UHeaderBar.BevelInner := bvNone;
      UHeaderBar.Caption := '';

      UGreenTop := TPanel.Create(UninstallProgressForm);
      UGreenTop.Parent := UninstallProgressForm;
      UGreenTop.SetBounds(0, 48, CW, 2);
      UGreenTop.Color := $001DB954;
      UGreenTop.BevelOuter := bvNone;
      UGreenTop.BevelInner := bvNone;
      UGreenTop.Caption := '';

      UTitleLbl := TLabel.Create(UninstallProgressForm);
      UTitleLbl.Parent := UHeaderBar;
      UTitleLbl.SetBounds(24, 14, 200, 20);
      UTitleLbl.Caption := 'Spotify VORB';
      UTitleLbl.Font.Name := 'Segoe UI';
      UTitleLbl.Font.Size := 14;
      UTitleLbl.Font.Style := [fsBold];
      UTitleLbl.Font.Color := $001DB954;
      UTitleLbl.Transparent := True;

      UVersionLbl := TLabel.Create(UninstallProgressForm);
      UVersionLbl.Parent := UHeaderBar;
      UVersionLbl.SetBounds(CW - 100, 14, 80, 20);
      UVersionLbl.Alignment := taRightJustify;
      UVersionLbl.Caption := 'v' + '{#MyAppVersion}';
      UVersionLbl.Font.Name := 'Segoe UI';
      UVersionLbl.Font.Size := 8;
      UVersionLbl.Font.Color := $00555555;
      UVersionLbl.Transparent := True;

      { === FOOTER BAR === }
      UFooterBar := TPanel.Create(UninstallProgressForm);
      UFooterBar.Parent := UninstallProgressForm;
      UFooterBar.SetBounds(0, FooterTop, CW, 50);
      UFooterBar.Color := $00141414;
      UFooterBar.BevelOuter := bvNone;
      UFooterBar.BevelInner := bvNone;
      UFooterBar.Caption := '';

      UGreenBottom := TPanel.Create(UninstallProgressForm);
      UGreenBottom.Parent := UninstallProgressForm;
      UGreenBottom.SetBounds(0, FooterTop - 1, CW, 2);
      UGreenBottom.Color := $001DB954;
      UGreenBottom.BevelOuter := bvNone;
      UGreenBottom.BevelInner := bvNone;
      UGreenBottom.Caption := '';

      UDisclaimerLbl := TLabel.Create(UninstallProgressForm);
      UDisclaimerLbl.Parent := UFooterBar;
      UDisclaimerLbl.SetBounds(0, 34, CW - 20, 14);
      UDisclaimerLbl.Caption := 'Not affiliated with Spotify AB.';
      UDisclaimerLbl.Font.Name := 'Segoe UI';
      UDisclaimerLbl.Font.Size := 8;
      UDisclaimerLbl.Font.Color := $00444444;
      UDisclaimerLbl.Transparent := True;
      UDisclaimerLbl.Alignment := taRightJustify;

      UCreditLbl := TLabel.Create(UninstallProgressForm);
      UCreditLbl.Parent := UninstallProgressForm;
      UCreditLbl.SetBounds(0, FooterTop - 22, CW, 20);
      UCreditLbl.Caption := 'Created by Sossi';
      UCreditLbl.Font.Name := 'Segoe UI';
      UCreditLbl.Font.Size := 9;
      UCreditLbl.Font.Color := $00555555;
      UCreditLbl.Transparent := True;
      UCreditLbl.Alignment := taCenter;

      { === STATUS LABEL === }
      if Assigned(StatusLabel) then begin
        StatusLabel.Visible := True;
        StatusLabel.Parent := UninstallProgressForm;
        StatusLabel.SetBounds(40, 100, CW - 80, 20);
        StatusLabel.Font.Name := 'Segoe UI';
        StatusLabel.Font.Size := 12;
        StatusLabel.Font.Color := $00CCCCCC;
      end;

      { === PROGRESS BAR === }
      if Assigned(ProgressBar) then begin
        ProgressBar.Visible := True;
        ProgressBar.Parent := UninstallProgressForm;
        ProgressBar.SetBounds(40, 130, CW - 80, 20);
      end;

      { === CANCEL BUTTON === }
      if Assigned(CancelButton) then begin
        CancelButton.Visible := True;
        CancelButton.Parent := UFooterBar;
        CancelButton.SetBounds(CW - 100, 10, 80, 28);
        CancelButton.Font.Name := 'Segoe UI';
        CancelButton.Font.Size := 9;
      end;
    end;
  end;

  if CurUninstallStep = usDone then begin
    if not UninstKeepSettings then begin
      SettingsPath := ExpandConstant('{userappdata}\Spotify VORB');
      if DirExists(SettingsPath) then begin
        DelTree(SettingsPath, True, True, True);
      end;
    end;
  end;
end;

procedure CurStepChanged(CurStep: TSetupStep);
var
  ResultCode: Integer;
  UninstallKey: String;
begin
  if CurStep = ssPostInstall then begin
    { Overwrite UninstallString to skip built-in confirmation dialog }
    UninstallKey := 'Software\Microsoft\Windows\CurrentVersion\Uninstall\{#emit SetupSetting("AppId")}_is1';
    RegWriteStringValue(HKA, UninstallKey, 'UninstallString', '"' + ExpandConstant('{app}') + '\unins000.exe" /SILENT');

    if WizardIsTaskSelected('launchApp') then begin
      Exec(ExpandConstant('{app}\{#MyAppExeName}'), '', '', SW_SHOWNORMAL, ewNoWait, ResultCode);
    end;
  end;
end;
