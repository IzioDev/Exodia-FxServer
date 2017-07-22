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
  SetTimeout(500, function()
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
  for i,v in ipairs(allVeh) do
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

AddEventHandler('vehshop:retrieve', function()
  TriggerEvent('es:getPlayerFromId', source, function(user)
    player = user.get('identifier')
  end)
  local src = source
  local vehicle
  local plate
  local state
  local primarycolor
  local secondarycolor
  local pearlescentcolor
  local wheelcolor
  local lastpos
  local result = MySQL.Sync.fetchAll("SELECT * FROM user_vehicle WHERE identifier = @username", {
      ['@username'] = player
  })

  if (result) then -- Spawn Veh on connection
      for i=1, #result do
        vehicle = result[i].vehicle_model
        plate = result[i].vehicle_plate
        state = result[i].vehicle_state
        primarycolor = result[i].vehicle_colorprimary
        secondarycolor = result[i].vehicle_colorsecondary
        pearlescentcolor = result[i].vehicle_pearlescentcolor
        wheelcolor = result[i].vehicle_wheelcolor
        lastpos = result[i].lastpos
        TriggerClientEvent('veh:spawn', src, vehicle, plate, state, primarycolor, secondarycolor, pearlescentcolor, wheelcolor, lastpos)
        allVeh[plate].set('state', "out")
      end
  end
end)

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
      print("else")
      if tonumber(user.get('money')) >= price then
        user.removeMoney((price))
        print("Triggered")
        TriggerClientEvent('FinishMoneyCheckForVeh', user.get('source'), name, vehicle, price)
        TriggerClientEvent("veh_s:notif", user.get('source'), "Vehicule ~r~Livré!~w~")
      else
        print("Arf...")
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

---Save Datas
function SaveCarDatas()
  SetTimeout(saveTime, function()
    for k, v in pairs(allVeh) do
      if v.get('haveChanged') then
        MySQL.Async.execute("UPDATE user_vehicle SET `identifier`=@identifier, `vehicle_wheelcolor`=@vehicle_wheelcolor, `vehicle_pearlescentcolor` = @vehicle_pearlescentcolor, `vehicle_colorsecondary`=@vehicle_colorsecondary, `vehicle_colorprimary`=@vehicle_colorprimary, `vehicle_state`=@vehicle_state,`lastpos`=@lastpos, `inventory`=@inventory WHERE vehicle_plate = @vehicle_plate",{
          ['@identifier'] = v.get('identifier'),
          ['@vehicle_wheelcolor'] = json.encode(v.get('vehicle_wheelcolor')),
          ['@vehicle_pearlescentcolor'] = v.get('vehicle_pearlescentcolor'),
          ['@vehicle_colorsecondary'] = v.get('vehicle_colorsecondary'),
          ['@vehicle_colorprimary'] = v.get('vehicle_colorprimary'),
          ['@vehicle_state'] = v.get('vehicle_state'),
          ['@identifier'] = v.get('identifier'),
          ['@lastpos'] = json.encode(v.get('lastpos')),
          ['@inventory'] = json.encode(v.get('inventory')),
          ['@vehicle_plate'] = v.get('vehicle_plate')
          })
        v.set("haveChanged", false)
      end
    end
    SaveCarDatas()
  end)
end
SaveCarDatas()

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