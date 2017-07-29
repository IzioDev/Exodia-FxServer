local lang = "fr"
local config = 
  {
  ['fr'] = {
    noSpace = "<span style='color: red' > Tu n'as plus de place dans votre inventaire!</span>",
    giveItem = "<span style='color: green' > Tu as recu ", -- infos à variable
    useItem = "<span style='color: blue' > Tu as utilisé 1 ", -- infos à variable
    notEnoughItem = "<span style='color: red' > Tu n'as pas assez d'items pour faire ça!</span>",
    dropItem = "<span style='color: blue' > Tu viens de jetter ", -- infos à variable
    giveItemG = "<span style='color: blue' > Tu as donné ",
    deposit = "<span style='color: blue' > Tu as deposé ",
    withdraw = "<span style='color: blue' > Tu as retiré ",
    by = "par"
  },
  ['en'] = {
    noSpace = "<span style='color: red' > You don't have enough space to handle that!</span>",
    giveItem = "<span style='color: green' > You have received ",
    useItem = "<span style='color: green' > You used 1:",
    notEnoughItem = "<span style='color: red' > You don't have enough items to do that!</span>",
    dropItem = "<span style='color: blue' > You throw ",
    giveItemG = "<span style='color: blue' > You gave ",
    deposit = "<span style='color: blue' > You deposit ",
    withdraw = "<span style='color: blue' > You withdraw ",
    by = "by"
  }
} 
RegisterServerEvent("inv:buyItemByItemId")
RegisterServerEvent("inventory:give")
RegisterServerEvent("inventory:drop")
RegisterServerEvent("inventory:add")
RegisterServerEvent("inventory:use")
RegisterServerEvent("inventory:ask")
RegisterServerEvent("getIdentifierFromSource")
RegisterServerEvent("inventory:start")
RegisterServerEvent("getIdentifier")
allItem = nil

AddEventHandler('onMySQLReady', function ()
  local result = MySQL.Sync.fetchAll("SELECT * FROM item", {})
  allItem = result
end)

AddEventHandler("inventory:retrieveItemRestart", function() -- Support restart with restart-manager
  local result = MySQL.Sync.fetchAll("SELECT * FROM item", {})
  allItem = result

  SetTimeout(1000, function()
    TriggerEvent("es:getPlayers", function(Users)
      for k,v in pairs(Users) do
        if v ~= nil then
          TriggerClientEvent("inventory:change", v.get('source'), json.decode(v.sendDatas())) -- error here
          TriggerClientEvent("inventory:getData", v.get('source'), allItem)
        end
      end
    end)
  end)
end)

AddEventHandler("getIdentifier", function(targetNetId)
  local source = source -- Thanks to FXS
  TriggerEvent("es:getPlayerFromId", targetNetId, function(user)
    TriggerClientEvent("returnIdentifier", source, targetNetId, user.get('identifier'))
  end)
end)

AddEventHandler("es:playerLoaded", function(source)
  local source = source -- Thanks to FXS
  TriggerEvent("es:getPlayerFromId", source, function(user)
    TriggerClientEvent("inventory:change", source, json.decode(user.sendDatas()))
    TriggerClientEvent("inventory:getData", source, allItem)
  end)
end)

