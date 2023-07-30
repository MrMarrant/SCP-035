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

if SERVER then return end

SCP_035_CONFIG.ScrW = ScrW()
SCP_035_CONFIG.ScrH = ScrH()
SCP_035_CONFIG.MaxDialogVersion = 5 -- Don't increase the value if you didnt implement the number of version set.

-- 
surface.CreateFont( "SCP035_Font1", {
    font = "Arial",
    size = 40,
} )
surface.CreateFont( "SCP035_Font2", {
    font = "Arial",
    size = 35,
} )
surface.CreateFont( "SCP035_Font3", {
    font = "Arial",
    size = 45,
} )
surface.CreateFont( "SCP035_Font4", {
    font = "Arial",
    size = 30,
} )
surface.CreateFont( "SCP035_Font5", {
    font = "Arial",
    size = 38,
} )
surface.CreateFont( "SCP035_Font6", {
    font = "Arial",
    size = 25,
} )
surface.CreateFont( "SCP035_FontFinal", {
    font = "DermaDefaultBold",
    size = 150,
} )
SCP_035_CONFIG.FontEffect = {}
for var = 1, 6 do
    SCP_035_CONFIG.FontEffect[var] = "SCP035_Font"..var
end

