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

if SERVER then return end

/* 
* Display the moving text on screen player.
* @Player ply
*/
function scp_035.DisplayMovingText(ply)
    local maxDialog = SCP_035_CONFIG.MaxDialogVersion
    local timerToInfect = SCP_035_CONFIG.ClientTimeTotalEffect
    local timerPhase = timerToInfect/maxDialog
    local timerFinalText = timerToInfect + (timerToInfect/(maxDialog - 1)) + 5
    local index = 1
    local TextTodisplay = {}
    local DialogVersion = math.random(1, maxDialog)
    for var = 1, maxDialog do
        TextTodisplay[var] = scp_035.TranslateLanguage(SCP_035_LANG, "TextDisplay_v"..DialogVersion.."_"..var)
    end

    timer.Create("DisplayTextTimer_SCP035_"..ply:EntIndex(), 5, maxDialog, function()
        if(!IsValid(ply)) then return end
        if(!ply.SCP035_AffectByMask or ply.SCP035_IsWear or !ply:Alive()) then return end

        local PannelDisplayText = vgui.Create("SCP035MovingText")
        PannelDisplayText:SetInitValue(TextTodisplay[index], timerPhase)
        ply.SCP035_PannelDisplayText = PannelDisplayText
        if(index == 1) then timer.Adjust( "DisplayTextTimer_SCP035_"..ply:EntIndex(), timerPhase, nil, nil ) end
        index = index + 1
    end)

    scp_035.DisPlayFinalText(ply, timerFinalText)
end

