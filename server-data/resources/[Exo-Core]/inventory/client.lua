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

  data = json.decode(data)
  if steamid == nil then -- ok
    steamid = data.id
  end
--
  inventoryList[data.id] = data

  inventoryMenu(data.id, data)

--
end)

function inventoryMenu(idInv, Inventory)
  if Menu.hidden then
    ClearMenu()
    currentMenu = nil
  else
    ClearMenu()
    currentMenu = "mainMenu"
    MenuTitle = idInv

    for ind, value in pairs(Inventory.items) do
        if (value.quantity > 0) then
          if value.name == nil then
            return false
          end
          if value.name == "???" then
            value.name = "404 > ID: " .. value.id
          end
            Menu.addButton(tostring(value.name) .. " : " .. tostring(value.quantity), "ItemMenu", {itemId = value.id, invType = Iventory.invType, inv = Inventory})
        end
    end
    return true
end

function ItemMenu(args)
  local x,y,z = table.unpack(GetEntityCoords(GetPlayerPed(-1), true))
  currentMenu = "subMenu"
  local itemId = args.itemId
  ClearMenu()
  MenuTitle="Actions :"
  if invType == "vehicle_inventory" then
    -- Menu.addButton("Utiliser", "use", {itemId = itemId, id = val, invType = invType})
    -- Menu.addButton("Ajouter", "add", {itemId})
    Menu.addButton("Prendre du coffre", "takec", {itemId = itemId, invId = "plate:"..GetVehicleNumberPlateText(GetClosestVehicle(x, y, z, 3.0, 0, 70))})
    -- Menu.addButton("Donner (voiture)", "givec", {itemId})
    Menu.addButton("Jeter", "drop", {itemId = itemId, invType = invType})
    Menu.addButton("Retour", "back", {inv = args.inv, invType = invType})
  elseif invType == "personal_inventory" then
    Menu.addButton("Utiliser", "use", {itemId = itemId, invType = invType})
    -- Menu.addButton("Ajouter", "add", {itemId})
    Menu.addButton("Donner", "givep", {itemId = itemId, invType = invType})
    if DoesEntityExist(GetClosestVehicle(x, y, z, 3.0, 0, 70)) then
      Menu.addButton("Déposer dans un coffre", "givec", {itemId = itemId, invId = "plate:"..GetVehicleNumberPlateText(GetClosestVehicle(x, y, z, 3.0, 0, 70))})
    end
    Menu.addButton("Jeter", "drop", {itemId = itemId, invType = invType})
    Menu.addButton("Retour", "back", {inv = args.inv, invType = invType})
  end
end

function add(arg)
  prompt(function(quantity)
    TriggerServerEvent("inventory:add", steamid, tonumber(args.itemId), quantity)
  end)
end

function givep(args)
  prompt(function(quantity)
    TriggerServerEvent("inventory:give", steamid, "steam:", GetClosestPlayer(2.1), args.itemId, quantity)
  end)
end

function takec(args)
  prompt(function(quantity)
    TriggerServerEvent("inventory:give", args.invId, "steam:", GetPlayerServerId(GetPlayerPed(-1)), args.itemId, quantity)
  end)
end

function givec(args)
  prompt(function(quantity)
      TriggerServerEvent("inventory:give", steamid, args.invId, "OSEF", args.itemId, quantity)
  end)
end

function drop(args)
  prompt(function(quantity)
    if args.invType == "personal_inventory" then
      TriggerServerEvent("inventory:drop", steamid, tonumber(args.itemId), quantity)
    elseif args.invType == "vehicle_inventory" then
      TriggerServerEvent("inventory:drop", GetVehicleNumberPlateText(GetClosestVehicle(x, y, z, 3.0, 0, 70)), tonumber(args.itemId), quantity)
    end
  end)
end

function use(args)
  prompt(function(quantity)
    TriggerServerEvent("inventory:use", tonumber(args.itemId), 1)
  end)
end

function back(args)
  inventoryMenu(args.inv, args.invType)
end


-- Citizen.CreateThread(function()

--   while true do

--     Wait(0)

--    if IsControlJustReleased(1, 311) then
--         Menu.hidden = not Menu.hidden -- Hide/Show the menu
--         ClearMenu()
--         MenuTitle="Items: "
--         if openInventoryID ~= nil then
--           while inventoryMenu() == false do
--             Wait(0)
--             ClearMenu()
--             inventoryMenu()
--           end

--         end
--     end


--   end
-- end)




AddEventHandler("inventory:result", function(jsonDATA)
    print(jsonDATA)
    inventory = json.decode(jsonDATA)
    openInventoryID = inventory.id
    -- if openInventoryID ~= inventory.id then
    --     return false
    -- end

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

    inventoryMenu(inventory.id, inventory)

    Menu.hidden = not Menu.hidden
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
  TriggerServerEvent("inventory:retreiveIfRestart")
  while true do
    Citizen.Wait(0)

    Menu.renderGUI()

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
        TriggerServerEvent("inventory:ask", askedInventory)
      else -- alors on a un veh
        --OpenChoiceMenu() TODO if the rest works
        --openInventoryID = "plate:".. GetVehicleNumberPlateText(GetClosestVehicle(GetEntityCoords(GetPlayerPed(-1), true), 3.0, 0, 70))
        TriggerServerEvent("inventory:ask", "plate:".. GetVehicleNumberPlateText(GetClosestVehicle(GetEntityCoords(GetPlayerPed(-1), true), 3.0, 0, 70)))
        print("on vient de demander l'inv d'une caisse")
      end

    elseif IsControlJustReleased(1,32) then
      -- if askedInventory ~= steamid then
      --   askedInventory =  steamid
      -- end
      -- TriggerServerEvent("inventory:add", askedInventory, 1, 1)
    elseif IsControlPressed(1, 177) then
      if currentMenu == "mainMenu" and not(Menu.hidden) then
        currentMenu = nil
        ClearMenu()
        Menu.hidden = true
      elseif currentMenu == "subMenu" and not(Menu.hidden) then
        currentMenu = "mainMenu"

      end
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

AddEventHandler("inv:gotItemsAndQuantity", function(itemInfos, bool)
  local countValidated = 0
  for i = 1, #items do
    for j = 1, #inventoryList[steamid].items do
      if items.id == tonumber(inventoryList[steamid].items[j].id) then
        if inventoryList[steamid].items[j].quantity >= items.quantity then
          countValidated = countValidated + 1
        end
      end
    end
  end
  if countValidated == #itemInfos then
    bool(true)
  else
    bool(false)
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
