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

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetModel( "models/props_junk/popcan01a.mdl" ) --? Never drawn, the tentacle is drawn in cl_init.lua.
	self:SetMoveType( MOVETYPE_NONE )
	self:SetSolid( SOLID_BBOX )
	self:SetCollisionGroup( COLLISION_GROUP_DEBRIS_TRIGGER ) --? Can be shot, but doesn't block players and NPCs.
	--? The bounds contain everything the tentacle can reach, the real shape is tested in ENT:TestCollision.
	--? It also bypass the hitboxes of the placeholder model, that were the only thing hit by bullets.
	local reach = SCP_035_CONFIG.TentacleRange + SCP_035_CONFIG.TentacleLength
	self:SetCollisionBounds(Vector(-reach, -reach, -reach), Vector(reach, reach, reach))
	self:EnableCustomCollisions(true)

	self:SetMaxHealth(SCP_035_CONFIG.TentacleHealth)
	self:SetHealth(SCP_035_CONFIG.TentacleHealth)
	self.NextAttack = 0
	self.LastTargetTime = CurTime()
	self:SetState(self.STATE_RISING)
	self:EmitSound("npc/barnacle/barnacle_tongue_pull"..math.random(1, 3)..".wav", 75, math.random(80, 90))
end

function ENT:SetState(state)
	self:SetTentacleState(state)
	self:SetStateStart(CurTime())
end

-- Go back in the stain, starting from the current height (it can be stopped while rising).
function ENT:Retract()
	local ratio = self:GetHeightRatio()
	self:SetTentacleState(self.STATE_RETRACTING)
	self:SetStateStart(CurTime() - (1 - ratio) * SCP_035_CONFIG.TentacleRiseTime)
	self:SetTarget(NULL)
	self:EmitSound("npc/barnacle/barnacle_tongue_pull"..math.random(1, 3)..".wav", 75, math.random(80, 90))
end

/*
* Closest points between two segments (p1 + s * d1) and (p2 + t * d2), s and t between 0 and 1.
* @return number s, number t
*/
local function ClosestPointsSegments(p1, d1, p2, d2)
	local r = p1 - p2
	local a, e, f = d1:Dot(d1), d2:Dot(d2), d2:Dot(r)
	local epsilon = 0.0001

	if (a <= epsilon and e <= epsilon) then return 0, 0 end
	if (a <= epsilon) then return 0, math.Clamp(f / e, 0, 1) end

	local c = d1:Dot(r)
	if (e <= epsilon) then return math.Clamp(-c / a, 0, 1), 0 end

	local b = d1:Dot(d2)
	local denom = a * e - b * b
	local s = denom != 0 and math.Clamp((b * f - c * e) / denom, 0, 1) or 0
	local t = (b * s + f) / e
	if (t < 0) then
		return math.Clamp(-c / a, 0, 1), 0
	elseif (t > 1) then
		return math.Clamp((b - c) / a, 0, 1), 1
	end
	return s, t
end

-- Test the traces (bullets, melee, ...) against every segments of the tentacle, like a chain of cylinders.
function ENT:TestCollision(startPos, delta, isBox, extents, mask)
	if (self:GetTentacleState() == self.STATE_RETRACTING) then return end

	local points = self:GetSegmentPoints()
	local extraRadius = isBox and math.max(extents.x, extents.y) or 0
	local bestFraction, bestPos, bestNormal = nil, nil, nil

	for i = 1, #points - 1 do
		local segmentStart = points[i]
		local segmentDir = points[i + 1] - segmentStart
		local s, t = ClosestPointsSegments(startPos, delta, segmentStart, segmentDir)
		local rayPoint = startPos + delta * s
		local segmentPoint = segmentStart + segmentDir * t
		local radius = self:GetSegmentWidth((i - 1 + t) / self.Segments) / 2 + extraRadius

		if (rayPoint:DistToSqr(segmentPoint) <= radius * radius and (!bestFraction or s < bestFraction)) then
			bestFraction, bestPos = s, rayPoint
			bestNormal = (rayPoint - segmentPoint):GetNormalized()
		end
	end

	if (!bestFraction) then return end
	return { HitPos = bestPos, Fraction = bestFraction, Normal = bestNormal }
end

