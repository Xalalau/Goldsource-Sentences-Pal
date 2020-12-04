local info = [[
	========================
	Goldsource Sentences Pal
	========================    V. 1.0

	2020 Xalalau Xubilozo. MIT License
	https://xalalau.com/
	https://www.moddb.com/news/mesa-preta-dubs
]]

--[[
	GSP solves a VERY SPECIFIC problem: having all the sentences.txt
	sounds of a goldsource game selected and copied into a separate
	folder.

	This means we can easily identify MANY sounds that weren't used,
	especially in relation to the VOX system, and replace files more
	safely, since "mods" like Opposing Force pull many sentence.txt
	audios directly from the "valve" folder instead of their own.

	That's it, I hope it'll be useful to someone.

	Usage: open the CMD and execute lua54.exe gsp.lua typing the HL1
	"mod" full path (the folder	containging the "sound" directory) as
	the first parameter, then the rest is automatic.

	e.g.
	cd "C:/Users/vdale/Desktop/GSP"
	.\core\lua54.exe gsp.lua "E:/SteamLibrary/steamapps/common/Half-Life/gearbox"

--]]

-- Check if a directory or a folder exist
local function Exists(path)
	path = "\"" .. path .. "\"" -- Note: somehow doing this concat outside popen is workarounding a "bug" where the script thinks the path is nil when it's not -- and it's a rare thing...
	return io.popen("if exist " .. path .. " (echo 1)"):read'*l'=='1'
end

-- Split strings by spaces
local function SplitSpaces(line)
	local chunks = {}

	for substring in line:gmatch("%S+") do
	   table.insert(chunks, substring)
	end

	return chunks
end

-- Create folder tree
local function CreateDirTree(path)
	os.execute("mkdir \"" .. path .. "\"")
end

-- Get a line and:
-- return nil if invalid;
-- return a table of sounds and their folder if valid.
local function FormatLine(line)
	if string.find(line, "//") then return nil end
	line = string.gsub(line, "\t", " ") -- Remove tabs
	if line == "" then return nil end
	line = string.gsub(line, ",", "") -- Remove commas
	line = string.gsub(line, "%b()", " ") -- Change "(...)" for a space (this space prevents some words from joining)
	line = string.gsub(line, ".-%s(.*)", "%1") -- Remove the sentence name
	line = string.gsub(line, "%s+", " ") -- Remove multiple spaces
	line = string.gsub(line, "%.", "") -- Remove dots

	local folder = string.match(line, "^(.*/)") or "vox/" -- Store the folder separately
	folder = string.gsub(folder, "/", "")

	line = string.gsub(line, folder .. "/", "") -- Remove the folder

	local sounds = SplitSpaces(line) -- Store the sounds in a table

	return sounds, folder
end

-- Print the results in the console and in the log file
local function PrintLog(logFiles, sound, result)
	-- Specific log
	if logFiles[result] then
		logFiles[result]:write(sound .. "\n")
	end

	-- General log
	local text = sound .. ":" .. "\n" .. "\t" .. result .. "\n"
	print(text)
	logFiles["General"]:write(text .. "\n")
end

-- Get the file from the correct mounting folder
local function SearchMountings(mounting, relPath)
	for i = #mounting, 1, -1 do
		if mounting[i] then
			local searchSound = mounting[i] .. relPath

			if Exists(searchSound) then
				return searchSound, i
			end
		end
	end
end

-- Copy the sentences.txt current line sounds
local function CopySounds(sentencesDir, mounting, logFiles, fileCounter, curSounds, curSoundsFolder)
	local toFolder =  sentencesDir .. "/sound/" .. curSoundsFolder

	if not Exists(toFolder) then
		CreateDirTree(toFolder)
	end

	for _,fileName in pairs(curSounds) do
		local shortFilename = curSoundsFolder .. "/" .. fileName .. ".wav"
		local outFilename = toFolder .. "/" .. fileName .. ".wav"

		if Exists(outFilename) then
			--PrintLog(logFiles, shortFilename, "Has already been copied") -- This message floods the logs
		else
			local inFilename, index = SearchMountings(mounting, "/sound/" .. curSoundsFolder .. "/" .. fileName .. ".wav")

			if not inFilename then
				PrintLog(logFiles, shortFilename, "Not found")
			else
				local inFile = io.open(inFilename, "rb")
				local outFile = io.open(outFilename, "wb")

				if outFile:write(inFile:read("*all")) then
					PrintLog(logFiles, shortFilename, "Copied from " .. string.gsub(mounting[index], ".+/(.*)", "%1"))
					fileCounter[index] = fileCounter[index] + 1
				else
					PrintLog(logFiles, shortFilename, "Found but not copied")
				end

				outFile:close()
				inFile:close()
			end
		end
	end
