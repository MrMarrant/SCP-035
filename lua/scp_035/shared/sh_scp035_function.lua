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

/*
* Returns the element to be translated according to the server language.
* @table langData Array containing all translations.
* @string name Element to translate.
*/
function scp_035.TranslateLanguage(langData, name)
    local langUsed = SCP_035_CONFIG.LangServer
    if not langData[langUsed] then
        langUsed = "en" -- Default lang is EN.
    end
    return string.format( langData[langUsed][ name ] or "Not Found" )
end

/*
* Function used for get every players in sphere and filter.
* @Entity ent The Mask SCP035
*/
function scp_035.GetInSpherePlayers(ent)
    local tableFilter = {}
    local playersFound = ents.FindInSphere( ent:GetPos(), SCP_035_CONFIG.RadiusEffect )
    for key, value in ipairs(playersFound) do
        if (value:IsPlayer() and value:Alive() and !value.SCP035_AffectByMask and !scp_035.IsSCP035(value)) then
            table.insert(tableFilter, value)
        end
    end
    return tableFilter, playersFound
end

/*
* 
* @table tablePlayers 
*/
function scp_035.SetEffectsMask(ent, tablePlayers)
    for key, value in ipairs(tablePlayers) do
        value.SCP035_AffectByMask = true
        if (SERVER) then
            net.Start(SCP_035_CONFIG.SetEffectsMask)
            net.Send(value)
        end
        scp_035.CheckDistance(ent, value)
    end
end

function scp_035.CheckDistance(ent, ply)

    timer.Create("CheckDistance_SCP035_"..ply:EntIndex(), 0.1, 0, function()
        if (!IsValid(ply)) then return end
        if ( !ply.SCP035_AffectByMask or !ply:Alive()) then return end
        if (!IsValid(ent)) then scp_035.RemoveEffectProximity(ply) return end

        local distanceMask = ent:GetPos():Distance( ply:GetPos() )
        if ( distanceMask > SCP_035_CONFIG.RadiusEffect + 20 ) then
            if (!timer.Exists("DissipatesEffect_SCP035_"..ply:EntIndex())) then
                timer.Create("DissipatesEffect_SCP035_"..ply:EntIndex(), 0.1, 1, function()
                    if(!IsValid(ply)) then return end

                    scp_035.RemoveEffectProximity(ply)
                    if (CLIENT) then ply:EmitSound("scp_035/out_of_effect.mp3") end
                end)
            end
        else
            timer.Remove("DissipatesEffect_SCP035_"..ply:EntIndex())
        end
    end)
end

function scp_035.RemoveEffectProximity(ply)
    if (IsValid(ply.SCP035_ProximityEffect)) then
        ply.SCP035_ProximityEffect:Remove()
        ply.SCP035_ProximityEffect = nil
    end
    ply.SCP035_AffectByMask = nil
    if CLIENT then scp_035.EndSound(ply) end
end

function scp_035.IsSCP035(ply)
    if (ply:HasWeapon( "scp_035_swep" ) or ply.SCP035_IsWear) then return true end
    return false
end