AddEventHandler("inventory:give", function(from, target, targetId,item, quantity) -- iventory ID; soit identifier soit une plaque, soit un chest, TargetId can be anything or playerNetId
  local source = source -- Thanks to FXS
  local toInv
  local fromInv
  local fromInvId, fromInvType = GetInventoryType(from)
  local toInvId, toInvType = GetInventoryType(target)
  local isAbleToGive
  local isAbleToReceive

  if fromInvType == "personal" then
    TriggerEvent("es:getPlayerFromId", source, function(user)
      fromInv = user
      isAbleToGive = user.isAbleToGive(item, quantity)
    end)
  elseif fromInvType == "car" then
    TriggerEvent("car:getCarFromPlate", fromInvId, function(car)
      fromInv = car
      isAbleToGive = car.isAbleToGive(item, quantity)
    end)
  elseif fromInvType == "chest" then
    isAbleToGive = false -- TODO
  end

  if toInvType == "personal" then
    TriggerEvent("es:getPlayerFromId", targetId, function(targetUser)
      toInv = targetUser
      isAbleToReceive = targetUser.isAbleToReceive(tonumber(item), quantity)
    end)
  elseif toInvType == "car" then
    TriggerEvent("car:getCarFromPlate", toInvId, function(car)
      toInv = car
      isAbleToReceive = car.isAbleToReceive(item, quantity)
    end)
  elseif toInvType == "chest" then
    isAbleToReceive = false
  end
  if isAbleToGive then                                                                   -- si l'envoyeur peut donner
    if isAbleToReceive then                                                              -- si le receveur peut recevoir
      fromInv.removeQuantity(item, quantity)                                             -- on enleve la quantity 
      TriggerClientEvent("inventory:change", source, json.decode(fromInv.sendDatas()))   -- on actualise ses données
      toInv.addQuantity(item, quantity)    
                                                    -- On ajoute la quantité
      if fromInvType == "personal" and fromInvType == toInvType then -- kikoo spotted
        TriggerClientEvent("inventory:change", targetId, json.decode(toInv.sendDatas()))
        toInv.notify(config[lang].giveItem .. quantity .. " " .. allItem[tonumber(item)].name .. config[lang].by  .. fromInv.get('displayName') .. "</span>", "success", "centerLeft", true, 5000)
        fromInv.notify(config[lang].giveItem .. quantity .. " " .. allItem[tonumber(item)].name .. config[lang].by  .. toInv.get('displayName') .. "</span>", "warning", "centerLeft", true, 5000) 
        CancelEvent()
      end

      if fromInvType == "personal" and (toInvType == "car" or toInvType == "chest") then
        fromInv.notify(config[lang].deposit .. quantity .. " " .. allItem[tonumber(item)].name .. " to the " .. toInvType .."!</span>", "info", "centerLeft", true, 5000)
        CancelEvent()
      end

      if (fromInvType == "car" or fromInvType == "chest") and toInvType == "personal" then
        fromInv.notify(config[lang].withdraw .. quantity .. " " .. allItem[tonumber(item)].name .. "!</span>", "info", "centerLeft", true, 5000)
        CancelEvent()
      end

      if toInvType == "personal" then
        TriggerClientEvent("inventory:change", targetId, json.decode(toInv.sendDatas())) -- on actualise ses données si c'est un joueur
        toInv.notify(config[lang].giveItem .. quantity .. " " .. allItem[tonumber(item)].name .. "!</span>", "success", "centerLeft", true, 5000)           -- on le notify
      elseif toInvType == "car" then                                                     -- sinon si c'est une voiture
        TriggerClientEvent("inventory:change", source, json.decode(toInv.sendDatas()))   -- on actualise les données de l'inventaire de la voiture à l'envoyeur
      end
      if fromInvType == "personal" then
        fromInv.notify(config[lang].giveItemG .. quantity .. " " .. allItem[tonumber(item)].name .. "!</span>", "success", "centerLeft", true, 5000) 
      end
    else
      if toInvType == "personal" then
        toInv.notify(config[lang].noSpace, "error", "centerLeft", true, 5000)
      end
    end
    
  else
    if fromInvType == "personal" then
      fromInv.notify(config[lang].notEnoughItem, "error", "centerLeft", true, 5000)
    end
  end

end)

