if SERVER then return end

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

net.Receive(SCP_035_CONFIG.SoundToPlayClientSide, function ( )
    local path = net.ReadString()
    local pitch = net.ReadUInt(8)
    local ply = LocalPlayer()

    ply:EmitSound(path, 75, pitch)
end)

net.Receive(SCP_035_CONFIG.RemoveEffectClient, function ( )
    local ply = LocalPlayer()
    if (!IsValid(ply)) then return end

    ply:StopSound("scp_035/idle_sound.wav" )
    ply:StopSound("scp_035/static_noise.mp3" )
    ply.SCP035_SoundProximity = nil
    ply.SCP035_SoundProximityVolume = nil
    ply.SCP035_IsImmobilize = nil
    ply.SCP035_IsWear = nil
    if(timer.Exists("RemoveAffectByPrimary_SCP035_"..ply:EntIndex())) then timer.Adjust("RemoveAffectByPrimary_SCP035_"..ply:EntIndex(), 0, nil, nil) end
    scp_035.RemoveEffectProximity(ply)
end)

net.Receive(SCP_035_CONFIG.AffectByPrimary, function ( )
    local ply = LocalPlayer()

    ply:EmitSound("scp_035/static_noise.mp3")
    util.ScreenShake( Vector(0, 0, 0), 20, 300, SCP_035_CONFIG.DurationImmobilize, 0 )
    ply.SCP035_AffectByPrimary = scp_035.DisPlayGIF(ply, "scp_035/static_noise.gif", 0.6)

    timer.Create("RemoveAffectByPrimary_SCP035_"..ply:EntIndex(), SCP_035_CONFIG.DurationImmobilize, 1, function()
        if (!IsValid(ply)) then return end

        if (ply.SCP035_AffectByPrimary) then
            ply.SCP035_AffectByPrimary:Remove()
            ply.SCP035_AffectByPrimary = nil
        end
        ply:StopSound("scp_035/static_noise.mp3")
    end)
end)