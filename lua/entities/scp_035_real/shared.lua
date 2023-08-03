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


ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.Author = "MrMarrant"
ENT.PrintName = "SCP-035"
ENT.Spawnable = true
ENT.Category = "SCP"

function ENT:Think()
	local FilterTable, NonFilterTable = scp_035.GetInSpherePlayers(self, SCP_035_CONFIG.RadiusEffect:GetInt())

	scp_035.SetEffectsMask(self, FilterTable)
    if CLIENT then
		for key, value in ipairs(NonFilterTable) do
			scp_035.LookAtMe(value, self)
		end
	end
end