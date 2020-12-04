# Goldsource Sentences Pal

With GSP you can automatically read all the sentences.txt sounds of a goldsource game to select and copy them into a separate folder.

Why?

Because this means we can easily identify **MANY** sounds that weren't actually used, especially in relation to the VOX system, and also replace files more safely, since "mods" like Opposing Force pull many sentence.txt audios directly from the "valve" folder instead of their own.

As you can see, this script solves a **VERY SPECIFIC** problem: make dubbing and personalizing the game sound more practical.

That's it! I hope it'll be useful to someone like it was [for me](https://www.moddb.com/mods/half-life-1-dublado-pt-br)!

# Usage

Just execute **Run GSP.bat** and it'll run in a self-explanatory way. The sounds will be copied to a new local folder called "sentences".

If you want to run the script manually, just start gsp.lua using the included lua executable. The program will ask for a game mod folder, but you can also pass it as the first parameter. E.g.
> cd "C:/Users/vdale/Desktop/Goldsource-Sentences-Pal/lua"
> .\core\lua54.exe ./gsp.lua "E:/SteamLibrary/steamapps/common/Half-Life/gearbox"
