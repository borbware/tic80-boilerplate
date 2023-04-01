# TIC-80 boilerplate

This is my TIC-80 boilerplate code for multi-file projects.
During development, the project is separated into multiple .lua files, and they are combined into one for building an executable.

## Environment setup

I'm using Windows for development, so all the scripts included are for Windows. You might get the idea how to implement them for Linux/Mac by looking at them, though.

### Requirements:

* Windows PC
* TIC-80 pro
  * Add installation directory to PATH environmental variable
* WSL2 on Windows
  * luarocks
  * luacc on luarocks

### Good-to-haves:

* Visual Studio Code
* [Lua Language Server](https://marketplace.visualstudio.com/items?itemName=sumneko.lua) Extension for Visual Studio Code
* [Lua Extension](https://marketplace.visualstudio.com/items?itemName=keyring.Lua) for Visual Studio Code

### Instructions

You need TIC-80 pro to get support for .lua cartridges - WSL is used for running luarocks (I've noticed running luarocks on WSL is less error-prone than on Windows)


In WSL, install [luarocks](https://luarocks.org/):

```
sudo apt-get install luarocks
```
and then install [luacc](https://github.com/mihacooper/luacc) that is used to combine the lua files.

```
sudo luarocks install luacc
```

Luacc isn't perfect (you need to supply it with a list of files to combine), so I might change to another system later.

## TIC-80 setup

### Lua path

To get `require` statement working, I've had to explicitly add the project folder to Lua's `package.path` variable. This happens on line 10 of `main.lua` - change the path `Q:/github/tic80-boilerplate/` to your project folder. 

Note that this is only needed if you get the error `module 'libs/math' not found` when running the game; if said error never appears, you can just remove the line.

### Adding more files

When you add a new file:
* Add a new require statement for it in `main.lua`
* Add the file to `luacc.sh` so the executable works as well.

## Running

Run `runtic80.bat` in the command line. It runs `main.lua` on TIC-80 from the command line.

The savefiles are located under the project folder in the `.local` directory.

## Building

Run `buildWin.bat <version>` (e.g., `buildWin.bat 1.0`). It creates a `game.lua` file that contains all the code, and then creates a new Windows build of the game in the `/build/` folder.