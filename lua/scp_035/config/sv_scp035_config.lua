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

SCP_035_CONFIG.RadiusEffect = CreateConVar( "SCP035_RadiusEffect", 100, {FCVAR_PROTECTED, FCVAR_ARCHIVE}, "The maximum distance at which the effect of the SCP-035 entity can affect players", 50, 9999 )
SCP_035_CONFIG.RangeImmobilize = CreateConVar( "SCP035_RangeImmobilize", 300, {FCVAR_PROTECTED, FCVAR_ARCHIVE}, "The maximum distance at which SCP-035's SWEP can freeze a player", 100, 9999 )
SCP_035_CONFIG.DurationImmobilize = CreateConVar( "SCP035_DurationImmobilize", 5, {FCVAR_PROTECTED, FCVAR_ARCHIVE}, "The freeze time of a player affected by SCP-035's SWEP", 1, 60 )
SCP_035_CONFIG.TimeTotalEffect = CreateConVar( "SCP035_TimeTotalEffect", 80, {FCVAR_PROTECTED, FCVAR_ARCHIVE}, "The total time taken for the SCP-035 effect to reach the final stage", 10, 180 )
SCP_035_CONFIG.ForcePutMask = CreateConVar( "SCP035_ForcePutMask", 0, {FCVAR_PROTECTED, FCVAR_ARCHIVE}, "If enable, force the mask to be put on the player around when a player reach the final stage", 0, 1 )
SCP_035_CONFIG.RadiusLaugh = CreateConVar( "SCP035_RadiusLaugh", 300, {FCVAR_PROTECTED, FCVAR_ARCHIVE}, "Define the radius effect of the Secondary Attack SWEP from SCP-035", 50, 9999 )

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
util.AddNetworkString( SCP_035_CONFIG.SetConvarClientSide )