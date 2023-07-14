if SERVER then return end

function scp_035.DisplayText(ply)
    local timerToInfect = SCP_035_CONFIG.TimeTotalEffect
    local timerPhase = timerToInfect/#SCP_035_CONFIG.FontEffect
    local index = 1
    local TextTodisplay = {}
    for var = 1, 5 do
        TextTodisplay[var] = scp_035.TranslateLanguage(SCP_035_LANG, "TextDisplay_"..var)
    end

    timer.Create("DisplayTextTimer_SCP035", timerPhase, #TextTodisplay, function()
        if(!IsValid(ply)) then return end
        if(!ply.SCP035_AffectByMask) then return end

        print(TextTodisplay[index])
        local PannelDisplayText = vgui.Create("SCP035MovingText")
        PannelDisplayText:SetInitValue(TextTodisplay[index], timerPhase)
        ply.SCP035_PannelDisplayText = PannelDisplayText
        index = index + 1
    end)
end


function scp_035.DisPlayEffect(ply)
end