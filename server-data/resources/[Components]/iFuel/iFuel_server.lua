os.execute('clear')

local storedVeh = {}

RegisterServerEvent("iFuel:askForQuantity")
AddEventHandler("iFuel:askForQuantity", function(plate)
    local source = source
    TriggerEvent("car:getCarFromPlate", plate, function(car)
        if car ~= nil then
            TriggerClientEvent("iFuel:returnLevel", source, plate, car.getEtatVeh('fuel'))
        else
            if storedVeh[plate] then
                TriggerClientEvent("iFuel:returnLevel", source, plate, storedVeh[plate].fuel)
            else
                storedVeh[plate] = {plate = plate, fuel = GenerateFuelLevel()}
                TriggerClientEvent("iFuel:returnLevel", source, plate, storedVeh[plate].fuel)
            end
        end
    end)
end)

RegisterServerEvent("iFuel:refreshFuel")
AddEventHandler("iFuel:refreshFuel", function(plate, level)
    TriggerEvent("car:getCarFromPlate", plate, function(car)
        if car ~= nil then
            car.setEtatVeh('fuel', level)
        else
            storedVeh[plate].fuel = level
        end
    end)
end)

RegisterServerEvent("iFuel:askFuelLevelForParkedCar")
AddEventHandler("iFuel:askFuelLevelForParkedCar", function(plate, model, c1, c2, askedLevel, entityId, stationId)
    local source = source
    TriggerEvent("car:getCarFromPlate", plate, function(car)
        if car ~= nil then
            TriggerClientEvent("iFuel:returnLevelForMission", source, plate, car.getEtatVeh('fuel'))
        else
            if storedVeh[plate] then
                TriggerClientEvent("iFuel:returnLevelForMission", source, plate, storedVeh[plate].fuel)
            else
                storedVeh[plate] = {plate = plate, fuel = GenerateFuelLevel()}
                TriggerClientEvent("iFuel:returnLevelForMission", source, plate, model, c1, c2, storedVeh[plate].fuel, askedLevel, entityId, stationId)
            end
        end
    end)
end)

RegisterServerEvent("iFuel:goToPay")
AddEventHandler("iFuel:goToPay", function(plate, askedLevel, entityId, stationId)
    local source = source
    local fuelMoney = askedLevel * 1.96
    local source = source
    TriggerEvent("es:getPlayerFromId", source, function(user)
        user.notify("Et voilà, maintenant va payer: " .. fuelMoney .. "$ vers le magasin.", "success", "topCenter", true, 5000)
    end)
    TriggerClientEvent("iFuel:launchPayMission", source, fuelMoney, entityId, stationId)
end)

RegisterServerEvent("iFuel:heHavntPay")
AddEventHandler("iFuel:heHavntPay", function(money, plate, model, c1, c2)
    local source = source
    local infos = {}
    TriggerEvent("es:getPlayerFromId", source, function(user)
        user.notify("Après ton départ, tu entends le mec de la sécu gueuler. Reste.. ou pars!", "error", "topCenter", true, 5000)
        infos.coords = user.get('coords')
        infos.money = money
    end)

    local luck = math.random(1,100)

    if luck <= 10 then
        -- les flics ont juste le lieu de l'appel
    elseif luck <= 30 then
        -- les flics ont la couleur et le lieu de l'appel
        infos.c1 = c1
        infos.c2 = c2
    elseif luck <= 60 then
        -- les flics ont la couleur, le model et le lieu de l'appel
        infos.c1 = c1
        infos.c2 = c2
        infos.model = model
    elseif luck <= 85 then
        -- les flics ont toutes les données
        infos.c1 = c1
        infos.c2 = c2
        infos.model = model
        infos.plate = plate
    else
        -- il ne se passe rien
        infos = {}
    end

    CallCops(infos)
end)

function CallCops(infos)
    local message = ""
    if infos.plate then
        message = "Un délit de fuite à été effectué vers une station essence (noté sur ton GPS), voici les infos que vous avez: </br> <ul> 
        <li>Plaque du véhicule : " .. infos.plate .. "</li> 
        <li>Modèle du véhicule: " .. infos.model .. "</li>
        <li>Couleur primaire : " .. infos.c1 .. "</li>
        <li>Couleur secondaire : " .. infos.c2 .. "</li>"
    elseif infos.model then
        message = "Un délit de fuite à été effectué vers une station essence (noté sur ton GPS), voici les infos que vous avez: </br> <ul> 
        <li>Modèle du véhicule: " .. infos.model .. "</li>
        <li>Couleur primaire : " .. infos.c1 .. "</li>
        <li>Couleur secondaire : " .. infos.c2 .. "</li>"
    elseif infos.c1 then
        message = "Un délit de fuite à été effectué vers une station essence (noté sur ton GPS), voici les infos que vous avez: </br> <ul> 
        <li>Couleur primaire : " .. infos.c1 .. "</li>
        <li>Couleur secondaire : " .. infos.c2 .. "</li>"
    elseif infos.coords then
        message = "Un délit de fuite à été effectué vers une station essence (noté sur ton GPS), vous n'avez pas d'infos supplémentaire."
    else
        message = nil
    end

    if message ~= nil then
        TriggerEvent("es:getPlayers", function(Users)
            for k, v in pairs(Users) do
                if v.get('job') == "LSPD" or v.get('job') == "LSSD" then
                    user.notify(message, "error", "topCenter", true, 10000)
                    TriggerClientEvent("iFuel:copsMission", v.get('source'), "délit", infos.coords, "unused variable")
                end
            end
        end)
    end
end

RegisterServerEvent("iFuel:peyTheFuel")
AddEventHanlder("iFuel:peyTheFuel", function(money)
    local source = source
    local coords
    TriggerEvent("es:getPlayerFromId", source, function(user)
        if user.get('money') >= money then
            user.removeMoney(money)
            user.notify("Tu viens de payer par espèce", "success", "topCenter", true, 4000)
        else
            user.notify("Tu n'as pas assez d'argent sur toi, tu décides d'inserer ta carte bleue. Demande d'autorisation...", "error", "topCenter", true, 4000)
            coords = user.get('coords')
        end
    end)

    SetTimeout(4000, PayViaCb(money, source, coords))
end)

function PayViaCb(money, source, coords)
    TriggerEvent("es:getPlayerFromId", source, function(user)
        if user ~= nil then
            if user.get("bank") >= money then
                user.removeBank(money)
                user.notify("Payement accepté.", "success", "topCenter", true, 5000)
            else
                user.notify("Payement refusé, la dame de l'accueil vient d'appeler la police, ils sont en route.", "success", "topCenter", true, 5000)
                TriggerEvent("es:getPlayers", function(Users)
                    for k, v in pairs(Users) do
                        v.notify("Un payement de: " .. money .. " a été refusé à la station service, vas jetter un coup d'oeil.", "error", "topCenter", true, 10000)
                        TriggerClientEvent("iFuel:copsMission", v.get('source'), "payment", coords, user.get('displayName'))
                    end
                end)
            end
        else
            print("un utilisateur s'est déconnecté pendant qu'il devait payer son essence.")
        end
    end)
end

function GenerateFuelLevel()
    return math.random(27,100)
end