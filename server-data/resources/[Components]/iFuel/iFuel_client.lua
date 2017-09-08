local isInVeh = false
local lastVehiculeFuelLevel = nil
local multiplicateur = 1
local lastTime = 0

local proked = false

local GasStation = {
    {x = 0, y = 0, z = 0, id = 1}
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
                            action = "openSelector"
                        })
                        proked = true

                    end

                end
            end

        end
    end
end)

RegisterNUICallback("choose", function(data)
    LaunchFilling(data.level)
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

function LaunchFilling(level)
    local sticked = false
    local embout = "prop_cs_fuel_nozle"
    local entity = nil

    RequestModel(embout)

    while not HasModelLoaded(embout) do
        Citizen.Wait(100)
    end

    local emboutEntity = CreateObject(embout, 1.0, 1.0, 1.0, 1, 1, 0)

    local bone = GetPedBoneIndex(GetPlayerPed(-1), 28422)

    AttachEntityToEntity(emboutEntity, GetPlayerPed(-1), bone, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1, 1, 0, 0, 2, 1)

    while not(sticked) do
        Wait(0)
        -- nozzles_r
        DisplayHelpText("Placez vous devant votre réservoir de voiture et appuyez sur ~INPUT_CONTEXT~.")

        if IsControlJustPressed(1, 38) then

            local inFrontOfPlayer = GetOffsetFromEntityInWorldCoords( GetPlayerPed(-1), 0.0, 1.5 , 0.0 )
            entity = GetEntityInDirection( playerPos, inFrontOfPlayer )

            if IsEntityAVehicle(entity) then
                local bone = GetEntityBoneIndexByName(entity, "nozzles_r")
                local bonePos = GetWorldPositionOfEntityBone(entity, bone)
                local playerPos = GetEntityCoords(GetPlayerPed(-1), 1)

                if GetDistanceBetweenCoords(playerPos, bonePos, true) <= 0.7 then
                    AttachEntityToEntity(emboutEntity, entity, bone, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1, 1, 0, 0, 2, 1)
                    sticked = true
                else
                    TriggerEvent("pNotify:notifyFromServer", "Rapproche toi du réservoire!", "error", "topCenter", true, 5000)
                end

            end
        end

        if not(IsNearGasStation) then
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
        -- while level > nowLevel do
        TriggerServerEvent("iFuel:askFuelLevelForParkedCar", GetVehicleNumberPlateText(entity))
        -- end
        -- demander au serveur le niveau, le recevoir en CB, attendre que ça se remplisse, puis on arrete de jouer le son et on le reset
        -- actualiser le GUI en temps réel puis le close
        -- faire payer le joueur
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
        if GetDistanceBetweenCoords(plyCoords, GasStation[i].x, GasStation[i].y, GasStation[i].z, true) <= 15.0 then
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