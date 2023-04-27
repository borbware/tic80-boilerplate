mkdir build

wsl bash luacc.sh

set gamename=TIC-80-boilerplate

tic80-pro-1.0.exe --fs . --cli --cmd="load game.lua & export win build/%gamename%-%1.exe alone=1 & exit"

copy "game.lua" "build\%gamename%-%1.lua"