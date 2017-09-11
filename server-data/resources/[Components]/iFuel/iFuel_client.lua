local isInVeh = false
local lastVehiculeFuelLevel = nil
local multiplicateur = 1
local lastTime = 0

local proked = false

local AllMissions = {}

local nowModel = nil
local nowPlate = nil
local nowColor1= nil
local nowColor2= nil

local GasStation = {
    {x = 0, y = 0, z = 0, id = 1}
}

local PumpStation = {
    {
        {}
    },
    
    {

    },
    
    {

    }
}

local PayStation = {
    {}
}

Citizen.CreateThread(function()
    while true do
        Wait(0)

        if lastTime == 0 and isInVeh then
            lastTime = GetGameTimer()
        end

        -- if GetGameTimer() - 60000 > lastTime and isInVeh then -- TODO: Dev pour refresh pas que a la sortie du veh
        --     lastTime = 0
        --     local plate = GetVehicleNumberPlateText(GetVehiclePedIsIn(GetPlayerPed(-1), 0))
        --     TriggerServerEvent("iFuel:refreshFuel", plate, lastVehiculeFuelLevel)
        -- end

        if IsPedInAnyVehicle(GetPlayerPed(-1), false) and not(isInVeh) then
            isInVeh = true
            local veh = GetVehiclePedIsIn(GetPlayerPed(-1), false)
            print('asked plate ' .. GetVehicleNumberPlateText(veh))
            TriggerServerEvent("iFuel:askForQuantity", GetVehicleNumberPlateText(veh))
        end

        if isInVeh and not(IsPedInAnyVehicle(GetPlayerPed(-1), false)) then
            local plate = GetVehicleNumberPlateText(GetVehiclePedIsIn(GetPlayerPed(-1), 1))
            TriggerServerEvent("iFuel:refreshFuel", plate, lastVehiculeFuelLevel)

            SendNUIMessage({
                action = "close"
            })

            isInVeh = false
            lastVehiculeFuelLevel = nil
        end

        if isInVeh then
            local veh = GetVehiclePedIsIn(GetPlayerPed(-1), false)
            if GetIsVehicleEngineRunning(veh) then
                local speed = math.abs(GetEntitySpeed(veh)) * 3.6
                if speed < 10 then
                    lastVehiculeFuelLevel = lastVehiculeFuelLevel - ( 0.000208375 )
                else
                    lastVehiculeFuelLevel = lastVehiculeFuelLevel - ( 0.001667 * (speed/80) * multiplicateur )
                end
            end

            if GetGameTimer() - 1000 > lastTime then
                SendNUIMessage({
                    action = "update",
                    level = lastVehiculeFuelLevel
                })
                lastTime = 0
            end

            if isInVeh and lastVehiculeFuelLevel ~= nil and lastVehiculeFuelLevel <= 0 then
                lastVehiculeFuelLevel = 0
                SetVehicleUndriveable(veh, true)
                SetVehicleEngineOn(veh, 0, 0, 1)
            end
        end

    end
end)

Citizen.CreateThread(function()
    while true do
        Wait(0)

        local isNearGasStation, id = IsNearGasStation()

        if isNearGasStation and not(proked) then
            DisplayHelpText("Garez votre voiture et venez près d'un réservoir.")

            local isNearPumpStation = IsNearPumpStation(id)

            if isNearPumpStation and not(proked) then
                while IsNearPumpStation(id) do
                    Wait(0)
                    DisplayHelpText("Appuyez sur ~INPUT_CONTEXT~ pour ouvrir le selecteur.")

                    if IsControlJustPressed(1, 38) then

                        SendNUIMessage({
                            action = "openSelector",
                            level = lastVehiculeFuelLevel,
                            stationId = id
                        })
                        proked = true

                    end

                end
            end

        end
    end
end)

RegisterNUICallback("choose", function(data)
    print("callback du choix")
    LaunchFilling(data.level, data.id)
end)

RegisterNUICallback("close", function(data)
    proked = false
end)

RegisterNetEvent("iFuel:returnLevel")
AddEventHandler("iFuel:returnLevel", function(plate, level)
    print(plate ..  " : " .. level)
    lastVehiculeFuelLevel = level
    SendNUIMessage({
        action = "open",
        level = level
    })
end)

