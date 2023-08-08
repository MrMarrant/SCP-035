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

/* 
* Fonction use by primary attack of the swep, it immobilise the first player found.
* @Player ply
* @string path
* @number pitch
*/
function scp_035.ImmobilizeVictim(ply)
    ply:Freeze(true)
    ply.SCP035_IsImmobilize = true
    scp_035.AffectByPrimary(ply)

    timer.Simple(SCP_035_CONFIG.DurationImmobilize:GetInt(), function()
        if(!IsValid(ply)) then return end
        if(!ply.SCP035_IsImmobilize) then return end
        
        ply.SCP035_IsImmobilize = nil
        ply:Freeze(false)
    end)
end

/* 
* Fonction use by primary attack of the swep, it immobilise the first player found.
* @Player ply
* @string path
* @number pitch
*/
function scp_035.PrimaryAttack(attacker)
    local startPos = attacker:GetShootPos()
    local dir = attacker:GetAimVector()
    local angle = math.cos( math.rad( 22 ) )

    local foundEnts = ents.FindInCone( startPos, dir, SCP_035_CONFIG.RangeImmobilize:GetInt(), angle )
    local victim = nil
    for key, value in ipairs(foundEnts) do
        if ((value:IsPlayer() or value:IsNPC() or value:IsNextBot()) and value != attacker) then
            victim = value
            break
        end
    end

    local ReturnValue = false

    if (IsValid(victim)) then
        if (victim:IsPlayer()) then
            scp_035.ImmobilizeVictim(victim)
            ReturnValue = true
        end
        if (victim:IsNPC() or victim:IsNextBot()) then
            scp_035.FreezeNPC(victim)
            ReturnValue = true
        end
    end

    return ReturnValue
end 


/* 
* Play a sound client side on a player.
* @Player ply
* @string path
* @number pitch
*/
function scp_035.PlaySoundToClient(ply, path, pitch)
    local pitch = pitch or 100

    net.Start(SCP_035_CONFIG.SoundToPlayClientSide)
        net.WriteString(path)
        net.WriteUInt(pitch, 8)
    net.Send(ply)
end

/*
* Function used for drop the entitie if it is equip by a player.
* @Player ply The player who will drop the entity.
*/
function scp_035.DropEntitie(ply)
    if (!IsValid(ply)) then return end

    if (ply:HasWeapon("scp_035_swep") or ply.SCP035_IsWear or ply.SCP035_IsTransforming) then

        local ent = ents.Create( "scp_035_real" )
        ent:SetPos( ply:GetShootPos() + ply:GetAimVector() * 20 )
        ent:SetAngles( ply:EyeAngles() + Angle(0, 48, 0))
        ent:Spawn()
        ent:Activate()
    end
end

/* 
* Remove every effects, var, sounds generate by this addon.
* @Player ply
*/
function scp_035.RemoveEffectClient(ply)
    scp_035.DropEntitie(ply)
    ply.SCP035_AffectByMask = nil
    ply.SCP035_OutOfEffect = nil
    if (ply.SCP035_IsWear) then
        ply:EmitSound("scp_035/rale_of_agony.mp3", 75, math.random(100, 110))
    end
    if (ply.SCP035_IsTransforming or ply.SCP035_IsImmobilize) then
        ply:Freeze(false)
    end
    ply.SCP035_IsImmobilize = nil
    ply.SCP035_IsWear = nil
    ply.SCP035_IsTransforming = nil
    scp_035.SetTableClient(ply, "PlayersWearingMask", false)
    timer.Remove("SetForcePutMask_SCP035_"..ply:EntIndex())

    net.Start(SCP_035_CONFIG.RemoveEffectClient)
    net.Send(ply)
end

function scp_035.AffectByPrimary(ply)
    net.Start(SCP_035_CONFIG.AffectByPrimary)
    net.Send(ply)
end

/*
* Function to synchronize the state of a table client side for a specific player.
* @Player ply The player to update the state.
* @string var String of the variable to update.
* @table tableToGet the table server side to update client side.
*/
function scp_035.GetTableClient(ply, var, tableToGet)
    if (!IsValid(ply) or type(var) != "string" or type(tableToGet) != "table") then return end
    for key, value in ipairs(tableToGet) do
        net.Start(SCP_035_CONFIG.SetTableClient)
            net.WriteString(var)
            net.WriteBool( true )
            net.WriteUInt( value, 11 )
        net.Send(ply)
    end
end

