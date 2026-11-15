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

local reachDistance = 60 -- Distance at which a NPC can take the mask or a weapon.
local weaponSearchRadius = 800
local thinkDelay = 0.5
local transformDuration = 7.6 --? Same duration as the player transformation (sound transform_mask.mp3)
-- Same cooldowns as the SWEP
local primaryCooldown = 10
local secondaryCooldown = 10

/*
* Check if an entity is a humanoid NPC, able to wear the mask and to use weapons.
* @Entity ent
*/
function scp_035.IsHumanoidNPC(ent)
    if (!IsValid(ent) or !ent:IsNPC() or ent:Health() <= 0) then return false end
    if (!ent:LookupBone("ValveBiped.Bip01_Head1")) then return false end --? Needed to display the mask.

    local caps = ent:CapabilitiesGet()
    return bit.band(caps, CAP_USE_WEAPONS) != 0 or bit.band(caps, CAP_WEAPON_RANGE_ATTACK1) != 0
end

/*
* Make a NPC run to a position, VJ Base NPCs use their own schedule system.
* @NPC npc
* @Vector pos
*/
function scp_035.NPCRunTo(npc, pos)
    npc:SetLastPosition(pos)
    if (npc.IsVJBaseSNPC) then
        if (!npc.CurrentSchedule or npc.CurrentScheduleName != "SCHEDULE_GOTO_POSITION") then npc:SCHEDULE_GOTO_POSITION("TASK_RUN_PATH") end
        return
    end

    if (!npc:IsCurrentSchedule(SCHED_FORCED_GO_RUN)) then npc:SetSchedule(SCHED_FORCED_GO_RUN) end
end

/*
* Called by the mask entity, attract the closest humanoid NPC and make him wear the mask when he reach it.
* @Entity ent The Mask SCP035
*/
function scp_035.AttractNPC(ent)
    if (!SCP_035_CONFIG.NPCCanWearMask:GetBool()) then return end

    local curTime = CurTime()
    if ((ent.SCP035_NextNPCCheck or 0) > curTime) then return end
    ent.SCP035_NextNPCCheck = curTime + thinkDelay

    local maskPos = ent:GetPos()
    local closestNPC, closestDist = nil, math.huge
    for key, value in ipairs(ents.FindInSphere(maskPos, SCP_035_CONFIG.RadiusEffect:GetInt())) do
        if (scp_035.IsHumanoidNPC(value) and !scp_035.IsSCP035(value)) then
            local dist = value:GetPos():DistToSqr(maskPos)
            if (dist < closestDist) then
                closestNPC, closestDist = value, dist
            end
        end
    end
    if (!IsValid(closestNPC)) then return end

    if (closestDist <= reachDistance * reachDistance) then
        scp_035.NPCPutTheMask(closestNPC)
        ent:Remove()
        return
    end

    scp_035.NPCRunTo(closestNPC, maskPos)
end

/*
* Initial function when a NPC take the mask, equivalent of SWEP:PutTheMask.
* @NPC npc
*/
function scp_035.NPCPutTheMask(npc)
    npc.SCP035_IsTransforming = true
    npc:StopMoving()
    if (npc.IsVJBaseSNPC) then
        npc:SetState(VJ_STATE_FREEZE)
    else
        npc:SetCondition(COND.NPC_FREEZE)
    end
    npc:EmitSound("scp_035/transform_mask.mp3")
    scp_035.SetTableClient(npc, "PlayersWearingMask", true)

    timer.Create("NPCTransform_SCP035_"..npc:EntIndex(), transformDuration, 1, function()
        if (!IsValid(npc)) then return end

        if (npc.IsVJBaseSNPC) then
            npc:SetState()
        else
            npc:SetCondition(COND.NPC_UNFREEZE)
        end
        scp_035.NPCSetWear(npc)
    end)
end

/*
* Set the NPC as a wearer of SCP-035 : aggressive toward every entities and use the abilities of the mask.
* @NPC npc
*/
function scp_035.NPCSetWear(npc)
    npc.SCP035_IsTransforming = nil
    npc.SCP035_IsWear = true
    npc.SCP035_NextPrimary = 0
    npc.SCP035_NextSecondary = 0
    SCP_035_CONFIG.NPCsWearingMask[npc] = true
    scp_035.SetTableClient(npc, "PlayersWearingMask", true)

    if (npc:GetClass() == "npc_citizen") then npc:Fire("RemoveFromPlayerSquad") end
    npc:SetKeyValue("squadname", "")
    if (npc.IsVJBaseSNPC) then scp_035.VJSetWear(npc) end
    for key, value in ipairs(ents.GetAll()) do
        scp_035.NPCHate(npc, value)
    end

    local timerName = "NPCThink_SCP035_"..npc:EntIndex()
    timer.Create(timerName, thinkDelay, 0, function()
        if (!IsValid(npc) or !npc.SCP035_IsWear) then timer.Remove(timerName) return end

        scp_035.NPCThink(npc)
    end)
end

/*
* Make the NPC wearer hate an entity.
* @NPC npc The wearer of SCP-035.
* @Entity target
*/
function scp_035.NPCHate(npc, target)
    if (!IsValid(target) or target == npc) then return end
    if (!target:IsNPC() and !target:IsPlayer() and !target:IsNextBot()) then return end

    npc:AddEntityRelationship(target, D_HT, 99)
    --? VJ Base recompute the relationships constantly, the override is kept in its memory.
    if (npc.IsVJBaseSNPC) then npc:SetRelationshipMemory(target, VJ.MEM_OVERRIDE_DISPOSITION, D_HT) end
