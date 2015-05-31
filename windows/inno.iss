; Script generated by the Inno Setup Script Wizard.
; SEE THE DOCUMENTATION FOR DETAILS ON CREATING INNO SETUP SCRIPT FILES!

#define MyAppName "GIMX"
#define MyAppId "{DCCE138F-C418-464F-BF07-FD69ED63D20E}"
#define MyAppVersion "0.00"
#define MyAppPublisher "MatLauLab"
#define MyAppURL "http://gimx.fr"
#define MyApp1 "gimx-launcher"
#define MyAppExeName1 "gimx-launcher.exe"
#define MyApp2 "gimx-config"
#define MyAppExeName2 "gimx-config.exe"
#define MyApp3 "gimx-fpsconfig"
#define MyAppExeName3 "gimx-fpsconfig.exe"

#define UsbdkVersion "1.0.4"
#define UsbdkAppId "{DE78E7B1-43E5-4278-9678-174A6EC4444E}"

#define SilabsCP210xAppId "B97004A400E30DCF940971EFA7A0C13C6B0A4B66"

[Setup]
; NOTE: The value of AppId uniquely identifies this application.
; Do not use the same AppId value in installers for other applications.
; (To generate a new GUID, click Tools | Generate GUID inside the IDE.)
AppId={{#MyAppId}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
;AppVerName={#MyAppName} {#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
#ifdef W64
ArchitecturesInstallIn64BitMode=x64
#endif
DefaultDirName={pf}\{#MyAppName}
DefaultGroupName={#MyAppName}
OutputDir=.
OutputBaseFilename=gimx-{#MyAppVersion}
Compression=lzma
SolidCompression=yes

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "GIMX\setup\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
#ifdef W64
Source: "tools\CP210x_VCP_Windows\*"; Excludes: "*x86*"; DestDir: "{app}\tools\CP210x_VCP_Windows"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "tools\usbdk\*"; Excludes: "*x86*"; DestDir: "{app}\tools\usbdk\"; Flags: ignoreversion recursesubdirs createallsubdirs
#else
Source: "tools\CP210x_VCP_Windows\*"; Excludes: "*x86*"; DestDir: "{app}\tools\CP210x_VCP_Windows"; Check: IsWin64() ; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "tools\usbdk\*"; Excludes: "*x86*"; DestDir: "{app}\tools\usbdk\"; Check: IsWin64() ; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "tools\CP210x_VCP_Windows\*"; Excludes: "*x64*"; DestDir: "{app}\tools\CP210x_VCP_Windows"; Check: not IsWin64() ; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "tools\usbdk\*"; Excludes: "*x64*"; DestDir: "{app}\tools\usbdk\"; Check: not IsWin64() ; Flags: ignoreversion recursesubdirs createallsubdirs
#endif
; NOTE: Don't use "Flags: ignoreversion" on any shared system files

[Icons]
Name: "{group}\{#MyApp1}"; Filename: "{app}\{#MyAppExeName1}"
Name: "{commondesktop}\{#MyApp1}"; Filename: "{app}\{#MyAppExeName1}"; Tasks: desktopicon
Name: "{group}\{#MyApp2}"; Filename: "{app}\{#MyAppExeName2}"
Name: "{commondesktop}\{#MyApp2}"; Filename: "{app}\{#MyAppExeName2}"; Tasks: desktopicon
Name: "{group}\{#MyApp3}"; Filename: "{app}\{#MyAppExeName3}"
Name: "{commondesktop}\{#MyApp3}"; Filename: "{app}\{#MyAppExeName3}"; Tasks: desktopicon

[Run]
Filename: "msiexec.exe"; Parameters: "/i ""{app}\tools\usbdk\UsbDk_{#UsbdkVersion}_x64.msi"" /qn"; Check: IsWin64() and not AppInstalled(True, False, '{#UsbdkAppId}') ; StatusMsg: "Installing USBDK {#UsbdkVersion}..."
Filename: "msiexec.exe"; Parameters: "/i ""{app}\tools\usbdk\UsbDk_{#UsbdkVersion}_x86.msi"" /qn"; Check: not IsWin64() and not AppInstalled(True, False, '{#UsbdkAppId}') ; StatusMsg: "Installing USBDK {#UsbdkVersion}..."
Filename: "{app}\tools\CP210x_VCP_Windows\CP210xVCPInstaller_x64.exe"; Description: "{cm:LaunchProgram,CP210x driver installer}"; Check: IsWin64() and not AppInstalled(True, False, '{#SilabsCP210xAppId}') ; Flags: runascurrentuser postinstall skipifsilent
Filename: "{app}\tools\CP210x_VCP_Windows\CP210xVCPInstaller_x86.exe"; Description: "{cm:LaunchProgram,CP210x driver installer}"; Check: not IsWin64() and not AppInstalled(True, False, '{#SilabsCP210xAppId}') ; Flags: runascurrentuser postinstall skipifsilent
Filename: "{app}\{#MyAppExeName1}"; Description: "{cm:LaunchProgram,{#StringChange(MyApp1, "&", "&&")}}"; Flags: nowait postinstall skipifsilent

[Code]
function GetNumber(var temp: String): Integer;
var
  part: String;
  pos1: Integer;
begin
  if Length(temp) = 0 then
  begin
    Result := -1;
    Exit;
  end;
	pos1 := Pos('.', temp);
	if (pos1 = 0) then
	begin
	  Result := StrToInt(temp);
	temp := '';
	end
	else
	begin
	part := Copy(temp, 1, pos1 - 1);
	  temp := Copy(temp, pos1 + 1, Length(temp));
	  Result := StrToInt(part);
	end;
end;

function CompareInner(var temp1, temp2: String): Integer;
var
  num1, num2: Integer;
begin
	num1 := GetNumber(temp1);
  num2 := GetNumber(temp2);
  if (num1 = -1) or (num2 = -1) then
  begin
    Result := 0;
    Exit;
  end;
  if (num1 > num2) then
  begin
	Result := 1;
  end
  else if (num1 < num2) then
  begin
	Result := -1;
  end
  else
  begin
	Result := CompareInner(temp1, temp2);
  end;
end;

function CompareVersion(str1, str2: String): Integer;
var
  temp1, temp2: String;
begin
	temp1 := str1;
	temp2 := str2;
	Result := CompareInner(temp1, temp2);
end;

function GetHKLM(isNative: Boolean): Integer;
begin
  if isNative then
  begin
    if IsWin64 then
    begin
      Result := HKLM64;
    end
    else
    begin
      Result := HKLM32;
    end;
  end
  else
  begin
    Result := HKLM;
  end;
end;

function GetUninstallRegKey(appId: String; isInno: Boolean): String;
begin
  Result := 'SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\' + appId;
  if isInno then
  begin
    Result := Result + '_is1';
  end;
end;

function AppInstalled(isNative, isInno: Boolean; appId: String): Boolean;
begin
  Result := RegKeyExists(GetHKLM(isNative), GetUninstallRegKey(appId, isInno));
end;

function InitializeSetup(): Boolean;
var
  oldVersion: String;
  uninstaller: String;
  ErrorCode: Integer;
  compareResult: Integer;
  appId: String;
  appName: String;
  appVersion: String;
begin
  appId := '{#MyAppId}';
  appName := '{#MyAppName}';
  appVersion := '{#MyAppVersion}'

  if not AppInstalled(False, True, appId) then
  begin
    Result := True;
    Exit;
  end;

  RegQueryStringValue(GetHKLM(False), GetUninstallRegKey(appId, TRUE), 'DisplayVersion', oldVersion);
  compareResult := CompareVersion(oldVersion, appVersion);
  if (compareResult = 0) then
  begin
    if (MsgBox(appName + ' ' + oldVersion + ' is already installed. Do you want to repair it now?',
	  mbConfirmation, MB_YESNO) = IDNO) then
	begin
	  Result := False;
	  Exit;
    end;
  end
  else
  begin
    if (MsgBox(appName + ' ' + oldVersion + ' is installed. Do you want to override it with {#MyAppVersion} now?',
	  mbConfirmation, MB_YESNO) = IDNO) then
	begin
	  Result := False;
	  Exit;
    end;
  end;
  // remove old version
  RegQueryStringValue(GetHKLM(False), GetUninstallRegKey(appId, True), 'UninstallString', uninstaller);
  ShellExec('runas', uninstaller, '/SILENT', '', SW_HIDE, ewWaitUntilTerminated, ErrorCode);
  if (ErrorCode <> 0) then
  begin
	MsgBox( 'Failed to uninstall ' + appName + ' version ' + oldVersion + '. Please restart Windows and run setup again.',
	 mbError, MB_OK );
	Result := False;
	Exit;
  end;

  Result := True;
end;