/*
* Function to update the state of a table client side of all players of the server.
* @Player ply The player to update the state.
* @string var String of the variable to update.
* @bool state Bool to set to the variable.
*/
function scp_035.SetTableClient(ply, var, state)
    if (!IsValid(ply) or type(var) != "string") then return end
    local entIndex = ply:EntIndex()
    if (SCP_035_CONFIG[var][entIndex] and state) then return end
    if (state) then
        SCP_035_CONFIG[var][entIndex] = entIndex
    else
        SCP_035_CONFIG[var][entIndex] = nil
    end
    net.Start(SCP_035_CONFIG.SetTableClient)
        net.WriteString( var )
        net.WriteBool( state )
        net.WriteUInt( entIndex, 11 )
    net.Broadcast()
end

/* 
* Display the screen to transform clientside (Gif & sound)
* @Player ply
*/
function scp_035.SetTranform(ply)
    net.Start(SCP_035_CONFIG.TransitionTransform)
    net.Send(ply)
end

/* 
* Lauch the idle sound client side.
* @Player ply
*/
function scp_035.StartIdleSound(ply)
    net.Start(SCP_035_CONFIG.StartIdleSound)
    net.Send(ply)
end

/* 
* Force the mask to be put on a player nearby when the player reach the final stage.
* @Player ply
* @Entity ent
*/
function scp_035.SetForcePutMask(ply, ent)
    local maxDialog = SCP_035_CONFIG.MaxDialogVersion
    local timerToInfect = SCP_035_CONFIG.TimeTotalEffect:GetInt()
    --? First iteration is 5s (whatever the set) and final text display during 1s
    local timerForcePutMask = timerToInfect + (timerToInfect/(maxDialog - 1)) + 6

    timer.Create("SetForcePutMask_SCP035_"..ply:EntIndex(), timerForcePutMask, 1, function()
        if(!IsValid(ply) or !IsValid(ent)) then return end
        if(!ply.SCP035_AffectByMask or scp_035.IsSCP035(ply)) then return end

        ply:Give("scp_035_swep")
        ent:Remove()
    end)
end

/* 
* 
* @string name
* @number value
*/
function scp_035.SetConvarClientSide(name, value, ply)
    if (type( value ) == "boolean") then value = value and 1 or 0 end
    net.Start(SCP_035_CONFIG.SetConvarClientSide)
        net.WriteString(name)
        net.WriteUInt(value, 14)
    if (ply) then
        net.Send(ply)
    else
        net.Broadcast()
    end
end

/* 
* Method for freeze NPC
* @NPC NPCTarget The NPC to freeze
*/
function scp_035.FreezeNPC(NPCTarget)
    local RagNPC = ents.Create( "prop_ragdoll" )
    if not RagNPC:IsValid() then return end

    PrintTable(NPCTarget:GetAttachments())
    local NPCWeapon = NPCTarget:GetActiveWeapon()
    local NPCPos = NPCTarget:GetPos()
    local NPCClass = NPCTarget:GetClass()
    local NPCModel = NPCTarget:GetModel()
    NPCTarget:SetLagCompensated( true ) --? To avoid small frame shifts during freeze.

    --? Set weapon prop pos
    if IsValid(NPCWeapon) then
        RagNPC.SCP035_NPCWeapon = NPCWeapon:GetClass()
    end

    --? Set every params to the ragdoll.
    RagNPC:SetModel( NPCModel or "" ) -- Somes NPC don't have models
    RagNPC:SetAngles(NPCTarget:GetAngles()) --! Models without physics are not affect by angles appartly
    RagNPC:SetPos(NPCPos)
    -- Skin
    RagNPC:SetSkin(NPCTarget:GetSkin())
    RagNPC:Spawn()

    --? Set Scale Model Ragdoll, in somes cases, it doesn't work properly, cause somes models are shit.
    --! Don't work on models thats don't have physics.
    local ScaleMode = NPCTarget:GetModelScale()
    RagNPC:SetModelScale(ScaleMode)
    for i = 0, NPCTarget:GetFlexNum() - 1 do
        RagNPC:SetFlexWeight( i, NPCTarget:GetFlexWeight(i) )
    end
    -- BodyGroup
    if NPCTarget:GetNumBodyGroups() then
        RagNPC.SCP035_NPCBodyGroup = {}
        for i = 0, NPCTarget:GetNumBodyGroups() - 1 do
            local BodyGroup = NPCTarget:GetBodygroup(i)
            RagNPC:SetBodygroup(i, BodyGroup)
            RagNPC.SCP035_NPCBodyGroup[i] = BodyGroup
        end
    end
    for i = 0, NPCTarget:GetBoneCount() do
        RagNPC:ManipulateBoneScale(i, NPCTarget:GetManipulateBoneScale(i))
        RagNPC:ManipulateBoneAngles(i, NPCTarget:GetManipulateBoneAngles(i))
        RagNPC:ManipulateBonePosition(i, NPCTarget:GetManipulateBonePosition(i))
    end

    RagNPC.SCP035_NPCPos = NPCPos
    RagNPC.SCP035_NPCAngle = NPCTarget:GetAngles()
    RagNPC.SCP035_NPCClass = NPCClass
    RagNPC.SCP035_NPCSkin = NPCTarget:GetSkin()
    RagNPC.SCP035_NPCHealth = NPCTarget:Health()
    RagNPC.SCP035_WasNPC = NPCTarget:IsNPC()
    RagNPC.SCP035_WasNextBot = NPCTarget:IsNextBot()
    RagNPC.SCP035_IsFreeze = true
    if (NPCClass == "npc_citizen") then
        RagNPC.SCP035_CityType = string.sub(NPCModel,21,21)
        if string.sub(NPCModel,22,22) == "m" then RagNPC.SCP035_CitMed = 1 end
    end
    RagNPC:SetMaterial(NPCTarget:GetMaterial())

    --? Set Every Bone of the ragdoll like The npc.
    --! Some models build their bones like shit fuck with a root bone, iam will se later to manage this.
    local Bones = RagNPC:GetPhysicsObjectCount()
    for i = 0, Bones - 1 do
        local phys = RagNPC:GetPhysicsObjectNum(i)
        local b = RagNPC:TranslatePhysBoneToBone(i)
        local pos,ang = NPCTarget:GetBonePosition(b)
        phys:EnableMotion(false)
        phys:SetPos(pos)
        phys:SetAngles(ang)
        phys:Wake()
    end

    NPCTarget:Remove()
    RagNPC:SetMoveType(MOVETYPE_NONE) --? Ragdoll will not move with this, even in air.

    timer.Simple(SCP_035_CONFIG.DurationImmobilize:GetInt(), function()
        if(!IsValid(RagNPC)) then return end

        scp_035.UnFreezeNPC(RagNPC)
    end)
