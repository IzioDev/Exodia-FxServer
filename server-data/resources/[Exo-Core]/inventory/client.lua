RegisterNetEvent("returnIdentifier")
RegisterNetEvent("inventory:result")
RegisterNetEvent("inventory:change")
RegisterNetEvent("inventory:getData")


AddEventHandler("returnIdentifier", function(clientsrc, identifier)
  idList[clientsrc] = identifier
end)


-- Citizen.CreateThread(function()
--   while true do
--     Wait(1)
--     print("spamming")
--
--   end
--
-- end)


local EI = exports.interface  -- moteur graphique :kappah: (fully deprecied)
local inventoryList = {}
local ItemData = {}
local openInventoryID = nil
local steamid = nil
AddEventHandler("inventory:getData", function(data)
  itemData = data
end)


AddEventHandler("inventory:change", function(data)

  if steamid == nil then -- ok
    steamid = data.id
  end
--
  print("CELA NE PROQUE PAS TOUT LE TEMPS")
  inventoryList[data.id] = data
  if openInventoryID == data.id then
    ClearMenu()
    while inventoryMenu() == false do
      Wait(0)
      ClearMenu()
      inventoryMenu()
    end
  end
--
end)

function inventoryMenu()
    ClearMenu()
    MenuTitle = openInventoryID
    for ind, value in pairs(inventoryList[openInventoryID].items) do
        if (value.quantity > 0) then
          if value.name == nil then
            return false
          end
          if value.name == "???" then
            value.name = "404 > ID: " .. value.id
          end
            Menu.addButton(tostring(value.name) .. " : " .. tostring(value.quantity), "ItemMenu", {value.id})
        end
    end
    return true
end

function ItemMenu(val)
    local itemId = val[1]
    ClearMenu()
    MenuTitle="Details :"
    Menu.addButton("Utiliser", "use", {itemId})
    Menu.addButton("Ajouter", "add", {itemId})
    Menu.addButton("Donner (joueur)", "givep", {itemId})
    Menu.addButton("Donner (voiture)", "givec", {itemId})
    Menu.addButton("Jeter", "drop", {itemId})
    Menu.addButton("Go Back", "back", {})
end

function add(arg)
  prompt(function(quantity)
    TriggerServerEvent("inventory:add", steamid, tonumber(arg[1]), quantity)
  end)
end

function givep(arg)
  prompt(function(quantity)
    TriggerServerEvent("inventory:give", steamid, "steam:", GetClosestPlayer(2.1), arg[1], quantity)
    print(GetClosestPlayer(2.1))
    print(arg[1])
    print(quantity)
    print(steamid)
  end)
end

function givec(arg)
  prompt(function(quantity)
    invID = GetClosestVehicleInventoryID(5.2)
    if invID ~= false then
      TriggerServerEvent("inventory:give", steamid, invID, invID, arg[1], quantity)
    end
  end)
end

function drop(arg)
  prompt(function(quantity)
    TriggerServerEvent("inventory:drop", steamid, tonumber(arg[1]), quantity)
  end)
end

function use(arg)
  TriggerServerEvent("inventory:use", tonumber(arg[1]), 1)
  while inventoryMenu() == false do
    Wait(0)
    ClearMenu()
    inventoryMenu()
  end
end

function back(arg)
  while inventoryMenu() == false do
    Wait(0)
    ClearMenu()
    inventoryMenu()
  end
end


Citizen.CreateThread(function()

  while true do

    Wait(0)
    Menu.renderGUI()

   if IsControlJustReleased(1, 311) then
        Menu.hidden = not Menu.hidden -- Hide/Show the menu
        ClearMenu()
        MenuTitle="Items: "
        if openInventoryID ~= nil then
          while inventoryMenu() == false do
            Wait(0)
            ClearMenu()
            inventoryMenu()
          end

        end
    end


  end
end)




AddEventHandler("inventory:result", function(jsonDATA)
    inventory = json.decode(jsonDATA)
    if openInventoryID ~= inventory.id then
        return false
    end

    if inventory.weight == nil then
        inventory.weight = -1
    end
    inventory.actualWeight = 0
    for i = 1, #inventory.items do
        inventory.items[i].name = "???"
        inventory.items[i].weight = 0
        inventory.items[i].index = i

        for z = 1, #itemData do
            if itemData[z].id == inventory.items[i].id then
                inventory.items[i].name = itemData[z].name
                inventory.items[i].weight = itemData[z].weight
                inventory.actualWeight = inventory.actualWeight + itemData[z].weight * inventory.items[i].quantity
            end

        end
    end
    inventory.actualWeight = inventory.actualWeight / 1000 --> convert g in kg

    inventoryList[openInventoryID] = inventory
    --loadDataInGUI(inventory)
    --setVisible(true)
end)



function GetPlayers()
    local players = {}
    for i = 0, 64 do
        if NetworkIsPlayerActive(i) then
            table.insert(players, i)
        end
    end
    return players
end

