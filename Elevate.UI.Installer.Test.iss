#define ApplicationName "QuestTest"
; Version value can be set by argument in cmd line, if you wish to run script directly from GUI, then please specify version number by manually
#define ApplicationVersion Version
#define ApplicationPublisher "Sourcepass"
#define ApplicationExeName "Quest.exe"
#define SetupExeName "QuestTestSetup"
#define ControlpanelName "Quest IT Support Platform by Sourcepass"
#define DesktopIconName "Quest IT Support Platform"
#define FilterRegKey "Software\Quest"

[Setup]
AppId={{dddb3e45-f2e9-43ed-89c3-b089ce05cee2}
AppName={#ApplicationName}
AppVersion={#ApplicationVersion}
;AppVerName={#ApplicationName} {#ApplicationVersion}
AppPublisher={#ApplicationPublisher}
DefaultDirName={userappdata}\{#ApplicationName}
DisableProgramGroupPage=yes
LicenseFile=Quest_EULA.rtf
DisableWelcomePage=no
WizardImageFile=AppLogo-Large.bmp
WizardSmallImageFile=AppLogo-Small.bmp
; Remove the following line to run in administrative install mode (install for all users.)
PrivilegesRequired=lowest
PrivilegesRequiredOverridesAllowed=dialog
OutputDir=..\..\..\out\deploy\TestBuild
OutputBaseFilename={#SetupExeName}_v{#ApplicationVersion}
SetupIconFile=App.ico
UninstallDisplayName = {#ControlpanelName}
UninstallDisplayIcon={app}\App.ico
UninstallIconFile={app}\App.ico
Compression=lzma
SolidCompression=yes
WizardStyle=modern
UsePreviousTasks=no
UsePreviousAppDir=no

[Registry]
Root: HKCU; Subkey: "{#FilterRegKey}"

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"

[Files]
;Source: "Dependencies\windowsdesktop-runtime-6.0.16-win-x64.exe"; DestDir: {tmp}; Flags: deleteafterinstall; AfterInstall: InstallFramework;
Source: "Dependencies\MicrosoftEdgeWebview2Setup.exe"; DestDir: {tmp}; Flags: deleteafterinstall; AfterInstall: InstallWebView;
Source: "..\..\..\out\build\Elevate.UI.Shell\Debug\netcoreapp3.1\{#ApplicationExeName}"; DestDir: "{app}"; Flags: ignoreversion 
Source: "..\..\..\out\build\Elevate.UI.Shell\Debug\netcoreapp3.1\{#ApplicationExeName}.config"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\..\..\out\build\Elevate.UI.Shell\Debug\netcoreapp3.1\*.dll"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "..\..\..\out\build\Quest.UI.Shell\Debug\Quest.exe"; DestDir: "{app}\Updater"; Flags: ignoreversion
Source: "..\..\..\out\build\Quest.UI.Shell\Debug\Quest.exe.config"; DestDir: "{app}\Updater"; Flags: ignoreversion
Source: "..\..\..\out\build\Quest.UI.Shell\Debug\*.dll"; DestDir: "{app}\Updater"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "App.ico"; DestDir:"{app}";
Source: "AnimatedIco.wmv"; DestDir:"{app}";
; NOTE: Don't use "Flags: ignoreversion" on any shared system files

[Icons]
Name: "{autoprograms}\{#DesktopIconName}"; Filename: "{app}\{#ApplicationExeName}";IconFilename:"{app}\App.ico"
Name: "{autodesktop}\{#DesktopIconName}"; Filename: "{app}\{#ApplicationExeName}"; Tasks: desktopicon;IconFilename:"{app}\App.ico"

[Run]
Filename: "{app}\{#ApplicationExeName}"; Description: "{cm:LaunchProgram,{#StringChange(ApplicationName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent

[InstallDelete]
Type: files; Name: "{userdesktop}\Quest.lnk"
Type: files; Name: "{commondesktop}\Quest.lnk"

[Code]

function IsDesktopRuntimeInstalled: Boolean;
begin
   Result:=True;
end;

procedure InstallFramework;
var
  StatusText: string;
  ResultCode: Integer;
begin
  StatusText := WizardForm.StatusLabel.Caption;
  WizardForm.StatusLabel.Caption := 'Installing .NET framework...';
  WizardForm.ProgressGauge.Style := npbstMarquee;
  try
    if not IsDesktopRuntimeInstalled then
    begin
      Exec(ExpandConstant('{tmp}\windowsdesktop-runtime-6.0.16-win-x64.exe'), '/q /norestart', '', SW_SHOW, ewWaitUntilTerminated, ResultCode);  
    end; 
  finally
    WizardForm.StatusLabel.Caption := StatusText;
    WizardForm.ProgressGauge.Style := npbstNormal;
  end;
end;

procedure InstallWebView;
var
  StatusText: string;
  ResultCode: Integer;
begin
  StatusText := WizardForm.StatusLabel.Caption;
  WizardForm.StatusLabel.Caption := 'Installing WebView2 framework...';
  WizardForm.ProgressGauge.Style := npbstMarquee;
  try
    Exec(ExpandConstant('{tmp}\MicrosoftEdgeWebview2Setup.exe'), '/silent /install', '', SW_SHOW, ewWaitUntilTerminated, ResultCode)
  finally
    WizardForm.StatusLabel.Caption := StatusText;
    WizardForm.ProgressGauge.Style := npbstNormal;
  end;
end;

procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
begin
  if CurUninstallStep = usPostUninstall then
  begin
    if RegKeyExists(HKEY_CURRENT_USER, '{#FilterRegKey}')      
      then
        RegDeleteKeyIncludingSubkeys(HKEY_CURRENT_USER, '{#FilterRegKey}');
  end;
end;

/////////////////////////////////////////////////////////////////////
function GetUninstallString(): String;
var
  sUnInstPath: String;
  sUnInstallString: String;
begin
  sUnInstPath := ExpandConstant('Software\Microsoft\Windows\CurrentVersion\Uninstall\{#emit SetupSetting("AppId")}_is1');
  sUnInstallString := '';
  if not RegQueryStringValue(HKLM, sUnInstPath, 'UninstallString', sUnInstallString) then
    RegQueryStringValue(HKCU, sUnInstPath, 'UninstallString', sUnInstallString);
  Result := sUnInstallString;
end;

/////////////////////////////////////////////////////////////////////
function IsUpgrade(): Boolean;
begin
  Result := (GetUninstallString() <> '');
end;

/////////////////////////////////////////////////////////////////////
function UnInstallOldVersion(): Integer;
var
  sUnInstallString: String;
  iResultCode: Integer;
begin
// Return Values:
// 1 - uninstall string is empty
// 2 - error executing the UnInstallString
// 3 - successfully executed the UnInstallString

  // default return value
  Result := 0;

  // get the uninstall string of the old app
  sUnInstallString := GetUninstallString();
  if sUnInstallString <> '' then begin
    sUnInstallString := RemoveQuotes(sUnInstallString);
    if Exec(sUnInstallString, '/SILENT /NORESTART /SUPPRESSMSGBOXES','', SW_HIDE, ewWaitUntilTerminated, iResultCode) then
      Result := 3
    else
      Result := 2;
  end else
    Result := 1;
end;

/////////////////////////////////////////////////////////////////////
procedure CurStepChanged(CurStep: TSetupStep);
begin
  if (CurStep=ssInstall) then
  begin
    if (IsUpgrade()) then
    begin
      UnInstallOldVersion();
    end;
  end;
end;