end

local function Start()
	print(info)

	-- Execution identifier
	local dateCode = string.gsub(os.date("%d %b %Y - %Hh %Mm %Ss"), "[/:-]", {["/"] = "-", [":"] = "."})
	local luaDir = string.gsub(io.popen"cd":read'*l', "\\", "/")

	-- Main directories
	local inDir = arg[1] -- Full mod path

	if not inDir then
		io.write('TYPE or DRAG AND DROP the HL1 mod folder and press Enter:\n\n')
		inDir = io.read()
		print()
	end

	inDir = string.gsub(string.gsub(inDir, "\"", ""), "\\", "/")
	local inDirRel = string.gsub(inDir, ".+/(.*)", "%1") -- The relative mod path (inside "Half-Life" folder)

	if not Exists(inDir) then
		print("\nERROR - Your mod directory is invalid.\n")
		return
	end

	local sentencesDir = string.match(luaDir, "(.+/)") .. "sentences/" .. dateCode
	local logsDir = sentencesDir .. "/logs"

	local HLDir = string.sub(string.match(inDir, "(.+/)"), 1, #string - 2) -- Full Half-Life path (inside "common" folder)

	local mounting = {                                                                   -- Content mounting:
		HLDir .. "/valve",                                                               --   valve
		not string.match(inDirRel, "valve") and string.gsub(inDir, "_addon", "") or nil, --      mod
		string.match(inDirRel, "_addon") and inDir                                       --         mod_addon
	}

	-- Counter
	local fileCounter = {}
	for i = 1, #mounting, 1 do
		if mounting[i] then
			fileCounter[i] = 0
		end
	end

	-- Log files
	if not Exists(logsDir) then
		CreateDirTree(logsDir)
	end

	local logGeneralFilename = logsDir .. "/" .. dateCode .. ".txt"
	local logFiles = {
		["General"] = io.open(logGeneralFilename, "w"),
		["Not found"] = io.open(logsDir .. "/Not found.txt", "w"),
		["Found but not copied"] = io.open(logsDir .. "/Found but not copied.txt", "w"),
	}

	for i = 1, #mounting, 1 do
		if mounting[i] then
			logFiles["Copied from " .. string.gsub(mounting[i], ".+/(.*)", "%1")] = io.open(logsDir .. "/Copied from " .. string.gsub(mounting[i], ".+/(.*)", "%1") .. ".txt", "w")
		end
	end

	-- Get the correct mounted sentences.txt
	local sentencesFilename = SearchMountings(mounting, "/sound/sentences.txt")
	if not sentencesFilename then
		print("ERROR - sentences.txt not found...")
		return
	end

	-- Start to process sentences.txt text
	local sentencesFile = io.open(sentencesFilename, "r")

	io.input(sentencesFile)
	local line = io.read()

	while (line) do
		local curSounds, curSoundsFolder = FormatLine(line)

		if curSounds then
			CopySounds(sentencesDir, mounting, logFiles, fileCounter, curSounds, curSoundsFolder)
		end

		line = io.read()
	end

	io.close(sentencesFile)

	-- Final steps
	local result = "---------------------------------\n"
	local total = 0
	for i = 1, #mounting, 1 do
		if mounting[i] and fileCounter[i] > 0 then
			result = result .. string.gsub(mounting[i], ".+/(.*)", "%1") .. ": " .. fileCounter[i] .. "\n"
			total = total + fileCounter[i]
		end
	end
	result = result .. "total: " .. total .. "\n"
	result = result .. "\n[Log Saved] " .. logGeneralFilename .. "\n"

	print(result)
	logFiles["General"]:write(result)

	for _,logFile in pairs(logFiles) do
		io.close(logFile)
	end
end

Start()