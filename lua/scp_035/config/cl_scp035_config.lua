if SERVER then return end

SCP_035_CONFIG.ScrW = ScrW()
SCP_035_CONFIG.ScrH = ScrH()

SCP_035_CONFIG.TimeTotalEffect = 40

-- 
surface.CreateFont( "SCP035_Font1", {
    font = "Arial",
    size = 40,
} )
surface.CreateFont( "SCP035_Font2", {
    font = "Arial",
    size = 35,
} )
surface.CreateFont( "SCP035_Font3", {
    font = "Arial",
    size = 45,
} )
surface.CreateFont( "SCP035_Font4", {
    font = "Arial",
    size = 30,
} )
surface.CreateFont( "SCP035_Font5", {
    font = "Arial",
    size = 38,
} )
surface.CreateFont( "SCP035_Font6", {
    font = "Arial",
    size = 25,
} )
SCP_035_CONFIG.FontEffect = {}
for var = 1, 6 do
    SCP_035_CONFIG.FontEffect[var] = "SCP035_Font"..var
end