AddEventHandler("inventory:drop", function(id, item, quantity)
  local source = source -- Thanks to FXS
  local InvId, InvType = GetInventoryType(id)
  local inv
  local isAbleToGive
  if InvType == "personal" then
    TriggerEvent("es:getPlayerFromId", source, function(user)
      inv = user
      isAbleToGive = user.isAbleToGive(item, quantity)
    end)
  elseif InvType == "car" then
    TriggerEvent("car:getCarFromPlate", InvId, function(car)
      if car == nil or not(car) then
        CancelEvent()
      end
      inv = car
      isAbleToGive = car.isAbleToGive(item, quantity)
    end)
  elseif InvType == "chest" then
    isAbleToGive = false -- TODO
  end

  if isAbleToGive then
    inv.removeQuantity(item, quantity) -- à tester sinon IF
    TriggerClientEvent("inventory:change", source, json.decode(inv.sendDatas()))
    if InvType == "personal" then
      inv.notify(config[lang].dropItem .. quantity .. " " .. allItem[tonumber(item)].name .. "!</span>", "info", "centerLeft", true, 5000)
    end
  else
    if InvType == "personal" then 
      inv.notify(config[lang].noEnoughItem, "error", "centerLeft", true, 5000)
    end
  end

end)

AddEventHandler("inventory:add", function(id, item, quantity)
  local source = source -- Thanks to FXS
  local InvId, InvType = GetInventoryType(id)
  local inv
  local isAbleToReceive
  if InvType == "personal" then
    TriggerEvent("es:getPlayerFromId", source, function(user)
      inv = user
      isAbleToReceive = user.isAbleToReceive(tonumber(item), quantity)
    end)
  elseif InvType == "car" then
    if car == nil or not(car) then
        CancelEvent()
    end
    TriggerEvent("car:getCarFromPlate", InvId, function(car)
      inv = car
      isAbleToReceive = car.isAbleToReceive(tonumber(item), quantity)
    end)
  elseif InvType == "chest" then
    isAbleToReceive = false -- TODO
  end

  if isAbleToReceive then
    inv.addQuantity(item, quantity)
    if InvType == "personal" then
      inv.notify(config[lang].giveItem .. quantity .. " " .. allItem[tonumber(item)].name .. "!</span>", "success", "centerLeft", true, 5000)
    end
    TriggerClientEvent("inventory:change", source, json.decode(inv.sendDatas()))
  else
    if InvType == "personal" then
      inv.notify(config[lang].noSpace, "error", "centerLeft", true, 5000)
    end
  end
end)


AddEventHandler("personalInventory:add", function(id, item, quantity)
  local source = source -- Thanks to FXS
  TriggerEvent("es:getPlayerFromId", source, function(user)
    local isAbleToReceive = user.isAbleToReceive(item, quantity)
    if isAbleToReceive then
      user.addQuantity(item, quantity)
      user.notify(config[lang].giveItem .. quantity .. " " .. allItem[tonumber(item)].name .. "!</span>", "success", "centerLeft", true, 5000)
    else
      user.notify(config[lang].noSpace, "error", "centerLeft", true, 5000)
      --TriggerEvent("inventory:notAbleToReceive")
    end
  end)
end)


AddEventHandler("inventory:use", function(item)
  local source = source -- Thanks to FXS
  TriggerEvent("es:getPlayerFromId", source, function(user)
    user.removeQuantity(tonumber(item), 1)
    user.notify(config[lang].useItem .. allItem[tonumber(item)].name .. "! </span>", "info", "centerLeft", true, 5000)
    TriggerClientEvent("inventory:change", source, json.decode(user.sendDatas()))
  end)
end)

AddEventHandler("inventory:ask", function(id)
  local source = tonumber(source)
  local invToReturn
  local inventoryId, invType = GetInventoryType(id)
  if invType == "personal" then
    TriggerEvent("es:getPlayerFromId", source, function(user)
      invToReturn = user.sendDatas()
    end)
  elseif invType == "car" then
    TriggerEvent("car:getCarFromPlate", inventoryId, function(car)
      if car ~= nil then
        invToReturn = car.sendDatas()
      else
        invToRetrun = nil
      end
    end)
  elseif invType == "chest" then
    invToReturn = nil
  end
  if invToReturn ~= nil then
    TriggerClientEvent("inventory:result", source, invToReturn)
  else
    print("ce n est pas une voiture enregistré")
  end
end)


