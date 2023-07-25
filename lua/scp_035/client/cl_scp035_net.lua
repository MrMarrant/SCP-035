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
    local ply = LocalPlayer()

    ply:EmitSound(path)
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

    scp_035.RemoveEffectProximity(ply)
end)