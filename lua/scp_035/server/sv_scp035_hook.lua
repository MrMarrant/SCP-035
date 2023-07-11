if CLIENT then return end

hook.Add( "PlayerDeath", "PlayerDeath.Remove_SCP035", scp_035.DropEntitie )
hook.Add( "PlayerDisconnected", "PlayerDisconnected.Remove_SCP035", scp_035.DropEntitie )