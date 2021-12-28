@REM Silences the commands below
@echo off

set filename=08-hello-world
set musicname1=pokemon_center
set musicname2=quasar
set toolpath=tools\rgbds-0.5.1-win32\
set binpath=bin\

echo ### Compiling files: %filename%
@REM https://rgbds.gbdev.io/docs/master/rgbasm.1
@REM Assemble code into .obj files
%toolpath%rgbasm -o %binpath%hUGEDriver.obj -i .. include/hUGEDriver.asm
if ERRORLEVEL 1 exit
%toolpath%rgbasm -o %binpath%%musicname1%.obj -i .. %musicname1%.asm
%toolpath%rgbasm -o %binpath%%musicname2%.obj -i .. %musicname2%.asm
if ERRORLEVEL 1 exit
%toolpath%rgbasm -o %binpath%%filename%.obj %filename%.asm
if ERRORLEVEL 1 exit

echo ### Linking files...
@REM https://rgbds.gbdev.io/docs/master/rgblink.1
@REM Link all .obj files into a .gb file, BGB debugger .sym file
%toolpath%rgblink -o %binpath%%filename%.gb -n %binpath%%filename%.sym %binpath%%filename%.obj %binpath%hUGEDriver.obj %binpath%%musicname1%.obj %binpath%%musicname2%.obj
if ERRORLEVEL 1 exit

%toolpath%rgbfix -v -p 0xFF %binpath%%filename%.gb
if ERRORLEVEL 1 exit

echo ### Starting BGB...
.\tools\bgb\bgb.exe %binpath%%filename%.gb
