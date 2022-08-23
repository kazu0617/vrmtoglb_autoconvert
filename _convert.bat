@echo off
chcp 65001
setlocal
:first

set BLENDER_USER_CONFIG=%~dp0%\VRMConvert
set BLENDER_USER_SCRIPTS=%~dp0%\VRMConvert
for /f "usebackq delims=" %%A in (`powershell -command "(Get-ItemProperty HKLM:\Software\\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-Object DisplayName,DisplayVersion,InstallLocation | Where-Object {$_.DisplayName -eq \"Blender\"} | Sort -Property DisplayVersion | Select-Object -Last 1 ).DisplayVersion"`) do set version=%%A
for /f "usebackq delims=" %%A in (`powershell -command "(Get-ItemProperty HKLM:\Software\\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-Object DisplayName,DisplayVersion,InstallLocation | Where-Object {$_.DisplayName -eq \"Blender\"} | Sort -Property DisplayVersion | Select-Object -Last 1 ).InstallLocation"`) do set blender=%%A
set blender=%blender:"=%

for /f "usebackq delims=" %%A in (`curl --version`) do set curlresult=%%A
for /f "usebackq delims=" %%A in (`ver`) do set windowsversion=%%A

if exist "%~dp0VRM_Addon_for_Blender-release.zip" set blender-addon=true
if not exist "%~dp0VRM_Addon_for_Blender-release.zip" set blender-addon=false

echo ===Enviroment Checker. if alert to send from Dev, send it!===
echo BlenderVersion: %version%
echo BlenderInstallLocation: %blender%
echo CurlResult: %curlresult%
echo WindowsVersion: %windowsversion%
echo BlenderAddonInstalled: %blender-addon%
echo ===Enviroment Checker. if alert to send from Dev, send it!===

timeout 3

echo "VRMアドオンの最新版を取得中…"
curl -L -o "%~dp0VRM_Addon_for_Blender-release.zip" https://github.com/saturday06/VRM_Addon_for_Blender/raw/release-archive/VRM_Addon_for_Blender-release.zip

if "%blender%" == "" (
echo "Blenderが検出できませんでした。インストーラをダウンロードし、インストールします"
curl -L -o "%~dp0Blender.msi" https://mirrors.aliyun.com/blender/release/Blender3.2/blender-3.2.2-windows-x64.msi
Blender.msi
goto first
)
set blender='%blender%'

for /f "usebackq delims=" %%A in (`powershell -command "Join-Path %blender% blender.exe"`) do set blender=%%A
set blender="%blender%"
:cycle

set VRM=%1
set OUTPUT="%~1-converted.glb"

echo BLENDER = %BLENDER%
echo VRM = %VRM%
echo OUTPUT = %OUTPUT%
echo ADDONFILE = "%~dp0VRM_Addon_for_Blender-release.zip"

IF NOT DEFINED BLENDER goto error
IF NOT DEFINED VRM goto error-drop

%BLENDER% "%~dp0empty.blend"^
 --python "%~dp0vrmconv.py"^
 --background^
 -- --input %VRM%^
 --output %OUTPUT%^
 --addonfile "%~dp0VRM_Addon_for_Blender-release.zip"
rem --fbx True

echo "変換が正常に完了しました(スクリプトでエラーが出てくる場合があります、その場合は連絡お願いします)"
timeout 600
goto end

:error

echo "Blenderを標準のインストール位置から変更しているか、そもそもインストールしていない可能性があります"
echo "標準のインストール位置から変更している場合はkazuまで連絡お願いします"
echo "インストールしていない場合はBlender3系をインストールお願いします"
pause
goto end

:error-drop

echo "VRMファイルをドラッグ&ドロップで入れてください"
pause
:end

if not "%~2" == "" (
shift
echo check: %1
goto cycle
)

endlocal
