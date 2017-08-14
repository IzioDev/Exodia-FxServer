allVeh = {}
local maxVehCapacity = 15
local saveTime = 60000

RegisterServerEvent('CheckMoneyForVeh')
RegisterServerEvent('BuyForVeh')
RegisterServerEvent('es:firstSpawn')
RegisterServerEvent('baseevents:leftVehicle')
RegisterServerEvent('vehshop:checkveh')
RegisterServerEvent('vehshop:retrieve')

AddEventHandler('onMySQLReady', function ()
  local result = MySQL.Sync.fetchAll("SELECT * FROM user_vehicle", {})
  for i = 1, #result do
    if not(result[i].inventory) or result[i].inventory == nil then
      result[i].inventory = json.encode({})
    end
    allVeh[result[i].vehicle_plate] = CreateCar(result[i])
  end
end)

AddEventHandler("onVehRestart", function()
  local result = MySQL.Sync.fetchAll("SELECT * FROM user_vehicle", {})
  for i = 1, #result do
    if not(result[i].inventory) or result[i].inventory == nil then
      result[i].inventory = json.encode({})
    end
    allVeh[result[i].vehicle_plate] = CreateCar(result[i])
  end

  SaveCarDatas()

  SetTimeout(1500, function()
    TriggerEvent("es:getPlayers", function(Users)
      for k,v in pairs(Users) do
        TriggerClientEvent("veh:BlibAfterRestart", tonumber(v.get('source')))
      end
    end)
  end)
end)

AddEventHandler("car:getCarFromPlate", function(plate, car) 
  if allVeh[plate] ~= nil then
    car(allVeh[plate])
  else
    car(nil)
  end
end)

AddEventHandler("car:getAllCars", function(car)
  if allVeh then
    car(allVeh)
  else
    car(nil)
  end
end)

AddEventHandler("car:getAllPlayerCars", function(player, car)
  local carsResult = {}
  for k,v in pairs(allVeh) do
    print(v.get("owner"))
    print(player)
    if v.get("owner") == player then
      table.insert(carsResult, v)
    end
  end
  if #carsResult ~= 0 then
    car(carsResult)
  else
    car(nil)
  end
end)

AddEventHandler('baseevents:leftVehicle', function(data)
    TriggerClientEvent("vehshop:leftvehicle", source)
end)

AddEventHandler('es:playerLoaded', function(source)
  TriggerClientEvent("veh:test", source)
end)

AddEventHandler('vehshop:checkveh', function(veh, plate, LX, LY, LZ, LH)
  TriggerEvent('es:getPlayerFromId', source, function(user)
    local player = user.get('identifier')
    local LastPos = {
    LX,
    LY,
    LZ,
    LH
}
    local LastPosEncoded = json.encode(LastPos)
    IsPlayerGotThisVeh(player, plate, LastPosEncoded)
  end)
end)

function PrintArrayUnknowIndex(table)
    for i=1, #table do
        print(tostring(i).. " :")
        for k,v in pairs(table[i]) do print(k,v) end
    end
end

-- AddEventHandler('vehshop:retrieve', function()
--   TriggerEvent('es:getPlayerFromId', source, function(user)
--     player = user.get('identifier')
--   end)
--   local src = source
--   local vehicle
--   local plate
--   local state
--   local primarycolor
--   local secondarycolor
--   local pearlescentcolor
--   local wheelcolor
--   local lastpos
--   local result = MySQL.Sync.fetchAll("SELECT * FROM user_vehicle WHERE identifier = @username", {
--       ['@username'] = player
--   })

--   if (result) then -- Spawn Veh on connection
--       for i=1, #result do
--         vehicle = result[i].vehicle_model
--         plate = result[i].vehicle_plate
--         state = result[i].vehicle_state
--         primarycolor = result[i].vehicle_colorprimary
--         secondarycolor = result[i].vehicle_colorsecondary
--         pearlescentcolor = result[i].vehicle_pearlescentcolor
--         wheelcolor = result[i].vehicle_wheelcolor
--         lastpos = result[i].lastpos
--         TriggerClientEvent('veh:spawn', src, vehicle, plate, state, primarycolor, secondarycolor, pearlescentcolor, wheelcolor, lastpos)
--         allVeh[plate].set('state', "out")
--       end
--   end
-- end)

function IsPlayerGotThisVeh(player, vehPlate, LastPosEncoded) -- vehplate string
  if allVeh[vehPlate] then
    if allVeh[vehPlate].get("owner") == player then
      allVeh[vehPlate].set("lastpos", json.decode(LastPosEncoded))
      return true
    else
      return false
    end
  else
    return false
  end
