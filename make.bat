@REM Silences the commands below
@echo off

set filename=08-hello-world
set musicname=pokemon_center
set toolpath=tools\rgbds-0.5.1-win32\
set binpath=bin\

echo ### Compiling files: %filename%
@REM https://rgbds.gbdev.io/docs/master/rgbasm.1
@REM Assemble code into .obj files
%toolpath%rgbasm -o %binpath%hUGEDriver.obj -i .. include/hUGEDriver.asm
if ERRORLEVEL 1 exit
%toolpath%rgbasm -o %binpath%%musicname%.obj -i .. %musicname%.asm
if ERRORLEVEL 1 exit
%toolpath%rgbasm -o %binpath%%filename%.obj -D SONG_DESCRIPTOR=%musicname% %filename%.asm
if ERRORLEVEL 1 exit

echo ### Linking files...
@REM https://rgbds.gbdev.io/docs/master/rgblink.1
@REM Link all .obj files into a .gb file, BGB debugger .sym file
%toolpath%rgblink -o %binpath%%filename%.gb -n %binpath%%filename%.sym %binpath%%filename%.obj %binpath%hUGEDriver.obj %binpath%%musicname%.obj
if ERRORLEVEL 1 exit

%toolpath%rgbfix -v -p 0xFF %binpath%%filename%.gb
if ERRORLEVEL 1 exit

echo ### Starting BGB...
.\tools\bgb\bgb.exe %binpath%%filename%.gb
