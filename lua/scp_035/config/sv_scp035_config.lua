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

if CLIENT then return end

util.AddNetworkString( SCP_035_CONFIG.SoundToPlayClientSide )
util.AddNetworkString( SCP_035_CONFIG.DisplayText )
util.AddNetworkString( SCP_035_CONFIG.RemoveEffectClient )
util.AddNetworkString( SCP_035_CONFIG.AffectByPrimary )
util.AddNetworkString( SCP_035_CONFIG.SetEffectsMask )
util.AddNetworkString( SCP_035_CONFIG.SetTableClient )
util.AddNetworkString( SCP_035_CONFIG.TransitionTransform )
util.AddNetworkString( SCP_035_CONFIG.StartIdleSound )
util.AddNetworkString( SCP_035_CONFIG.AffectBySecondary )
util.AddNetworkString( SCP_035_CONFIG.SetConvarInt )
util.AddNetworkString( SCP_035_CONFIG.SetConvarBool )