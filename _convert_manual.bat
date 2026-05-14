@echo off
chcp 65001
setlocal enabledelayedexpansion

set BLENDER_USER_CONFIG=%~dp0%\scripts\VRMConvert
set BLENDER_USER_SCRIPTS=%~dp0%\scripts\VRMConvert
for /f "usebackq delims=" %%A in (`powershell -NoProfile -command "(Get-ItemProperty HKLM:\Software\\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-Object DisplayName,DisplayVersion,InstallLocation | Where-Object {$_.DisplayName -eq \"Blender\"} | Sort -Property DisplayVersion | Select-Object -Last 1 ).DisplayVersion"`) do set version=%%A
for /f "usebackq delims=" %%A in (`powershell -NoProfile -command "(Get-ItemProperty HKLM:\Software\\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-Object DisplayName,DisplayVersion,InstallLocation | Where-Object {$_.DisplayName -eq \"Blender\"} | Sort -Property DisplayVersion | Select-Object -Last 1 ).InstallLocation"`) do set blender=%%A
set blender=%blender:"=%

if defined BLENDER_LOCATION_OVERRIDE (
    set "blender=%BLENDER_LOCATION_OVERRIDE%"
    set "version="
)

rem Fallback: レジストリからバージョンを取得できない場合(Steam版等)、blender.exeから直接取得
if "%version%" == "" if defined blender (
    echo "レジストリからBlenderバージョンを検出できませんでした。blender.exeから直接取得します…"
    for /f "tokens=2 delims= " %%A in ('"%blender%\blender.exe" --version 2^>nul') do (
        if not defined version set version=%%A
    )
)

for /f "usebackq delims=" %%A in (`curl --version`) do set curlresult=%%A
for /f "usebackq delims=" %%A in (`ver`) do set windowsversion=%%A

rem Blender 4.2以上のみ対応し、Extensionシステムを使用
set supported_blender=false
for /f "tokens=1,2 delims=." %%a in ("%version%") do (
    set major=%%a
    set minor=%%b
)
if defined major (
    if !major! GEQ 5 (
        set supported_blender=true
    )
    if !major! EQU 4 if defined minor if !minor! GEQ 2 (
        set supported_blender=true
    )
)
echo.
echo ===Enviroment Checker===
echo BlenderVersion: %version%
echo BlenderInstallLocation: %blender%
echo CurlResult: %curlresult%
echo WindowsVersion: %windowsversion%

timeout 3

if "%blender%" == "" goto error-blender
if "!supported_blender!" == "false" goto error-blender-version

echo "Extension版VRMアドオンの最新版を取得中…"
for /f "usebackq delims=" %%A in (`powershell -NoProfile -command "try { $r = Invoke-RestMethod -Uri 'https://api.github.com/repos/saturday06/VRM_Addon_for_Blender/releases/latest'; ($r.assets | Where-Object { $_.name -like '*Extension*' } | Select-Object -First 1).browser_download_url } catch { Write-Output '' }"`) do set extension_url=%%A
if defined extension_url (
    curl -L -o "%~dp0scripts\VRM_Addon_for_Blender-Extension-release.zip" "!extension_url!"
) else (
    echo "Extension版のダウンロードURLの取得に失敗しました"
    goto error-addon
)
set blender='%blender%'

for /f "usebackq delims=" %%A in (`powershell -NoProfile -command "Join-Path %blender% blender.exe"`) do set blender=%%A
set blender="%blender%"

rem Extension mode: pre-install extension via Blender CLI
echo "VRM Extensionをインストール中…"
%blender% --command extension install-file "%~dp0scripts\VRM_Addon_for_Blender-Extension-release.zip" -r user_default -e

set VRM=%1
set VRM_PATH=%~1
if "%VRM_PATH:~0,2%" == "~/" set VRM_PATH=%USERPROFILE%\%VRM_PATH:~2%
if "%VRM_PATH:~0,2%" == "~\" set VRM_PATH=%USERPROFILE%\%VRM_PATH:~2%
set VRM_PATH=%VRM_PATH:/=\%
if not "%VRM_PATH%" == "" set VRM="%VRM_PATH%"
set OUTPUT="%VRM_PATH%-converted.glb"

echo.
echo ===Convert Files Checker===
echo BLENDER = %BLENDER%
echo VRM = %VRM%
echo OUTPUT = %OUTPUT%
echo EXTENSIONFILE = "%~dp0scripts\VRM_Addon_for_Blender-Extension-release.zip"
echo.
echo.

IF NOT DEFINED BLENDER goto error-blender
IF NOT EXIST %BLENDER% goto error-blender
IF NOT DEFINED VRM goto error-drop
IF NOT EXIST %VRM% goto error-drop
IF NOT EXIST "%~dp0scripts\VRM_Addon_for_Blender-Extension-release.zip" goto error-addon

echo ===Convert Start===
%BLENDER% "%~dp0scripts\empty.blend" --python "%~dp0scripts\vrmconv.py" -- --input %VRM% --output %OUTPUT%
echo ===Convert End===
echo.
echo.
goto end

:error-blender
echo "Blenderを標準のインストール位置から変更しているか、そもそもインストールしていない可能性があります"
echo "標準のインストール位置から変更している場合はblender.exeまでのパスが通っているか確認してください(フォルダ名まで検索した後は手動で処理しています)"
echo "Blenderのインストール場所を手動で指定する場合は BLENDER_LOCATION_OVERRIDE 環境変数にblender.exeが入っているディレクトリを指定してください"
echo "インストールしていない場合はBlender4.2以上をインストールお願いします"
echo "Blender公式サイト: https://www.blender.org/download/"
echo "何かキーをクリックすると終了します"
pause
goto end

:error-blender-version
echo "このツールはBlender 4.2以上でのみ動作します"
echo "検出されたBlenderバージョン: %version%"
echo "Blender 4.2 LTS以降をインストールしてください"
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
echo "https://github.com/saturday06/VRM_Addon_for_Blender/releases/latest"
echo "何かキーをクリックすると終了します"
pause
:end

endlocal
