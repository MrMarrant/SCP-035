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
            value:SetTextColor( Color(255, 255, 255, saturation) )
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
    local InitPosY, InitPosX = math.random(HeightParent * 0.2, HeightParent * 0.7), math.random(WidthParent * 0.1, WidthParent * 0.5)
    local originalPosX = InitPosX
    local keyManager = 1
    surface.SetFont( "DermaLarge" )
    for _, code in StringSplit do
        local textToDisplay = utf8.char(code)
        local sizeText = surface.GetTextSize( textToDisplay ) + 18 -- We add some spaces between each characters.
        local Children = self:Add("DLabel")
        Children:SetText( textToDisplay )
        Children:SetTextColor( Color(255, 255, 255) )
        Children:SetSize( WidthParent * 0.1, HeightParent * 0.1 )
        Children:SetPos(InitPosX, InitPosY)
        Children:SetFont(table.Random(SCP_035_CONFIG.FontEffect))
        if (keyManager >= 25 and textToDisplay == " ") then --? Every 25 characters we do a line break, Not the best solution, it can maybe cause some problemes for some screen.
            InitPosY = InitPosY + 30
            keyManager = 1
            InitPosX = originalPosX
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