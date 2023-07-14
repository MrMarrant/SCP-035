include("shared.lua")

function ENT:Draw()
    self:DrawModel() 
end

function ENT:LookAtMe(entsTable)
    for k,v in pairs(entsTable) do
        if(v:IsPlayer()) then
            v:SetEyeAngles((self:GetPos() - v:GetShootPos()):Angle())
        end
    end
end