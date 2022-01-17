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
rgbgfx.exe -T -u -o out.2bpp in.png
```

- (optional) Use [Tilemapstudio](https://github.com/Rangi42/tilemap-studio) to visualise the output. Drag-n-drop the `.2bpp` and `.tilemap` files into Tilemapstudio and adjust as necessary. Then `Save As...` the resulting `.tilemap` file, which you can use in the next step.

- Import the `.2bpp` and `.tilemap` files in the ASM code normally, since they're all just binaries.

### Notes

Open `.gbr` files with [GameBoy Tile Designer](http://www.devrs.com/gb/hmgd/gbtd.html)