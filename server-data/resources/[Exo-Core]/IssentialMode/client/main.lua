-- Copyright (C) Izio, Inc - All Rights Reserved
-- Unauthorized copying of this file, via any medium is strictly prohibited
-- Proprietary and confidential
-- Written by Romain Billot <romainbillot3009@gmail.com>, Jully 2017

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)

		if NetworkIsSessionStarted() then
			--Citizen.InvokeNative(0x170F541E1CADD1DE, false)
			--Citizen.InvokeNative(0x0772DF77852C2E30, 1, 1)
			TriggerServerEvent('es:firstJoinProper')
			TriggerEvent('es:allowedToSpawn')
			return
		end
	end
end)

playerLoaded = false
local cashy = 0
local oldPos

AddEventHandler('playerFirstSpawn', function() -- Ne pas restart essential si le mode character est actif.
    playerLoaded = true
end)

function IzioFreezePlayer(id, freeze)
    local player = id
    SetPlayerControl(player, not freeze, false)

    local ped = GetPlayerPed(player)

    if not freeze then
        if not IsEntityVisible(ped) then
            SetEntityVisible(ped, true)
        end

        if not IsPedInAnyVehicle(ped) then
            SetEntityCollision(ped, true)
        end

        FreezeEntityPosition(ped, false)
        --SetCharNeverTargetted(ped, false)
        SetPlayerInvincible(player, false)
    else
        if IsEntityVisible(ped) then
            SetEntityVisible(ped, false)
        end

        SetEntityCollision(ped, false)
        FreezeEntityPosition(ped, true)
        --SetCharNeverTargetted(ped, true)
        SetPlayerInvincible(player, true)
        --RemovePtfxFromPed(ped)

        if not IsPedFatallyInjured(ped) then
            ClearPedTasksImmediately(ped)
        end
    end
end

Citizen.CreateThread(function()
AddTextEntry("FE_THDR_GTAO", "~y~Exodia ~r~RP") -- title
AddTextEntry("PM_SCR_MAP", "Etat de Los Santos") -- map button
AddTextEntry("PM_SCR_GAM", "Quitter") -- gaame button
AddTextEntry("PM_SCR_SET", "Configuration") -- settings button
AddTextEntry("PM_SCR_RPL", "Editeur Rockstar") -- editor button
AddTextEntry("PM_PANE_LEAVE", "Retour à la liste des serveurs") -- disconnect button
AddTextEntry("PM_PANE_QUIT", "Retour vers windows") -- exit button
	while true do
		Citizen.Wait(1000)
		local pos = GetEntityCoords(GetPlayerPed(-1))

		if(oldPos ~= pos)then
			TriggerServerEvent('es:updatePositions', pos.x, pos.y, pos.z)
			oldPos = pos
		end

	end
end)

RegisterNetEvent("es:afterSelection")
AddEventHandler("es:afterSelection", function(spawn)
  RequestCollisionAtCoord(spawn.x, spawn.y, spawn.z + 0.5)
	SetEntityCoords(GetPlayerPed(-1), spawn.x, spawn.y, spawn.z + 0.5, 0.0, 0.0, 0.0, false)
  Citizen.CreateThread(function()
    Citizen.Wait(3000)
    TriggerServerEvent("es:playerLoadedDelay")
    TriggerEvent("pNotify:notifyFromServer", "Chargement en cours de ton skin...", "error", "topCenter", true, 8000)
    while not(GetEntityModel(GetPlayerPed(-1)) == GetHashKey("mp_m_freemode_01")) do
      Wait(500)
    end
    IzioFreezePlayer(PlayerId(), false)
    SetEntityVisible(GetPlayerPed(-1), true, 1)
    SetEntityInvincible(GetPlayerPed(-1), 0)
  end)
end)

local myDecorators = {}

RegisterNetEvent("es:setPlayerDecorator")
AddEventHandler("es:setPlayerDecorator", function(key, value, doNow)
	myDecorators[key] = value
	DecorRegister(key, 3)

	if(doNow)then
		DecorSetInt(GetPlayerPed(-1), key, value)
	end
end)

AddEventHandler("playerSpawned", function()
	for k,v in pairs(myDecorators)do
		DecorSetInt(GetPlayerPed(-1), k, v)
	end
end)

RegisterNetEvent('es:setMoneyIcon')
AddEventHandler('es:setMoneyIcon', function(i)
	SendNUIMessage({
		seticon = true,
		icon = i
	})
end)

RegisterNetEvent('es:activateMoney')
AddEventHandler('es:activateMoney', function(e)
	SendNUIMessage({
		setmoney = true,
		money = e
	})
end)

