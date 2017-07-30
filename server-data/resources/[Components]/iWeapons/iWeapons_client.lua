-- Copyright (C) Izio, Inc - All Rights Reserved
-- Unauthorized copying of this file, via any medium is strictly prohibited
-- Proprietary and confidential
-- Written by Romain Billot <romainbillot3009@gmail.com>, Jully 2017
RegisterNetEvent("iWeapons:cbSearchInfos")


local weaponPed = {}
local weaponsLoaded = false
local currentMenu
local currentShop = {hash="s_m_m_ammucountry", x=1692.733, y=3761.895, z=34.705, a=218.535}
local alreadySearched = false
-- Configure the coordinates for the vendors.
local weapon_peds = {
  {hash="s_m_m_ammucountry", x=1692.733, y=3761.895, z=34.705, a=218.535},
  {hash="s_m_m_ammucountry", x=-330.933, y=6085.677, z=31.455, a=207.323},
  {hash="s_m_y_ammucity_01", x=253.629, y=-51.305, z=69.941, a=59.656},
  {hash="s_m_y_ammucity_01", x=841.363, y=-1035.350, z=28.195, a=328.528},
  {hash="s_m_y_ammucity_01", x=-661.317, y=-933.515, z=21.829, a=152.798},
  {hash="s_m_y_ammucity_01", x=-1304.413, y=-395.902, z=36.696, a=44.440},
  {hash="s_m_y_ammucity_01", x=-1118.037, y=2700.568, z=18.554, a=196.070},
  {hash="s_m_y_ammucity_01", x=2566.596, y=292.286, z=108.735, a=337.291},
  {hash="s_m_y_ammucity_01", x=-3173.182, y=1089.176, z=20.839, a=223.930},
}
local weaponsSubMenu = {
  ["cata"] = {
    title = "Catégorie A",
    name = "cata",
    buttons = {
      -- {name = "Catégorie A", targetFunction = "BuyWeapon", targetArrayParam = "cata" },
      -- {name = "Catégorie B", targetFunction = "BuyWeapon", targetArrayParam = "catb" },
      -- {name = "Catégorie C", targetFunction = "BuyWeapon", targetArrayParam = "catc" },
      -- {name = "Catégorie D", targetFunction = "BuyWeapon", targetArrayParam = "catd" },
     -- {name = "Retour aux catégorie", targetFunction = "OpenMenu", targetArrayParam = weaponsMainMenu["main"] }
    }
  },
  ["catb"] = {
    title = "Catégorie B",
    name = "catb",
    buttons = {
      -- {name = "Catégorie A", targetFunction = "BuyWeapon", targetArrayParam = "cata" },
      -- {name = "Catégorie B", targetFunction = "BuyWeapon", targetArrayParam = "catb" },
      -- {name = "Catégorie C", targetFunction = "BuyWeapon", targetArrayParam = "catc" },
      -- {name = "Catégorie D", targetFunction = "BuyWeapon", targetArrayParam = "catd" },
     -- {name = "Retour aux catégorie", targetFunction = "OpenMenu", targetArrayParam = weaponsMainMenu["main"] }
    }
  },
  ["catc"] = {
    title = "Catégorie C",
    name = "catc",
    buttons = {
      {name = "Arme1 test", targetFunction = "BuyWeapon", targetArrayParam = "WEAPON_KNIFE" },
      {name = "Arme2 test", targetFunction = "BuyWeapon", targetArrayParam = "WEAPON_NIGHTSTICK" },
      -- {name = "Catégorie C", targetFunction = "BuyWeapon", targetArrayParam = "catc" },
      -- {name = "Catégorie D", targetFunction = "BuyWeapon", targetArrayParam = "catd" },
     -- {name = "Retour aux catégorie", targetFunction = "OpenMenu", targetArrayParam = weaponsMainMenu["main"] }
    }
  },
  ["catd"] = {
    title = "Catégorie D",
    name = "catd",
    buttons = {
      {name = "Arme1 test", targetFunction = "BuyWeapon", targetArrayParam = "WEAPON_VINTAGEPISTOL" },
      {name = "Arme2 test", targetFunction = "BuyWeapon", targetArrayParam = "WEAPON_POOLCUE" },
      -- {name = "Catégorie C", targetFunction = "BuyWeapon", targetArrayParam = "catc" },
      -- {name = "Catégorie D", targetFunction = "BuyWeapon", targetArrayParam = "catd" },
     -- {name = "Retour aux catégorie", targetFunction = "OpenMenu", targetArrayParam = weaponsMainMenu["main"] }
    }
  }
}
local weaponsMainMenu = {
  ["main"] = {
    title = "Acheter une arme",
    name = "main",
    buttons = {

    }
  }
}

