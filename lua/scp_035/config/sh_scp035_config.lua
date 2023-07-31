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

SCP_035_CONFIG.RadiusEffect = CreateConVar( "SCP035_RadiusEffect", 100, {FCVAR_PROTECTED, FCVAR_ARCHIVE}, "The maximum distance at which the effect of the SCP-035 entity can affect players", 50, 9999 )
SCP_035_CONFIG.RangeImmobilize = CreateConVar( "SCP035_RangeImmobilize", 300, {FCVAR_PROTECTED, FCVAR_ARCHIVE}, "The maximum distance at which SCP-035's SWEP can freeze a player", 10, 9999 )
SCP_035_CONFIG.DurationImmobilize = CreateConVar( "SCP035_DurationImmobilize", 5, {FCVAR_PROTECTED, FCVAR_ARCHIVE}, "The freeze time of a player affected by SCP-035's SWEP", 1, 60 )
SCP_035_CONFIG.TimeTotalEffect = CreateConVar( "SCP035_TimeTotalEffect", 80, {FCVAR_PROTECTED, FCVAR_ARCHIVE}, "The total time taken for the SCP-035 effect to reach the final stage ", 10, 180 )
SCP_035_CONFIG.LangServer = GetConVar("gmod_language"):GetString()
SCP_035_CONFIG.HandledLanguage = {
    "fr",
    "en"
}

SCP_035_CONFIG.PlayersWearingMask = {}

SCP_035_CONFIG.SoundToPlayClientSide = "SCP_035_CONFIG.SoundToPlayClientSide"
SCP_035_CONFIG.DisplayText = "SCP_035_CONFIG.DisplayText"
SCP_035_CONFIG.RemoveEffectClient = "SCP_035_CONFIG.RemoveEffectClient"
SCP_035_CONFIG.AffectByPrimary = "SCP_035_CONFIG.AffectByPrimary"
SCP_035_CONFIG.SetEffectsMask = "SCP_035_CONFIG.SetEffectsMask"
SCP_035_CONFIG.SetTableClient = "SCP_035_CONFIG.SetTableClient"
SCP_035_CONFIG.TransitionTransform = "SCP_035_CONFIG.TransitionTransform"
SCP_035_CONFIG.StartIdleSound = "SCP_035_CONFIG.StartIdleSound"

scp_035.LoadLanguage(SCP_035_CONFIG.RootFolder.."language/", SCP_035_CONFIG.HandledLanguage, SCP_035_LANG)
scp_035.LoadDirectory(SCP_035_CONFIG.RootFolder.."shared/")
scp_035.LoadDirectory(SCP_035_CONFIG.RootFolder.."server/")
scp_035.LoadDirectory(SCP_035_CONFIG.RootFolder.."client/")