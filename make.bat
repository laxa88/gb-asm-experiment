@REM Silences the commands below
@echo off

set filename=05-input-move-sprite
set musicname=quasar
set toolpath=tools\rgbds-0.5.1-win32\
set binpath=bin\

echo ### Compiling files: %filename%
@REM %toolpath%rgbasm -L -o %binpath%%filename%.o %filename%.asm
%toolpath%rgbasm -o %binpath%hUGEDriver.obj -i .. include/hUGEDriver.asm
%toolpath%rgbasm -o %binpath%%musicname%.obj -i .. %musicname%.asm
%toolpath%rgbasm -o %binpath%%filename%.obj -D SONG_DESCRIPTOR=%musicname% %filename%.asm

@REM %toolpath%rgblink -o %binpath%%filename%.gb -n %binpath%%filename%.sym %binpath%%filename%.o
@REM %toolpath%rgblink -o %binpath%%filename%.gb %binpath%%filename%.obj %binpath%hUGEDriver.obj %binpath%%musicname%.obj
%toolpath%rgblink -o %binpath%%filename%.gb -n %binpath%%filename%.sym %binpath%%filename%.obj %binpath%hUGEDriver.obj %binpath%%musicname%.obj
@REM %toolpath%rgblink -n %binpath%%filename%.sym %binpath%%filename%.o %binpath%hUGEDriver.obj %binpath%%musicname%.obj

%toolpath%rgbfix -v -p 0xFF %binpath%%filename%.gb

echo ### Starting BGB...
.\tools\bgb\bgb.exe %binpath%%filename%.gb
