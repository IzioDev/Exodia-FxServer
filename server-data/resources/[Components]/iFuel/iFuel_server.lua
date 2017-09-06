os.execute('clear')

local storedVeh = {}

RegisterServerEvent("iFuel:askForQuantity")
AddEventHandler("iFuel:askForQuantity", function(plate)
    local source = source
    print(plate)
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
    print(plate.. " FUEL LEVEL : " .. level)
    TriggerEvent("car:getCarFromPlate", plate, function(car)
        if car ~= nil then
            car.setEtatVeh('fuel', level)
        else
            storedVeh[plate].fuel = level
        end
    end)
end)

function GenerateFuelLevel()
    return math.random(27,100)
end