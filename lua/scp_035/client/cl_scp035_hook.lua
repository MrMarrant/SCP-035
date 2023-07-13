if SERVER then return end

hook.Add("PreDrawHalos", "PreDrawHalos.AegisHaloSWEP", function()
	local ply = LocalPlayer()
	if (!IsValid( ply )) then return end
	local weapon = ply:GetActiveWeapon()
    if !ply:Alive() or !IsValid(weapon) or !weapon:GetClass() == "scp_035_swep" then return end


end)

hook.Add( "OnScreenSizeChanged", "OnScreenSizeChanged.SCP035_ScreenSize", function( oldWidth, oldHeight )
    SCP_035_CONFIG.ScrW = ScrW()
    SCP_035_CONFIG.ScrH = ScrH()
end )