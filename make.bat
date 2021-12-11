echo ### starting GB build...

@REM works!
set input=main.asm

@REM works!
@REM set input=test.asm

set output=game.gb

echo %output%

@REM Works
@REM .\vasmz80_oldstyle_Win64\vasmz80_oldstyle.exe %input% -chklabels -nocase -gbz80 -Fbin -o .\bin\%output%

@REM Works
.\tools\vasm-z80-32.exe %input% -chklabels -nocase -gbz80 -Fbin -o .\bin\%output%

if %errorlevel% neq 0 exit

echo ### Applying RGBfix...

.\tools\rgbds-0.5.1-win32\rgbfix.exe -v -p 0 .\bin\%output%

echo ### Starting BGB...

.\tools\bgb\bgb.exe .\bin\%output%
exit


