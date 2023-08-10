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
SWEP.SecondaryCooldown = 10
SWEP.ReloadCooldown = 10

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

-- Freeze the first player or NPC hit and make a visuel effect on his screen
function SWEP:PrimaryAttack()
	local curtime = CurTime()

	self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	self:SetCurentAnim()
	if CLIENT then return end

	local FoundTarget = scp_035.PrimaryAttack(self:GetOwner())
	if (FoundTarget) then scp_035.PlaySoundToClient(self:GetOwner(), "scp_035/hit_sound.mp3", math.random( 90, 110 )) end
	self:SetNextPrimaryFire( FoundTarget and curtime + self.PrimaryCooldown or curtime + self.CurentAnim )
end 

-- Laugh and make every players around to loot at you and make them a blurry vision
function SWEP:SecondaryAttack()
	if CLIENT then return end

	self:SetNextSecondaryFire( CurTime() +  self.SecondaryCooldown)

	local FilterTable, NonFilterTable = scp_035.GetInSpherePlayers(self, SCP_035_CONFIG.RadiusLaugh:GetInt())
	for key, value in ipairs(NonFilterTable) do
		if (value:IsPlayer()) then
			net.Start(SCP_035_CONFIG.AffectBySecondary)
				net.WriteEntity(self:GetOwner())
			net.Send(value)
		end
	end
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
		if(!IsValid(ply)) then return end
		ply:Kill()
	end)
end

-- Use for knows what's the current animation and time is ending
function SWEP:SetCurentAnim()
	local ply = self:GetOwner()
	local VMAnim = ply:GetViewModel()
	if (IsValid(VMAnim)) then
		local NextIdle = VMAnim:SequenceDuration() / VMAnim:GetPlaybackRate() 
		self.CurentAnim = NextIdle
	else
		self.CurentAnim = 3 -- Default Time (VMAnim is invalid for bot generally)
	end
end

function SWEP:SetNextAction()
	local curtime = CurTime()
	self:SetNextPrimaryFire( self.PrimaryCooldown )
	self.ReloadNextFire = curtime + self.ReloadCooldown
end

-- Intial function when player receive the weapon.
function SWEP:PutTheMask()
	local ply = self:GetOwner()
	ply:Freeze(true)
	self:SendWeaponAnim( ACT_VM_DRAW )

	self:SetCurentAnim()
	ply.SCP035_IsTransforming = true
	timer.Simple(self.CurentAnim, function()
        if(!IsValid(self)) then return end
        if(!IsValid(ply)) then return end
		if(!ply:Alive()) then return end

		if SERVER then 
			scp_035.SetTableClient(ply, "PlayersWearingMask", true) 
			scp_035.SetTranform(ply)
		end
		self:SendWeaponAnim( ACT_VM_IDLE )
		self:SetCurentAnim()

		timer.Simple(7.6, function() --? 7.6s equal to duration of the sound played in scp_035.StartIdleSound(ply)
			if(!IsValid(self)) then return end
			if(!IsValid(ply)) then return end
			if(!ply:Alive()) then return end

			ply.SCP035_IsWear = true
			ply.SCP035_IsTransforming = false
			scp_035.RemoveEffectProximity(ply)
			if SERVER then 
				ply:Freeze(false)
				scp_035.StartIdleSound(ply)
			end
		end)
    end)
end

-- Override ACT_VM_DRAW animation (cause it play this animation when deploy (for what ever reason))
function SWEP:Deploy()
	if (self:GetOwner().SCP035_IsWear) then
		self:SendWeaponAnim( ACT_VM_IDLE )
		self:SetCurentAnim()
	end
	return true
end