end

/*
* VJ Base NPCs ignore the source relationships, they use their own classes system.
* The wearer get a class of its own, so every VJ Base NPCs consider him as an enemy and he does the same.
* @NPC npc The wearer of SCP-035.
*/
function scp_035.VJSetWear(npc)
    npc.VJ_NPC_Class = {"CLASS_SCP035"}
    npc.PlayerFriendly = false
    npc.AlliedWithPlayerAllies = false
    npc.Behavior = VJ_BEHAVIOR_AGGRESSIVE
    npc.Weapon_UnarmedBehavior = false --? Don't flee when unarmed, he will search a weapon instead.
    if (npc.IsFollowing) then npc:ResetFollowBehavior() end
end

/*
* Abilities of the mask used by the NPC wearer, equivalent of the SWEP attacks.
* @NPC npc The wearer of SCP-035.
*/
function scp_035.NPCThink(npc)
    if (npc:Health() <= 0) then return end

    local curTime = CurTime()
    local enemy = npc:GetEnemy()

    if (IsValid(enemy) and npc:Visible(enemy)) then
        local distance = npc:GetPos():Distance(enemy:GetPos())

        if (npc.SCP035_NextPrimary <= curTime and distance <= SCP_035_CONFIG.RangeImmobilize:GetInt()) then
            local startPos = npc:EyePos()
            local dir = (enemy:WorldSpaceCenter() - startPos):GetNormalized()
            if (scp_035.PrimaryAttack(npc, startPos, dir)) then
                npc:EmitSound("scp_035/hit_sound.mp3", 75, math.random( 90, 110 ))
                npc.SCP035_NextPrimary = curTime + primaryCooldown
            end
        end

        if (npc.SCP035_NextSecondary <= curTime and distance <= SCP_035_CONFIG.RadiusLaugh:GetInt()) then
            scp_035.Laugh(npc)
            npc.SCP035_NextSecondary = curTime + secondaryCooldown
        end
    end

    if (!IsValid(npc:GetActiveWeapon())) then
        scp_035.NPCSearchWeapon(npc)
    end
end

/*
* Make the NPC go to the closest weapon on the ground and equip it.
* @NPC npc The wearer of SCP-035.
*/
function scp_035.NPCSearchWeapon(npc)
    local usableWeapons = {}
    for key, value in pairs(list.Get("NPCUsableWeapons")) do
        usableWeapons[value.class] = true
    end

    local npcPos = npc:GetPos()
    local closestWeapon, closestDist = nil, math.huge
    for key, value in ipairs(ents.FindInSphere(npcPos, weaponSearchRadius)) do
        if (value:IsWeapon() and !IsValid(value:GetOwner()) and usableWeapons[value:GetClass()]) then
            local dist = value:GetPos():DistToSqr(npcPos)
            if (dist < closestDist) then
                closestWeapon, closestDist = value, dist
            end
        end
    end
    if (!IsValid(closestWeapon)) then return end

    if (closestDist <= reachDistance * reachDistance) then
        npc:Give(closestWeapon:GetClass())
        closestWeapon:Remove()
        return
    end

    scp_035.NPCRunTo(npc, closestWeapon:GetPos())
end

/*
* Remove every effects, var, timers of a NPC wearer.
* @NPC npc
* @bool dropMask If the mask entity must be dropped.
*/
function scp_035.RemoveEffectNPC(npc, dropMask)
    if (!npc.SCP035_IsWear and !npc.SCP035_IsTransforming) then return end

    if (dropMask) then
        scp_035.DropEntitie(npc)
        if (npc.SCP035_IsWear) then npc:EmitSound("scp_035/rale_of_agony.mp3", 75, math.random(100, 110)) end
    end

    local entIndex = npc:EntIndex()
    npc.SCP035_IsWear = nil
    npc.SCP035_IsTransforming = nil
    SCP_035_CONFIG.NPCsWearingMask[npc] = nil
    scp_035.SetTableClient(npc, "PlayersWearingMask", false)
    timer.Remove("NPCTransform_SCP035_"..entIndex)
    timer.Remove("NPCThink_SCP035_"..entIndex)
end

hook.Add( "OnNPCKilled", "OnNPCKilled.Remove_SCP035", function(npc)
    scp_035.RemoveEffectNPC(npc, true)
end)

hook.Add( "EntityRemoved", "EntityRemoved.Remove_SCP035", function(ent)
    if (!ent:IsNPC()) then return end

    scp_035.RemoveEffectNPC(ent, false)
end)

-- New entities are also hated by the NPCs wearers.
hook.Add( "OnEntityCreated", "OnEntityCreated.SCP035_NPCHate", function(ent)
    if (table.IsEmpty(SCP_035_CONFIG.NPCsWearingMask)) then return end

    timer.Simple(0, function() --? The entity is not initialized yet.
        if (!IsValid(ent)) then return end

        for npc, _ in pairs(SCP_035_CONFIG.NPCsWearingMask) do
            if (IsValid(npc)) then scp_035.NPCHate(npc, ent) end
        end
    end)
end)