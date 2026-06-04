--- Chat-Befehle + Hilfe-Vorschläge (ec_chat / Standard-Chat)

local function addChatSuggestion(command, helpText, params)
    if Config.ChatSuggestions == false then
        return
    end

    local slash = '/' .. command
    TriggerEvent('chat:addSuggestion', slash, helpText, params or {})

    for _, res in ipairs({ 'ec_chat', 'ec_chat_theme' }) do
        if GetResourceState(res) == 'started' then
            pcall(function()
                exports[res]:addSuggestion(slash, helpText, params or {})
            end)
        end
    end
end

local function registerSuggestions()
    local cmds = Config.Commands or {}

    if cmds.creategarage and cmds.creategarage.enabled ~= false then
        addChatSuggestion(
            'creategarage',
            cmds.creategarage.help or 'Garagen-Creator öffnen (Garagen bearbeiten & speichern)',
            cmds.creategarage.params
        )
    end

    if cmds.garageui and cmds.garageui.enabled ~= false then
        addChatSuggestion(
            'garageui',
            cmds.garageui.help or 'Garage-UI testweise öffnen',
            cmds.garageui.params or {
                { name = 'modus', help = 'land, air, water oder impound' },
            }
        )
    end
end

CreateThread(function()
    registerSuggestions()
end)

AddEventHandler('onClientResourceStart', function(resName)
    if resName == 'ec_chat' or resName == 'ec_chat_theme' then
        registerSuggestions()
    end
end)

RegisterCommand('creategarage', function()
    if ECGarage.UI.IsOpen() then
        ECGarage.UI.Close()
        return
    end
    ECGarage.UI.OpenCreator()
end, false)

RegisterCommand('garageui', function(_, args)
    if ECGarage.UI.IsOpen() then
        ECGarage.UI.Close()
        return
    end
    ECGarage.UI.OpenGarage({
        mode = args[1] or 'land',
        garageName = 'Garage',
    })
end, false)
