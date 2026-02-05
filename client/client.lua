local inTest = false
local currentQuestion = 1
local errorCount = 0
local testType = nil -- 'code' ou 'permis'

-- Variables pour le permis
local permisVehicle = nil
local currentCheckpoint = 1
local permisErrors = 0
local lastVehicleHealth = 1000
local currentLicenseType = nil -- 'car', 'moto', 'truck'
local currentMaxSpeed = 50

-- Créer le PED de l'auto-école
CreateThread(function()
    local pedModel = 'a_m_m_business_01'
    RequestModel(pedModel)
    while not HasModelLoaded(pedModel) do
        Wait(1)
    end
    
    local ped = CreatePed(4, pedModel, Config.SchoolPosition.x, Config.SchoolPosition.y, Config.SchoolPosition.z - 1.0, Config.SchoolHeading, false, true)
    SetEntityAsMissionEntity(ped, true, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
    
    -- Blip sur la carte
    local blip = AddBlipForCoord(Config.SchoolPosition.x, Config.SchoolPosition.y, Config.SchoolPosition.z)
    SetBlipSprite(blip, 225)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, 0.8)
    SetBlipColour(blip, 3)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Auto-école")
    EndTextCommandSetBlipName(blip)
end)

-- Interaction avec le PED
CreateThread(function()
    local hasShownNotification = false
    
    while true do
        local wait = 1000
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local distance = #(playerCoords - Config.SchoolPosition)
        
        if distance < 15.0 then
            wait = 0
            if distance < 2.0 and not inTest then
                if not hasShownNotification then
                    hasShownNotification = true
                end
                
                DrawText3D(Config.SchoolPosition.x, Config.SchoolPosition.y, Config.SchoolPosition.z + 1.0, '~g~[E]~s~ Parler à l\'instructeur')
                
                if IsControlJustReleased(0, 38) then -- E
                    OpenSchoolMenu()
                end
            else
                hasShownNotification = false
            end
        else
            hasShownNotification = false
        end
        
        Wait(wait)
    end
end)

-- Menu principal de l'auto-école
function OpenSchoolMenu()
    ESX.TriggerServerCallback('esx_permis:hasCode', function(hasCode)
        ESX.TriggerServerCallback('esx_permis:getAllLicenses', function(licenses)
            local elements = {}
            
            if not hasCode then
                table.insert(elements, {label = 'Passer le code de la route - ' .. Config.CodePrice .. '$', value = 'code'})
            else
                -- Afficher les permis disponibles
                if not licenses.car then
                    table.insert(elements, {label = '🚗 Permis Voiture - ' .. Config.PermisPrice.car .. '$', value = 'permis_car'})
                else
                    table.insert(elements, {label = '✅ Permis Voiture (obtenu)', value = 'none'})
                end
                
                if not licenses.moto then
                    table.insert(elements, {label = '🏍️ Permis Moto - ' .. Config.PermisPrice.moto .. '$', value = 'permis_moto'})
                else
                    table.insert(elements, {label = '✅ Permis Moto (obtenu)', value = 'none'})
                end
                
                if not licenses.truck then
                    table.insert(elements, {label = '🚚 Permis Camion - ' .. Config.PermisPrice.truck .. '$', value = 'permis_truck'})
                else
                    table.insert(elements, {label = '✅ Permis Camion (obtenu)', value = 'none'})
                end
                
                if licenses.car and licenses.moto and licenses.truck then
                    table.insert(elements, {label = '🎉 Vous avez tous les permis !', value = 'none'})
                end
            end
            
            ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'school_menu', {
                title = 'Auto-école',
                align = 'top-left',
                elements = elements
            }, function(data, menu)
                if data.current.value == 'code' then
                    menu.close()
                    TriggerServerEvent('esx_permis:buyCode')
                elseif data.current.value == 'permis_car' then
                    menu.close()
                    TriggerServerEvent('esx_permis:buyPermis', 'car')
                elseif data.current.value == 'permis_moto' then
                    menu.close()
                    TriggerServerEvent('esx_permis:buyPermis', 'moto')
                elseif data.current.value == 'permis_truck' then
                    menu.close()
                    TriggerServerEvent('esx_permis:buyPermis', 'truck')
                end
            end, function(data, menu)
                menu.close()
            end)
        end)
    end)
