SCP_035_CONFIG.RadiusEffect = 300
SCP_035_CONFIG.RangeImmobilize = 300
SCP_035_CONFIG.DurationImmobilize = 5
SCP_035_CONFIG.LangServer = GetConVar("gmod_language"):GetString()
SCP_035_CONFIG.HandledLanguage = {
    "fr"
}

SCP_035_CONFIG.SoundToPlayClientSide = "SCP_035_CONFIG.SoundToPlayClientSide"
SCP_035_CONFIG.DisplayText = "SCP_035_CONFIG.DisplayText"

scp_035.LoadLanguage(SCP_035_CONFIG.RootFolder.."language/", SCP_035_CONFIG.HandledLanguage, SCP_035_LANG)
scp_035.LoadDirectory(SCP_035_CONFIG.RootFolder.."shared/")
scp_035.LoadDirectory(SCP_035_CONFIG.RootFolder.."server/")
scp_035.LoadDirectory(SCP_035_CONFIG.RootFolder.."client/")