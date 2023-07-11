if (!toucanlib) then return end
include('shared.lua')

SWEP.PrintName = "SCP-035 MindControl"
SWEP.Author = "MrMarrant"
SWEP.Purpose = "On verra"
SWEP.DrawCrosshair = false

-- TODO : bouger ça et voir si je le met en application sur les joueurs devant lui.
hook.Add("PreDrawHalos", "PreDrawHalos.AegisHaloSWEP", function()
	local ply = LocalPlayer()
	if (!IsValid( ply )) then return end
	local weapon = ply:GetActiveWeapon()
    if !ply:Alive() or !IsValid(weapon) or !weapon:GetClass() == "scp_035_swep" then return end


end)