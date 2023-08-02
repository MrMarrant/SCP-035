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

-- Remove effect and drop mask if they have it
hook.Add( "PlayerDeath", "PlayerDeath.Remove_SCP035", scp_035.RemoveEffectClient)

hook.Add( "PlayerChangedTeam", "PlayerChangedTeam.Remove_SCP035", scp_035.RemoveEffectClient)

hook.Add( "PlayerSpawn", "PlayerSpawn.Remove_SCP035", scp_035.RemoveEffectClient )

-- Send to player the list of actual players who wear the mask client side.
hook.Add( "PlayerInitialSpawn", "PlayerInitialSpawn.SCP035_LoadPossessor", function(ply)
    scp_035.GetTableClient(ply, "PlayersWearingMask", SCP_035_CONFIG.PlayersWearingMask)
end)