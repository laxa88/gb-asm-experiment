# Experimental Game Boy Assembly Project

Just a bunch of template code, teaching myself how to make a simple Game Boy game. My goal is to complete a game like "tic tac toe" which includes all the basic features that comprise a game:

- Tiled background images
- Sprite images with animations
- Input
- Music and SFX

### Environment

This project is developed using Visual Studio Code on a Windows machine.

### Build

Run `make.bat`, which should build and open the `.gb` game in BGB emulator.

### Static image workflow

- Create image in your favourite art program, e.g. MSPaint, export it in `.png` format. Make sure to use the correct number of shades (i.e. 4 shades of grey). One way to get an accurate color palette is to use [Game Boy Tile Designer](http://www.devrs.com/gb/hmgd/gbtd.html) to draw 4 dots of the 4-colour palette, then CTRL+C the tile and CTRL+V it into your art program (yes, it's that convenient!)

- Use [RGBGFX](https://rgbds.gbdev.io/docs/master/rgbgfx.1) to convert the PNG into the GB ASM binaries, e.g. the following command will output two files, `out.2bpp` and `in.tilemap`:

```
// -T = also generates .tilemap file
// -u = unique tiles (remove duplicate tiles in output 2bpp file)
rgbgfx.exe -T -o rps-text.2bpp rps-text.png
rgbgfx.exe -T -u -o rps-title.2bpp rps-title.png
rgbgfx.exe -T -u -o rps-hands.2bpp rps-hands.png
```

- Use [Tilemapstudio](https://github.com/Rangi42/tilemap-studio) to visualise the output. Drag-n-drop the `.2bpp` and `.tilemap` files into Tilemapstudio and adjust as necessary. Then `Save As...` the resulting `.tilemap` file, which you can use in the next step. The visible area is 20x18, but the full BG map is 32x32, so make sure to adjust the width to `32` in Tilemapstudio and save the `.tilemap` before using it as a static title image in the game.

- Import the `.2bpp` and `.tilemap` files in the ASM code normally, since they're all just binaries.

### SFX workflow

- Download ZIP file or clone repository from: https://github.com/Zal0/GBSoundDemo
- Open the `.gb` file using an emulator (e.g. BGB emulator)
- Tinker with the values until you find a sound you like
- Copy the values into your game and call it whenever you want, e.g.

```
; The values provided for NR10-14: 45, 80, A6, CE, 86
PlaySfx:
  push af
    ld a, $45
    ld [rNR10], a
    ld a, $80
    ld [rNR11], a
    ld a, $a6
    ld [rNR12], a
    ld a, $ce
    ld [rNR13], a
    ld a, $86
    ld [rNR14], a
  pop af
  ret
```

### Notes

Open `.gbr` files with [GameBoy Tile Designer](http://www.devrs.com/gb/hmgd/gbtd.html)