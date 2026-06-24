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

REM Some mods nest the actual mod contents in a same-named subfolder, e.g.
REM mymods\PseudoSaltRecipes\PseudoSaltRecipes\{42,common} - detect that and
REM copy from the nested folder instead of the outer one (which also holds
REM doc\ and isn't itself a valid mod folder).
set "SOURCE_DIR=%SOURCE_ROOT%"
if exist "%SOURCE_ROOT%\%MOD_NAME%\42" (
    set "SOURCE_DIR=%SOURCE_ROOT%\%MOD_NAME%"
) else if exist "%SOURCE_ROOT%\%MOD_NAME%\common" (
    set "SOURCE_DIR=%SOURCE_ROOT%\%MOD_NAME%"
)

if not exist "%MODS_DIR%" (
    echo ERROR: Target mods directory not found: %MODS_DIR%
    exit /b 1
)

set "TARGET_DIR=%MODS_DIR%\%MOD_NAME%"

echo Copying mod "%MOD_NAME%"
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
