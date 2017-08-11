local call = {
    ["LSSD"] = {},
    ["LSPD"] = {},
    ["médecin"] = {},
    ["taxi"] = {},
    ["mécanicien"] = {}
}

local blipList = {}

---- Services Police:
-- Partie Thread:
Citizen.CreateThread(function()
    while true do
        Wait(0)
        for k,v in pairs(call) do
            for j = 1, #v do
                local this = v[j]
                print(json.encode(v[j]))
                if IsControlJustPressed(1, 166) then
                    -- accepted
                    TriggerServerEvent("iServie:acceptedCall", this)
                    table.remove(v, j)
                elseif IsControlJustPressed(1, 167) then
                    -- refused
                    TriggerServerEvent("iServie:refusedCall", this)
                    table.remove(v, j)
                end
            end
        end
    end
end)

-- Partie Récupération depuis le phone:

AddEventHandler('police:callPolice', function(array)
    this = array.type
    TriggerServerEvent("iService:callCops", this)
end)

AddEventHandler('police:callPoliceCustom', function() -- autre
    local editing = true
    DisplayOnscreenKeyboard(true, "FMMC_KEY_TIP8", "", "", "zoneName categorie", "", "", 120)
    while editing do
        Wait(0)
        if UpdateOnscreenKeyboard() == 2 then 
            editing = nil
        end
        if UpdateOnscreenKeyboard() == 1 then
            editing = false
            resultat = GetOnscreenKeyboardResult()
        end
    end
    if editing ~= nil then
        TriggerServerEvent("iService:callCops", resultat)
    end
end)

AddEventHandler('police:cancelCall', function()
    TriggerServerEvent("iService:callCops", "cancel")
end)

---- Service Médecin:
AddEventHandler("ambulancier:callAmbulancier", function(array)
    this = array.type
    TriggerServerEvent("iService:callMedic", this)
end)

AddEventHandler("ambulancier:cancelCall", function() -- annuler l'appel
    TriggerServerEvent("iService:callMedic", "cancel")
end)

---- Service Taxi:
AddEventHandler("taxi:callService", function(array)
    this = array.type
    TriggerServerEvent("iService:callTaxi", this)
end)

AddEventHandler('taxi:cancelCall', function() -- annuler l'appel
    TriggerServerEvent("iService:callTaxi", "cancel")
end)

---- Service Mécano:
AddEventHandler('mecano:callMecano', function(array)
    this = array.type
    TriggerServerEvent("iService:callMecano", this)
end)

AddEventHandler('mecano:cancelCall', function() -- annuler l'appel
    TriggerServerEvent("iService:callMecano", "cancel")
end)


-- Partie listener for Server:
RegisterNetEvent("iService:sendToLSSD") -- send
AddEventHandler("iService:sendToLSSD", function(cT, fS)
    table.insert(call["LSSD"], {callType = cT, fromSource = fS})
end)

RegisterNetEvent("iService:cancelLSSD") -- cancel 
AddEventHandler("iService:cancelLSSD", function(fromSource)
    for k,v in pairs(call) do
        for j = 1, #v do
            if v[j].fromSource == fromSource then
                table.remove(v, j)
            end
        end
    end
end)

RegisterNetEvent("iService:timeOutLSSD") -- timeOut 
AddEventHandler("iService:timeOutLSSD", function(fromSource)
    for k,v in pairs(call) do
        for j = 1, #v do
            if v[j].fromSource == fromSource then
                tabme.remove(v, j)
            end
        end
    end
end)

RegisterNetEvent("iService:takenLSSD") -- taken
AddEventHandler("iService:takenLSSD", function(fromSource)
    for k,v in pairs(call) do
        for j = 1, #v do
            if v[j].fromSource == fromSource then
                tabme.remove(v, j)
            end
        end
    end
end)

RegisterNetEvent("iService:acceptedLSSD")
AddEventHandler("iService:acceptedLSSD", function(coords)
    AddBlipToListWithCoords(coords)
end)

RegisterNetEvent("iService:sendToLSPD") -- send
AddEventHandler("iService:sendToLSPD", function(cT, fS)
    print("received")
    table.insert(call["LSPD"], {callType = cT, fromSource = fS})
end)

RegisterNetEvent("iService:cancelLSPD") -- cancel
AddEventHandler("iService:cancelLSPD", function(fromSource)
    for k,v in pairs(call) do
        for j = 1, #v do
            if v[j].fromSource == fromSource then
                table.remove(v, j)
            end
        end
    end
end)

RegisterNetEvent("iService:timeOutLSPD") -- timeOut
AddEventHandler("iService:timeOutLSPD", function(fromSource)
    for k,v in pairs(call) do
        for j = 1, #v do
            if v[j].fromSource == fromSource then
                table.remove(v, j)
            end
        end
    end
end)

RegisterNetEvent("iService:takenLSPD") -- taken 
AddEventHandler("iService:takenLSPD", function(fromSource)
    for k,v in pairs(call) do
        for j = 1, #v do
            if v[j].fromSource == fromSource then
                table.remove(v, j)
            end
        end
    end
end)

RegisterNetEvent("iService:acceptedLSPD")
AddEventHandler("iService:acceptedLSPD", function(coords)
    AddBlipToListWithCoords(coords)
end)

-- Partie send to Server:

-- Functions:
Citizen.CreateThread(function()
    while true do
        Wait(0)
        local x,y,z = table.unpack(GetEntityCoords(GetPlayerPed(-1), true))
        for i = 1, #blipList do
            if GetGameTimer() > nowTime + 1200000 then -- 20 minutes
                RemoveBlipFromListAndRefresh(i)
            else
                if GetDistanceBetweenCoords(x, y, z, blipList[i].x, blipList[i].y, blipList[i].z, true) <= 5 then
                    SetBlipAsMissionCreatorBlip(blip, false)
                    Citizen.InvokeNative(0x86A652570E5F25DD, Citizen.PointerValueIntInitialized(blip))
                    return
                end
            end
        end
    end
end)

function AddBlipToListWithCoords(coords)
    local blip = AddBlipForCoord(tonumber(coords.x), tonumber(coords.y), tonumber(coords.z))
    SetBlipSprite(blip, 1)
    SetBlipColour(blip, 4)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Appel")
    EndTextCommandSetBlipName(blip)
    SetBlipAsShortRange(blip,true)
    SetBlipAsMissionCreatorBlip(blip,true)
    SetBlipRoute(blip, true)
    SetBlipRouteColour(blip, 38)
    local nowTime = GetGameTimer()
    table.insert(blipList, {id = blip, x = coords.x, y = coords.y, z = coords.z, time = nowTime})
end

function RemoveBlipFromListAndRefresh(index)
    SetBlipAsMissionCreatorBlip(blipList[i], false)
    Citizen.InvokeNative(0x86A652570E5F25DD, Citizen.PointerValueIntInitialized(blipList[i]))
end