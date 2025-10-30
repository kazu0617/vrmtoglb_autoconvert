@echo off
chcp 65001
setlocal

set BLENDER_USER_CONFIG=%~dp0%\scripts\VRMConvert
set BLENDER_USER_SCRIPTS=%~dp0%\scripts\VRMConvert
for /f "usebackq delims=" %%A in (`powershell -command "(Get-ItemProperty HKLM:\Software\\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-Object DisplayName,DisplayVersion,InstallLocation | Where-Object {$_.DisplayName -eq \"Blender\"} | Sort -Property DisplayVersion | Select-Object -Last 1 ).DisplayVersion"`) do set version=%%A
for /f "usebackq delims=" %%A in (`powershell -command "(Get-ItemProperty HKLM:\Software\\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-Object DisplayName,DisplayVersion,InstallLocation | Where-Object {$_.DisplayName -eq \"Blender\"} | Sort -Property DisplayVersion | Select-Object -Last 1 ).InstallLocation"`) do set blender=%%A
set blender=%blender:"=%

if defined BLENDER_LOCATION_OVERRIDE (set blender=%BLENDER_LOCATION_OVERRIDE%)

for /f "usebackq delims=" %%A in (`curl --version`) do set curlresult=%%A
for /f "usebackq delims=" %%A in (`ver`) do set windowsversion=%%A

if exist "%~dp0scripts\VRM_Addon_for_Blender-release.zip" set blender-addon=true
if not exist "%~dp0scripts\VRM_Addon_for_Blender-release.zip" set blender-addon=false

echo ===Enviroment Checker. if alert to send from Dev, send it!===
echo BlenderVersion: %version%
echo BlenderInstallLocation: %blender%
echo CurlResult: %curlresult%
echo WindowsVersion: %windowsversion%
echo BlenderAddonInstalled: %blender-addon%
echo ===Enviroment Checker. if alert to send from Dev, send it!===

timeout 3


echo "VRMアドオンの最新版を取得中…"
curl -L -o "%~dp0scripts\VRM_Addon_for_Blender-release.zip" https://github.com/saturday06/VRM_Addon_for_Blender/raw/release-archive/VRM_Addon_for_Blender-release.zip

if "%blender%" == "" (
echo "Blenderが検出できませんでした。インストーラをダウンロードし、インストールします"
curl -L -o "%~dp0Blender.msi" https://mirrors.aliyun.com/blender/release/Blender3.6/blender-3.6.4-windows-x64.msi
Blender.msi
goto first
)
set blender='%blender%'

for /f "usebackq delims=" %%A in (`powershell -command "Join-Path %blender% blender.exe"`) do set blender=%%A
set blender="%blender%"
set VRM=%1
set OUTPUT="%~1-converted.glb"

echo BLENDER = %BLENDER%
echo VRM = %VRM%
echo OUTPUT = %OUTPUT%
echo ADDONFILE = "%~dp0scripts\VRM_Addon_for_Blender-release.zip"

IF NOT DEFINED BLENDER goto error-blender
IF NOT EXIST %BLENDER% goto error-blender
IF NOT DEFINED VRM goto error-drop
IF NOT EXIST %VRM% goto error-drop
IF NOT EXIST "%~dp0scripts\VRM_Addon_for_Blender-release.zip" goto error-addon

%BLENDER% "%~dp0scripts\empty.blend"^
 --python "%~dp0scripts\vrmconv.py"^
 -- --input %VRM%^
 --output %OUTPUT%^
 --addonfile "%~dp0scripts\VRM_Addon_for_Blender-release.zip"
rem --fbx True

:error-blender
echo "Blenderを標準のインストール位置から変更しているか、そもそもインストールしていない可能性があります"
echo "標準のインストール位置から変更している場合はblender.exeまでのパスが通っているか確認してください(フォルダ名まで検索した後は手動で処理しています)"
echo "Blenderのインストール場所を手動で指定する場合は BLENDER_LOCATION_OVERRIDE 環境変数にblender.exeが入っているディレクトリを指定してください"
echo "インストールしていない場合はBlender3.4以上をインストールお願いします"
echo "何かキーをクリックすると終了します"
pause
goto end

:error-drop
echo "VRMファイルをドラッグ&ドロップで入れてください"
echo "何かキーをクリックすると終了します"
pause
goto end

:error-addon
echo "アドオンのダウンロードに失敗しています"
echo "パソコンの設定を確認の上、再度実行してください(失効証明書管理サーバが正常に機能していない際にこの問題が起きることがあります)"
echo "もしくは、右のリンクから手動でダウンロードし、このbatがある階層にD&Dしてください: "
echo "https://github.com/saturday06/VRM_Addon_for_Blender/raw/release-archive/VRM_Addon_for_Blender-release.zip"
echo "何かキーをクリックすると終了します"
pause
:end

endlocal
