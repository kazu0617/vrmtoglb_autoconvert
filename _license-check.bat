@echo off
chcp 65001
setlocal
:first

for /f "usebackq delims=" %%A in (`powershell -command "(Get-ItemProperty HKLM:\Software\\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-Object DisplayName,DisplayVersion,InstallLocation | Where-Object {$_.DisplayName -eq \"Blender\"} | Sort -Property DisplayVersion | Select-Object -Last 1 ).DisplayVersion"`) do set version=%%A
for /f "usebackq delims=" %%A in (`powershell -command "(Get-ItemProperty HKLM:\Software\\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-Object DisplayName,DisplayVersion,InstallLocation | Where-Object {$_.DisplayName -eq \"Blender\"} | Sort -Property DisplayVersion | Select-Object -Last 1 ).InstallLocation"`) do set blender=%%A
set blender=%blender:"=%

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
 --python "%~dp0licensecheck.py"^
 -- --input %VRM%^
 --addonfile "%~dp0VRM_Addon_for_Blender-release.zip"
goto end

:error

echo Blenderがインストールされているか確認して再度実行してください
pause
goto end

:error-drop

echo VRMファイルをドラッグ＆ドロップで入れてください
pause
:end

endlocal