end

AddEventHandler('CheckMoneyForVeh', function(name, vehicle, price)
  TriggerEvent('es:getPlayerFromId', source, function(user)
    local player = user.get('identifier')
    local vehicle = vehicle
    local name = name
    local price = math.abs(tonumber(price))
    local source = tonumber(source)

    local result = MySQL.Sync.fetchAll("SELECT * FROM user_vehicle WHERE identifier = @username AND id = @id", {['@username'] = player, ['@id'] = user.get('id')})

    if (result) then
      count = 0
      for _ in pairs(result) do
        count = count + 1
      end
      if count >= maxVehCapacity then
          TriggerClientEvent("veh_s:notif", source, "Ton garage est ~r~Plein!~w~")
      else
        if tonumber(user.get('money')) >= price then
          user.removeMoney((price))
          TriggerClientEvent('FinishMoneyCheckForVeh', user.get('source'), name, vehicle, price)
          TriggerClientEvent("veh_s:notif", user.get('source'), "Vehicule ~r~Livré!~w~")
        else
          TriggerClientEvent("veh_s:notif", user.get('source'), "Tu n'as pas assez d'argent")
        end
      end
    else
      if tonumber(user.get('money')) >= price then
        user.removeMoney((price))
        TriggerClientEvent('FinishMoneyCheckForVeh', user.get('source'), name, vehicle, price)
        TriggerClientEvent("veh_s:notif", user.get('source'), "Vehicule ~r~Livré!~w~")
      else
        TriggerClientEvent("veh_s:notif", user.get('source'), "Tu n'as pas assez d'argent")
      end
    end
  end)
end)

AddEventHandler('BuyForVeh', function(name, vehicle, price, plate, primarycolor, secondarycolor, pearlescentcolor, wheelcolor)
  TriggerEvent('es:getPlayerFromId', source, function(user)
    local player = user.get('identifier')
    print("Its ok")

    MySQL.Sync.execute("INSERT INTO user_vehicle (`identifier`, `vehicle_name`, `vehicle_model`, `vehicle_price`, `vehicle_plate`, `vehicle_state`, `vehicle_colorprimary`, `vehicle_colorsecondary`, `vehicle_pearlescentcolor`, `vehicle_wheelcolor`, `lastpos`,`inventory`, `inventoryWeight`) VALUES (@username, @name, @vehicle, @price, @plate, @state, @primarycolor, @secondarycolor, @pearlescentcolor, @wheelcolor, @lastpos, @inventory, @inventoryWeight)",{
      ['@username'] = player,
      ['@name'] = name,
      ['@vehicle'] = vehicle,
      ['@price'] = price,
      ['@plate'] = plate,
      ['@state'] = "out",
      ['@primarycolor'] = primarycolor,
      ['@secondarycolor'] = secondarycolor,
      ['@pearlescentcolor'] = pearlescentcolor,
      ['@wheelcolor'] = wheelcolor,
      ['@lastpos'] = json.encode({0,0,0,0}),
      ['@inventory'] = json.encode({}),
      ['@inventoryWeight'] = "300.0"
    }) -- Vous noterez qu'on est pas obligé d'avoir une fonction après ça, on peut en avoir un (un callback) mais osef ici

    local carInfos = {
      vehicle_model = vehicle,
      vehicle_plate = plate,
      vehicle_state = "out",
      vehicle_colorprimary = primarycolor,
      vehicle_colorsecondary = secondarycolor,
      vehicle_pearlescentcolor = pearlescentcolor,
      vehicle_wheelcolor = wheelcolor,
      lastpos = json.encode({0,0,0,0}),
      inventory = json.encode({}),
      inventoryWeight = "300.0"
    }

    allVeh[plate] = CreateCar(carInfos)
  end)
end)

AddEventHandler("tShop:registerNewVeh", function(carPlate, owner, inventoryWeight)
  local carInfos = {
    vehicle_plate = plate,
    vehicle_state = "out",
    lastpos = json.encode({0,0,0,0}),
    inventory = json.encode({}),
    owner = owner,
    inventoryWeight = inventoryWeight
  }
  allVeh[carPlate] = CreateJobCar(carInfos)
end)

AddEventHandler("tShop:removeVeh", function(carPlate, owner)
  if allVeh[carPlate] then
    table.remove(allVeh, carPlate)
  end
end)

