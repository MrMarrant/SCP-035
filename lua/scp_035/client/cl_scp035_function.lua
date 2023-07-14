if SERVER then return end

function scp_035.DisplayText(ply)
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
        -- TODO : On fais quoi quand on a finis tous les textes ?
    end)

    timer.Create("DisplayFinalEffect_SCP035_"..ply:EntIndex(), timerToInfect + timerPhase, 1, function()
        if(!IsValid(ply)) then return end
        if(!ply.SCP035_AffectByMask) then return end

        ply.SCP035_SimpleText_1 = scp_035.DisPlaySimpleText(ply, scp_035.TranslateLanguage(SCP_035_LANG, "FinalText_1"), SCP_035_CONFIG.ScrW * 0.1, SCP_035_CONFIG.ScrH * 0.3)
        ply.SCP035_SimpleText_2 = scp_035.DisPlaySimpleText(ply, scp_035.TranslateLanguage(SCP_035_LANG, "FinalText_2"), SCP_035_CONFIG.ScrW * 0.8, SCP_035_CONFIG.ScrH * 0.3)
        ply.SCP035_StaticNoise = scp_035.DisPlayGIF(ply, "scp_035/static_noise.gif")
        ply.SCP035_MaskIMG = scp_035.DisPlayIMG(ply, "scp_035/mask.png")

        timer.Simple(3, function()
            if (IsValid(ply)) then
                ply.SCP035_StaticNoise:Remove()
                ply.SCP035_MaskIMG:Remove()
                ply.SCP035_SimpleText_1:Remove()
                ply.SCP035_SimpleText_2:Remove()
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
    ImageObject:SetSize(SCP_035_CONFIG.ScrW * 0.5, SCP_035_CONFIG.ScrH)
    ImageObject:SetPos(SCP_035_CONFIG.ScrW *0.27, 0)
    ImageObject:SetImage(material)
    ImageObject:SetZPos( 50 )

    return ImageObject
end

function scp_035.DisPlayGIF(ply, material, delay)

    local width, height = SCP_035_CONFIG.ScrW + 100, SCP_035_CONFIG.ScrH + 100 --? Cant disabled overflow-y, dont know why again so i hide it in a more stupid way.
    StaticNoise = vgui.Create("DHTML")
    StaticNoise:SetPos(-10, -10) --? No idea why, but the element dont pos exactly to 0,0, so iam doig stupid shit like this.
    StaticNoise:SetSize(width, height)
    StaticNoise:SetZPos( 10 )
    StaticNoise:SetHTML(
        '<style>'..
            '#container {overflow: hidden;}'..
        '</style>'..

        '<div id="portrait">'..
            '<div id="container">'..
                '<img src="asset://garrysmod/materials/'..material..'" width="'..width..'" height="'..height..'">'..
            '</div>'..
        '</div>'
        )
    return StaticNoise
end


function scp_035.DisPlayEffect(ply)
end