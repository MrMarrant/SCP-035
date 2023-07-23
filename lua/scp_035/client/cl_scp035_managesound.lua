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

function scp_035.CreateSound(ply, path, isLoop, crescent)
    ply.SCP035_SoundProximity = ply.SCP035_SoundProximity or CreateSound( ply, path )
    ply.SCP035_SoundProximityVolume = ply.SCP035_SoundProximityVolume or 0.01
    ply.SCP035_SoundProximity:Stop()
    ply.SCP035_SoundProximity:PlayEx(ply.SCP035_SoundProximityVolume, 100)

    if (isLoop) then scp_035.LoopingSound(ply, path) end
    if (crescent) then scp_035.IncreaseVolume(ply) end
end

function scp_035.LoopingSound(ply, path)
    local duration = SoundDuration( path )

    timer.Create("LoopingSound_SCP035_"..ply:EntIndex(), duration, 1, function()
        if(!IsValid(ply)) then return end
        if(!ply.SCP035_AffectByMask) then return end
        if(!ply.SCP035_SoundProximity) then return end

        scp_035.CreateSound(ply, path, true, false)
    end)
end

function scp_035.IncreaseVolume(ply)
    if(!ply.SCP035_SoundProximity) then return end

    local volume = 0.01
    local repetitions = SCP_035_CONFIG.TimeTotalEffect * 2
    local incrementVolume = 0.8/repetitions
    timer.Create("IncreaseVolume_SCP035_"..ply:EntIndex(), 0.5, repetitions, function()
        if(!IsValid(ply)) then return end
        if(!ply.SCP035_SoundProximity) then return end

        volume = volume + incrementVolume
        ply.SCP035_SoundProximity:ChangeVolume( volume )
        ply.SCP035_SoundProximityVolume = volume
    end)
end

function scp_035.EndSound(ply)
    if(!ply.SCP035_SoundProximity) then return end

    ply.SCP035_SoundProximity:Stop()
    ply.SCP035_SoundProximityVolume = nil
    ply.SCP035_SoundProximity = nil
end