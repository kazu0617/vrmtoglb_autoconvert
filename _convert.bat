@echo off
chcp 65001
setlocal enabledelayedexpansion
:first

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

:cycle

set VRM=%1
set VRM_PATH=%~1
if "%VRM_PATH:~0,2%" == "~/" set VRM_PATH=%USERPROFILE%\%VRM_PATH:~2%
if "%VRM_PATH:~0,2%" == "~\" set VRM_PATH=%USERPROFILE%\%VRM_PATH:~2%
set VRM_PATH=%VRM_PATH:/=\%
if not "%VRM_PATH%" == "" set VRM="%VRM_PATH%"
set OUTPUT="%VRM_PATH%-converted.glb"
for %%F in ("%VRM_PATH%") do set VRM_DIR=%%~dpF

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
%BLENDER% "%~dp0scripts\empty.blend" --python "%~dp0scripts\vrmconv.py" --background -- --input %VRM% --output %OUTPUT%
echo ===Convert End===
echo.
echo.

:select-license
if not exist %OUTPUT% (

    echo "GLBファイルが正常に出力されていません。"
    echo "このパネルを上に戻っていただき、ライセンス上問題があるファイルかどうか確認してください"
    echo "(問題のあるファイルの場合、その旨記載があります)"
    echo.

    set /p Select="ライセンス上問題のあるファイルでしたか？: [Y]はい / [N]いいえ:"

    echo Select is !Select!
    if '!Select!' == 'y' goto license-check
    if '!Select!' == 'Y' goto license-check
    if "!Select!" == "Yes" goto license-check
    if "!Select!" == "はい" goto license-check
    if "!Select!" == ""  goto select-license


    echo.
    echo "ライセンス上問題ないファイルで正常に変換できていない場合はbat自体の問題の可能性があります"
    echo "上のログを全てコピーした上で作者に連絡してください"
    echo "何かキーをクリックすると終了します"
    pause

    goto end

)

echo "変換が完了しファイルが生成されました"
echo.
echo "Resoniteにインポートするファイル・フォルダは以下の二つです"
echo.
echo %OUTPUT%
echo %VRM_DIR% "に生成された.texturesフォルダ"
echo.
echo.
echo "フォルダの方はテクスチャが正常に紐つかない場合に使用していただき"
echo "テクスチャがglbファイルインポート時にそのまま紐ついた場合は[x]マークで削除してください"
echo.
echo.
echo.
echo.
echo "スクリプトでエラーが出てくる場合があります"
echo "もし正常に変換できていない場合は"
echo "上のログを全てコピーした上で作者に連絡してください"
echo "何かキーをクリックすると終了します"
timeout 600
goto end

:license-check
echo "ライセンス上問題のあるファイルでも強制的に読み込むことは可能です"
echo "問題が発生した場合に自己責任となりますが、本当に変換しますか？"
echo "変換する場合は「自己の責任の下変換します」と入力後、最後に句点を追加してください(途中や最後にスペースなどは入れないでください)"
echo "変換しない場合はこのまま×を押していただくか、「変換しません」など他の文章を入力してください"
echo "---"
echo.
echo.
set /p Select="本当に変換しますか？: "

if "!Select!" == "自己の責任の下変換します。" (
    cls
    echo.
    echo.
    echo "以下に「LICENSE」と入力してください"
    set /p Select="入力お願いします: "
    set BLENDER_VRM_AUTOMATIC_!Select!_CONFIRMATION=true
    goto first
)
cls
echo.
echo.
echo "ライセンスを確認した上でインポートしてください(Please Check License First)。"
echo "何かキーをクリックすると終了します"
pause
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

if not "%~2" == "" (
shift
echo cycle_check: %1
goto cycle
)

endlocal
