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

ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.Author = "MrMarrant"
ENT.PrintName = "SCP-035 Tentacle"
ENT.Spawnable = false
ENT.Category = "SCP"
ENT.RenderGroup = RENDERGROUP_OPAQUE

ENT.STATE_RISING = 0
ENT.STATE_ACTIVE = 1
ENT.STATE_RETRACTING = 2

ENT.Segments = 12
ENT.WhipDuration = 0.6 -- Duration of the attack animation.
ENT.BaseWidth = 12
ENT.TipWidth = 1.5

function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "TentacleState")
	self:NetworkVar("Float", 0, "StateStart")
	self:NetworkVar("Float", 1, "AttackTime")
	self:NetworkVar("Entity", 0, "Target")
end

-- Ratio of the tentacle out of the stain, from 0 (in the stain) to 1 (fully out).
function ENT:GetHeightRatio()
	local progress = math.Clamp((CurTime() - self:GetStateStart()) / SCP_035_CONFIG.TentacleRiseTime, 0, 1)
	local state = self:GetTentacleState()

	if (state == self.STATE_RISING) then return progress end
	if (state == self.STATE_RETRACTING) then return 1 - progress end
	return 1
end

-- Width of the tentacle, from the base (t = 0) to the tip (t = 1).
function ENT:GetSegmentWidth(t)
	return Lerp(t, self.BaseWidth, self.TipWidth)
end

/*
* Procedural tentacle: it sways, leans toward its target and whips it when it attacks.
* Shared, so the collisions server side (see ENT:TestCollision) match the drawing client side.
* Return the points from the base to the tip, or an empty table if the tentacle is in the stain.
*/
function ENT:GetSegmentPoints()
	local points = {}
	local ratio = self:GetHeightRatio()
	if (ratio <= 0) then return points end

	local curTime = CurTime()
	local base = self:GetPos()
	local up, right, forward = self:GetUp(), self:GetRight(), self:GetForward()
	local length = SCP_035_CONFIG.TentacleLength * ratio
	local seed = self:EntIndex() --? Each tentacle sways differently.

	local target = self:GetTarget()
	local targetPos = IsValid(target) and target:WorldSpaceCenter() or nil
	local attackElapsed = curTime - self:GetAttackTime()
	local whip = attackElapsed < self.WhipDuration and math.sin(math.pi * attackElapsed / self.WhipDuration) or 0

	for i = 0, self.Segments do
		local t = i / self.Segments
		local swayRight = math.sin(curTime * 2.5 + t * 4 + seed) * 12 * t
		local swayForward = math.cos(curTime * 1.7 + t * 3 + seed) * 8 * t
		local point = base + up * (length * t) + right * swayRight + forward * swayForward

		if (targetPos) then
			--? The tip lean toward the target, and touch it at the peak of the attack.
			local bend = t * t * (0.25 + 0.75 * whip) * ratio
			point = LerpVector(bend, point, targetPos)
		end

		points[i + 1] = point
	end

	return points
end