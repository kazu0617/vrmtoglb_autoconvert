@echo off
chcp 65001
setlocal

if exist "C:\Program Files\Blender Foundation\Blender 2.83\blender.exe" set BLENDER="C:\Program Files\Blender Foundation\Blender 2.83\blender.exe"
if exist "C:\Program Files\Blender Foundation\Blender 2.93\blender.exe" set BLENDER="C:\Program Files\Blender Foundation\Blender 2.93\blender.exe"
if exist "C:\Program Files\Blender Foundation\Blender 3.0\blender.exe" set BLENDER="C:\Program Files\Blender Foundation\Blender 3.0\blender.exe"
if exist "C:\Program Files\Blender Foundation\Blender 3.2\blender.exe" set BLENDER="C:\Program Files\Blender Foundation\Blender 3.2\blender.exe"
if exist "C:\Program Files\Blender Foundation\Blender\blender.exe" set BLENDER="C:\Program Files\Blender Foundation\Blender\blender.exe"
if exist "C:\Program Files (x86)\Steam\steamapps\common\Blender\blender.exe" set BLENDER="C:\Program Files (x86)\Steam\steamapps\common\Blender\blender.exe"

curl -L -o "%~dp0VRM_Addon_for_Blender-release.zip" https://github.com/saturday06/VRM_Addon_for_Blender/raw/release-archive/VRM_Addon_for_Blender-release.zip

set VRM=%1

echo BLENDER = %BLENDER%
echo VRM = %VRM%
echo ADDONFILE = "%~dp0VRM_Addon_for_Blender-release.zip"

IF NOT DEFINED BLENDER goto error
IF NOT DEFINED VRM goto error-drop

%BLENDER% "%~dp0empty.blend"^
 --python "%~dp0licensecheck.py"^
 -- --input %VRM%^
 --addonfile "%~dp0VRM_Addon_for_Blender-release.zip"

echo ライセンス確認お願いします
goto end

:error

echo Blenderがインストールされているか確認して再度実行してください
pause
goto end

:error-drop

echo VRMファイルをドラッグ＆ドロップで入れてください
pause
:end

del "%~dp0VRM_Addon_for_Blender-release.zip"

endlocal
