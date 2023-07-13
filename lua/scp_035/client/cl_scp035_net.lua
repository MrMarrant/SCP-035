if SERVER then return end

net.Receive(SCP_035_CONFIG.SoundToPlayClientSide, function ( )
    local path = net.ReadString()
    local ply = LocalPlayer()

    ply:EmitSound(path)
end)

net.Receive(SCP_035_CONFIG.DisplayText, function ( )
    local ply = LocalPlayer()
    local timerToInfect = SCP_035_CONFIG.TimeTotalEffect
    local timerPhase = timerToInfect/#SCP_035_CONFIG.FontEffect
    local index = 1
    local TextTodisplay = {}
    for var = 1, 5 do
        TextTodisplay[var] = scp_035.TranslateLanguage(SCP_035_LANG, "TextDisplay_"..var)
    end

    timer.Create("DisplayTextTimer_SCP035", timerPhase, #TextTodisplay, function()
        if(!IsValid(ply)) then return end

        local PannelDisplayText = vgui.Create("SCP035MovingText")
        PannelDisplayText:SetInitValue(TextTodisplay[index], timerPhase)
        ply.SCP035_PannelDisplayText = PannelDisplayText
        index = index + 1
    end)
end)