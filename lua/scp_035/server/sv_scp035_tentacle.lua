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

local checkDelay = 0.5

/*
* Write a stain in the current net message.
* @table stain
*/
local function WriteLiquidStain(stain)
    net.WriteVector(stain.pos)
    net.WriteNormal(stain.normal)
    net.WriteFloat(stain.size)
    net.WriteFloat(stain.rotation)
    net.WriteFloat(stain.time)
end

/*
* Check if an entity can trigger and be attacked by a tentacle (every living entities, except the wearers of SCP-035).
* @Entity ent
*/
function scp_035.IsTentacleTarget(ent)
    if (!IsValid(ent) or scp_035.IsSCP035(ent)) then return false end
    if (ent:IsPlayer()) then return ent:Alive() end
    if (ent:IsNPC()) then return ent:Health() > 0 end
    return ent:IsNextBot()
end

/*
* Create a black stain on the ground under the mask, and send it to every players.
* @Entity ent The Mask or the wearer.
* @Vector pos Position of the mask.
*/
function scp_035.CreateLiquidStain(ent, pos)
    local tr = util.TraceLine({
        start = pos,
        endpos = pos - Vector(0, 0, 200),
        filter = ent,
        mask = MASK_SOLID_BRUSHONLY --? Only on the map, a stain on a moving prop would float in the air.
    })
    if (!tr.Hit) then return end

    local stainPos = tr.HitPos + tr.HitNormal * 0.5 --? Slightly above the ground to avoid z-fighting.
    local stains = SCP_035_CONFIG.LiquidStains
    for key, value in ipairs(stains) do
        if (value.pos:DistToSqr(stainPos) < SCP_035_CONFIG.TentacleMinDistance ^ 2) then return end --? Only one stain in this radius.
    end
    --? The stains are sorted from the oldest to the newest, the client do the same in scp_035.AddLiquidStain.
    while (#stains >= SCP_035_CONFIG.LiquidStainMaxCount) do
        table.remove(stains, 1)
    end

    local stain = {
        pos = stainPos,
        normal = tr.HitNormal,
        size = math.Rand(SCP_035_CONFIG.LiquidStainMinSize, SCP_035_CONFIG.LiquidStainMaxSize),
        rotation = math.Rand(0, 360),
        time = CurTime(),
        nearby = {}, --? Server only, entities that were close to the stain at the last check.
        isTentacleKilled = false --? Server only, no more tentacle can come out of the stain once one was killed.
    }
    table.insert(stains, stain)

    net.Start(SCP_035_CONFIG.AddLiquidStains)
        net.WriteUInt(1, 16)
        WriteLiquidStain(stain)
    net.Broadcast()
end

/*
* Send every existing stains to a player.
* @Player ply
*/
function scp_035.SendLiquidStains(ply)
    local stains = SCP_035_CONFIG.LiquidStains
    if (#stains == 0) then return end

    net.Start(SCP_035_CONFIG.AddLiquidStains)
        net.WriteUInt(#stains, 16)
        for key, value in ipairs(stains) do
            WriteLiquidStain(value)
        end
    net.Send(ply)
end

/*
* Create a stain every LiquidStainDelay under every masks, on the ground or worn.
*/
local function UpdateStainSources()
    local curTime = CurTime()
    local sources = {}

    for key, value in ipairs(ents.FindByClass("scp_035_real")) do
        sources[value] = value:GetPos()
    end
    for key, value in ipairs(player.GetAll()) do
        if (value.SCP035_IsWear and value:Alive()) then sources[value] = value:EyePos() end
    end
    for npc, _ in pairs(SCP_035_CONFIG.NPCsWearingMask) do
        if (IsValid(npc) and npc.SCP035_IsWear) then sources[npc] = npc:EyePos() end
    end

    for ent, pos in pairs(sources) do
        if ((ent.SCP035_NextStain or 0) <= curTime) then
            ent.SCP035_NextStain = curTime + SCP_035_CONFIG.LiquidStainDelay
            scp_035.CreateLiquidStain(ent, pos)
        end
    end
end

/*
* Make a tentacle come out of a stain.
* @table stain
*/
function scp_035.SpawnTentacle(stain)
    local tentacle = ents.Create("scp_035_tentacle")
    if (!IsValid(tentacle)) then return end

    tentacle:SetPos(stain.pos)
    tentacle:SetAngles(stain.normal:Angle() + Angle(90, 0, 0)) --? The up of the tentacle is the normal of the ground.
    tentacle.SCP035_Stain = stain
    tentacle:Spawn()
    stain.tentacle = tentacle
end

/*
* Check if a tentacle can come out of a stain.
* @table stain
* @number tentacleCount Number of tentacles currently out.
*/
local function CanSpawnTentacle(stain, tentacleCount)
    if (tentacleCount >= SCP_035_CONFIG.TentacleMaxCount) then return false end
    if (stain.isTentacleKilled or IsValid(stain.tentacle)) then return false end --? Only one tentacle at a time per stain.

    for key, value in ipairs(ents.FindInSphere(stain.pos, SCP_035_CONFIG.TentacleMinDistanceSCP035)) do
        if (value:GetClass() == "scp_035_real" or scp_035.IsSCP035(value)) then return false end
    end
    return true
end

/*
* Remove the expired stains, and roll the chance to spawn a tentacle when an entity come close to a stain.
*/
local function UpdateStains()
    local curTime = CurTime()
    local stains = SCP_035_CONFIG.LiquidStains
    local tentacleCount = #ents.FindByClass("scp_035_tentacle")

    for i = #stains, 1, -1 do
        local stain = stains[i]

        if (curTime - stain.time >= SCP_035_CONFIG.LiquidStainLifeTime) then
            table.remove(stains, i)
        elseif (SCP_035_CONFIG.EnabledTentacle:GetBool()) then
            local nearby = {}
            for key, value in ipairs(ents.FindInSphere(stain.pos, SCP_035_CONFIG.TentacleRange)) do
                if (scp_035.IsTentacleTarget(value)) then
                    nearby[value] = true
                    --? Only one roll when the entity come close, not at every check.
                    if (!stain.nearby[value] and math.random() < SCP_035_CONFIG.TentacleChance and CanSpawnTentacle(stain, tentacleCount)) then
                        scp_035.SpawnTentacle(stain)
                        tentacleCount = tentacleCount + 1
                    end
                end
            end
            stain.nearby = nearby
        end
    end
end

timer.Create("SCP035_LiquidStains", checkDelay, 0, function()
    UpdateStainSources()
    UpdateStains()
end)

hook.Add( "PlayerInitialSpawn", "PlayerInitialSpawn.SCP035_LoadLiquidStains", scp_035.SendLiquidStains)

hook.Add( "PostCleanupMap", "PostCleanupMap.SCP035_ClearLiquidStains", function()
    SCP_035_CONFIG.LiquidStains = {}
end)