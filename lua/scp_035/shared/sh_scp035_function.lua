/*
* Returns the element to be translated according to the server language.
* @table langData Array containing all translations.
* @string name Element to translate.
*/
function scp_035.TranslateLanguage(langData, name)
    local langUsed = SCP_035_CONFIG.LangServer
    if not langData[langUsed] then
        langUsed = "fr" -- Default lang is EN.
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
        if (value:IsPlayer() and value:Alive() and !value.SCP035_AffectByMask) then
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
        -- TODO : Faire le son de la neige de TV qui augmente au fur et à mesure
        if (CLIENT) then
            scp_035.DisplayMovingText(value)
            scp_035.DisPlayEffect(value)
            scp_035.ProximityEffect(value)
            --TODO : Jouer le son static noise de façon progressive (Voir le script de tag ?)
        end
        scp_035.CheckDistance(ent, value)
    end
end

function scp_035.CheckDistance(ent, ply)

    timer.Create("CheckDistance_SCP035_"..ply:EntIndex(), 0.1, 0, function()
        if (!IsValid(ent) or !IsValid(ply)) then return end
        if ( !ply.SCP035_AffectByMask or !ply:Alive()) then return end

        local distanceMask = ent:GetPos():Distance( ply:GetPos() )
        if ( distanceMask > SCP_035_CONFIG.RadiusEffect + 20 ) then
            if (!timer.Exists("DissipatesEffect_SCP035_"..ply:EntIndex())) then
                timer.Create("DissipatesEffect_SCP035_"..ply:EntIndex(), 0.1, 1, function()
                    if(!IsValid(ply)) then return end

                    if (IsValid(ply.SCP035_ProximityEffect)) then 
                        ply.SCP035_ProximityEffect:Remove()
                        ply.SCP035_ProximityEffect = nil
                    end
                    ply.SCP035_AffectByMask = nil
                end)
            end
        else
            timer.Remove("DissipatesEffect_SCP035_"..ply:EntIndex())
        end
    end)
end