AddEventHandler("inv:buyItemByItemId", function(itemId)
  local source = tonumber(source) -- thanks FXS
  TriggerEvent("es:getPlayerFromId", source, function(user)
    local isAbleToReceive = user.isAbleToReceive(itemId, 1)
    if isAbleToReceive then
      if user.get('money') >= tonumber(allItem[tonumber(itemId)].price) then
        user.addQuantity(itemId, 1)
        user.removeMoney(allItem[tonumber(itemId)].price)
        TriggerClientEvent("inventory:change", source, json.decode(user.sendDatas()))
        user.notify("Tu viens d'acheter <span style='color:green' >" .. "1" .. "</span><span style='color:blue' > " .. allItem[tonumber(itemId)].name .. "!</span>", "success", "centerLeft", true, 5000)
      else
        user.notify("Tu n'as pas assez d'argent", "error", "centerLeft", true, 5000)
      end
    else
      user.notify(config[lang].noSpace, "error", "centerLeft", true, 5000)
    end
  end)
end)

function GetInventoryType(id)
  local result = nil
  local invType
  print(id)
  result = stringsplit(id, ":")
  if result[1] == "steam" then
    invType = "personal"
  elseif result[1] == "plate" then
    invType = "car"
  elseif result[1] == "chest" then
    invType = "chest"
  else
    print("Error GetInventoryType inventory/server.lua")
  end
  return result[2], invType
end

function stringsplit(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end

    local t={} ; i=1

    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
        t[i] = str
        i = i + 1
    end

    return t
end
---- Commandes :
TriggerEvent('es:addGroupCommand', 'additem', "mod", function(source, args, user)
  if #args~=4 or args[2] == "help" then
    user.notify("Usage : /additem [PSID] [ID] [QUANTITY]", "error", "topCenter", true, 5000)
  else
    TriggerEvent("es:getPlayerFromId", tonumber(args[2]), function(targetUser)
      if targetUser == nil then
        user.notify("Le joueur n'est pas en ligne", "error", "topCenter", true, 5000)
      else
        if allItem[tonumber(args[3])] then
          if tonumber(args[4]) >= 100 then
            user.notify("Calme toi sur la quantité mon bruh", "error", "topCenter", true, 5000)
          else
            local isAbleToReceive = targetUser.isAbleToReceive(tonumber(args[3]), tonumber(args[4]))
            if not(isAbleToReceive) then
              user.notify("Le joueur n'a pas assez de palce dans ton inventaire", "error", "topCenter", true, 5000)
            else
              targetUser.addQuantity(tonumber(args[3]), tonumber(args[4]))
              targetUser.notify("Un administrateur vient de vous ajouter " .. args[4] .. " " .. allItem[tonumber(args[3])].name .. ".", "success", "topCenter", true, 5000)
              targetUser.refreshInventory()
              user.notify("Vous avez ajouté " .. tonumber(args[4]) .. " " .. allItem[tonumber(args[3])].name .. " à " .. targetUser.get("displayName") .. ".", "success", "topCenter", true, 5000)
            end
          end
        else
          user.notify("L'item est innexistant..", "error", "topCenter", true, 5000)
        end
      end
    end)
  end
end, function(source, args, user)
  user.notify("Tu ne peux pas faire ça mon coco :p", "error", "topCenter", true, 5000)
end)

---- iJob : 

RegisterServerEvent("ijob:getItemInfosFromIdArray")
AddEventHandler("ijob:getItemInfosFromIdArray", function(itemIdArray)
  local source = source
  local processResult = {}
  for i = 1, #itemIdArray do
    table.insert(processResult, allItem[itemIdArray[i]])
  end
  TriggerClientEvent("ijob:getItemInfosFromIdArray", source, processResult)
end)