Citizen.CreateThread(function()
  while true do
    Citizen.Wait(0)
    
    playerPed = GetPlayerPed(-1)
    playerCoords = GetEntityCoords(playerPed, 0)

    if (not weaponsLoaded) then
      for k,v in pairs(weapon_peds) do
        RequestModel(GetHashKey(v.hash))
        while not HasModelLoaded(GetHashKey(v.hash)) do
          Wait(1)
        end

        -- Load the animation for the vendors
        RequestAnimDict("amb@prop_human_bum_shopping_cart@male@base")
        while not HasAnimDictLoaded("amb@prop_human_bum_shopping_cart@male@base") do
          Wait(0)
        end

        weaponPed = CreatePed(4, v.hash, v.x, v.y, v.z, v.a, false, false)
        SetBlockingOfNonTemporaryEvents(weaponPed, true)
        SetPedFleeAttributes(weaponPed, 0, 0)
        SetEntityInvincible(weaponPed, true)
        -- Annimations
        SetAmbientVoiceName(weaponPed, "AMMUCITY")
        TaskPlayAnim(weaponPed,"amb@prop_human_bum_shopping_cart@male@base","base", 8.0, 0.0, -1, 1, 0, 0, 0, 0)
      end
      weaponsLoaded = true
    end

    -- Check if the player is at the store and show him the menu
    for k,v in pairs(weapon_peds) do
      local doordist = Vdist(playerCoords.x, playerCoords.y, playerCoords.z, v.x, v.y, v.z)
      if doordist < 11 then
        SetCurrentPedWeapon(playerPed, GetHashKey("WEAPON_UNARMED"), true)
      end

      if doordist < 4 then
        currentShop = v
        if Menu.hidden then
          buyWeaponInfo("Appuyez sur ~INPUT_CONTEXT~ pour regarder les armes", 0)
        end
        if IsControlJustPressed(1, 38) then
          if not(alreadySearched) then
            TriggerServerEvent("iWeapons:searchInfos")
          else
            Menu.hidden = not(Menu.hidden)
            if not(Menu.hidden) then
              OpenMenu(weaponsMainMenu["main"])
            end
          end
          --Open menu
        elseif IsControlJustPressed(1, 177) then
          if currentMenu == "main" then
            CloseMenu("test")
            print("closed")
          else
            OpenMenu(weaponsMainMenu["main"])
            print("opened main by back")
          end
        end
      elseif Vdist(playerCoords.x, playerCoords.y, playerCoords.z, currentShop.x, currentShop.y, currentShop.z) >= 4 and not(Menu.hidden) then
        CloseMenu("osef")
        print("closed2")
      end
    end
    Menu.renderGUI()
  end
end)

function OpenMenu(menu)
  ClearMenu()
  MenuTitle = menu.title
  for i = 1, #menu.buttons do
    Menu.addButton(menu.buttons[i].name, menu.buttons[i].targetFunction, menu.buttons[i].targetArrayParam)
  end
  Menu.hidden = false
  currentMenu = menu.name
end

function CloseMenu(fake)
  ClearMenu()
  Menu.hidden = true
  currentMenu = nil
end

function buyWeaponInfo(text, state)
  SetTextComponentFormat("STRING")
  AddTextComponentString(text)
  DisplayHelpTextFromStringLabel(0, state, 0, -1)
end

function BuyWeapon(weaponHash)
  TriggerServerEvent("iweapons:checkForBuy", weaponHash)
end

RegisterNetEvent("iWeapons:giveWeapon")
AddEventHandler("iWeapons:giveWeapon", function(weapon)
  GiveWeaponToPed(GetPlayerPed(-1), GetHashKey(weapon), 2000, false)
end)

AddEventHandler("iWeapons:cbSearchInfos", function(weaponInfos)
  for i = 1, #weaponInfos do
    table.insert(weaponsMainMenu["main"].buttons, 
      {name = weaponInfos[i].name .. " " .. weaponInfos[i].weight .."g, ".. weaponInfos[i].price .."$.", targetFunction = "BuyWeapon", targetArrayParam = weaponInfos[i].hash })
  end
  alreadySearched = true
  Menu.hidden = not(Menu.hidden)
  if not(Menu.hidden) then
    OpenMenu(weaponsMainMenu["main"])
  end
end)