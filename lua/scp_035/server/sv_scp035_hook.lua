if CLIENT then return end

-- TODO : Stoper tous les sons utilisés & les effets.
hook.Add( "PlayerDeath", "PlayerDeath.Remove_SCP035", function(ply)
    scp_035.DropEntitie(ply)
    ply.SCP035_IsImmobilize = nil
    ply.SCP035_AffectByMask = nil
end)

hook.Add( "PlayerDisconnected", "PlayerDisconnected.Remove_SCP035", function(ply)
    scp_035.DropEntitie(ply)
    ply.SCP035_IsImmobilize = nil
    ply.SCP035_AffectByMask = nil
end)