end

-- Démarrer le test du code
RegisterNetEvent('esx_permis:startCode')
AddEventHandler('esx_permis:startCode', function()
    inTest = true
    testType = 'code'
    currentQuestion = 1
    errorCount = 0
    ShowCodeQuestion()
end)

-- Afficher une question du code
function ShowCodeQuestion()
    if currentQuestion > #Config.CodeQuestions then
        FinishCodeTest(true)
        return
    end
    
    local question = Config.CodeQuestions[currentQuestion]
    local elements = {}
    
    table.insert(elements, {
        label = '' .. question.question,
        value = 'question_text',
        disabled = true
    })
    
    table.insert(elements, {
        label = '────────────────────',
        value = 'separator',
        disabled = true
    })
    
    for i, answer in ipairs(question.answers) do
        table.insert(elements, {
            label = answer.text,
            value = i,
            correct = answer.correct
        })
    end
    
    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'code_question', {
        title = 'Code de la route - ' .. currentQuestion .. '/' .. #Config.CodeQuestions,
        align = 'top-left',
        elements = elements
    }, function(data, menu)
        if data.current.value == 'question_text' or data.current.value == 'separator' then
            return
        end
        
        if data.current.correct then
            ESX.ShowNotification('~g~Bonne réponse !')
            currentQuestion = currentQuestion + 1
            menu.close()
            Wait(500)
            ShowCodeQuestion()
        else
            errorCount = errorCount + 1
            ESX.ShowNotification('~r~Mauvaise réponse ! (' .. errorCount .. '/' .. Config.MaxCodeErrors .. ' erreurs)')
            
            if errorCount >= Config.MaxCodeErrors then
                menu.close()
                FinishCodeTest(false)
            else
                currentQuestion = currentQuestion + 1
                menu.close()
                Wait(500)
                ShowCodeQuestion()
            end
        end
    end, function(data, menu)
        menu.close()
        FinishCodeTest(false)
    end)
end

-- Terminer le test du code
function FinishCodeTest(success)
    inTest = false
    testType = nil
    
    if success then
        TriggerServerEvent('esx_permis:validateCode')
    else
        ESX.ShowNotification('~r~Vous avez échoué au code de la route. Vous devez le repasser.')
    end
end

-- Démarrer le permis de conduire (voiture, moto ou camion)
RegisterNetEvent('esx_permis:startPermis')
AddEventHandler('esx_permis:startPermis', function(licenseType)
    inTest = true
    testType = 'permis'
    currentLicenseType = licenseType
    currentCheckpoint = 1
    permisErrors = 0
    
    SpawnPermisVehicle(licenseType)
end)

-- Spawn du véhicule pour le permis
function SpawnPermisVehicle(licenseType)
    local vehicleModel = Config.VehicleModel[licenseType]
    local spawnPos = Config.VehicleSpawn[licenseType]
    
    ESX.Game.SpawnVehicle(vehicleModel, spawnPos, spawnPos.w, function(vehicle)
        permisVehicle = vehicle
        SetVehicleEngineOn(vehicle, true, true, false)
        SetVehicleOnGroundProperly(vehicle)
        
        Wait(500)
        lastVehicleHealth = GetVehicleBodyHealth(vehicle)
        
        TaskWarpPedIntoVehicle(PlayerPedId(), vehicle, -1)
        
        -- Obtenir la vitesse max du premier checkpoint
        local firstCheckpoint = Config.PermisCheckpoints[licenseType][1]
        currentMaxSpeed = firstCheckpoint.maxSpeed
        
        local vehicleName = 'voiture'
        if licenseType == 'moto' then
            vehicleName = 'moto'
        elseif licenseType == 'truck' then
            vehicleName = 'camion'
        end
        
        ESX.ShowNotification('~b~Suivez le parcours en respectant les limitations de vitesse')
        ESX.ShowNotification('~y~Vitesse maximale actuelle : ' .. currentMaxSpeed .. ' km/h')
        
        CreatePermisCheckpoint()
        
        Wait(500)
        StartPermisChecks()
    end)
end

