@echo off
set COMPILEDIR=%CD%
set GAMEDIR="C:\COD4 - Modern Warfare"
set color=1e
color %color%


:START
cls
echo.
echo       _____ __      ___________ 
echo      / ___// /_  __/ __/__  __/            Inspired by OpenWarfare mod
echo      \__ \/ __ \/ / /_   / /               Modified by [SHIFT]Newfie{A}
echo     ___/ / / / / / __/  / / 
echo    /____/_/ /_/_/_/    /_/                 email jearle1974@gmail.com
echo
echo    SPEARHEAD INTERNATIONAL FREEZETAG
echo.

echo  Checking language directories...

if not exist %GAMEDIR%\zone\english mkdir ..\..\zone\english
if not exist %GAMEDIR%\zone_source\english xcopy ..\..\zone_source\english ..\..\zone_source\english /SYI > NUL
if not exist %GAMEDIR%\Mods\shift mkdir %GAMEDIR%\Mods\shift

echo _________________________________________________________________
echo.
echo  Building z_shift.iwd:
echo    Deleting old z_shift.iwd file...
del z_shift.iwd
del z_shift_spearhead.iwd
echo    Adding images...
7za a -r -tzip z_shift.iwd images\*.iwi > NUL
echo    Adding sounds...
7za a -r -tzip z_shift.iwd sound\shift\*.mp3 > NUL
7za a -r -tzip z_shift.iwd sound\shift\*.wav > NUL
echo    Adding spearhead sounds...
7za a -r -tzip z_shift_spearhead.iwd sound\spearhead\*.mp3 > NUL
echo    Adding weapons...
7za a -r -tzip z_shift.iwd weapons\mp\*_mp > NUL

echo  New z_shift.iwd file successfully built!
echo _________________________________________________________________
echo.
echo  Building mod.ff:
echo    Deleting old mod.ff file...
del mod.ff

echo    Copying localized strings...
xcopy english %GAMEDIR%\raw\english /SYI > NUL

echo    Copying game resources...
xcopy configs %GAMEDIR%\raw\configs /SYI > NUL
xcopy images %GAMEDIR%\raw\images /SYI > NUL
xcopy fx %GAMEDIR%\raw\fx /SYI > NUL
xcopy maps %GAMEDIR%\raw\maps /SYI > NUL
xcopy materials %GAMEDIR%\raw\materials /SYI > NUL
xcopy sound %GAMEDIR%\raw\sound /SYI > NUL
xcopy soundaliases %GAMEDIR%\raw\soundaliases /SYI > NUL

echo    Copying xmodel resources...
xcopy xmodel %GAMEDIR%\raw\xmodel /SYI > NUL
xcopy xmodelparts %GAMEDIR%\raw\xmodelparts /SYI > NUL
xcopy xmodelsurfs %GAMEDIR%\raw\xmodelsurfs /SYI > NUL

echo    Copying shift custom items...
xcopy ui_mp %GAMEDIR%\raw\ui_mp /SYI > NUL
xcopy shift %GAMEDIR%\raw\shift /SYI > NUL

copy /Y mod.csv %GAMEDIR%\zone_source > NUL
cd %GAMEDIR%\bin > NUL

echo    Compiling mod...
cd %GAMEDIR%\bin > NUL
linker_pc.exe -language english -compress -cleanup mod 
cd %COMPILEDIR% > NUL
copy %GAMEDIR%\zone\english\mod.ff > NUL

echo f | xcopy config.cfg %GAMEDIR%\Mods\shift\config.cfg /Y > NUL
xcopy configs %GAMEDIR%\Mods\shift\configs /SYI > NUL
xcopy *.iwd %GAMEDIR%\Mods\shift /Y > NUL
echo f | xcopy mod.ff %GAMEDIR%\Mods\shift\mod.ff /Y > nul

echo  New shift custom mod.ff file successfully built!
goto RUN_GAME


:RUN_GAME
echo _________________________________________________________________
echo.
echo  Please choose option:
echo    1. Start COD4 multiplayer
echo    2. Exit
echo.

choice /C:12 /T 10 /D 2
if errorlevel 2 goto FINAL
if errorlevel 1 goto STARTGAME
goto RUN_GAME

:STARTGAME
cd %GAMEDIR% > NUL
start iw3mp.exe +set developer 0 +set fs_game mods/shift +exec config.cfg +set dedicated 0 +set developer 1 +set sv_punkbuster 0 +map_rotate

:FINAL