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
	-- TODO : Afficher la bulle de texte et les effets
	--? Get tous les joueurs proches en sphere
	--? S'il n'étais pas affecté, leur applique la méthode d'effet
	--? La méthode check la distance entre le joueur et l'entité à chaque tick
	--? Si elle n'est plus bonne, dissipe l'ffet lentement, et renvoie coté serveur qu'il n'est plus affecté.
	local FilterTable, NonFilterTable = scp_035.GetInSpherePlayers(self, true)
	scp_035.SetEffectsMask(self, FilterTable)
    if CLIENT then self:LookAtMe(NonFilterTable) end
end