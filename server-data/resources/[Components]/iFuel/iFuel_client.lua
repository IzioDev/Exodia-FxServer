local isInVeh = false
local lastVehiculeFuelLevel = nil
local multiplicateur = 1
local lastTime = 0

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

        if IsPedInAnyVehicle(GetPlayerPed(-1), true) and not(isInVeh) then
            isInVeh = true
            local veh = GetVehiclePedIsTryingToEnter(GetPlayerPed(-1))
            print('asked plate ' .. GetVehicleNumberPlateText(veh))
            TriggerServerEvent("iFuel:askForQuantity", GetVehicleNumberPlateText(veh))
        end

        if isInVeh and not(IsPedInAnyVehicle(GetPlayerPed(-1), true)) then
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

            if lastVehiculeFuelLevel <= 0 then
                lastVehiculeFuelLevel = 0
                SetVehicleUndriveable(veh, true)
                SetVehicleEngineOn(veh, 0, 0, 1)
            end
        end

    end
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