RegisterNetEvent("es:addedMoney")
AddEventHandler("es:addedMoney", function(m, native)

	if not native then
		SendNUIMessage({
			addcash = true,
			money = m
		})
	else
		Citizen.InvokeNative(0x170F541E1CADD1DE, true)
		Citizen.InvokeNative(0x0772DF77852C2E30, math.ceil(m), 0)
	end

end)

RegisterNetEvent("es:removedMoney")
AddEventHandler("es:removedMoney", function(m, native, current)
	if not native then
		SendNUIMessage({
			removecash = true,
			money = m
		})
	else
		Citizen.InvokeNative(0x170F541E1CADD1DE, true)
		Citizen.InvokeNative(0x0772DF77852C2E30, -math.ceil(m), 0)
	end
end)

RegisterNetEvent('es:activateDirtyMoney')
AddEventHandler('es:activateDirtyMoney', function(e)
	SendNUIMessage({
		setDirty_money = true,
		dirty_money = e
	})
end)

RegisterNetEvent("es:addedDirtyMoney")
AddEventHandler("es:addedDirtyMoney", function(m)
	SendNUIMessage({
		addDirty_cash = true,
		dirty_money = m
	})

end)

RegisterNetEvent("es:removedDirtyMoney")
AddEventHandler("es:removedDirtyMoney", function(m)
	SendNUIMessage({
		removeDirty_cash = true,
		dirty_money = m
	})
end)

AddEventHandler("is:updateJob", function(userJob, userRank)
  SendNUIMessage({    -- à envoyer dans essential. :/
    setJob = true,
    job = userJob,
    rank = userRank
  })
end)

-- Send NUI message to update bank balance
RegisterNetEvent('banking:updateBalance')
AddEventHandler('banking:updateBalance', function(balance)
  local id = PlayerId()
  local playerName = GetPlayerName(id)
  SendNUIMessage({
    updateBalance = true,
    balance = balance,
    player = playerName
  })
end)

-- Send NUI Message to display add balance popup
RegisterNetEvent("banking:addBalance")
AddEventHandler("banking:addBalance", function(amount)
  SendNUIMessage({
    addBalance = true,
    amount = amount
  })

end)

-- Send NUI Message to display remove balance popup
RegisterNetEvent("banking:removeBalance")
AddEventHandler("banking:removeBalance", function(amount)
  SendNUIMessage({
    removeBalance = true,
    amount = amount
  })
end)

RegisterNetEvent("es:setMoneyDisplay")
AddEventHandler("es:setMoneyDisplay", function(val)
	SendNUIMessage({
		setDisplay = true,
		display = val
	})
end)

RegisterNetEvent("es:enablePvp")
AddEventHandler("es:enablePvp", function()
	Citizen.CreateThread(function()
		while true do
			Citizen.Wait(0)
			for i = 0,32 do
				if NetworkIsPlayerConnected(i) then
					if NetworkIsPlayerConnected(i) and GetPlayerPed(i) ~= nil then
						SetCanAttackFriendly(GetPlayerPed(i), true, true)
						NetworkSetFriendlyFireOption(true)
					end
				end
			end
		end
	end)
end)
-------------- Never Wanted ------------------
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if GetPlayerWantedLevel(PlayerId()) ~= 0 then
            SetPlayerWantedLevel(PlayerId(), 0, false)
            SetPlayerWantedLevelNow(PlayerId(), false)
        end
    end
end)

local waitingAlert = {}
-------------- Alert NUI ---------------------
RegisterNetEvent("Issential:alertFromServer")
AddEventHandler("Issential:alertFromServer", function(title, desc, params)
  table.insert(waitingAlert, {title = title, desc = desc, params = params})
end)

Citizen.CreateThread(function()
  while true do
    Wait(1000)
    local isWaiting = {}
    for i = 1, #waitingAlert do
      if waitingAlert.isWaiting == true then
        table.insert(isWaiting, waitingAlert)
      end
    end
    if #isWaiting == 0 and #waitingAlert ~= 0 then
      SetNuiFocus(true, true)
      SendNUIMessage({
          action = "openAlert",
          title = waitingAlert[1].title,
          desc = waitingAlert[1].desc,
          params = waitingAlert[1].params
        })
      waitingAlert[1].isWaiting = true
    end
  end
end)

RegisterNUICallback('selected', function(data, cb)
  SetNuiFocus(false, false)
  table.remove(waitingAlert, 1)
  TreatAlert(data)
  -- data.choice
  -- data.params
end)

RegisterNUICallback('close', function(data, cb)
  SetNuiFocus(false, false)
  table.remove(waitingAlert, 1)
  data.choice = false
  TreatAlert(data)
  -- data.params
end)

