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

if SERVER then return end

local tab = {
	["$pp_colour_addr"] = 0,
	["$pp_colour_addg"] = 0,
	["$pp_colour_addb"] = 0,
	["$pp_colour_brightness"] = 0.1,
	["$pp_colour_contrast"] = 1,
	["$pp_colour_colour"] = 0,
	["$pp_colour_mulr"] = 0,
	["$pp_colour_mulg"] = 0,
	["$pp_colour_mulb"] = 0
}
local maxRange = 200 -- TODO : ConVar ?

hook.Add( "OnScreenSizeChanged", "OnScreenSizeChanged.SCP035_ScreenSize", function( oldWidth, oldHeight )
    SCP_035_CONFIG.ScrW = ScrW()
    SCP_035_CONFIG.ScrH = ScrH()
end )

hook.Add( "RenderScreenspaceEffects", "RenderScreenspaceEffects.SCP035_WearMask", function()
    local ply = LocalPlayer()

    if (ply.SCP035_IsWear) then
        local allPlayers = ents.FindInCone( ply:EyePos(), ply:GetAimVector(), maxRange, math.cos( math.rad( 170 ) ) )
        local angle = EyeAngles()
    
        angle = Angle( 0, angle.y, 0 )
        angle:RotateAroundAxis( angle:Up(), -90 )
        angle:RotateAroundAxis( angle:Forward(), 90 )

        DrawColorModify( tab )
        DrawSobel( 0.1 )
        cam.Start3D()
        render.SetStencilEnable( true )
        render.SetStencilWriteMask( 1 )
        render.SetStencilTestMask( 1 )
        render.SetStencilReferenceValue( 1 )
        render.SetStencilFailOperation( STENCIL_KEEP )
        render.SetStencilZFailOperation( STENCIL_KEEP )

        for key, ent in ipairs(allPlayers) do
            if(!ent:IsPlayer()) then continue end
            local isCloak = ent:GetColor().a == 0 and true or false -- If it is equal to 0, then the player is cloaked.
            if(isCloak) then continue end

            render.ClearStencil()
            local range = ent:GetPos():Distance( EyePos() )
            local transparency = 1 - math.Clamp( ( range - 300 ) / (maxRange/2), 0, 1 )

            render.SetBlend( math.min( transparency, 0.99 ) )
            render.SetStencilCompareFunction( STENCIL_ALWAYS )
            render.SetStencilPassOperation( STENCIL_REPLACE )
            ent:DrawModel()
            render.SetStencilCompareFunction( STENCIL_EQUAL )
            render.SetStencilPassOperation( STENCIL_KEEP )

            cam.Start2D()
                surface.SetDrawColor( Color(0,0,0, 250 * transparency * 0.2) )
                surface.DrawRect( 0, 0, SCP_035_CONFIG.ScrW, SCP_035_CONFIG.ScrH )
            cam.End2D()
        end
        render.SetStencilEnable( false )
    cam.End3D()
    end
end )

local modelMask = ClientsideModel( "models/scp_035_real/scp_035_real.mdl" )
modelMask:SetNoDraw( true )

hook.Add( "PostPlayerDraw" , "PostPlayerDraw.SCP035_DrawMask" , function( ply )
    if (SCP_035_CONFIG.PlayersWearingMask[ply:EntIndex()]) then
        local attachments = ply:GetAttachments()
        local keyEye = nil

        for key, value in ipairs(attachments) do
            if (value.name == "eyes") then keyEye = value.id end --? We find the attachment eye
        end

        local offsetvec = keyEye and ply:GetAttachment( keyEye ).Pos or Vector(2.5, -5.6, 0 )
        local offsetang = keyEye and ply:GetAttachment( keyEye ).Ang or Angle( 180, 0, -180 )

        if (keyEye) then --? If player have eye attachment (very precise)
            local UpAng, RightAng, ForwardAng = offsetang:Up(), offsetang:Right(), offsetang:Forward()

            offsetvec = offsetvec + RightAng * 0 + ForwardAng * 1.6 + UpAng * -1.3
            offsetang:RotateAroundAxis(RightAng, 6)
            offsetang:RotateAroundAxis(UpAng, 0)
            offsetang:RotateAroundAxis(ForwardAng, 0)
            modelMask:SetRenderOrigin(offsetvec)
            modelMask:SetRenderAngles(offsetang)
        else --? And if he has not
            local boneid = ply:LookupBone( "ValveBiped.Bip01_Head1" ) --? Work only on models that have this bone, if not, the mask will not show up.
        
            if not boneid then
                return
            end
            
            local matrix = ply:GetBoneMatrix( boneid )
            
            if not matrix then 
                return 
            end
            
            local newpos, newang = LocalToWorld( offsetvec, offsetang, matrix:GetTranslation(), matrix:GetAngles() )

            modelMask:SetPos( newpos )
            modelMask:SetAngles( newang )
            modelMask:SetupBones()
        end
        
        modelMask:DrawModel()
    end
end)

hook.Add("RenderScreenspaceEffects","RenderScreenspaceEffects.SCP035_BlurryVision" , function()
    local ply = LocalPlayer()
    local curTime = FrameTime()

    if ply.SCP035_AffectBySecondary then 
        local AddAlpha = 0.4
        local DrawAlpha = 0.5
        local Delay = 0.05
        local ColorDrain = 0
        DrawMotionBlur( AddAlpha, DrawAlpha, Delay )
    end
end)