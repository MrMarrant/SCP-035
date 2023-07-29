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

AddCSLuaFile()
AddCSLuaFile( "cl_init.lua" )

SWEP.Slot = 0
SWEP.SlotPos = 1

SWEP.Spawnable = true

SWEP.Category = "SCP"
SWEP.ViewModel = Model( "models/weapons/scp_035_real/v_scp_035.mdl" )
SWEP.WorldModel = ""

SWEP.ViewModelFOV = 65
SWEP.HoldType = "normal"
SWEP.UseHands = true

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"
SWEP.DrawAmmo = false
SWEP.AutoSwitch = true
SWEP.Automatic = false

-- Variables Personnal to this weapon --
-- [[ STATS WEAPON ]]
SWEP.PrimaryCooldown = 10
SWEP.SecondaryCooldown = 15
SWEP.ReloadCooldown = 10

-- Allows you to set the animations of a player on several actions, example: ACT_MP_STAND_IDLE : allows you to define the animation when a player is static.
-- TODO : Pk pas ?
local ActivityTranslate = {}
	ActivityTranslate[ ACT_MP_STAND_IDLE ]	= ACT_HL2MP_IDLE_ZOMBIE
	ActivityTranslate[ ACT_MP_WALK ] = ACT_HL2MP_WALK_ZOMBIE_04
	ActivityTranslate[ ACT_MP_RUN ]	= ACT_HL2MP_WALK_ZOMBIE_05
	ActivityTranslate[ ACT_MP_CROUCH_IDLE ]	= ACT_HL2MP_IDLE_CROUCH_ZOMBIE
	ActivityTranslate[ ACT_MP_CROUCHWALK ]	= ACT_HL2MP_WALK_CROUCH_ZOMBIE_04
	ActivityTranslate[ ACT_MP_JUMP ] = ACT_ZOMBIE_LEAPING
	ActivityTranslate[ ACT_MP_ATTACK_STAND_PRIMARYFIRE ] = ACT_GMOD_GESTURE_RANGE_ZOMBIE
	ActivityTranslate[ ACT_MP_ATTACK_CROUCH_PRIMARYFIRE ] = ACT_GMOD_GESTURE_RANGE_ZOMBIE
	ActivityTranslate[ ACT_MP_RELOAD_STAND ] = ACT_GMOD_GESTURE_TAUNT_ZOMBIE
	ActivityTranslate[ ACT_MP_RELOAD_CROUCH ] = ACT_GMOD_GESTURE_TAUNT_ZOMBIE

function SWEP:Initialize()
	self:SetWeaponHoldType( self.HoldType )
	self:SetHoldType( self.HoldType )
	self:SetPlaybackRate( GetConVarNumber( "sv_defaultdeployspeed" ) )
	self:SetNextAction()

	timer.Simple(engine.TickInterval(), function()
		if (!IsValid(self)) then return end
		self:PutTheMask() --? Deploy is shit, so i prefer using in Initialize method instead, but i need to w8 1 tick cause owner is nil.
	end)
end

function SWEP:OnDrop()
	local ply = self:GetOwner()
	self:Remove()
end

-- Set animation Walking/Attack when equip with this swep.
-- TODO : On garde ?
-- function SWEP:TranslateActivity( act )
-- 	if ( self:GetOwner():IsPlayer() ) then
-- 		if (ActivityTranslate[act]) then
-- 			return ActivityTranslate[act]
-- 		end
-- 	end
-- 	return -1
-- end

-- TODO : lui faire un effet psychodelique
function SWEP:PrimaryAttack()
	local curtime = CurTime()

	self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	self:SetCurentAnim()
	if CLIENT then return end

	local FoundTarget = scp_035.PrimaryAttack(self:GetOwner())
	if (FoundTarget) then scp_035.PlaySoundToClient(self:GetOwner(), "scp_035/hit_sound.mp3", math.random( 90, 110 )) end
	self:SetNextPrimaryFire( FoundTarget and curtime + self.PrimaryCooldown or curtime + self.CurentAnim )
end 

function SWEP:SecondaryAttack()
	if CLIENT then return end

	self:SetNextSecondaryFire( CurTime() +  self.SecondaryCooldown)

	self:GetOwner():EmitSound("scp_035/laugh_"..math.random(1, 3)..".mp3")
end

-- Kill the player and drop the entitie (and play an animation before.)
function SWEP:Reload()
	local currentTime = CurTime()
	if ( currentTime < self.ReloadNextFire) then return end
	self.ReloadNextFire = currentTime + self.ReloadCooldown

	local ply = self:GetOwner()
	self:SendWeaponAnim( ACT_VM_RELOAD )

	if CLIENT then return end

	local VMAnim = ply:GetViewModel()
	local NextIdle = VMAnim:SequenceDuration() / VMAnim:GetPlaybackRate() 
	timer.Simple(NextIdle, function()
		ply:Kill()
		ply:EmitSound("scp_035/snap_neck.mp3", 75, math.random(100, 110)) -- TODO : changer le son
	end)
end

function SWEP:SetCurentAnim()
	local ply = self:GetOwner()
	local VMAnim = ply:GetViewModel()
	if (IsValid(VMAnim)) then
		local NextIdle = VMAnim:SequenceDuration() / VMAnim:GetPlaybackRate() 
		self.CurentAnim = NextIdle
	end
end

function SWEP:SetNextAction()
	local curtime = CurTime()
	self:SetNextPrimaryFire( self.PrimaryCooldown )
	self.ReloadNextFire = curtime + self.ReloadCooldown
end

function SWEP:PutTheMask()
	local ply = self:GetOwner()
	ply:Freeze(true)
	self:SendWeaponAnim( ACT_VM_DRAW )

	self:SetCurentAnim()

	timer.Simple(self.CurentAnim, function()
        if(!IsValid(self)) then return end
        if(!IsValid(ply)) then return end
		if(!ply:Alive()) then return end

		if SERVER then scp_035.SetTableClient(ply, "PlayersWearingMask", true) end
		if CLIENT then 
			ply.SCP035_TransitionTransform = scp_035.DisPlayGIF(ply, "scp_035/transform_mask.gif", 1) 
			ply:EmitSound("scp_035/transform_mask.mp3")
		end
		self:SendWeaponAnim( ACT_VM_IDLE )
		self:SetCurentAnim()

		timer.Simple(8, function()
			if(!IsValid(self)) then return end
			if(!IsValid(ply)) then return end
			if(!ply:Alive()) then return end

			ply.SCP035_IsWear = true
			scp_035.RemoveEffectProximity(ply)
			if SERVER then ply:Freeze(false) end
			if CLIENT then
				ply.SCP035_TransitionTransform:Remove()
				ply.SCP035_TransitionTransform = nil
				ply:StartLoopingSound("scp_035/idle_sound.wav" )
			end
		end)
    end)
end

-- Override ACT_VM_DRAW animation (cause it his play when deploy (for what ever reason))
function SWEP:Deploy()
	if (self:GetOwner().SCP035_IsWear) then
		self:SendWeaponAnim( ACT_VM_IDLE )
		self:SetCurentAnim()
	end
	return true
end