---Save Datas
function SaveCarDatas()
  SetTimeout(saveTime, function()
    for k, v in pairs(allVeh) do
      print("Vehicle changed ? ".. tostring(v.get('haveChanged')))
      if v.get('haveChanged') then
        if not(v.get('vehJob')) then
          print("query launched")
          MySQL.Sync.execute("UPDATE user_vehicle SET `identifier`=@identifier, `vehicle_wheelcolor`=@vehicle_wheelcolor, `vehicle_pearlescentcolor` = @vehicle_pearlescentcolor, `vehicle_colorsecondary`=@vehicle_colorsecondary, `vehicle_colorprimary`=@vehicle_colorprimary, `vehicle_state`=@vehicle_state,`lastpos`=@lastpos, `inventory`=@inventory WHERE vehicle_plate = @vehicle_plate",{
            ['@identifier'] = v.get('owner'),
            ['@vehicle_wheelcolor'] = v.get('wheelscolor'),
            ['@vehicle_pearlescentcolor'] = v.get('plctColor'),
            ['@vehicle_colorsecondary'] = v.get('secondaryColor'),
            ['@vehicle_colorprimary'] = v.get('primaryColor'),
            ['@vehicle_state'] = v.get('state'),
            ['@lastpos'] = json.encode(v.get('lastpos')),
            ['@inventory'] = json.encode(v.get('inventory')),
            ['@vehicle_plate'] = v.get('plate')
            })
          v.set("haveChanged", false)
        end
      end
    end
    SaveCarDatas()
  end)
end

-- AddEventHandler('es:firstSpawn', function(source) -- Donner une première voiture ? De toutes manière il faut changer le code
--     TriggerEvent('es:getPlayerFromId', source, function(user)
--         local player = user.get('identifier')
--         local name = "Faggio"
--         local vehicle = "faggio2"
--         local price = 2000
--         local plate = math.random(10000000, 99999999)
--         local state = "in"
--         local primarycolor = 0
--         local secondarycolor = 0
--         local pearlescentcolor = 3
--         local wheelcolor = 156
--         MySQL.Async.execute("INSERT INTO user_vehicle (`identifier`, `vehicle_name`, `vehicle_model`, `vehicle_price`, `vehicle_plate`, `vehicle_state`, `vehicle_colorprimary`, `vehicle_colorsecondary`, `vehicle_pearlescentcolor`, `vehicle_wheelcolor`) VALUES (@username, @name, @vehicle, @price, @plate, @state, @primarycolor, @secondarycolor, @pearlescentcolor, @wheelcolor)", {
--           ['@username'] = player,
--           ['@name'] = name,
--           ['@vehicle'] = vehicle,
--           ['@price'] = price,
--           ['@plate'] = plate,
--           ['@state'] = state,
--           ['@primarycolor'] = primarycolor,
--           ['@secondarycolor'] = secondarycolor,
--           ['@pearlescentcolor'] = pearlescentcolor,
--           ['@wheelcolor'] = wheelcolor
--           }, function()

--         end)
--     end)
-- end)

-- Partie iGarage:
RegisterServerEvent("iGarage:buyCheckForMoney")
AddEventHandler("iGarage:buyCheckForMoney", function(price)
  local source = source
  TriggerEvent("es:getPlayerFromId", source, function(user)
    if user.get('bank') >= price then
      if user.getOtherInGameInfos("garage") then
        user.notify("Tu as déjà un garage mon gourmand!", "error", "topCenter", true, 5000)
      else
        user.notify("Tu viens d'acheter un garage, tu peux y mettre au maximum 5 voitures, mais que des véhicules achetés! Pas de buisness illégal ici. </br><strong>Cordialement, l'agence immobilière.</strong>", "success", "topCenter", true, 10000)
        user.setOtherInGameInfos("garage", true)
        user.removeBank(price)
      end
    else
      user.notify("Tu n'as pas "..price.. "$ en banque.", "error", "topCenter", true, 5000)
    end
  end)
end)

RegisterServerEvent("sellCheckForGotting")
AddEventHandler("sellCheckForGotting", function(sellingPrice)
  local source = source
  TriggerEvent("es:getPlayerFromId", source, function(user)
    if user.getOtherInGameInfos("garage") then
      user.notify("Tu viens de vendre ton garage pour "..sellingPrice.."$. Tu ne le trouvait pas bien?", "error", "topCenter", true, 5000)
      user.addBank(sellingPrice)
      TriggerClientEvent("banking:updateBalance", source, user.get('bank'))
      user.setOtherInGameInfos("garage", false)
    else
      user.notify("Je ne trouve pas de garage à ton nom dans le registre.", "error", "topCenter", true, 5000)
    end
  end)
end)

