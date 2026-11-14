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

include("shared.lua")

function ENT:Initialize()
	--? The model is a placeholder, the render bounds must contain the whole tentacle (and its attack).
	local reach = SCP_035_CONFIG.TentacleRange + 50
	self:SetRenderBounds(Vector(-reach, -reach, -reach), Vector(reach, reach, reach))
end

-- Draw the tentacle as a beam (see ENT:GetSegmentPoints).
function ENT:Draw()
	local points = self:GetSegmentPoints()
	if (#points == 0) then return end

	render.SetMaterial(SCP_035_CONFIG.TentacleMaterial)
	render.StartBeam(#points)
	for key, value in ipairs(points) do
		local t = (key - 1) / self.Segments
		render.AddBeam(value, self:GetSegmentWidth(t), t * 3, SCP_035_CONFIG.TentacleColor)
	end
	render.EndBeam()
end