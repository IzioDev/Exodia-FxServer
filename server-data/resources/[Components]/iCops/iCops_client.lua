-- Copyright (C) Izio, Inc - All Rights Reserved
-- Unauthorized copying of this file, via any medium is strictly prohibited
-- Proprietary and confidential
-- Written by Romain Billot <romainbillot3009@gmail.com>, Jully 2017

local userRank = nil 
local userJob = nil
local isInService = true
local isDragged = false
local isHandCuffed = false
local currentMenu = nil
local active = false
local gaveWeapons = false
local officerDrag = nil
local subButtonList = { 
	["annimations"] = {
		title = "Annimations",
		name = "annimations",
		buttons = {
			{name = "Faire la circulation", targetFunction = "PlayEmote", targetArrayParam = "circulation" },
			{name = "Prendre des notes", targetFunction = "PlayEmote", targetArrayParam = "note" },
			{name = "Repos", targetFunction = "PlayEmote", targetArrayParam = "repos" },
			{name = "Repos 2", targetFunction = "PlayEmote", targetArrayParam = "repos2" },
			{name = "Annuler emote", targetFunction = "PlayEmote", targetArrayParam = "stop" }
		}
	},
	["citoyens"] = {
		title = "Citoyens",
		name = "citoyens",
		buttons = {
			{name = "Carte d'identité", targetFunction = "ShowId", targetArrayParam = {} },
			{name = "Fouiller", targetFunction = "Search", targetArrayParam = {} },
			{name = "(Dé)Menotter", targetFunction = "Cuff", targetArrayParam = {} },
			{name = "Confisquer les armes [WIP]", targetFunction = "TakeWeapon", targetArrayParam = {} },
			{name = "Mettre dans le véhicule", targetFunction = "PutIntoVeh", targetArrayParam = {} },
			{name = "Faire sortir du véhicule", targetFunction = "UnputFromVeh", targetArrayParam = {} },
			{name = "Escorter le joueur", targetFunction = "EscortPlayer", targetArrayParam = {} },
			{name = "Amendes", targetFunction = "Fines", targetArrayParam = {} },
			{name = "Mettre en prison [WIP]", targetFunction = "Jail", targetArrayParam = {} }
		}
	},
	["vehicle"] = {
		title = "Véhicules",
		name = "vehicle",
		buttons = {
			{name = "Crocheter le véhicule", targetFunction = "ForceVeh", targetArrayParam = {} }
		}
	}
}
local mainButtonList = { 
	["main"] = {
		title = "Actions",
		name = "main",
		buttons = {
			{name = "Annimations", targetFunction = "OpenMenu", targetArrayParam = subButtonList["annimations"] },
			{name = "Citoyens", targetFunction = "OpenMenu", targetArrayParam = subButtonList["citoyens"] },
			{name = "Véhicules", targetFunction = "OpenMenu", targetArrayParam = subButtonList["vehicle"] },
			{name = "Fermer le menu", targetFunction = "CloseMenu", targetArrayParam = {}}
		}
	},
}

AddEventHandler("is:updateJob", function(jobName, rank)
	userJob = jobName
	userRank = rank

	if (userJob == "LSPD" or userJob == "LSSD") and not(active) then
		active = true
		RunCopThread()
	else
		active = false
	end
end)

