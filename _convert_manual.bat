@echo off
chcp 65001
setlocal enabledelayedexpansion

set BLENDER_USER_CONFIG=%~dp0%\scripts\VRMConvert
set BLENDER_USER_SCRIPTS=%~dp0%\scripts\VRMConvert
for /f "usebackq delims=" %%A in (`powershell -command "(Get-ItemProperty HKLM:\Software\\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-Object DisplayName,DisplayVersion,InstallLocation | Where-Object {$_.DisplayName -eq \"Blender\"} | Sort -Property DisplayVersion | Select-Object -Last 1 ).DisplayVersion"`) do set version=%%A
for /f "usebackq delims=" %%A in (`powershell -command "(Get-ItemProperty HKLM:\Software\\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-Object DisplayName,DisplayVersion,InstallLocation | Where-Object {$_.DisplayName -eq \"Blender\"} | Sort -Property DisplayVersion | Select-Object -Last 1 ).InstallLocation"`) do set blender=%%A
set blender=%blender:"=%

if defined BLENDER_LOCATION_OVERRIDE (
    set blender=%BLENDER_LOCATION_OVERRIDE%
    set version=
)
set blender=%blender:"=%

rem Fallback: レジストリからバージョンを取得できない場合(Steam版等)、blender.exeから直接取得
if "%version%" == "" if defined blender (
    echo "レジストリからBlenderバージョンを検出できませんでした。blender.exeから直接取得します…"
    set blender_for_version=%blender%
    if /i not "!blender_for_version:~-11!"=="blender.exe" set blender_for_version=!blender_for_version!\blender.exe
    for /f "tokens=2 delims= " %%A in ('"!blender_for_version!" --version 2^>nul') do (
        if not defined version set version=%%A
    )
)

for /f "usebackq delims=" %%A in (`curl --version`) do set curlresult=%%A
for /f "usebackq delims=" %%A in (`ver`) do set windowsversion=%%A

rem Blender 4.2以上ではExtensionシステムを使用
set use_extension=false
set major=0
set minor=0
for /f "tokens=1,2 delims=." %%a in ("%version%") do (
    set major=%%a
    set minor=%%b
)
if "!minor!"=="" set minor=0
if defined major (
    if !major! GEQ 5 set use_extension=true
    if !major! EQU 4 if !minor! GEQ 2 set use_extension=true
)

if "!use_extension!" == "true" (
    if exist "%~dp0scripts\VRM_Addon_for_Blender-Extension-release.zip" (set blender-addon=true) else (set blender-addon=false)
) else (
    if exist "%~dp0scripts\VRM_Addon_for_Blender-release.zip" (set blender-addon=true) else (set blender-addon=false)
)

echo ===Enviroment Checker. if alert to send from Dev, send it!===
echo BlenderVersion: %version%
echo BlenderInstallLocation: %blender%
echo CurlResult: %curlresult%
echo WindowsVersion: %windowsversion%
echo BlenderAddonInstalled: !blender-addon!
echo UseExtension: !use_extension!
echo ===Enviroment Checker. if alert to send from Dev, send it!===

timeout 3


if "!use_extension!" == "true" (
    echo "Extension版VRMアドオンの最新版を取得中…"
    for /f "usebackq delims=" %%A in (`powershell -command "try { $r = Invoke-RestMethod -Uri 'https://api.github.com/repos/saturday06/VRM_Addon_for_Blender/releases/latest'; ($r.assets | Where-Object { $_.name -like '*Extension*' } | Select-Object -First 1).browser_download_url } catch { Write-Output '' }"`) do set extension_url=%%A
    if defined extension_url (
        curl -L -o "%~dp0scripts\VRM_Addon_for_Blender-Extension-release.zip" "!extension_url!"
    ) else (
        echo "Extension版のダウンロードURLの取得に失敗しました"
        goto error-addon
    )
) else (
    echo "VRMアドオンの最新版を取得中…"
    curl -L -o "%~dp0scripts\VRM_Addon_for_Blender-release.zip" https://github.com/saturday06/VRM_Addon_for_Blender/raw/release-archive/VRM_Addon_for_Blender-release.zip
)

if "%blender%" == "" (
echo "Blenderが検出できませんでした。インストーラをダウンロードし、インストールします"
curl -L -o "%~dp0Blender.msi" https://mirrors.aliyun.com/blender/release/Blender3.6/blender-3.6.4-windows-x64.msi
Blender.msi
goto first
)
if /i "!blender:~-11!"=="blender.exe" (
    set blender="%blender%"
) else (
    set blender='%blender%'
    for /f "usebackq delims=" %%A in (`powershell -command "Join-Path %blender% blender.exe"`) do set blender=%%A
    set blender="%blender%"
)

rem Extension mode: pre-install extension via Blender CLI
if "!use_extension!" == "true" (
    echo "VRM Extensionをインストール中…"
    %blender% --command extension install-file "%~dp0scripts\VRM_Addon_for_Blender-Extension-release.zip" -r user_default -e
    if errorlevel 1 goto error-addon
)

set VRM=%1
set OUTPUT="%~1-converted.glb"

echo BLENDER = %BLENDER%
echo VRM = %VRM%
echo OUTPUT = %OUTPUT%
if "!use_extension!" == "true" (
    echo ADDONFILE = Extension mode
) else (
    echo ADDONFILE = "%~dp0scripts\VRM_Addon_for_Blender-release.zip"
)

IF NOT DEFINED BLENDER goto error-blender
IF NOT EXIST %BLENDER% goto error-blender
IF NOT DEFINED VRM goto error-drop
IF NOT EXIST %VRM% goto error-drop
if "!use_extension!" == "true" (
    IF NOT EXIST "%~dp0scripts\VRM_Addon_for_Blender-Extension-release.zip" goto error-addon
) else (
    IF NOT EXIST "%~dp0scripts\VRM_Addon_for_Blender-release.zip" goto error-addon
)

if "!use_extension!" == "true" (
    %BLENDER% "%~dp0scripts\empty.blend" --python "%~dp0scripts\vrmconv.py" -- --input %VRM% --output %OUTPUT%
) else (
    %BLENDER% "%~dp0scripts\empty.blend" --python "%~dp0scripts\vrmconv.py" -- --input %VRM% --output %OUTPUT% --addonfile "%~dp0scripts\VRM_Addon_for_Blender-release.zip"
)
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
