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
function scp_035.GetInSpherePlayers(ent, radius)
    local tableFilter = {}
    local entsFound = ents.FindInSphere( ent:GetPos(), radius )
    for key, value in ipairs(entsFound) do
        if (value:IsPlayer() and value:Alive() and !value.SCP035_AffectByMask and !scp_035.IsSCP035(value)) then
            table.insert(tableFilter, value)
        end
    end
    return tableFilter, entsFound
end

/* Set the effects proximity to players nearby.
* @entity ent
* @table tablePlayers 
*/
function scp_035.SetEffectsMask(ent, tablePlayers)
    for key, value in ipairs(tablePlayers) do
        value.SCP035_AffectByMask = true
        if (SERVER) then
            net.Start(SCP_035_CONFIG.SetEffectsMask)
            net.Send(value)
            if (SCP_035_CONFIG.ForcePutMask:GetBool()) then
                scp_035.SetForcePutMask(value, ent)
            end
        end
        scp_035.CheckDistance(ent, value)
    end
end

/* 
* It check if a player is still nearby the mask entitie, if not, remove the proximity effects.
* @string ent
* @Player ply
*/
function scp_035.CheckDistance(ent, ply)
    timer.Create("CheckDistance_SCP035_"..ply:EntIndex(), 0.1, 0, function()
        if (!IsValid(ply)) then return end
        if ( !ply.SCP035_AffectByMask or !ply:Alive()) then return end
        if (!IsValid(ent)) then scp_035.RemoveEffectProximity(ply) return end

        local distanceMask = ent:GetPos():Distance( ply:GetPos() )
        if ( distanceMask > (SCP_035_CONFIG.ClientRadiusEffect or SCP_035_CONFIG.RadiusEffect:GetInt()) + 20 ) then
            if (!timer.Exists("DissipatesEffect_SCP035_"..ply:EntIndex())) then
                timer.Create("DissipatesEffect_SCP035_"..ply:EntIndex(), 0.1, 1, function()
                    if(!IsValid(ply)) then return end

                    scp_035.RemoveEffectProximity(ply)
                    if (!ply.SCP035_OutOfEffect and SERVER) then --? Avoid spam out of range sound
                        scp_035.PlaySoundToClient(ply, "scp_035/out_of_effect.mp3", 100)
                        ply.SCP035_OutOfEffect = true
                        timer.Simple(4, function()
                            ply.SCP035_OutOfEffect = nil
                        end)
                    end
                end)
            end
        else
            timer.Remove("DissipatesEffect_SCP035_"..ply:EntIndex())
        end
    end)
end

/* 
* Remove only the proximity effects from mask entitie.
* @Player ply
*/
function scp_035.RemoveEffectProximity(ply)
    if (IsValid(ply.SCP035_ProximityEffect)) then
        ply.SCP035_ProximityEffect:Remove()
        ply.SCP035_ProximityEffect = nil
    end
    ply.SCP035_AffectByMask = nil
    if CLIENT then
        if (ply.SCP035_PannelDisplayText) then
            ply.SCP035_PannelDisplayText:Remove()
            ply.SCP035_PannelDisplayText = nil
        end
        scp_035.EndSound(ply) 
    end
end

function scp_035.IsSCP035(ply)
    if (!IsValid(ply)) then return false end
    if (ply:HasWeapon( "scp_035_swep" ) or ply.SCP035_IsWear) then return true end
    return false
end