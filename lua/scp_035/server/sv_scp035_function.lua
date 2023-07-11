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
end

function scp_035.PlaySoundToClient(ply)
end

/*
* Function used for drop the entiot if it is equip by a player.
* @Player ply The player who will drop the entity.
*/
function scp_035.DropEntitie(ply)
    if (!IsValid(ply)) then return end

    if (ply:HasWeapon("scp_035_swep")) then

        local ent = ents.Create( "scp_035_real" )
        ent:SetPos( ply:GetShootPos() + ply:GetAimVector() * 20 )
        ent:SetAngles( ply:EyeAngles() + Angle(0, 48, 0))
        ent:Spawn()
        ent:Activate()
    end
end