function TreatAlert(data)
  if data.params.event then
    TriggerServerEvent(data.params.event, data)
  else
    if data.id == "pompisteMission" then
      TriggerServerEvent("iPompiste:manageChoiceMission", data.choice, data.params)
    end
  end
end

------------------------------------UI CHARACTER PART-----------------------------------
EI = exports.interface

ActualUI = {}
characters = nil
maxNumbChars = nil
numberCharacters = nil


function registerPedForm()
  parent = EI:CreateComponent("parent", "body", "<div class='GUI-dark'><center><h2>Right Click Entertainment<h2></center><center><h3 style='margin-bottom: 5px'>Select your character</h3></center></div>")
  charactere = EI:CreateComponent(parent.jS, "<div class='charactere'></div>")
  maincenter = EI:CreateComponent(charactere.jS, "<center><h2 class='slotind'>Create your charactere</h2></center>")
  row1 = EI:CreateComponent(maincenter.jS, "<div class='rowinfo-register'></div>")
  info1 = EI:CreateComponent(row1.jS,  "<a style='float:left'>First Name:</a>")
  info2 = EI:CreateComponent(row1.jS,  "<a style='float:right'></a>")
  input1 = EI:CreateComponent(info2.jS, "<input type='text' placeholder='needed'></input>")
  row2 = EI:CreateComponent(maincenter.jS, "<div class='rowinfo-register'></div>")
  info3 = EI:CreateComponent(row2.jS,  "<a style='float:left'>Last Name:</a>")
  info4 = EI:CreateComponent(row2.jS,  "<a style='float:right'></a>")
  input2 = EI:CreateComponent(info4.jS, "<input type='text' placeholder='needed'></input>")
  row3 = EI:CreateComponent(maincenter.jS, "<div class='rowinfo-register'></div>")
  info5 = EI:CreateComponent(row3.jS,  "<a style='float:left'>Age:</a>")
  info6 = EI:CreateComponent(row3.jS,  "<a style='float:right'></a>")
  input3 = EI:CreateComponent(info6.jS, "<input type='number' min='18' max='99' placeholder='needed'></input>")
  createbtn = EI:CreateComponent("gobtn", maincenter.jS, "<button class='btn-fully'>Enter the universe</button>")
  backbtn = EI:CreateComponent("backbtn", maincenter.jS, "<button class='btn-fully'>Go back to the selection</button>")

  createbtn.setAttribute( "clickCB", function()
    firstname = EI:GetComponentById(input1.id).value
    lastname = EI:GetComponentById(input2.id).value
    age = EI:GetComponentById(input3.id).value
    if tonumber(age) > 18 and tonumber(age) <= 100 and firstname ~= nil and firstname ~= "" and lastname ~= nil and lastname ~= "" and playerLoaded then
	    TriggerServerEvent("es:LoadChar", firstname, lastname, age, true)
	    HidePedSelector(ActualUI)
	else
		-- TODO dosplay notif : "Please enter age greater than 18 and less than 101, valid firstname and lastname"
	end
  end)
EI:SetComponentAttribute(backbtn.id, "clickCB", function()
     EI:hideComponent(ActualUI, {false, false})
     ActualUI = selectPedForm()
     EI:showComponent(ActualUI, {true, true})
   end)
myui = {parent , charactere, maincenter, row1, info1, info2, input1, row2, info3, info4, input2, row3, info5, info6, input3,createbtn, backbtn}
  return myui
