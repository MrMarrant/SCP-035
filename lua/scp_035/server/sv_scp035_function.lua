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

function scp_035.PrimaryAttack(attacker)
    local startPos = attacker:GetShootPos()
    local dir = attacker:GetAimVector()
    local angle = math.cos( math.rad( 22 ) )

    local foundEnts = ents.FindInCone( startPos, dir, SCP_035_CONFIG.RangeImmobilize:GetInt(), angle )
    local victim = nil
    for key, value in ipairs(foundEnts) do
        if (value:IsPlayer() and value != attacker) then
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
    end

    return ReturnValue
end 

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

function scp_035.RemoveEffectClient(ply)
    scp_035.DropEntitie(ply)
    ply.SCP035_IsImmobilize = nil
    ply.SCP035_AffectByMask = nil
    ply.SCP035_OutOfEffect = nil
    if (ply.SCP035_IsWear) then
        ply:EmitSound("scp_035/rale_of_agony.mp3", 75, math.random(100, 110))
    end
    if (ply.SCP035_IsTransforming) then
        ply:Freeze(false)
    end
    ply.SCP035_IsWear = nil
    ply.SCP035_IsTransforming = nil
    scp_035.SetTableClient(ply, "PlayersWearingMask", false)

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

function scp_035.SetTranform(ply)
    net.Start(SCP_035_CONFIG.TransitionTransform)
    net.Send(ply)
end

function scp_035.StartIdleSound(ply)
    net.Start(SCP_035_CONFIG.StartIdleSound)
    net.Send(ply)
end