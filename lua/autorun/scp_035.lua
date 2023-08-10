-- SCP-035, A representation of a paranormal object on a fictional series on the game Garry's Mod.
-- Copyright (C) 2023  MrMarrant aka BIBI.

-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.

-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.

-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <https://www.gnu.org/licenses/>.

-- Functions
scp_035 = {}
-- Global Variable
SCP_035_CONFIG = {}
-- Lang
SCP_035_LANG = {}

SCP_035_CONFIG.RootFolder = "scp_035/"

/*
* Allows to load all the language files that the addon can handle.
* @string path Path containing the language files.
* @string default Default language.
* @table handledLanguage Array containing the supported languages.
* @table langData Table containing all translations.
*/
local function LoadLanguage(path, handledLanguage, langData )
    for key, value in ipairs(handledLanguage) do
        local filename = path .. value .. ".lua"
        include( filename )
        if SERVER then AddCSLuaFile( filename ) end
        assert(langData[value], "Language not found : ".. filename )
    end
end

/*
* Allows you to load all the files in a folder.
* @string path of the folder to load.
* @bool isFile if the path is a file and not a folder.
*/
local function LoadDirectory(pathFolder, isFile)
    if isFile then
        if (pathFolder != SCP_035_CONFIG.RootFolder.."config/sv_scp035_config.lua") then
            AddCSLuaFile(pathFolder)
        end
        include(pathFolder)
    else
        local files, directories = file.Find(pathFolder.."*", "LUA")
        for key, value in pairs(files) do
            local typeFile = string.sub(value, 1, 2)
            if (typeFile == "sh" or typeFile == "cl") then
                AddCSLuaFile(pathFolder..value)
            end
            include(pathFolder..value)
        end
        for key, value in pairs(directories) do
            LoadDirectory(pathFolder..value)
        end
    end
end

print("SCP-035 Loading . . .")
LoadDirectory(SCP_035_CONFIG.RootFolder.."config/sh_scp035_config.lua", true)
if SERVER then LoadDirectory(SCP_035_CONFIG.RootFolder.."config/sv_scp035_config.lua", true) end
LoadDirectory(SCP_035_CONFIG.RootFolder.."config/cl_scp035_config.lua", true)

LoadLanguage(SCP_035_CONFIG.RootFolder.."language/", SCP_035_CONFIG.HandledLanguage, SCP_035_LANG)
LoadDirectory(SCP_035_CONFIG.RootFolder.."shared/")
if SERVER then LoadDirectory(SCP_035_CONFIG.RootFolder.."server/") end
LoadDirectory(SCP_035_CONFIG.RootFolder.."client/")
print("SCP-035 Loaded!")