RegisterServerEvent("iGarage:playerGotAGarage")
AddEventHandler("iGarage:playerGotAGarage", function(result, plate)
  local source = source
  TriggerEvent("es:getPlayerFromId", source, function(user)
    if not(user.getSessionVar("garageEntré")) or (os.time() - user.getSessionVar("garageEntré") > 5) then
      user.setSessionVar("garageEntré", os.time())
      if user.getOtherInGameInfos('garage') == true then
        if plate ~= nil then
          if allVeh[plate] then
            if allVeh[plate].get('vehJob') then
              user.notify("Tu ne va quand même pas rentrer le véhicule de ton patron ici ?.", "error", "topCenter", true, 5000)
            else
              allVeh[plate].set('state', 'in')
              local cars = GetAllVehicleFromAPlayerWithInState(user.get('identifier'))
              user.notify("Tu viens de rentrer un véhicule dans ton garage.", "success", "topCenter", true, 5000)
              TriggerClientEvent("iGarage:returnPlayerGotAGarage", source, user.getOtherInGameInfos('garage'), result, cars)
            end
          else
            if not(user.getSessionVar("notifiedFromConcierge")) or (os.time() - user.getSessionVar("notifiedFromConcierge") > 5) then
              user.notify("Et moi j'veux pas d'enmmerdes avec les keuffs, dégage de là, les véhicules volés c'est pas ici!</br> <strong>Le concierge</strong>", "error", "topCenter", true, 5000)
              user.setSessionVar("notifiedFromConcierge", os.time())
            end
          end
        else
          local cars = GetAllVehicleFromAPlayerWithInState(user.get('identifier'))
          TriggerClientEvent("iGarage:returnPlayerGotAGarage", source, user.getOtherInGameInfos('garage'), result, cars)
        end
      else
        if not(user.getSessionVar("notifiedFromSecretary")) or (os.time() - user.getSessionVar("notifiedFromSecretary") > 5) then
          user.notify("Uhm.. Mais tu n'as pas de garage! D'ailleurs je t'invite à regarder nos magnifiques offres promotionnelles mon choux. </br> <strong>La jolie secrétaire. ♥</strong>", "error", "topCenter", true, 5000)
          user.setSessionVar("notifiedFromSecretary", os.time())
        end
      end
    end
  end)
end)

RegisterServerEvent("iGarage:leaveGarageWithCar")
AddEventHandler("iGarage:leaveGarageWithCar", function(result, plate)
  local source = source
  TriggerEvent("es:getPlayerFromId", source, function(user)
    if not(user.getSessionVar("garageSortie")) or (os.time() - user.getSessionVar("garageSortie") > 5) then
      user.setSessionVar("garageSortie", os.time())
      if allVeh[plate] then
        allVeh[plate].set('state', 'out')
        user.notify("Tu viens de sortir un véhicule.", "success", "topCenter", true, 5000)
        local car = {
          model = allVeh[plate].get('model'),
          plate = allVeh[plate].get('plate'),
          colorprimary = allVeh[plate].get("colorprimary"),
          colorsecondary = allVeh[plate].get("colorsecondary"),
          pearlescentcolor = allVeh[plate].get("pearlescentcolor"),
          wheelcolor = allVeh[plate].get("wheelcolor")
        }
        TriggerClientEvent("iGarage:returnLeaveGarageWithCar", source, result, car)
      end
    end
  end)
end)

function GetAllVehicleFromAPlayerWithInState(identifier)
  local toBeReturned = {}
  TriggerEvent("car:getAllPlayerCars", identifier, function(Cars)
    for k,v in pairs(Cars) do
      if v.get('state') == "in" then
        table.insert(toBeReturned, {
            model = v.get('model'),
            plate = v.get('plate'),
            colorprimary = v.get("colorprimary"),
            colorsecondary = v.get("colorsecondary"),
            pearlescentcolor = v.get("pearlescentcolor"),
            wheelcolor = v.get("wheelcolor")
          })
      end
    end
  end)
  return toBeReturned
end

TriggerEvent('es:addGroupCommand', 'izio', "mod", function(source, args, user)
  local source = source
  if #args == 3 then
    TriggerClientEvent("izio:spawnCar", source, args[2], args[3])
  end
end, function(source, args, user)

end)

