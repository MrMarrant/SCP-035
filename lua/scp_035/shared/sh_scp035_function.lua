/*
* Returns the element to be translated according to the server language.
* @table langData Array containing all translations.
* @string name Element to translate.
*/
function scp_035.TranslateLanguage(langData, name)
    local langUsed = SCP_035_CONFIG.LangServer
    if not langData[langUsed] then
        langUsed = "fr" -- Default lang is EN.
    end
    return string.format( langData[langUsed][ name ] or "Not Found" )
end