-- SCP-035, A representation of a paranormal object on a fictional series on the game Garry's Mod.
-- Copyright (C) 2026  MrMarrant aka BIBI.

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
    "zh-CN",
    "tr"
}

SCP_035_CONFIG.PlayersWearingMask = {}

--? Black stains & tentacles
SCP_035_CONFIG.LiquidStainDelay = 30 -- A stain every 30s under each mask.
SCP_035_CONFIG.LiquidStainLifeTime = 1200 -- Each stain is removed 20 minutes after its creation.
SCP_035_CONFIG.LiquidStainMinSize = 120 -- The size of a stain is random between the min and the max.
SCP_035_CONFIG.LiquidStainMaxSize = 180
SCP_035_CONFIG.LiquidStainMaxCount = 10 -- When a new stain appear and the limit is reached, the oldest one is removed.
SCP_035_CONFIG.TentacleChance = 0.3 --Chance that a tentacle appear when an entity come close to a stain. (0.2 = 20%)
SCP_035_CONFIG.TentacleMinDistance = 100 -- A stain can't appear if another one is closer than this distance.
SCP_035_CONFIG.TentacleMinDistanceSCP035 = 50 -- A tentacle can't appear if SCP-035 (the mask or a wearer) is closer than this distance.
SCP_035_CONFIG.TentacleMaxCount = 3 -- Maximum number of tentacles out at the same time (on the whole map).
SCP_035_CONFIG.TentacleRiseTime = 2 -- Time to come out (or go back) in the stain.
SCP_035_CONFIG.TentacleIdleTime = 10 -- Time without target before the tentacle go back in the stain.
SCP_035_CONFIG.TentacleRange = 100
SCP_035_CONFIG.TentacleDamage = 30
SCP_035_CONFIG.TentacleAttackDelay = 2
SCP_035_CONFIG.TentacleLength = 90
SCP_035_CONFIG.TentacleHealth = 50 -- When the tentacle has no more health, it go back in the stain.

SCP_035_CONFIG.SoundToPlayClientSide = "SCP_035_CONFIG.SoundToPlayClientSide"
SCP_035_CONFIG.DisplayText = "SCP_035_CONFIG.DisplayText"
SCP_035_CONFIG.RemoveEffectClient = "SCP_035_CONFIG.RemoveEffectClient"
SCP_035_CONFIG.AffectByPrimary = "SCP_035_CONFIG.AffectByPrimary"
SCP_035_CONFIG.SetEffectsMask = "SCP_035_CONFIG.SetEffectsMask"
SCP_035_CONFIG.RemoveEffectProximity = "SCP_035_CONFIG.RemoveEffectProximity"
SCP_035_CONFIG.SetTableClient = "SCP_035_CONFIG.SetTableClient"
SCP_035_CONFIG.TransitionTransform = "SCP_035_CONFIG.TransitionTransform"
SCP_035_CONFIG.StartIdleSound = "SCP_035_CONFIG.StartIdleSound"
SCP_035_CONFIG.AffectBySecondary = "SCP_035_CONFIG.AffectBySecondary"
SCP_035_CONFIG.SetConvarInt = "SCP_035_CONFIG.SetConvarInt"
SCP_035_CONFIG.SetConvarBool = "SCP_035_CONFIG.SetConvarBool"
SCP_035_CONFIG.SetConvarClientSide = "SCP_035_CONFIG.SetConvarClientSide"
SCP_035_CONFIG.AddLiquidStains = "SCP_035_CONFIG.AddLiquidStains"