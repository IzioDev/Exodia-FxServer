-- Copyright (C) Izio, Inc - All Rights Reserved
-- Unauthorized copying of this file, via any medium is strictly prohibited
-- Proprietary and confidential
-- Written by Romain Billot <romainbillot3009@gmail.com>, Jully 2017
RegisterServerEvent("iWeapons:searchInfos")
RegisterServerEvent("iweapons:checkForBuy")


AddEventHandler("iweapons:checkForBuy", function(weaponHash)
  print(weaponHash)
  local source = source -- Thanks FXS
  TriggerEvent("es:getPlayerFromId", source, function(user)
    local weaponInfo = user.returnWeaponInfos(weaponHash)
    print(type(weaponInfo))
    if weaponInfo == "not found" then
      user.notify("Contacter Izio ! : Weapon not founded > iWeapons_server.lua hash error?", "error", "topCenter", true, 5000)
      print("contact")
    else
      local isAbleToReceive = user.isAbleToReceive(weaponInfo.id, 1)

      if not(isAbleToReceive) then
        print("notenoughtspace")
        user.notify("Vous n'avez pas assez de place dans votre inventaire.", "error", "topCenter", true, 5000)
      else
        if user.get("money") >= weaponInfo.price then
          user.removeMoney(weaponInfo.price)
          user.addQuantity(weaponInfo.id, 1) -- ###TODO ajouter un matricul###
          print("bought")
          user.notify("Tu as acheté 1 " .. weaponInfo.name .. " qui a couté: " .. weaponInfo.price .."$.", "success", "topCenter", true, 5000)
          user.refreshInventory()
        else
          user.notify("Vous n'avez pas assez d'argent pour acheter 1 " .. weaponInfo.name .. " qui coute: " .. weaponInfo.price .."$.", "error", "topCenter", true, 5000)
          print("not enought money")
        end
      end
    end
  end)
end)

AddEventHandler("iWeapons:searchInfos", function()
  local source = source
  TriggerEvent("es:getPlayerFromId", source, function(user)
    local Info = user.get("item")
    local weaponInfos = Info.weapons
    print(json.encode(weaponInfos))
    TriggerClientEvent("iWeapons:cbSearchInfos", source, weaponInfos)
  end)
end)