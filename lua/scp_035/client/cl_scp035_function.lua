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

function scp_035.DisplayMovingText(ply)
    local timerToInfect = SCP_035_CONFIG.TimeTotalEffect
    local timerPhase = timerToInfect/#SCP_035_CONFIG.FontEffect
    local index = 1
    local TextTodisplay = {}
    local DialogVersion = math.random(1, SCP_035_CONFIG.MaxDialogVersion)
    for var = 1, 5 do
        TextTodisplay[var] = scp_035.TranslateLanguage(SCP_035_LANG, "TextDisplay_v"..DialogVersion.."_"..var)
    end

    timer.Create("DisplayTextTimer_SCP035_"..ply:EntIndex(), 5, #TextTodisplay, function()
        if(!IsValid(ply)) then return end
        if(!ply.SCP035_AffectByMask) then return end

        local PannelDisplayText = vgui.Create("SCP035MovingText")
        PannelDisplayText:SetInitValue(TextTodisplay[index], timerPhase)
        ply.SCP035_PannelDisplayText = PannelDisplayText
        if(index == 1) then timer.Adjust( "DisplayTextTimer_SCP035_"..ply:EntIndex(), timerPhase, nil, nil ) end
        index = index + 1
    end)

    scp_035.DisPlayFinalText(ply, timerToInfect + timerPhase)
end

function scp_035.DisPlayFinalText(ply, delay)
    timer.Create("DisplayFinalEffect_SCP035_"..ply:EntIndex(), delay, 1, function()
        if(!IsValid(ply)) then return end
        if(!ply.SCP035_AffectByMask) then return end

        ply:EmitSound( Sound( "scp_035/final_effect.mp3" ), 75, math.random( 100, 110 ) ) -- TODO : Le rendre plus fort
        ply.SCP035_SimpleText_1 = scp_035.DisPlaySimpleText(ply, scp_035.TranslateLanguage(SCP_035_LANG, "FinalText_1"), SCP_035_CONFIG.ScrW * 0.1, SCP_035_CONFIG.ScrH * 0.3)
        ply.SCP035_SimpleText_2 = scp_035.DisPlaySimpleText(ply, scp_035.TranslateLanguage(SCP_035_LANG, "FinalText_2"), SCP_035_CONFIG.ScrW * 0.8, SCP_035_CONFIG.ScrH * 0.3)
        ply.SCP035_StaticNoise = scp_035.DisPlayGIF(ply, "scp_035/static_noise.gif")
        ply.SCP035_MaskIMG = scp_035.DisPlayIMG(ply, "scp_035/mask.png")

        timer.Simple(1, function()
            if (IsValid(ply)) then
                ply.SCP035_StaticNoise:Remove()
                ply.SCP035_MaskIMG:Remove()
                ply.SCP035_SimpleText_1:Remove()
                ply.SCP035_SimpleText_2:Remove()

                scp_035.DisPlayFinalText(ply, math.random(5, 10))
            end
        end)
    end)
end

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

function scp_035.DisPlayIMG(ply, material)
    ImageObject = vgui.Create("DImage")
    ImageObject:SetSize(SCP_035_CONFIG.ScrW * 0.5, SCP_035_CONFIG.ScrH * 1.3)
    ImageObject:SetPos(SCP_035_CONFIG.ScrW *0.27, -SCP_035_CONFIG.ScrH * 0.12)
    ImageObject:SetImage(material)
    ImageObject:SetZPos( 50 )

    return ImageObject
end

function scp_035.DisPlayGIF(ply, material, alpha)

    alpha = alpha or 1
    local width, height = SCP_035_CONFIG.ScrW + 100, SCP_035_CONFIG.ScrH + 100 --? Cant disabled overflow-y, dont know why again so i hide it in a more stupid way.
    StaticNoise = vgui.Create("DHTML")
    StaticNoise:SetPos(-10, -10) --? No idea why, but the element dont pos exactly to (0,0), so i've to do stupid shit like this.
    StaticNoise:SetSize(width, height)
    StaticNoise:SetZPos( 10 )
    StaticNoise:SetHTML(
        '<style>'..
            '#container {overflow: hidden;}'..
            'img {opacity: '..alpha..';}'..
        '</style>'..

        '<div id="portrait">'..
            '<div id="container">'..
                '<img id="gif-scp035" src="asset://garrysmod/materials/'..material..'" width="'..width..'" height="'..height..'">'..
            '</div>'..
        '</div>'
        )
    return StaticNoise
end

/*
* Display a static noise gif that increment in alpha depend on the total time every 0.5s.
*/
function scp_035.ProximityEffect(ply)
    local alpha = 0.01
    local repetitions = SCP_035_CONFIG.TimeTotalEffect * 2
    local incrementAlpha = 0.3/repetitions

    ply.SCP035_ProximityEffect = ply.SCP035_ProximityEffect or scp_035.DisPlayGIF(ply, "scp_035/static_noise.gif", alpha)
    timer.Create("ProximityEffect_SCP035_"..ply:EntIndex(), 0.5, repetitions, function()
        if(!IsValid(ply)) then return end
        if(!IsValid(ply.SCP035_ProximityEffect)) then return end

        alpha = alpha + incrementAlpha
        ply.SCP035_ProximityEffect:Call('document.getElementById("gif-scp035").style.opacity = "'..alpha..'";')
    end)
end