-- Créer le checkpoint
function CreatePermisCheckpoint()
    local checkpoint = Config.PermisCheckpoints[currentLicenseType][currentCheckpoint]
    local nextCheckpoint = Config.PermisCheckpoints[currentLicenseType][currentCheckpoint + 1]
    
    -- Mettre à jour la vitesse max pour ce checkpoint
    currentMaxSpeed = checkpoint.maxSpeed
    
    local checkpointType = 1
    if currentCheckpoint == #Config.PermisCheckpoints[currentLicenseType] then
        checkpointType = 4
    end
    
    if nextCheckpoint then
        SetNewWaypoint(nextCheckpoint.pos.x, nextCheckpoint.pos.y)
    end
    
    CreateThread(function()
        while inTest and testType == 'permis' and DoesEntityExist(permisVehicle) do
            local playerCoords = GetEntityCoords(PlayerPedId())
            local distance = #(playerCoords - checkpoint.pos)
            
            -- Checkpoint vert et plus petit (3.0 au lieu de 5.0)
            DrawMarker(checkpointType, checkpoint.pos.x, checkpoint.pos.y, checkpoint.pos.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 3.0, 3.0, 1.5, 0, 255, 0, 100, false, true, 2, false, nil, nil, false)
            
            if distance < 4.0 then
                if currentCheckpoint == #Config.PermisCheckpoints[currentLicenseType] then
                    FinishPermisTest(true)
                    break
                else
                    currentCheckpoint = currentCheckpoint + 1
                    local newCheckpoint = Config.PermisCheckpoints[currentLicenseType][currentCheckpoint]
                    ESX.ShowNotification('~g~Checkpoint validé !')
                    ESX.ShowNotification('~y~Nouvelle limite : ' .. newCheckpoint.maxSpeed .. ' km/h')
                    CreatePermisCheckpoint()
                    break
                end
            end
            
            Wait(0)
        end
    end)
end

-- Vérifications pendant le permis
function StartPermisChecks()
    local lastSpeedCheck = GetGameTimer()
    local speedViolationTime = 0
    
    CreateThread(function()
        while inTest and testType == 'permis' and DoesEntityExist(permisVehicle) do
            local playerPed = PlayerPedId()
            local vehicle = GetVehiclePedIsIn(playerPed, false)
            
            if vehicle == permisVehicle then
                local currentTime = GetGameTimer()
                
                -- Vérifier la vitesse avec la limite du checkpoint actuel
                local speed = GetEntitySpeed(vehicle) * 3.6
                
                if speed > currentMaxSpeed + 5 then
                    if speedViolationTime == 0 then
                        speedViolationTime = currentTime
                    elseif currentTime - speedViolationTime > 2000 then
                        AddPermisError('Excès de vitesse ! (Max: ' .. currentMaxSpeed .. ' km/h)')
                        speedViolationTime = 0
                    end
                else
                    speedViolationTime = 0
                end
                
                -- Vérifier les dégâts
                local currentHealth = GetVehicleBodyHealth(vehicle)
                local healthDiff = lastVehicleHealth - currentHealth
                
                if healthDiff > 100 then
                    AddPermisError('Collision détectée !')
                    lastVehicleHealth = currentHealth
                end
            else
                AddPermisError('Vous avez quitté le véhicule !')
                FinishPermisTest(false)
                break
            end
            
            Wait(500)
        end
    end)
end

-- Ajouter une erreur au permis
function AddPermisError(reason)
    permisErrors = permisErrors + 1
    ESX.ShowNotification('~r~Erreur : ' .. reason .. ' (' .. permisErrors .. '/' .. Config.MaxPermisErrors .. ')')
    
    if permisErrors >= Config.MaxPermisErrors then
        FinishPermisTest(false)
    end
end

-- Terminer le test du permis
function FinishPermisTest(success)
    inTest = false
    testType = nil
    
    if DoesEntityExist(permisVehicle) then
        ESX.Game.DeleteVehicle(permisVehicle)
    end
    
    permisVehicle = nil
    
    if success then
        TriggerServerEvent('esx_permis:givePermis', currentLicenseType)
    else
        ESX.ShowNotification('~r~Vous avez échoué au permis. Vous devez le repasser.')
    end
    
    currentLicenseType = nil
end

-- Fonction pour afficher du texte 3D
function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local px, py, pz = table.unpack(GetGameplayCamCoords())
    
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x, _y)
end