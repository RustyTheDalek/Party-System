local socialActive = false

function toggleSocial()
    socialActive = not socialActive

    SendNUIMessage({
        action = "toggleSocial",
        active = socialActive
    })

    SetNuiFocus(socialActive, socialActive)
end

RegisterKeyMapping('socialToggle', 'Toggle Social menu', 'keyboard', 'o')

RegisterCommand('socialToggle', function()
    print("button pressed")
    toggleSocial()
end, false)

RegisterNUICallback('closeSocial', function()
    print("closing social");
    socialActive = false
    SetNuiFocus(socialActive, socialActive)
end)