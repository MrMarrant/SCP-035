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

SCP_035_CONFIG.LangServer = GetConVar("gmod_language"):GetString()
SCP_035_CONFIG.MaxDialogVersion = 5 -- Don't increase the value if you didnt implement the number of version set.
SCP_035_CONFIG.HandledLanguage = {
    "fr",
    "en",
    "ru",
    "zh-CN"
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
SCP_035_CONFIG.AffectBySecondary = "SCP_035_CONFIG.AffectBySecondary"
SCP_035_CONFIG.SetConvarInt = "SCP_035_CONFIG.SetConvarInt"
SCP_035_CONFIG.SetConvarBool = "SCP_035_CONFIG.SetConvarBool"
SCP_035_CONFIG.SetConvarClientSide = "SCP_035_CONFIG.SetConvarClientSide"