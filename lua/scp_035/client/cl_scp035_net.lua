if SERVER then return end

net.Receive(SCP_035_CONFIG.SoundToPlayClientSide, function ( )
    local path = net.ReadString()
    local ply = LocalPlayer()

    ply:EmitSound(path)
end)