function RunCopThread()
	Citizen.CreateThread(function() -- Thread Cop
		while true do
			Wait(15)
			if not(active) then
				return
			end
			if IsControlJustPressed(1, 288) and isInService then -- partie menu
				if IsPedInAnyVehicle(GetPlayerPed(-1), false) then -- alors UI check
					local actualVeh = GetVehiclePedIsIn(GetPlayerPed(-1), false)
					local a,b = string.find(GetVehicleNumberPlateText(actualVeh), "PO")
					if a then
						-- On peut ouvrir le menu HTML
					end
				else -- Sinon menu action
					Menu.hidden = not(Menu.hidden)
					if not(Menu.hidden) then
						OpenMenu(mainButtonList["main"])
					end
				end
			elseif IsControlJustPressed(1, 177) and currentMenu ~= nil then
				if currentMenu == "main" then
					CloseMenu()
				else
					OpenMenu(mainButtonList["main"])
				end
			end
			TriggerEvent("izone:getResultFromPlayerInAnyJobZone", userJob, function(result)
				if result ~= nil then
					if result.service then
						if isInService then
							DisplayHelpText("Appuyez sur ~INPUT_CONTEXT~ pour " ..result.displayedMessageInZone.leave)
						else
							DisplayHelpText("Appuyez sur ~INPUT_CONTEXT~ pour " ..result.displayedMessageInZone.take)
						end
						if IsControlJustPressed(1, 38) then
							TriggerEvent("police:swichService", isInService, result)
						end
					end
					if result.armurerie then
						if isInService then
							if not(gaveWeapons) then
								DisplayHelpText("Appuyez sur ~INPUT_CONTEXT~ pour " ..result.displayedMessageInZone.leave)
								if IsControlJustPressed(1, 38) then -- result.arme[userRank] = array(weaponsHash)
									TriggerEvent("police:depositArmurerie", result)
								end
							end
						else
							if gaveWeapons then
								DisplayHelpText("Appuyez sur ~INPUT_CONTEXT~ pour " ..result.displayedMessageInZone.take)
								if IsControlJustPressed(1, 38) then
									TriggerEvent("police:retrieveArmurerie")
								end
							end
						end
					end
				end
			end)
		end
	end)
end

Citizen.CreateThread(function()
	while true do
		Wait(0)
		if not(Menu.hidden) then
			Menu.renderGUI()
		end
		if not(Menu.hidden) and not(isInService) then
			CloseMenu("OSEF")
		end
	end
end)

AddEventHandler("police:swichService", function(service, result)
	if service then
		TriggerServerEvent("skin:retrieveOnExitMenu")
		isInService = false
	else
		local Sexe = "Female"
		if (GetEntityModel(GetPlayerPed(-1)) == GetHashKey("mp_m_freemode_01")) then
			Sexe = "Male"
		end
		SetPedComponentVariation(GetPlayerPed(-1), 9, result.uniform[userRank][Sexe].diff, result.uniform[userRank][Sexe].diffColor, 2)
		SetPedComponentVariation(GetPlayerPed(-1), 8,  result.uniform[userRank][Sexe].tshirt_1, result.uniform[userRank][Sexe].tshirt_2, 2)   -- Tshirt
		SetPedComponentVariation(GetPlayerPed(-1), 11, result.uniform[userRank][Sexe].torso_1, result.uniform[userRank][Sexe].torso_2, 2)     -- torso parts
		SetPedComponentVariation(GetPlayerPed(-1), 10, result.uniform[userRank][Sexe].decals_1, result.uniform[userRank][Sexe].decals_2, 2)   -- decals
		SetPedComponentVariation(GetPlayerPed(-1), 4, result.uniform[userRank][Sexe].pants_1, result.uniform[userRank][Sexe].pants_2, 2)      -- pants
		SetPedComponentVariation(GetPlayerPed(-1), 6, result.uniform[userRank][Sexe].shoes, result.uniform[userRank][Sexe].shoes_2, 2)  	  -- Shoes
		SetPedPropIndex(GetPlayerPed(-1), 1, result.uniform[userRank][Sexe].glasses_1, 0, 2)
		isInService = true
	end
	if isInService then
		TriggerEvent("pNotify:notifyFromServer", "Vous venez de prendre votre service", "success", "topCenter", true, 3500)
	else
		TriggerEvent("pNotify:notifyFromServer", "Vous venez de quitter votre service", "error", "topCenter", true, 3500)
	end
	-- TriggerServerEvent("", isInService)
end)

AddEventHandler("police:depositArmurerie", function(result)
	TriggerServerEvent("police:armurerieToServer", result)
end)

AddEventHandler("police:retrieveArmurerie", function()
	TriggerServerEvent("police:retrieveArmurerieToServer")
end)

RegisterNetEvent("police:returnFromServerRetreiving")
AddEventHandler("police:returnFromServerRetreiving", function()
	gaveWeapons = false
end)

RegisterNetEvent("icops:giveServiceWeapons")
AddEventHandler("icops:giveServiceWeapons", function(result)
	gaveWeapons = true
	for i = 1, #result.weapons[userJob][userRank] do
		print(json.encode(result.weapons[userJob]))
		GiveWeaponToPed(GetPlayerPed(-1), GetHashKey(result.weapons[userJob][userRank][i]), 500, false, false)
	end
end)

