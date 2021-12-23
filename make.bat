set filename=hello-world
set toolpath=.\tools\rgbds-0.5.1-win32\
set binpath=.\bin\

%toolpath%rgbasm -L -o %binpath%%filename%.o %filename%.asm
%toolpath%rgblink -o %binpath%%filename%.gb %binpath%%filename%.o
%toolpath%rgbfix -v -p 0xFF %binpath%%filename%.gb

echo ### Starting BGB...
.\tools\bgb\bgb.exe %binpath%%filename%.gb