/* 
* Display the final text & img/GIF depend on the delay set
* @Player ply
* @number delay
*/
function scp_035.DisPlayFinalText(ply, delay)
    timer.Create("DisplayFinalEffect_SCP035_"..ply:EntIndex(), delay, 1, function()
        if(!IsValid(ply)) then return end
        if(!ply.SCP035_AffectByMask or ply.SCP035_IsWear or !ply:Alive()) then return end

        ply:EmitSound( Sound( "scp_035/final_effect.mp3" ), 75, math.random( 100, 110 ) )
        local TextFinal_1 = scp_035.TranslateLanguage(SCP_035_LANG, "FinalText_1")
        local TextFinal_2 = scp_035.TranslateLanguage(SCP_035_LANG, "FinalText_2")
        --? Ugly asf, but hey, iam lazy to manage this with a clean way, and i use this method only here, so ...
        ply.SCP035_SimpleText_1 = scp_035.DisPlaySimpleText(ply, TextFinal_1, #TextFinal_2 > 4 and SCP_035_CONFIG.ScrW * 0.02 or SCP_035_CONFIG.ScrW * 0.05, SCP_035_CONFIG.ScrH * 0.3)
        ply.SCP035_SimpleText_2 = scp_035.DisPlaySimpleText(ply, TextFinal_2, SCP_035_CONFIG.ScrW * 0.8, SCP_035_CONFIG.ScrH * 0.3)
        local idGif = scp_035.PlayFakeGIF(SCP_035_CONFIG.Gif.StaticNoise, ".png", 12, 255)
        ply.SCP035_MaskIMG = scp_035.DisPlayIMG(ply, "scp_035/mask_deform_v"..math.random(1, 3)..".png")

        timer.Simple(1, function()
            if (IsValid(ply)) then
                scp_035.StopFakeGIF(idGif)
                ply.SCP035_MaskIMG:Remove()
                ply.SCP035_SimpleText_1:Remove()
                ply.SCP035_SimpleText_2:Remove()

                scp_035.DisPlayFinalText(ply, math.random(5, 10))
            end
        end)
    end)
end

/* 
* Display the final text on screen player (don't knwo why i set it like this)
* @Player ply
* @string text
* @number x
* @number y
*/
function scp_035.DisPlaySimpleText(ply, text, x, y)
    SimpleText = vgui.Create("DLabel")
    SimpleText:SetSize( 500, 500 )
    SimpleText:SetText( text )
    SimpleText:SetTextColor( Color(255, 255, 255) )
    SimpleText:SetPos(x, y)
    SimpleText:SetFont("SCP035_FontFinal")
    SimpleText:SetZPos( 100 )
    
    return SimpleText
end

/* 
* Display an img on srceen player
* @Player ply
* @string material
*/
function scp_035.DisPlayIMG(ply, material)
    ImageObject = vgui.Create("DImage")
    ImageObject:SetSize(SCP_035_CONFIG.ScrW * 0.5, SCP_035_CONFIG.ScrH * 1.3)
    ImageObject:SetPos(SCP_035_CONFIG.ScrW *0.27, -SCP_035_CONFIG.ScrH * 0.12)
    ImageObject:SetImage(material)
    ImageObject:SetZPos( 50 )

    return ImageObject
end

/* 
* Display a multitude of images depend on the fps and path
* @table frames
* @string format
* @number fps
* @number alpha
*/
function scp_035.PlayFakeGIF(frames, format, fps, alpha)
    alpha = alpha or 255
    fps = fps or 12
    local ply = LocalPlayer()
    local id = os.time() .. "_" .. math.random(1, 9999)
    ply.SCP035_Alpha = ply.SCP035_Alpha or {}
    ply.SCP035_Alpha[id] = alpha

    format = format or ".png"
    local path = frames.path
    local frameCount = frames.count
    local materials = {}
    for i = 1, frameCount do
        materials[i] = Material(path .. i .. format, "smooth")
    end

    local startTime = CurTime()


    hook.Add("HUDPaint", "HUDPaint:SCP035_FakeGIF_" .. id, function()
        if (not IsValid(ply)) then return end
        local elapsed = CurTime() - startTime
        local frame = math.floor(elapsed * fps) % frameCount + 1

        surface.SetDrawColor(255, 255, 255, ply.SCP035_Alpha[id])
        surface.SetMaterial(materials[frame])
        surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
    end)

    return id
end

function scp_035.StopFakeGIF(id)
    if (not id) then return end
    hook.Remove("HUDPaint", "HUDPaint:SCP035_FakeGIF_" .. id)
end

/*
* Display a static noise gif that increment in alpha depend on the total time every 0.5s.
* @Player ply
*/
function scp_035.ProximityEffect(ply)
    local alpha = 0.01 * 255
    local repetitions = SCP_035_CONFIG.ClientTimeTotalEffect * 2
    local incrementAlpha = 0.3 * 255/repetitions

    ply.SCP035_PEID = scp_035.PlayFakeGIF(SCP_035_CONFIG.Gif.StaticNoise, ".png", 12, alpha)
    timer.Create("ProximityEffect_SCP035_"..ply:EntIndex(), 0.5, repetitions, function()
        if(!IsValid(ply)) then return end
        if(not ply.SCP035_PEID or ply.SCP035_IsWear or !ply:Alive()) then return end

        alpha = alpha + incrementAlpha
        ply.SCP035_Alpha[ply.SCP035_PEID] = alpha
    end)
end

function scp_035.LookAtMe(ply, ent)
    if (ply:IsPlayer() and !scp_035.IsSCP035(ply) and ply:Alive()) then
        ply:SetEyeAngles((ent:GetPos() - ply:GetShootPos()):Angle())
    end
end

function scp_035.SetConvarInt(name, value, ply)
    if (ply:IsSuperAdmin() or game.SinglePlayer()) then --? Just for avoid to spam net message, we check server side to.
        net.Start(SCP_035_CONFIG.SetConvarInt)
            net.WriteString(name)
            net.WriteUInt(value, 14)
        net.SendToServer()
    end
end

function scp_035.SetConvarBool(name, value, ply)
    if (ply:IsSuperAdmin() or game.SinglePlayer()) then --? Just for avoid to spam net message, we check server side to.
        net.Start(SCP_035_CONFIG.SetConvarBool)
            net.WriteString(name)
            net.WriteBool(value)
        net.SendToServer()
    end
end

local liquidEmitter = nil
local liquidStains = {}
local liquidStainColor = Color(0, 0, 0, 255) --? Reused every frame to avoid creating a Color per stain.
local liquidOffsets = { --? Eyes and mouth of the mask model (local space), it has no attachments.
    Vector(0, 1.3, 1.5),
    Vector(0, -1.3, 1.5),
    Vector(0, 0, -2.5)
}

/*
* Remove the drop when it hit a surface.
* @Particle particle
*/
local function LiquidCollide(particle)
    particle:SetDieTime(0)
end

/*
* Make black liquid flow from the eyes and the mouth of the mask (only visual).
* @Entity ent The entity used to limit the flow (Mask or wearer).
* @Vector pos Position of the mask model.
* @Angle ang Angles of the mask model.
*/
function scp_035.EmitBlackLiquid(ent, pos, ang)
    if (!SCP_035_CONFIG.ClientEnabledBlackLiquid) then return end

    local curTime = CurTime()
    if ((ent.SCP035_NextDrop or 0) > curTime) then return end
    ent.SCP035_NextDrop = curTime + math.Rand(0.15, 0.4)

    if (pos:DistToSqr(EyePos()) > SCP_035_CONFIG.LiquidMaxDistance ^ 2) then return end

    if (!liquidEmitter or !liquidEmitter:IsValid()) then liquidEmitter = ParticleEmitter(pos) end
    liquidEmitter:SetPos(pos)

    local dropPos = LocalToWorld(liquidOffsets[math.random(#liquidOffsets)], angle_zero, pos, ang)
    local particle = liquidEmitter:Add(SCP_035_CONFIG.LiquidParticle, dropPos)
    if (!particle) then return end

    local color = SCP_035_CONFIG.LiquidColor
    particle:SetColor(color.r, color.g, color.b)
    particle:SetVelocity(VectorRand() * 2)
    particle:SetGravity(Vector(0, 0, -400))
    particle:SetDieTime(3)
    particle:SetStartAlpha(255)
    particle:SetEndAlpha(255)
    particle:SetStartSize(math.Rand(0.8, 1.4))
    particle:SetEndSize(0.6)
    particle:SetStartLength(1)
    particle:SetEndLength(6) --? Stretched drop, looks viscous.
    particle:SetAirResistance(20)
    particle:SetCollide(true)
    particle:SetBounce(0)
    particle:SetCollideCallback(LiquidCollide)
end

/*
* Add a black stain received from the server (see scp_035.CreateLiquidStain).
* Engine decals can't be removed one by one, so the stains are drawn by the addon (see scp_035.DrawLiquidStains).
* @table stain {pos, normal, size, rotation, time}
*/
function scp_035.AddLiquidStain(stain)
    table.insert(liquidStains, stain)
    --? Same limit as the server, the oldest stain (the first) is removed.
    while (#liquidStains > SCP_035_CONFIG.LiquidStainMaxCount) do
        table.remove(liquidStains, 1)
    end
end

/*
* Draw the black stains, and remove them when their lifetime is over (with a fade out at the end).
*/
function scp_035.DrawLiquidStains()
    if (#liquidStains == 0) then return end

    local curTime = CurTime()
    local lifeTime = SCP_035_CONFIG.LiquidStainLifeTime
    local fadeTime = SCP_035_CONFIG.LiquidStainFadeTime
    local color = SCP_035_CONFIG.LiquidColor
    liquidStainColor.r, liquidStainColor.g, liquidStainColor.b = color.r, color.g, color.b

    render.SetMaterial(SCP_035_CONFIG.LiquidStainMaterial)
    for i = #liquidStains, 1, -1 do
        local stain = liquidStains[i]
        local timeLeft = lifeTime - (curTime - stain.time)

        if (timeLeft <= 0) then
            table.remove(liquidStains, i)
        else --? Always drawn (even if the black liquid is disabled), tentacles come out of them.
            liquidStainColor.a = 255 * math.Clamp(timeLeft / fadeTime, 0, 1)
            render.DrawQuadEasy(stain.pos, stain.normal, stain.size, stain.size, liquidStainColor, stain.rotation)
        end
    end
end

/*
* Remove every black stains.
*/
function scp_035.ClearLiquidStains()
    liquidStains = {}
end