-- Smoke tests run by GLuaTest on a dedicated server (see .github/workflows/gluatest.yml).
-- GLuaTest only fails on test failures, not on Lua errors while loading the addon.
-- Each check targets the last thing defined in a file: if it exists, the file compiled and ran to the end.

local function HasHook(event, name)
    local hooks = hook.GetTable()[event]
    return hooks ~= nil and hooks[name] ~= nil
end

return {
    groupName = "SCP-035 load",
    cases = {
        {
            name = "Global tables are created by the autorun",
            func = function()
                expect( scp_035 ).to.beA( "table" )
                expect( SCP_035_CONFIG ).to.beA( "table" )
                expect( SCP_035_LANG ).to.beA( "table" )
            end
        },
        {
            name = "Shared and server configs are loaded",
            func = function()
                expect( SCP_035_CONFIG.AddLiquidStains ).to.beA( "string" )
                expect( util.NetworkStringToID( SCP_035_CONFIG.AddLiquidStains ) ).to.beGreaterThan( 0 )
            end
        },
        {
            name = "Every handled language is loaded",
            func = function()
                expect( SCP_035_CONFIG.HandledLanguage ).to.beA( "table" )
                for _, lang in ipairs( SCP_035_CONFIG.HandledLanguage ) do
                    expect( SCP_035_LANG[lang] ).to.beA( "table" )
                end
            end
        },
        {
            name = "Shared functions are loaded",
            func = function()
                expect( scp_035.IsSCP035 ).to.beA( "function" )
            end
        },
        {
            name = "Server files are loaded",
            func = function()
                expect( scp_035.UnFreezeNPC ).to.beA( "function" )
                expect( scp_035.SpawnTentacle ).to.beA( "function" )
                expect( HasHook( "PlayerInitialSpawn", "PlayerInitialSpawn.SCP035_LoadPossessor" ) ).to.beTrue()
                expect( HasHook( "OnEntityCreated", "OnEntityCreated.SCP035_NPCHate" ) ).to.beTrue()
                expect( HasHook( "PostCleanupMap", "PostCleanupMap.SCP035_ClearLiquidStains" ) ).to.beTrue()
            end
        },
        {
            name = "Entity scp_035_real is registered",
            func = function()
                local ent = scripted_ents.GetStored( "scp_035_real" )
                expect( ent ).to.exist()
                expect( ent.t.Use ).to.beA( "function" )
                expect( ent.t.Think ).to.beA( "function" )
            end
        },
        {
            name = "Entity scp_035_tentacle is registered",
            func = function()
                local ent = scripted_ents.GetStored( "scp_035_tentacle" )
                expect( ent ).to.exist()
                expect( ent.t.Attack ).to.beA( "function" )
                expect( ent.t.GetSegmentPoints ).to.beA( "function" )
            end
        },
        {
            name = "Weapon scp_035_swep is registered",
            func = function()
                local swep = weapons.GetStored( "scp_035_swep" )
                expect( swep ).to.exist()
                expect( swep.Deploy ).to.beA( "function" )
            end
        },
    }
}