Citizen.CreateThread(function() -- Thread Civil
	SetPoliceIgnorePlayer(PlayerId(), true)
	SetDispatchCopsForPlayer(PlayerId(), false)
	Citizen.InvokeNative(0xDC0F817884CDD856, 1, false)
	Citizen.InvokeNative(0xDC0F817884CDD856, 2, false)
	Citizen.InvokeNative(0xDC0F817884CDD856, 3, false)
	Citizen.InvokeNative(0xDC0F817884CDD856, 5, false)
	Citizen.InvokeNative(0xDC0F817884CDD856, 8, false)
	Citizen.InvokeNative(0xDC0F817884CDD856, 9, false)
	Citizen.InvokeNative(0xDC0F817884CDD856, 10, false)
	Citizen.InvokeNative(0xDC0F817884CDD856, 11, false)
	while true do
		Wait(0)

		if (isHandCuffed) then
			RequestAnimDict('mp_arresting')

			while not HasAnimDictLoaded('mp_arresting') do
				Citizen.Wait(0)
			end

			local myPed = PlayerPedId(-1)
			local animation = 'idle'
			local flags = 16
			
			while(IsPedBeingStunned(myPed, 0)) do
				ClearPedTasksImmediately(myPed)
			end
			TaskPlayAnim(myPed, 'mp_arresting', animation, 8.0, -8, -1, flags, 0, 0, 0, 0)
		end
	end
	if (isDragged) then
		local ped = GetPlayerPed(GetPlayerFromServerId(officerDrag))
		local myPed = GetPlayerPed(-1)
		AttachEntityToEntity(myPed, ped, 4103, 11816, 0.48, 0.00, 0.0, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
	else
		DetachEntity(GetPlayerPed(-1), true, false)		
	end
end)

function DisplayHelpText(str)
	SetTextComponentFormat("STRING")
	AddTextComponentString(str)
	DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end

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

function PlayEmote(annimName)
	local params = {}
	if annimName == "stop" then
		ClearPedTasksImmediately(GetPlayerPed(-1))
		return
	elseif annimName == "circulation" then
		table.insert(params, "WORLD_HUMAN_CAR_PARK_ATTENDANT")
		table.insert(params, false)
		table.insert(params, 60000)
	elseif annimName == "note" then
		table.insert(params, "WORLD_HUMAN_CLIPBOARD")
		table.insert(params, false)
		table.insert(params, 20000)
	elseif annimName == "repos" then
		table.insert(params, "WORLD_HUMAN_COP_IDLES")
		table.insert(params, true)
		table.insert(params, 20000)
	elseif annimName == "repos2" then
		table.insert(params, "WORLD_HUMAN_GUARD_STAND")
		table.insert(params, true)
		table.insert(params, 20000)
	end

	Citizen.CreateThread(function()
		TaskStartScenarioInPlace(GetPlayerPed(-1), params[1], 0, params[2])
        Citizen.Wait(params[3])
        ClearPedTasksImmediately(GetPlayerPed(-1))
	end)

end

function ShowId()
	local t, distance = GetClosestPlayer()
	if(distance ~= -1 and distance < 3) then
		TriggerServerEvent("police:checkId", GetPlayerServerId(t), false)
		print("test")
	else
		TriggerEvent("pNotify:notifyFromServer", "Il n'y a personne à proximité. Tu ne peux pas faire cette action.", "error", "topCenter", true, 5000)
	end
end

function Search()
	local t, distance = GetClosestPlayer()
	if(distance ~= -1 and distance < 3) then
		TriggerServerEvent("police:targetCheckInventory", GetPlayerServerId(t), false)
	else
		TriggerEvent("pNotify:notifyFromServer", "Il n'y a personne à proximité. Tu ne peux pas faire cette action.", "error", "topCenter", true, 5000)
	end
end

function Cuff()
	local t, distance = GetClosestPlayer()
	if(distance ~= -1 and distance < 3) then
		TriggerServerEvent("police:cuffPlayer", GetPlayerServerId(t))
	else
		TriggerEvent("pNotify:notifyFromServer", "Il n'y a personne à proximité. Tu ne peux pas faire cette action.", "error", "topCenter", true, 5000)
	end
end

-- function TakeWeapon() -- TO SEE

-- end

function PutIntoVeh()
	local t, distance = GetClosestPlayer()
	if(distance ~= -1 and distance < 3) then
		TriggerServerEvent("police:setPlayerIntoVeh", GetPlayerServerId(t))
	else
		TriggerEvent("pNotify:notifyFromServer", "Il n'y a personne à proximité. Tu ne peux pas faire cette action.", "error", "topCenter", true, 5000)
	end
end

function UnputFromVeh()
	local t, distance = GetClosestPlayer()
	if(distance ~= -1 and distance < 3) then
		TriggerServerEvent("police:unSetPlayerIntoVeh", GetPlayerServerId(t))
	else
		TriggerEvent("pNotify:notifyFromServer", "Il n'y a personne à proximité. Tu ne peux pas faire cette action.", "error", "topCenter", true, 5000)
	end
end

function EscortPlayer()
	local t, distance = GetClosestPlayer()
	if(distance ~= -1 and distance < 3) then
		TriggerServerEvent("police:dragRequest", GetPlayerServerId(t), isDragged)
	else
		TriggerEvent("pNotify:notifyFromServer", "Il n'y a personne à proximité. Tu ne peux pas faire cette action.", "error", "topCenter", true, 5000)
	end
end

function Fines()
	local t, distance = GetClosestPlayer()
	if(distance ~= -1 and distance < 3) then
		local editing = true
		local resultat = nil
		DisplayOnscreenKeyboard(true, "FMMC_KEY_TIP8", "", "", "amount", "", "", 120)
		while editing do
			Wait(0)
			if UpdateOnscreenKeyboard() == 2 then 
				editing = false
			end
			if UpdateOnscreenKeyboard() == 1 then
				editing = false
				resultat = GetOnscreenKeyboardResult()
			end
		end
		if resultat == nil then
			TriggerEvent("pNotify:notifyFromServer", "Tu viens d'annuler l'amande.", "error", "topCenter", true, 5000)
		else
			resultat = tonumber(resultat)
			TriggerServerEvent("police:setFineToPlayer", GetPlayerServerId(t), resultat)
		end
		-- TriggerServerEvent("police:unSetPlayerIntoVeh", GetPlayerServerId(t))
	else
		TriggerEvent("pNotify:notifyFromServer", "Il n'y a personne à proximité. Tu ne peux pas faire cette action.", "error", "topCenter", true, 5000)
	end
end

function Jail()

end

function ForceVeh()
	Citizen.CreateThread(function()
		local pos = GetEntityCoords(GetPlayerPed(-1))
		local entityWorld = GetOffsetFromEntityInWorldCoords(GetPlayerPed(-1), 0.0, 20.0, 0.0)

		local rayHandle = CastRayPointToPoint(pos.x, pos.y, pos.z, entityWorld.x, entityWorld.y, entityWorld.z, 10, GetPlayerPed(-1), 0)
		local _, _, _, _, vehicleHandle = GetRaycastResult(rayHandle)
		if(DoesEntityExist(vehicleHandle)) then
			local prevObj = GetClosestObjectOfType(pos.x, pos.y, pos.z, 10.0, GetHashKey("prop_weld_torch"), false, true, true)
			if(IsEntityAnObject(prevObj)) then
				SetEntityAsMissionEntity(prevObj)
				DeleteObject(prevObj)
			end
			TaskStartScenarioInPlace(GetPlayerPed(-1), "WORLD_HUMAN_WELDING", 0, true)
			Citizen.Wait(20000)
			SetVehicleDoorsLocked(vehicleHandle, 1)
			ClearPedTasksImmediately(GetPlayerPed(-1))
			TriggerEvent("pNotify:notifyFromServer", "Tu viens de crochetter la voiture.", "error", "topCenter", true, 5000)
		else
			TriggerEvent("pNotify:notifyFromServer", "Il n'y a pas de voiture à proximité. Tu ne peux pas faire cette action.", "error", "topCenter", true, 5000)
		end
	end)
end

function GetPlayers()
    local players = {}

    for i = 0, 31 do
        if NetworkIsPlayerActive(i) then
            table.insert(players, i)
        end
    end

    return players
end

function GetClosestPlayer()
	local players = GetPlayers()
	local closestDistance = -1
	local closestPlayer = -1
	local ply = GetPlayerPed(-1)
	local plyCoords = GetEntityCoords(ply, 0)
	
	for index,value in ipairs(players) do
		local target = GetPlayerPed(value)
		if(target ~= ply) then
			local targetCoords = GetEntityCoords(GetPlayerPed(value), 0)
			local distance = Vdist(targetCoords["x"], targetCoords["y"], targetCoords["z"], plyCoords["x"], plyCoords["y"], plyCoords["z"])
			if(closestDistance == -1 or closestDistance > distance) then
				closestPlayer = value
				closestDistance = distance
			end
		end
	end
	
	return closestPlayer, closestDistance
end

RegisterNetEvent("police:coffPlayerReturnFromServer")
AddEventHandler("police:coffPlayerReturnFromServer", function(bool)
	isHandCuffed = bool
end)

RegisterNetEvent("police:checkId")
AddEventHandler("police:checkId", function(officerPsid)
	Citizen.CreateThread(function()
		local actualTime = GetGameTimer()
		while GetGameTimer() < actualTime + 10000 do
			Wait(0)
			if IsControlJustPressed(1, 246) then
				TriggerEvent("pNotify:notifyFromServer", "Tu viens de donner ta carte d'identité à l'agent de police.", "error", "topCenter", true, 5000)
				TriggerServerEvent("police:accptedToGiveCard", officerPsid)
				return
			elseif IsControlJustPressed(1, 245) then
				TriggerEvent("pNotify:notifyFromServer", "Tu as refusé de donner ta carte d'identité à l'agent de police.", "error", "topCenter", true, 5000)
				TriggerServerEvent("police:refusedToGiveCard", officerPsid)
				return
			end
		end
		TriggerEvent("pNotify:notifyFromServer", "Tu as refusé de donner ta carte d'identité à l'agent de police.", "error", "topCenter", true, 5000)
		TriggerServerEvent("police:refusedToGiveCard", officerPsid)
	end)
end)

RegisterNetEvent("police:checkInventory")
AddEventHandler("police:checkInventory", function(officerPsid)
	Citizen.CreateThread(function()
		local actualTime = GetGameTimer()
		while GetGameTimer() < actualTime + 10000 do
			Wait(0)
			if IsControlJustPressed(1, 246) then
				TriggerEvent("pNotify:notifyFromServer", "Tu viens es en train de montrer tes poches à l'agent de police.", "error", "topCenter", true, 5000)
				TriggerServerEvent("police:acceptedToShowPoached", officerPsid)
				return
			elseif IsControlJustPressed(1, 245) then
				TriggerEvent("pNotify:notifyFromServer", "Tu as refusé de montrer tes poches à l'agent de police.", "error", "topCenter", true, 5000)
				TriggerServerEvent("police:refusedToShowPoached", officerPsid)
				return
			end
		end
		TriggerEvent("pNotify:notifyFromServer", "Tu as refusé de montrer tes poches à l'agent de police.", "error", "topCenter", true, 5000)
		TriggerServerEvent("police:refusedToShowPoached", officerPsid)
	end)
end)

RegisterNetEvent('police:forcedEnteringVeh')
AddEventHandler('police:forcedEnteringVeh', function()
	if(isHandCuffed) then
		local pos = GetEntityCoords(GetPlayerPed(-1))
		local entityWorld = GetOffsetFromEntityInWorldCoords(GetPlayerPed(-1), 0.0, 20.0, 0.0)

		local rayHandle = CastRayPointToPoint(pos.x, pos.y, pos.z, entityWorld.x, entityWorld.y, entityWorld.z, 10, GetPlayerPed(-1), 0)
		local _, _, _, _, vehicleHandle = GetRaycastResult(rayHandle)

		if vehicleHandle ~= nil then
			SetPedIntoVehicle(GetPlayerPed(-1), vehicleHandle, 1)
		end
	end
end)

RegisterNetEvent('police:forcedLeavingVeh')
AddEventHandler('police:forcedLeavingVeh', function()
	local ped = GetPlayerPed(-1) 
	ClearPedTasksImmediately(ped)
	plyPos = GetEntityCoords(GetPlayerPed(-1),  true)
	local xnew = plyPos.x+2
	local ynew = plyPos.y+2
	SetEntityCoords(GetPlayerPed(-1), xnew, ynew, plyPos.z)
end)

RegisterNetEvent("police:dragAnswer")
AddEventHandler("police:dragAnswer", function(officerPsid)
	isDragged = not(isDragged)
	officerDrag = t
end)
