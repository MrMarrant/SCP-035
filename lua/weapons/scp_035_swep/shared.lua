AddCSLuaFile()
AddCSLuaFile( "cl_init.lua" )

SWEP.Slot = 0
SWEP.SlotPos = 1

SWEP.Spawnable = true

SWEP.Category = "SCP"
SWEP.ViewModel = ""
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

-- Variables Personnal to this weapon --
-- [[ STATS WEAPON ]]
SWEP.Range = 300
SWEP.PrimaryCooldown = 10
SWEP.SecondaryCooldown = 10

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
end

-- 
function SWEP:Deploy()
	local ply = self:GetOwner()
	if(!ply:Alive()) then return end -- For some fking reason, deploy is call when a player died, i don't know what to said.

	ply.SCP035_IsWear = true

	local speedAnimation = GetConVarNumber( "sv_defaultdeployspeed" )
	self:SendWeaponAnim( ACT_DEPLOY )
	self:SetPlaybackRate( speedAnimation )

	local VMAnim = ply:GetViewModel()
	local NextIdle = VMAnim:SequenceDuration() / VMAnim:GetPlaybackRate() 

	self.CurentAnim = CurTime() + NextIdle

	return true
end

-- Remove Effect On remove.
function SWEP:OnRemove()
	local ply = self:GetOwner()
end


-- Remove Effect On drop.
function SWEP:OnDrop()
	local ply = self:GetOwner()
	self:Remove()
end

-- Set animation Walking/Attack when equip with this swep.
-- TODO : On garde ?
function SWEP:TranslateActivity( act )
	if ( self:GetOwner():IsPlayer() ) then
		if (ActivityTranslate[act]) then
			return ActivityTranslate[act]
		end
	end
	return -1
end

-- TODO : Immobilise un joueur et lui fais un effet psychodelique
function SWEP:PrimaryAttack()
	if ( CurTime() < self.CurentAnim ) then return end
	self:SetNextPrimaryFire( curtime + self.PrimaryCooldown )

end 

-- TODO : Rigole ?
function SWEP:SecondaryAttack()
	local curtime = CurTime()
	if ( CurTime() < self.CurentAnim ) then return end
	self:SetNextSecondaryFire( curtime +  self.SecondaryCooldown)

end

-- Kill the player and drop the entitie (and play an animation before.)
function SWEP:Reload()
	if ( CurTime() < self.CurentAnim ) then return end

	local ply = self:GetOwner()
	self:SendWeaponAnim( ACT_RELOAD )
	local VMAnim = ply:GetViewModel()
	local NextIdle = VMAnim:SequenceDuration() / VMAnim:GetPlaybackRate() 
	timer.Simple(NextIdle, function()
		ply:Kill()
		scp_035.DropEntitie(ply)
	end)
end