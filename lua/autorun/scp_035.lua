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

SCP_035_CONFIG.RootFolder = "scp_035/"

/*
* Allows you to load all the files in a folder.
* @string path of the folder to load.
* @bool isFile if the path is a file and not a folder.
*/
function scp_035.LoadDirectory(pathFolder, isFile)
    if isFile then
        AddCSLuaFile(pathFolder)
        include(pathFolder)
    else
        local files, directories = file.Find(pathFolder.."*", "LUA")
        for key, value in pairs(files) do
            AddCSLuaFile(pathFolder..value)
            include(pathFolder..value)
        end
        for key, value in pairs(directories) do
            LoadDirectory(pathFolder..value)
        end
    end
end

print("SCP-035 Loading . . .")
scp_035.LoadDirectory(SCP_035_CONFIG.RootFolder.."config/sh_scp035_config.lua", true)
print("SCP-035 Loaded!")