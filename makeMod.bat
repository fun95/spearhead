@echo off
set COMPILEDIR=%CD%
set color=1e
color %color%

echo  Checking language directories...

if not exist ..\..\zone\english mkdir ..\..\zone\english
if not exist ..\..\zone_source\english xcopy ..\..\zone_source\english ..\..\zone_source\english /SYI > NUL

echo _________________________________________________________________
echo.
echo  Building z_shift.iwd:
echo    Deleting old z_shift.iwd file...
del z_shift.iwd
echo    Adding images...
7za a -r -tzip z_shift.iwd images\*.iwi > NUL
echo    Adding sounds...
7za a -r -tzip z_shift.iwd sound\*.mp3 > NUL
7za a -r -tzip z_shift.iwd sound\*.wav > NUL

echo  New z_shift.iwd file successfully built!
echo _________________________________________________________________
echo.
echo  Building mod.ff:
echo    Deleting old mod.ff file...
del mod.ff

echo    Copying localized strings...
xcopy english ..\..\raw\english /SYI > NUL

echo    Copying game resources...
xcopy configs ..\..\raw\configs /SYI > NUL
xcopy images ..\..\raw\images /SYI > NUL
xcopy fx ..\..\raw\fx /SYI > NUL
xcopy maps ..\..\raw\maps /SYI > NUL
xcopy materials ..\..\raw\materials /SYI > NUL
xcopy sound ..\..\raw\sound /SYI > NUL
xcopy soundaliases ..\..\raw\soundaliases /SYI > NUL

echo    Copying xmodel resources...
xcopy xmodel ..\..\raw\xmodel /SYI > NUL
xcopy xmodelparts ..\..\raw\xmodelparts /SYI > NUL
xcopy xmodelsurfs ..\..\raw\xmodelsurfs /SYI > NUL

echo    Copying shift custom items...
xcopy ui_mp ..\..\raw\ui_mp /SYI > NUL
xcopy shift ..\..\raw\shift /SYI > NUL

copy /Y mod.csv ..\..\zone_source > NUL
cd ..\..\bin > NUL


echo    Compiling mod...
linker_pc.exe -language english -compress -cleanup mod 
cd %COMPILEDIR% > NUL
copy ..\..\zone\english\mod.ff > NUL
echo  New shift custom mod.ff file successfully built!
goto END


:END
echo.

pause