function LaunchFilling(level, id)
    local sticked = false
    local embout = "prop_cs_fuel_nozle"
    local entity = nil

    RequestModel(embout)

    while not HasModelLoaded(embout) do
        Citizen.Wait(100)
    end

    local emboutEntity = CreateObject(embout, 1.0, 1.0, 1.0, 1, 1, 0)
    print("embout créer")

    local bone = GetPedBoneIndex(GetPlayerPed(-1), 28422)

    AttachEntityToEntity(emboutEntity, GetPlayerPed(-1), bone, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1, 1, 0, 0, 2, 1)
    print("embout attaché")

    while not(sticked) do
        Wait(0)
        -- nozzles_r
        DisplayHelpText("Placez vous devant votre réservoir de voiture et appuyez sur ~INPUT_CONTEXT~.")

        if IsControlJustPressed(1, 38) then
            print("appuyez")
            local inFrontOfPlayer = GetOffsetFromEntityInWorldCoords( GetPlayerPed(-1), 0.0, 1.5 , 0.0 )
            entity = GetEntityInDirection( playerPos, inFrontOfPlayer )

            if IsEntityAVehicle(entity) then
                print("l'entité est un véhicule")
                local bone = GetEntityBoneIndexByName(entity, "nozzles_r")
                local bonePos = GetWorldPositionOfEntityBone(entity, bone)
                local playerPos = GetEntityCoords(GetPlayerPed(-1), 1)

                if GetDistanceBetweenCoords(playerPos, bonePos, true) <= 0.7 then
                    print("accrohé")
                    AttachEntityToEntity(emboutEntity, entity, bone, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1, 1, 0, 0, 2, 1)
                    sticked = true
                else
                    TriggerEvent("pNotify:notifyFromServer", "Rapproche toi du réservoire!", "error", "topCenter", true, 5000)
                end

            end
        end

        if not(IsNearGasStation(id)) then
            print("on delete l'objet")
            DeleteObject(emboutEntity)
            break
        end
    end

    if sticked then
        TriggerEvent("pNotify:notifyFromServer", "Remplissage en cours...", "success", "topCenter", true, 9000)
        FreezeEntityPosition(GetPlayerPed(-1), true)
        SendNUIMessage({
            action = "PlaySound"
        })
        print("on joue le son est on freeze le joueur et on demande au serveur le level veh")
        local c1, c2 = GetVehicleColours(entity, 1, 1)
        print("veh color : " .. tostring(c1).. "  " .. tostring(c2))
        TriggerServerEvent("iFuel:askFuelLevelForParkedCar", GetVehicleNumberPlateText(entity), GetEntityModel(entity), c1, c2, level, entity, id)
    end
end

RegisterNetEvent("iFuel:returnLevelForMission")
AddEventHandler("iFuel:returnLevelForMission", function(plate, model, c1, c2, thisLevel, askedLevel, entityId, stationId)

    SendNUIMessage({
        action = "open",
        level = level
    })
    print("on ouvre l'ui avec le niveau que le veh a")
    while askedLevel + thisLevel > thisLevel do
        Wait(100)
        thisLevel = thisLevel + 0.1
        if thisLevel > askedLevel then
            thisLevel = askedLevel
        end
        SendNUIMessage({
            action = "update",
            level = thisLevel
        })
    end

    print("fin du remplissage, on ferme l'ui")

    SendNUIMessage({
        action = "close"
    })

    SendNUIMessage({
        action = "stopAndResetSound"
    })

    TriggerServerEvent("iFuel:refreshFuel", plate, thisLevel)

    FreezeEntityPosition(GetPlayerPed(-1), false)
    print("on défreeze")
    nowPlate = plate
    nowModel = model
    nowColor1 = c1
    nowColor2 = c2

    TriggerServerEvent("iFuel:goToPay", plate, askedLevel, entityId, stationId)
end)

