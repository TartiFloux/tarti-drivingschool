-- Vérifie si le joueur a le code de la route
ESX.RegisterServerCallback('esx_permis:hasCode', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    local hasCode = xPlayer.get('hasCode') or false
    cb(hasCode)
end)

-- Vérifie si le joueur a déjà un permis spécifique
ESX.RegisterServerCallback('esx_permis:hasLicense', function(source, cb, licenseType)
    local xPlayer = ESX.GetPlayerFromId(source)
    local itemName = Config.LicenseItem[licenseType]
    local item = exports.ox_inventory:GetItem(source, itemName, nil, true)
    cb(item and item > 0)
end)

-- Vérifie tous les permis du joueur
ESX.RegisterServerCallback('esx_permis:getAllLicenses', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    local licenses = {
        car = false,
        moto = false,
        truck = false
    }
    
    for licenseType, itemName in pairs(Config.LicenseItem) do
        local item = exports.ox_inventory:GetItem(source, itemName, nil, true)
        licenses[licenseType] = item and item > 0
    end
    
    cb(licenses)
end)

-- Acheter le passage du code
RegisterNetEvent('esx_permis:buyCode')
AddEventHandler('esx_permis:buyCode', function()
    local xPlayer = ESX.GetPlayerFromId(source)
    
    if xPlayer.getMoney() >= Config.CodePrice then
        xPlayer.removeMoney(Config.CodePrice)
        TriggerClientEvent('esx_permis:startCode', source)
    else
        TriggerClientEvent('esx:showNotification', source, '~r~Vous n\'avez pas assez d\'argent (' .. Config.CodePrice .. '$)')
    end
end)

-- Valider le code de la route
RegisterNetEvent('esx_permis:validateCode')
AddEventHandler('esx_permis:validateCode', function()
    local xPlayer = ESX.GetPlayerFromId(source)
    xPlayer.set('hasCode', true)
    TriggerClientEvent('esx:showNotification', source, '~g~Félicitations ! Vous avez obtenu votre code de la route !')
end)

-- Acheter le passage du permis (voiture, moto ou camion)
RegisterNetEvent('esx_permis:buyPermis')
AddEventHandler('esx_permis:buyPermis', function(licenseType)
    local xPlayer = ESX.GetPlayerFromId(source)
    local hasCode = xPlayer.get('hasCode') or false
    
    if not hasCode then
        TriggerClientEvent('esx:showNotification', source, '~r~Vous devez d\'abord obtenir votre code de la route !')
        return
    end
    
    local price = Config.PermisPrice[licenseType]
    
    if xPlayer.getMoney() >= price then
        xPlayer.removeMoney(price)
        TriggerClientEvent('esx_permis:startPermis', source, licenseType)
    else
        TriggerClientEvent('esx:showNotification', source, '~r~Vous n\'avez pas assez d\'argent (' .. price .. '$)')
    end
end)

-- Donner le permis de conduire
RegisterNetEvent('esx_permis:givePermis')
AddEventHandler('esx_permis:givePermis', function(licenseType)
    local xPlayer = ESX.GetPlayerFromId(source)
    
    -- Vérification de sécurité
    local hasCode = xPlayer.get('hasCode') or false
    if not hasCode then
        return
    end
    
    -- Donner l'item avec ox_inventory
    local itemName = Config.LicenseItem[licenseType]
    local success = exports.ox_inventory:AddItem(source, itemName, 1)
    
    if success then
        local licenseName = ''
        if licenseType == 'car' then
            licenseName = 'permis voiture'
        elseif licenseType == 'moto' then
            licenseName = 'permis moto'
        elseif licenseType == 'truck' then
            licenseName = 'permis camion'
        end
        
        TriggerClientEvent('esx:showNotification', source, '~g~Félicitations ! Vous avez obtenu votre ' .. licenseName .. ' !')
        -- NE PAS reset le code pour permettre de passer d'autres permis
    else
        TriggerClientEvent('esx:showNotification', source, '~r~Erreur lors de l\'attribution du permis')
    end
end)

-- Commande pour retirer le code (admin)
ESX.RegisterCommand('removeCode', 'admin', function(xPlayer, args, showError)
    local targetId = args.playerId
    
    if targetId then
        local xTarget = ESX.GetPlayerFromId(targetId)
        
        if xTarget then
            xTarget.set('hasCode', false)
            xPlayer.showNotification('~g~Vous avez retiré le code de ' .. xTarget.getName())
            xTarget.showNotification('~r~Votre code de la route a été retiré par un administrateur')
        else
            xPlayer.showNotification('~r~Joueur introuvable')
        end
    else
        xPlayer.showNotification('~r~Usage: /removeCode [ID du joueur]')
    end
end, false, {help = 'Retirer le code de la route à un joueur', validate = true, arguments = {
    {name = 'playerId', help = 'ID du joueur', type = 'player'}
}})

-- Commande pour se retirer son propre code
RegisterCommand('resetMyCode', function(source, args, rawCommand)
    local xPlayer = ESX.GetPlayerFromId(source)
    
    if xPlayer then
        xPlayer.set('hasCode', false)
        xPlayer.showNotification('~g~Votre code de la route a été réinitialisé')
    end
end, false)