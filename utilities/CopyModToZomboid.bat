@echo off
setlocal enabledelayedexpansion

REM Copies a mod from mymods\<ModName> into a Project Zomboid mods directory,
REM overwriting whatever is currently there.
REM
REM Usage:
REM   CopyModToZomboid.bat <ModName> [TargetModsDir]
REM
REM   ModName        Name of the mod folder under mymods\ to copy (required).
REM   TargetModsDir  Optional. Destination mods directory. If omitted, falls
REM                  back to the ZOMBOID_MODS_DIR environment variable, then
REM                  to %USERPROFILE%\Zomboid\mods if that isn't set either.
REM
REM Examples:
REM   CopyModToZomboid.bat PseudoSaltRecipes
REM   CopyModToZomboid.bat PseudoSaltRecipes D:\Games\Zomboid\mods
REM   set ZOMBOID_MODS_DIR=D:\Games\Zomboid\mods
REM   CopyModToZomboid.bat PseudoSaltRecipes

if "%~1"=="" (
    echo Usage: %~nx0 ^<ModName^> [TargetModsDir]
    echo.
    echo   ModName        Name of the mod folder under mymods\ to copy.
    echo   TargetModsDir  Optional. Overrides the destination mods directory.
    echo                  Falls back to the ZOMBOID_MODS_DIR environment
    echo                  variable, then to %%USERPROFILE%%\Zomboid\mods.
    exit /b 1
)

set "MOD_NAME=%~1"
set "SCRIPT_DIR=%~dp0"
set "SOURCE_ROOT=%SCRIPT_DIR%..\mymods\%MOD_NAME%"

if not "%~2"=="" (
    set "MODS_DIR=%~2"
) else if not "%ZOMBOID_MODS_DIR%"=="" (
    set "MODS_DIR=%ZOMBOID_MODS_DIR%"
) else (
    set "MODS_DIR=%USERPROFILE%\Zomboid\mods"
)

if not exist "%SOURCE_ROOT%" (
    echo ERROR: Source mod folder not found: %SOURCE_ROOT%
    exit /b 1
)

REM Some mods nest the actual mod contents in a subfolder instead of having
REM 42\/common\ directly under mymods\<ModName> - e.g.
REM mymods\PseudoSaltRecipes\PseudoSaltRecipes\{42,common} (nested folder
REM matches ModName) or mymods\PseudoSaltWell42_19\PseudoSaltWell\{42,common}
REM (nested folder does NOT match ModName - ModName here is just a dev-cycle
REM label, the real mod id is the nested folder's name). Detect either case
REM by scanning immediate subfolders of mymods\<ModName> (skipping doc\ and
REM .git\) for one containing 42\ or common\, and use that subfolder's own
REM name as the target folder name, since that's what the mod actually is.
set "SOURCE_DIR="
set "TARGET_NAME=%MOD_NAME%"

if exist "%SOURCE_ROOT%\42" (
    set "SOURCE_DIR=%SOURCE_ROOT%"
) else if exist "%SOURCE_ROOT%\common" (
    set "SOURCE_DIR=%SOURCE_ROOT%"
) else (
    set "MATCH_COUNT=0"
    for /d %%D in ("%SOURCE_ROOT%\*") do (
        if /i not "%%~nxD"=="doc" if /i not "%%~nxD"==".git" (
            if exist "%%D\42" (
                set /a MATCH_COUNT+=1
                set "SOURCE_DIR=%%D"
                set "TARGET_NAME=%%~nxD"
            ) else if exist "%%D\common" (
                set /a MATCH_COUNT+=1
                set "SOURCE_DIR=%%D"
                set "TARGET_NAME=%%~nxD"
            )
        )
    )
    if not "!MATCH_COUNT!"=="1" (
        echo ERROR: Could not find a unique mod folder ^(with 42\ or common\^) under %SOURCE_ROOT%
        echo Found !MATCH_COUNT! candidate^(s^). Pass the exact mod folder yourself if this is ambiguous.
        exit /b 1
    )
)

if not exist "%MODS_DIR%" (
    echo ERROR: Target mods directory not found: %MODS_DIR%
    exit /b 1
)

set "TARGET_DIR=%MODS_DIR%\%TARGET_NAME%"

echo Copying mod "%TARGET_NAME%"
echo   From: %SOURCE_DIR%
echo   To:   %TARGET_DIR%
echo.

REM /MIR mirrors the source into the target, overwriting changed files and
REM removing anything in the target that isn't in the source. doc\ and .git\
REM are excluded since they aren't part of the shipped mod.
robocopy "%SOURCE_DIR%" "%TARGET_DIR%" /MIR /XD doc .git /NFL /NDL /NJH

set "RC=%ERRORLEVEL%"
if %RC% GEQ 8 (
    echo ERROR: robocopy failed with exit code %RC%
    exit /b %RC%
)

echo Done.
exit /b 0
