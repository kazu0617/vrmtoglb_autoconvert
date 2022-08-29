@echo off
chcp 65001
setlocal enabledelayedexpansion
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

echo.
echo ===Enviroment Checker===
echo BlenderVersion: %version%
echo BlenderInstallLocation: %blender%
echo CurlResult: %curlresult%
echo WindowsVersion: %windowsversion%
echo BlenderAddonInstalled: %blender-addon%

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

echo.
echo ===Convert Files Checker===
echo BLENDER = %BLENDER%
echo VRM = %VRM%
echo OUTPUT = %OUTPUT%
echo ADDONFILE = "%~dp0VRM_Addon_for_Blender-release.zip"
echo.
echo.

IF NOT DEFINED BLENDER goto error
IF NOT DEFINED VRM goto error-drop

echo ===Convert Start===
%BLENDER% "%~dp0empty.blend"^
 --python "%~dp0vrmconv.py"^
 --background^
 -- --input %VRM%^
 --output %OUTPUT%^
 --addonfile "%~dp0VRM_Addon_for_Blender-release.zip"
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
echo "Neosにインポートするファイル・フォルダは以下の二つです"
echo.
echo %OUTPUT%
echo %~dp1% "に生成された.texturesフォルダ"
echo.
echo.
echo "フォルダの方はテクスチャが正常に紐つかない場合に使用していただき"
echo "テクスチャがglbファイルインポート時にそのまま紐ついた場合は[x]マークで削除してください"
echo "詳しくは[NeosVR日本語非公式Wiki]をご確認ください"
echo.
echo.
echo.
echo "スクリプトでエラーが出てくる場合があります"
echo "もし正常に変換できていない場合は"
echo "上のログを全てコピーした上で作者に連絡してください"
echo "何かキーをクリックすると終了します"
timeout 600
goto end

:error

echo "Blenderを標準のインストール位置から変更しているか、そもそもインストールしていない可能性があります"
echo "標準のインストール位置から変更している場合はkazuまで連絡お願いします"
echo "インストールしていない場合はBlender3系をインストールお願いします"
echo "何かキーをクリックすると終了します"
pause
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

:error-drop
echo "VRMファイルをドラッグ&ドロップで入れてください"
echo "何かキーをクリックすると終了します"
pause
:end

if not "%~2" == "" (
shift
echo cycle_check: %1
goto cycle
)

endlocal
