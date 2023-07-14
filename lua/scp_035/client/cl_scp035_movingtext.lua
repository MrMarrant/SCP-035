if SERVER then return end

local PANEL = {}

function PANEL:Init()
    self:SetSize(SCP_035_CONFIG.ScrW, SCP_035_CONFIG.ScrH)
    self:SetPaintBackground( false )
end

/*
* Allows you to update the saturation and position of each letter of the text currently displayed.
* @number duration Total duration to display the text.
*/
function PANEL:UpdatePosEvent(duration)
    local i = 1
    duration =  math.floor(duration*6.5) -- Because we do a tick every 0.1s, we have to multiply the duration totale to match with the actual duration.
    local saturation = 250
    local incrementSaturation = 250/duration
    timer.Create( "UpdatePosEvent_SCP035", 0.1, duration, function()
        if (!IsValid(self)) then return end
        local ChildrensPanel = self:GetChildren()
        for key, value in ipairs(ChildrensPanel) do
            value:SetPos(value.x, value.y + math.random(-0.6, 0.6))
            value:SetTextColor( Color(180, 180, 180, saturation) )
        end
        saturation = saturation - incrementSaturation
        if(i == duration) then self:Remove() -- When the total duration is ended, we remove the panel.
        else i = i +1 end
    end)
end

/*
* Initilisation value for the panel.
* @string text The text to display.
* @number duration Total duration to display the text.
*/
function PANEL:SetInitValue(text, duration)
    local WidthParent, HeightParent = self:GetSize()
    local StringSplit = utf8.codes(text) -- Some characters are not recognized by the string library, so we have to encode them and display them individually.
    local InitPosY, InitPosX = math.random(HeightParent * 0.2, HeightParent * 0.5), WidthParent * 0.2
    local keyManager = 1
    surface.SetFont( "DermaLarge" )
    for _, code in StringSplit do
        local textToDisplay = utf8.char(code)
        local sizeText = surface.GetTextSize( textToDisplay ) + 20 -- We add some spaces between each characters.
        local Children = self:Add("DLabel")
        Children:SetText( textToDisplay )
        Children:SetTextColor( Color(180, 180, 180) )
        Children:SetSize( WidthParent * 0.1, HeightParent * 0.1 )
        Children:SetPos(InitPosX, InitPosY)
        Children:SetFont(table.Random(SCP_035_CONFIG.FontEffect))
        if (keyManager >= 25 and textToDisplay == " ") then --TODO : Every 25 characters we do a line break, Not the best solution, it can maybe cause some problemes for some screen.
            InitPosY = InitPosY + 30
            keyManager = 1
            InitPosX = WidthParent * 0.2
        else
            InitPosX = InitPosX + sizeText
        end
        Children.x = InitPosX
        Children.y = InitPosY
        keyManager = keyManager + 1
    end
    self:UpdatePosEvent(duration)
end

vgui.Register( "SCP035MovingText", PANEL, "DPanel" )