RegisterNetEvent("iFuel:launchPayMission")
AddEventHandler("iFuel:launchPayMission", function(fuelMoney, entityId, stationId)
    print(' on lance la mission de pauyer ')
    local paid = false
    local proked = false
    while not(paid) do
        if not(IsCarNearGasStation(entityId, stationId)) then
            TriggerServerEvent("iFuel:heHavntPay", fuelMoney, nowPlate, nowModel, nowColor1, nowColor2)
            TriggerEvent("pNotify:notifyFromServer", "Ta voiture vient de quitter la station, tu vas avoir des ennuis...", "error", "topCenter", true, 5000)
            paid = true
            break
        end

        if not(IsNearGasStation(stationId)) then
            TriggerServerEvent("iFuel:heHavntPay", fuelMoney, nowPlate, nowModel, nowColor1, nowColor2)
            TriggerEvent("pNotify:notifyFromServer", "Tu viens de quitter la station, tu vas avoir des ennuis...", "error", "topCenter", true, 5000)
            paid = true
            break
        end

        if IsNearPayStation(stationId) then
            if not(proked) then
                DisplayHelpText("Appuies sur ~INPUT_CONTEXT~ pour payer l'essence " .. fuelMoney .. "$")
                if IsControlJustPressed(1, 38) then
                    print("on demande au serveur de payer")
                    TriggerServerEvent("iFuel:peyTheFuel", fuelMoney)
                    paid = true
                end
            end
        end
    end
end)

RegisterNetEvent("iFuel:copsMission")
AddEventHandler("iFuel:copsMission", function(missionType, coords, nameOrUnused)
    print("on insert la table dans la liste des missions courantes")
    table.insert(AllMissions, {
        missionType == missionType,
        coords == coords,
        nameOrUnused = nameOrUnused
    })
end)

Citizen.CreateThread(function()
    while true do
        Wait(100)
        for i, v in ipairs(AllMissions) do
            if not(v.inTreatment) then
                CreateBlip(v, k)
                v.inTreatment = true
                print("on créer le blip")
            end

            if GetDistanceBetweenCoords(v.coords.x, v.coords.y, v.coords.z, x, y, z, true) <= 5.0 then
                SetBlipAsMissionCreatorBlip(v.blipId, false)
                Citizen.InvokeNative(0x86A652570E5F25DD, Citizen.PointerValueIntInitialized(v.blipId))
                table.remove(AllMissions, i) 
                -- si ça fonctionne pas, il faudra créer un tableau auquel on ajoute les elements à remove (les index)
            end

        end
    end
end)

function CreateBlip(info, index)
    local blip = AddBlipForCoord(tonumber(info.coords.x), tonumber(info.coords.y), tonumber(info.coords.z))
    SetBlipSprite(blip, 1)
    SetBlipColour(blip, 3)

    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(info.missionType)
    EndTextCommandSetBlipName(blip)

    SetBlipAsShortRange(blip,true)
    SetBlipAsMissionCreatorBlip(blip,true)

    SetBlipRoute(blip, true)
    SetBlipRouteColour(blip, 38)

    local nowTime = GetGameTimer()

    AllMissions[index].nowTime = nowTime
    AllMissions[index].blipId = blip
end

function IsNearPayStation(id)
    local plyPos = GetEntityCoords(GetPlayerPed(-1), true)
    if GetDistanceBetweenCoords(plyPos, PayStation[id].x, PayStation[id].y, PayStation[id].z, 1)
end

function IsCarNearGasStation(id, stationId)
    local carPos = GetEntityCoords(id, false)
    if GetDistanceBetweenCoords(carPos, GasStation[stationId].x, GasStation[stationId].y, GasStation[stationId].z, true) <= 20.0 then
        return true
    else
        return false
    end
end

function GetEntityInDirection( coordFrom, coordTo )
    local rayHandle = CastRayPointToPoint( coordFrom.x, coordFrom.y, coordFrom.z, coordTo.x, coordTo.y, coordTo.z, 10, GetPlayerPed( -1 ), 0 )
    local _, _, _, _, vehicle = GetRaycastResult( rayHandle )
    return vehicle
end

function IsNearGasStation()

    if IsPedInAnyVehicle(GetPlayerPed(-1), false) then
        return false
    end

    local plyCoords = GetEntityCoords(GetPlayerPed(-1), true)
    for i=1, #GasStation do
        if GetDistanceBetweenCoords(plyCoords, GasStation[i].x, GasStation[i].y, GasStation[i].z, true) <= 20.0 then
            return true, GasStation[i].id
        end
    end
    return false, 0
end

function IsNearPumpStation(id)
    local plyCoords = GetEntityCoords(GetPlayerPed(-1), true)
    for i = 1, #PumpStation[id] do
        local this = PumpStation[id][i]
        if GetDistanceBetweenCoords(plyCoords, this.x, this.y, this.z, true) <= 1.5 then
            return true
        end
    end
    return false
end

-- Utils functions:

function DisplayHelpText(str)
    SetTextComponentFormat("STRING")
    AddTextComponentString(str)
    DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end