function ENT:OnTakeDamage(dmgInfo)
	if (self:GetTentacleState() == self.STATE_RETRACTING) then return end

	self:SetHealth(self:Health() - dmgInfo:GetDamage())
	self:Bleed(dmgInfo)

	if (self:Health() <= 0) then
		if (self.SCP035_Stain) then self.SCP035_Stain.isTentacleKilled = true end
		self:EmitSound("npc/barnacle/barnacle_die"..math.random(1, 2)..".wav", 75, math.random(90, 110))
		self:Retract()
	end
end

-- Blood effect where the tentacle was hit, and a pain sound.
function ENT:Bleed(dmgInfo)
	local center = self:GetPos() + self:GetUp() * (SCP_035_CONFIG.TentacleLength * self:GetHeightRatio() / 2)
	local pos = dmgInfo:GetDamagePosition()
	--? Some damages (explosions, ...) don't have a position on the tentacle.
	if (pos:DistToSqr(center) > SCP_035_CONFIG.TentacleLength ^ 2) then pos = center end

	local effectData = EffectData()
	effectData:SetOrigin(pos)
	effectData:SetNormal((pos - center):GetNormalized())
	effectData:SetColor(BLOOD_COLOR_RED)
	effectData:SetScale(6)
	util.Effect("BloodImpact", effectData)

	local curTime = CurTime()
	if ((self.NextPainSound or 0) > curTime) then return end --? Avoid sounds spam (shotgun, ...).
	self.NextPainSound = curTime + 0.15

	self:EmitSound("physics/flesh/flesh_squishy_impact_hard"..math.random(1, 4)..".wav", 75, math.random(90, 110))
end

function ENT:Think()
	local curTime = CurTime()
	local state = self:GetTentacleState()
	local elapsed = curTime - self:GetStateStart()

	if (state == self.STATE_RISING) then
		if (elapsed >= SCP_035_CONFIG.TentacleRiseTime) then
			self:SetState(self.STATE_ACTIVE)
			self.LastTargetTime = curTime
		end
	elseif (state == self.STATE_ACTIVE) then
		local target = self:FindTarget()
		self:SetTarget(target or NULL)

		if (IsValid(target)) then
			self.LastTargetTime = curTime
			if (self.NextAttack <= curTime) then
				self:Attack(target)
				self.NextAttack = curTime + SCP_035_CONFIG.TentacleAttackDelay
			end
		elseif (curTime - self.LastTargetTime >= SCP_035_CONFIG.TentacleIdleTime) then
			self:Retract()
		end
	elseif (state == self.STATE_RETRACTING) then
		if (elapsed >= SCP_035_CONFIG.TentacleRiseTime) then
			self:Remove()
			return
		end
	end

	self:NextThink(curTime + 0.1)
	return true
end

-- Return the closest entity that can be attacked, and not behind a wall.
function ENT:FindTarget()
	local origin = self:GetPos() + self:GetUp() * (SCP_035_CONFIG.TentacleLength / 2)
	local closestTarget, closestDist = nil, math.huge

	for key, value in ipairs(ents.FindInSphere(self:GetPos(), SCP_035_CONFIG.TentacleRange)) do
		if (scp_035.IsTentacleTarget(value)) then
			local targetPos = value:WorldSpaceCenter()
			local dist = targetPos:DistToSqr(origin)
			if (dist < closestDist) then
				local tr = util.TraceLine({ start = origin, endpos = targetPos, mask = MASK_SOLID_BRUSHONLY })
				if (!tr.Hit) then
					closestTarget, closestDist = value, dist
				end
			end
		end
	end

	return closestTarget
end

function ENT:Attack(target)
	local targetPos = target:WorldSpaceCenter()
	local dir = (targetPos - self:GetPos()):GetNormalized()

	local dmgInfo = DamageInfo()
	dmgInfo:SetDamage(SCP_035_CONFIG.TentacleDamage)
	dmgInfo:SetDamageType(DMG_SLASH)
	dmgInfo:SetAttacker(self)
	dmgInfo:SetInflictor(self)
	dmgInfo:SetDamagePosition(targetPos)
	dmgInfo:SetDamageForce(dir * 5000)
	target:TakeDamageInfo(dmgInfo)

	self:SetAttackTime(CurTime())
	self:EmitSound("npc/zombie/claw_strike"..math.random(1, 3)..".wav", 75, math.random(90, 110))
end