function GetClosestPlayer(maxdistance)
    local players = GetPlayers()
    local closestDistance = -1
    local closestPlayer = -1
    local ply = GetPlayerPed(-1)
    local plyCoords = GetEntityCoords(ply, 0)

    for index,value in ipairs(players) do
        local target = GetPlayerPed(value)
        if(target ~= ply) then
            local targetCoords = GetEntityCoords(GetPlayerPed(value), 0)
            local distance = GetDistanceBetweenCoords(targetCoords["x"], targetCoords["y"], targetCoords["z"], plyCoords["x"], plyCoords["y"], plyCoords["z"], true)
            if(closestDistance == -1 or closestDistance > distance) then
                closestPlayer = value
                closestDistance = distance
            end
        end
    end
    if closestDistance > maxdistance then
      return false
    else
      return GetPlayerServerId(closestPlayer)
    end
end

function GetClosestVehicleInventoryID(maxdistance)
  pos = GetEntityCoords(GetPlayerPed(-1))
  veh = GetClosestVehicle(pos.x, pos.y, pos.z, maxdistance, 0, 70)
  if IsAnEntity(veh) then
    return "plate:" .. GetVehicleNumberPlateText(veh)
  else
    return false
  end
end

askedInventory = nil
Citizen.CreateThread(function()

  while true do
    Citizen.Wait(1)

  --[[   if IsControlJustReleased(1, 173) then -- down
      SendNUIMessage({request = "inventory", action = "down"})
    elseif IsControlJustReleased(1, 27) then --up
      SendNUIMessage({request = "inventory", action = "up"})
    elseif IsControlJustReleased(1, 201) then -- nenter
      SendNUIMessage({request = "inventory", action = "enter"})
    elseif IsControlJustReleased(1,38)  then
      pos = GetEntityCoords(GetPlayerPed(-1))
      veh = GetClosestVehicle(pos.x, pos.y, pos.z, 2.1, 0, 70)
      if IsAnEntity(veh) then
        openInventoryID = "plate:"..GetVehicleNumberPlateText(veh)
        TriggerServerEvent("inventory:ask", openInventoryID)
      end
    elseif IsControlJustReleased(1, 29) then  -- press b add 5 bottle to the closest vehicle bought
      pos = GetEntityCoords(GetPlayerPed(-1))
      veh = GetClosestVehicle(pos.x, pos.y, pos.z, 2.1, 0, 70)
      if IsAnEntity(veh) then
        askedInventory =   "plate:" .. GetVehicleNumberPlateText(veh)
        TriggerServerEvent("inventory:add", askedInventory, 1, 5)
      end
    else ]]
    if IsControlJustReleased(1,311) then
      if not(DoesEntityExist(GetClosestVehicle(GetEntityCoords(GetPlayerPed(-1), true), 3.0, 0, 70))) then
        if askedInventory ~= steamid then
          askedInventory =  steamid
        end
        openInventoryID = steamid
        print("clicked")
        TriggerServerEvent("inventory:ask", openInventoryID)
      else -- alors on a un veh
        openInventoryID = "plate:".. GetVehicleNumberPlateText(GetClosestVehicle(GetEntityCoords(GetPlayerPed(-1), true), 3.0, 0, 70))
        TriggerServerEvent("inventory:ask", openInventoryID)
      end

    elseif IsControlJustReleased(1,32) then
      -- if askedInventory ~= steamid then
      --   askedInventory =  steamid
      -- end
      -- TriggerServerEvent("inventory:add", askedInventory, 1, 1)
    end
  end
end)

function prompt(callback)
    DisplayOnscreenKeyboard(true, "FMMC_KEY_TIP8", "", "", "", "", "", 120)
    while (UpdateOnscreenKeyboard() == 0) do
      DisableAllControlActions(0)
      Wait(0)
    end
    if (GetOnscreenKeyboardResult()) then
      quantity =  math.abs(tonumber(GetOnscreenKeyboardResult()))
      callback(quantity)
    end

end

------------------------------ IZI API --------------------- or easy Happy ? I don't really know 5:50 AM

AddEventHandler("inv:getAllInv", function(inv)
  if steamid ~= nil then
    inv(inventoryList[steamid])
  else
    Citizen.Trace("\nmy steam Id is null : inventory/client.lua\n")
  end
end)

AddEventHandler("inv:gotThisItemById", function(item, bool)
  if steamid ~= nil then
    for i = 1, #inventoryList[steamid].items do
      if item == inventoryList[steamid].items[i].id and inventoryList[steamid].items[i].quantity > 0 then -- So I got it !
        bool(true)
        return
      end
    end
    bool(false)
    return
  else
    bool("\nError processing gotThisItemById : We don't have the SteamID\n")
    return
  end
end)

AddEventHandler("inv:quantityGottenById", function(item, quantity)
  if steamid ~= nil then
    for i = 1, #inventoryList[steamid].items do
      if tonumber(item) == tonumber(inventoryList[steamid].items[i].id) then -- So I got it !
        quantity(tonumber(inventoryList[steamid].items[i].quantity))
        return
      end
    end
    quantity(0)
  else
    quantity("\nError processing gotThisItemById : We don't have the SteamID\n")
  end
end)

---------------------------------------------------------------
---- I dislike doing that client side but.. It'll be easly ----
---------------------------------------------------------------
