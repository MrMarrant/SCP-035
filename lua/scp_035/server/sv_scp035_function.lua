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

function scp_035.DisplayText(ply)
end

function scp_035.DisplayEffect(ply)
end

function scp_035.ImmobilizeVictim(ply)
    ply:Freeze(true)
    ply.SCP035_IsImmobilize = true
    -- TODO : Shacking screen et cris sons coté client
    scp_035.PlaySoundToClient(ply, "")

    timer.Simple(SCP_035_CONFIG.DurationImmobilize, function()
        if(!IsValid(ply)) then return end
        if(!ply.SCP035_IsImmobilize) then return end
        
        ply.SCP035_IsImmobilize = nil
        ply:Freeze(false)
    end)
end

function scp_035.PrimaryAttack(attacker)
    local starPos = attacker:GetShootPos()
    local endPos = attacker:GetShootPos() + attacker:GetAimVector() * SCP_035_CONFIG.RangeImmobilize
    local mins = Vector(-10, -10, -10)
    local maxs = Vector(10, 10, 10)

    local tr = util.TraceHull {
        start = starPos,
        endpos = endPos,
        filter = attacker,
        mins = mins,
        maxs = maxs
    }
    local victim = tr.Entity

    scp_035.ImmobilizeVictim(victim)

    return victim and true or false
end 

function scp_035.PlaySoundToClient(ply, path)
    net.Start(SCP_035_CONFIG.SoundToPlayClientSide)
        net.WriteString(path)
    net.Send(ply)
end

/*
* Function used for drop the entitie if it is equip by a player.
* @Player ply The player who will drop the entity.
*/
function scp_035.DropEntitie(ply)
    if (!IsValid(ply)) then return end

    if (ply:HasWeapon("scp_035_swep") or ply.SCP035_IsWear) then

        local ent = ents.Create( "scp_035_real" )
        ent:SetPos( ply:GetShootPos() + ply:GetAimVector() * 20 )
        ent:SetAngles( ply:EyeAngles() + Angle(0, 48, 0))
        ent:Spawn()
        ent:Activate()
    end

    ply.SCP035_IsWear = nil
end