end
function selectPedForm()
  choicePickerUI = {}
  -- print("okped")
  count = maxNumbChars
  parent = EI:CreateComponent("parent", "body", "<div class='GUI-dark'><center><h2>Right Click Entertainment<h2></center><center><h3 style='margin-bottom: 5px'>Select your character</h3></center></div>")
  choicePickerUI = {parent}
  for i = 1, #characters do

    if characters[i].name == nil then
      if characters[i].firstName == nil or characters[i].lastName == nil then
      else
        characters[i].name = characters[i].firstName .. " " .. characters[i].lastName
      end
    end
    count  = count - 1
    charactere = EI:CreateComponent(parent.jS, "<div class='charactere'></div>")
		idCharactere = charactere.id
    slotind = EI:CreateComponent(charactere.jS, "<center><h2 class='slotind'>Slot " .. tostring(i) .."</h2></center>")
    slot1Info = EI:CreateComponent(charactere.jS, "<div class='rowinfo'></div>")
    slot1Info1 =  EI:CreateComponent(slot1Info.jS,"<a style='float: left'>Name: " .. characters[i].name .. "</a>")
    slot1Info2 = EI:CreateComponent(slot1Info.jS, "<a style='float: right'>Job: " .. characters[i].job .. "</a>")

    slot2Info = EI:CreateComponent(charactere.jS, "<div class='rowinfo'></div>")
    slot2Info1 =  EI:CreateComponent(slot2Info.jS,"<a style='float: left'>Age: " .. characters[i].age .. " years old</a>")
    slot2Info2 = EI:CreateComponent(slot2Info.jS, "<a style='float: right'>Bank: " .. characters[i].bankMoney .. "$</a>")

    slot3Info = EI:CreateComponent(charactere.jS, "<div class='rowinfo'></div>")
    slot3Info1 =  EI:CreateComponent(slot3Info.jS,"<a style='float: left'>Last seen: " .. characters[i].lastSeen .. "</a>")
    slot3Info2 = EI:CreateComponent(slot3Info.jS, "<a style='float: right'>Money: " .. characters[i].money .. "$</a>")


    grpbtn = EI:CreateComponent(charactere.jS, "<center></center>")
		gobtn = EI:CreateComponent(grpbtn.jS, "<button class='gobtn'>Enter the universe</button>")
    delbtn = EI:CreateComponent(grpbtn.jS, "<button class='delbtn'>Remove</button>")
    gobtn.setAttribute("clickCB", function()
      if playerLoaded then
        TriggerServerEvent("es:LoadChar", characters[i].firstName, characters[i].lastName, characters[i].age, false)
        HidePedSelector(ActualUI)
      end
      -- print(" click => user selected: " .. characters[i].firstName)
    end)
		delbtn.setAttribute("clickCB", function()
      if playerLoaded then
  			TriggerServerEvent("es:deleteChar", characters[i].firstName, characters[i].lastName, characters[i].lastSeen)
  			EI:GetComponentById(idCharactere).hide()
      end
		end)
    --rembtn = EI:CreateComponent("button", grpbtn.jS, "delbtn", "Remove", "")
    CharComponentList = {charactere, slotind, slot1Info, slot1Info1, slot1Info2, slot2Info, slot2Info1, slot2Info2, slot3Info, slot3Info1, slot3Info2, grpbtn, gobtn, delbtn}
    for i = 1, #CharComponentList do
      table.insert(choicePickerUI, CharComponentList[i])
    end
  end
  emptySlotComponent = {}
  if tonumber(maxNumbChars) - tonumber(numberCharacters) > 0 then
    emptySlot = EI:CreateComponent(parent.jS, "<div class='charactere'> <div/>")
    slotind = EI:CreateComponent(emptySlot.jS, "<center><h2 class='slotind'>Slot " .. tostring(numberCharacters + 1) .."</h2></center>")
    createbtn = EI:CreateComponent(emptySlot.jS, "<button class='btn-fully'>Create a new one</button>")
    createbtn.setAttribute("clickCB", function()
      HidePedSelector(ActualUI, {true, true})
      ActualUI = registerPedForm()
      EI:showComponent(ActualUI, {true, true})
    end)
    emptySlotComponent = {emptySlot, slotind, createbtn}
  end

  for i = 1, #emptySlotComponent do
    table.insert(choicePickerUI, emptySlotComponent[i])
  end
  return choicePickerUI

end
RegisterNetEvent("es:choicePicker")
AddEventHandler("es:choicePicker", function(_characters, _numberCharacters, _maxNumbChars)
  characters = _characters
  maxNumbChars = _maxNumbChars
  numberCharacters = _numberCharacters
  EI:hideComponent(ActualUI, {false, false})
  ActualUI = selectPedForm()
  EI:showComponent(ActualUI, {true, true})
end)
function HidePedSelector(groupeComponent)-- ActualUI should close the actuel ui
  EI:hideComponent(groupeComponent, {false, false})
  groupeComponent = {}
end

-- Events Nearby car & nearby Veh
AddEventHandler('GetPedNearbyVehicles', function(ped, sizeAndVehs, cb)
	local value = IzioGetPedNearbyVehicles(ped, sizeAndVehs)
	cb(value)
end)

AddEventHandler('GetPedNearbyVehicles', function(ped, ignore, cb)
	local value = IzioGetPedNearbyPeds(ped, ignore)
	cb(value)
end)


function IzioGetPedNearbyVehicles(ped, sizeAndVehs)
    return _in(0xCFF869CBFA210D82, ped, _ii(sizeAndVehs) --[[ may be optional ]], _r, _ri)
end

function IzioGetPedNearbyPeds(ped, ignore)
    return _in(0x23F8F5FC7E8C4A6B, ped, _i, ignore, _r, _ri)
end
