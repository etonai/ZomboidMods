@echo off
setlocal enabledelayedexpansion

REM Copies a mod from mymods\<ModName> into a Project Zomboid Workshop staging
REM folder, overwriting whatever is currently there.
REM
REM Usage:
REM   DeployModToWorkshop.bat <ModName> [WorkshopDir]
REM
REM   ModName      Name of the mod folder under mymods\ to copy (required).
REM   WorkshopDir  Optional. Workshop root directory. If omitted, falls back
REM                to the ZOMBOID_WORKSHOP_DIR environment variable, then to
REM                %%USERPROFILE%%\Zomboid\Workshop if that isn't set either.
REM
REM The mod is placed at WorkshopDir\<TargetName>\Contents\mods\<TargetName>,
REM matching the folder layout Project Zomboid's Workshop upload tooling
REM expects (a "Contents\mods\<ModID>" folder per workshop item). TargetName
REM is the actual mod's own folder name (see detection notes below) - the
REM ModName argument may just be a dev-cycle/wrapper label and has no bearing
REM on how the mod is identified once deployed.
REM
REM Examples:
REM   DeployModToWorkshop.bat PseudoSaltWell42_19
REM   DeployModToWorkshop.bat PseudoSaltWell42_19 D:\Games\Zomboid\Workshop
REM   set ZOMBOID_WORKSHOP_DIR=D:\Games\Zomboid\Workshop
REM   DeployModToWorkshop.bat PseudoSaltWell42_19

if "%~1"=="" (
    echo Usage: %~nx0 ^<ModName^> [WorkshopDir]
    echo.
    echo   ModName      Name of the mod folder under mymods\ to copy.
    echo   WorkshopDir  Optional. Overrides the Workshop root directory.
    echo                Falls back to the ZOMBOID_WORKSHOP_DIR environment
    echo                variable, then to %%USERPROFILE%%\Zomboid\Workshop.
    exit /b 1
)

set "MOD_NAME=%~1"
set "SCRIPT_DIR=%~dp0"
set "SOURCE_ROOT=%SCRIPT_DIR%..\mymods\%MOD_NAME%"

if not "%~2"=="" (
    set "WORKSHOP_DIR=%~2"
) else if not "%ZOMBOID_WORKSHOP_DIR%"=="" (
    set "WORKSHOP_DIR=%ZOMBOID_WORKSHOP_DIR%"
) else (
    set "WORKSHOP_DIR=%USERPROFILE%\Zomboid\Workshop"
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

if not exist "%WORKSHOP_DIR%" (
    echo ERROR: Workshop directory not found: %WORKSHOP_DIR%
    exit /b 1
)

set "TARGET_DIR=%WORKSHOP_DIR%\%TARGET_NAME%\Contents\mods\%TARGET_NAME%"

echo Deploying mod "%TARGET_NAME%"
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