end

/* Method for unfreeze an NPC, recreate the NPC with the ragdoll created when he was froozen.
* @Ragdoll RagNPC The ragdoll create while the NPC was freeze.
*/
function scp_035.UnFreezeNPC(RagNPC)
    local NPCTarget = ents.Create(RagNPC.SCP035_NPCClass)
    NPCTarget:SetModel(RagNPC:GetModel() or "") -- Somes NPC don't have models
    NPCTarget:SetPos(RagNPC.SCP035_NPCPos)
    NPCTarget:SetSkin(RagNPC.SCP035_NPCSkin)
    NPCTarget:SetAngles(RagNPC.SCP035_NPCAngle)
    if RagNPC.SCP035_NPCWeapon then NPCTarget:SetKeyValue("additionalequipment",RagNPC.SCP035_NPCWeapon) end
    if (RagNPC.SCP035_CityType) then
        NPCTarget:SetKeyValue("citizentype", RagNPC.SCP035_CityType)
        if RagNPC.SCP035_CityType == "3" && RagNPC.SCP035_CitMed == 1 then
            NPCTarget:SetKeyValue("spawnflags","131072")
        end
    end
    NPCTarget:Spawn()
    NPCTarget:Activate()

    if (RagNPC.SCP035_NPCRagWeapon) then RagNPC.SCP035_NPCRagWeapon:Remove() end
    if (RagNPC.SCP035_NPCBodyGroup) then
        for key, value in pairs(RagNPC.SCP035_NPCBodyGroup) do
            NPCTarget:SetBodygroup(key, value)
        end
    end
    NPCTarget:SetHealth(RagNPC.SCP035_NPCHealth)
    RagNPC:Remove()
end

-- Set Convar Int for the client side
net.Receive(SCP_035_CONFIG.SetConvarInt, function ( len, ply )
    if (ply:IsSuperAdmin() or game.SinglePlayer()) then
        local name = net.ReadString()
        local value = net.ReadUInt(14)
        SCP_035_CONFIG[name]:SetInt(value)

        scp_035.SetConvarClientSide('Client'..name, value) --? The value clientside start with Client
    end
end)

-- Set Convar Bool for the client side
net.Receive(SCP_035_CONFIG.SetConvarBool, function ( len, ply )
    if (ply:IsSuperAdmin() or game.SinglePlayer()) then
        local name = net.ReadString()
        local value = net.ReadBool()
        SCP_035_CONFIG[name]:SetBool(value)

        scp_035.SetConvarClientSide('Client'..name, value) --? The value clientside start with Client
    end
end)