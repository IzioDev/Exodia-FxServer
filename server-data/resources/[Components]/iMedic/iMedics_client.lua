-- Copyright (C) Izio, Inc - All Rights Reserved
-- Unauthorized copying of this file, via any medium is strictly prohibited
-- Proprietary and confidential
-- Written by Romain Billot <romainbillot3009@gmail.com>, Jully 2017
local userRank = nil 
local userJob = nil
local isInService = false
local isDragged = false
local currentMenu = nil
local active = false
local gaveWeapons = false
local medicDrag = nil
local currentVeh = nil
local timeVeh = nil
-- local subButtonList = { 
-- 	["annimations"] = {
-- 		title = "Annimations",
-- 		name = "annimations",
-- 		buttons = {
-- 			{name = "Vous allez bien?", targetFunction = "PlayEmote", targetArrayParam = "circulation" },
-- 			{name = "Prendre des notes", targetFunction = "PlayEmote", targetArrayParam = "note" },
-- 			{name = "Sur les genouts", targetFunction = "PlayEmote", targetArrayParam = "medic:kneel" }, -- medic:kneel medic:tendtodeath medic:timeofdeath
-- 			{name = "Tend to Death", targetFunction = "PlayEmote", targetArrayParam = "medic:tendtodeath" },
-- 			{name = "Time of death", targetFunction = "PlayEmote", targetArrayParam = "medic:timeofdeath" } -- AddEventHandler("anim:Play", function(name)
-- 		}
-- 	},
-- 	["citoyens"] = {
-- 		title = "Citoyens",
-- 		name = "citoyens",
-- 		buttons = {
-- 			{name = "Carte d'identité", targetFunction = "ShowId", targetArrayParam = {} },
-- 			{name = "Mettre dans le véhicule", targetFunction = "PutIntoVeh", targetArrayParam = {} },
-- 			{name = "Faire sortir du véhicule", targetFunction = "UnputFromVeh", targetArrayParam = {} },
-- 			{name = "Escorter le joueur", targetFunction = "EscortPlayer", targetArrayParam = {} },
-- 			{name = "Premier soin", targetFunction = "firstAid", targetArrayParam = {}}
-- 		}
-- 	}
-- }
-- local mainButtonList = { 
-- 	["main"] = {
-- 		title = "Actions",
-- 		name = "main",
-- 		buttons = {
-- 			{name = "Annimations", targetFunction = "OpenMenu", targetArrayParam = subButtonList["annimations"] },
-- 			{name = "Citoyens", targetFunction = "OpenMenu", targetArrayParam = subButtonList["citoyens"] },
-- 			{name = "Fermer le menu", targetFunction = "CloseMenu", targetArrayParam = {}}
-- 		}
-- 	},
-- }

AddEventHandler("is:updateJob", function(jobName, rank)
	userJob = jobName
	userRank = rank
	print(userJob)
	print(tostring(userJob == "médecin"))
	if (userJob == "médecin") and not(active) then
		active = true
		RunMedicThread()
	else
		active = false
	end
end)

function RunMedicThread()
	Citizen.CreateThread(function() -- Thread Cop
		while true do
			Wait(15)
			if not(active) then
				return
			end
			if IsControlJustPressed(1, 288) and isInService then -- partie menu
				if IsPedInAnyVehicle(GetPlayerPed(-1), false) then -- alors UI check
					local actualVeh = GetVehiclePedIsIn(GetPlayerPed(-1), false)
					local a,b = string.find(GetVehicleNumberPlateText(actualVeh), "ME")
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
							TriggerEvent("imedic:swichService", isInService, result)
						end

					elseif result.garage then
						if isInService and not(IsPedInAnyVehicle(GetPlayerPed(-1), 0)) then
							if currentVeh == nil then
								if timeVeh == nil then
									DisplayHelpText("Appuyez sur ~INPUT_CONTEXT~ pour " ..result.displayedMessageInZone.noCurrentVeh)
									if IsControlJustPressed(1, 38) then
										print("first spawn")
										OpenGarage(result, currentVeh)
									end
								else
									DisplayHelpText("Appuyez sur ~INPUT_CONTEXT~ pour " ..result.displayedMessageInZone.noCurrentVeh)
									if GetGameTimer() >= timeVeh + 1800000 then -- 30 minutes
										if IsControlJustPressed(1, 38) then
											OpenGarage(result, currentVeh)
										end
									else
										if IsControlJustPressed(1, 38) then
											local time = (GetGameTimer()-timeVeh)/60000
											TriggerEvent("pNotify:notifyFromServer", "Tu as sorti un véhicule il y a: " .. math.ceil(time*10)/10 .. " minutes. </br> <center>Attends un peu.</center>", "error", "topCenter", true, 5000)
										end
									end
								end
							else
								DisplayHelpText("Appuyez sur ~INPUT_CONTEXT~ pour " ..result.displayedMessageInZone.currentVeh)
								if IsControlJustPressed(1, 38) then
									OpenGarage(result, currentVeh)
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

AddEventHandler("imedic:swichService", function(service, result)
	if service then
		TriggerServerEvent("skin:retrieveOnExitMenu")
		TriggerEvent("imedic:retrieveArmurerie", result)
		isInService = false
	else
		local Sexe = "Female"
		if (GetEntityModel(GetPlayerPed(-1)) == GetHashKey("mp_m_freemode_01")) then
			Sexe = "Male"
		end
		-- give uniform
		SetPedComponentVariation(GetPlayerPed(-1), 9, result.uniform[userRank][Sexe].diff, result.uniform[userRank][Sexe].diffColor, 2)
		SetPedComponentVariation(GetPlayerPed(-1), 8,  result.uniform[userRank][Sexe].tshirt_1, result.uniform[userRank][Sexe].tshirt_2, 2)   -- Tshirt
		SetPedComponentVariation(GetPlayerPed(-1), 11, result.uniform[userRank][Sexe].torso_1, result.uniform[userRank][Sexe].torso_2, 2)     -- torso parts
		SetPedComponentVariation(GetPlayerPed(-1), 10, result.uniform[userRank][Sexe].decals_1, result.uniform[userRank][Sexe].decals_2, 2)   -- decals
		SetPedComponentVariation(GetPlayerPed(-1), 4, result.uniform[userRank][Sexe].pants_1, result.uniform[userRank][Sexe].pants_2, 2)      -- pants
		SetPedComponentVariation(GetPlayerPed(-1), 6, result.uniform[userRank][Sexe].shoes, result.uniform[userRank][Sexe].shoes_2, 2)  	  -- Shoes
		SetPedPropIndex(GetPlayerPed(-1), 1, result.uniform[userRank][Sexe].glasses_1, 0, 2)

		-- take weapons
		TriggerEvent("imedic:depositArmurerie", result)

		-- change variable
		isInService = true
	end
	if isInService then
		TriggerEvent("pNotify:notifyFromServer", "Tu viens de déposer tes armes personnelles, prendre tes armes de sécurité et de prendre ton service.", "success", "topCenter", true, 3500)
	else
		TriggerEvent("pNotify:notifyFromServer", "Tu viens de déposer tes armes de service, récupérer tes armes personnelles et de quitter ton service.", "error", "topCenter", true, 3500)
	end
	-- TriggerServerEvent("", isInService)
end)

AddEventHandler("imedic:depositArmurerie", function(result)
	TriggerServerEvent("imedic:armurerieToServer", result)
end)

AddEventHandler("imedic:retrieveArmurerie", function()
	TriggerServerEvent("imedic:retrieveArmurerieToServer")
end)

RegisterNetEvent("imedic:giveServiceWeapons")
AddEventHandler("imedic:giveServiceWeapons", function(result)
	gaveWeapons = true
	for i = 1, #result.weapons[userRank] do
		GiveWeaponToPed(GetPlayerPed(-1), GetHashKey(result.weapons[userRank][i]), 500, false, false)
	end
end)

Citizen.CreateThread(function() -- Thread Civil
	while true do
		Wait(0)
		if (isDragged) then
			local ped = GetPlayerPed(GetPlayerFromServerId(officerDrag))
			local myPed = GetPlayerPed(-1)
			AttachEntityToEntity(myPed, ped, 4103, 11816, 0.48, 0.00, 0.0, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
		else
			DetachEntity(GetPlayerPed(-1), true, false)		
		end
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

function OpenGarage(result, currentVehi)
	if currentVehi == nil then
		ClearMenu()
		MenuTitle = "Garage " .. userRank
		this = result.carInfos[userRank]
		for i = 1, #this do
			Menu.addButton(this[i].name .. ":" .. this[i].price .. "$", "SpawnVeh", {point = result.spawnPoints, car = this[i].carHash, price = this[i].price})
		end
		Menu.hidden = false
		currentMenu = "main"
	else
		if DoesEntityExist(currentVehi) then
			local x,y,z = table.unpack(GetEntityCoords(currentVeh, true))
			TriggerEvent("izone:isPointInZone", x, y,"garageLspd", function(isVehInZone)
				if isVehInZone then
					Citizen.InvokeNative(0xEA386986E786A54F, Citizen.PointerValueIntInitialized(currentVeh))
					TriggerServerEvent("police:retreiveCaution")
					currentVeh = nil
					ClearMenu()
				else
					print("ton veh n'est pas dans le garage")
					TriggerEvent("pNotify:notifyFromServer", "Ton véhicule n'est pas dans le garage, merci de le rentrer.", "error", "topCenter", true, 5000)
				end
			end)
		else
			TriggerEvent("pNotify:notifyFromServer", "Contacter Izio iMedic_client.lua Entity doesn't exist.", "error", "topCenter", true, 5000)
			currentVeh = nil
			ClearMenu()
		end
	end
end

function SpawnVeh(args)
	local points = args.point
	local carHash = args.car
	local carPrice = args.price

	local car = tonumber(args.car)
	local playerPed = GetPlayerPed(-1)
	RequestModel(car)
	while not HasModelLoaded(car) do
			Citizen.Wait(0)
	end
	local playerCoords = GetEntityCoords(playerPed)
	local playerHeading = GetEntityHeading(playerPed)
	local closestVeh = nil
	local coords = playerCoords
	local medicVeh = nil
	for i = 1, #args.point do
		RequestCollisionAtCoord(args.point[i].x, args.point[i].y, args.point[i].z)
		closestVeh = GetClosestVehicle(x, y, z, 2.0, 0, 70)
		if closestVeh ~= nil then
			medicVeh = CreateVehicle(car, args.point[i].x, args.point[i].y, args.point[i].z, args.point[i].heading, true, false)
			break
		end
	end
	if medicVeh == nil then
		medicVeh = CreateVehicle(car, playerCoords, 90.0, true, false)
	end
	SetVehicleMod(medicVeh, 11, 2)
	SetVehicleMod(medicVeh, 12, 2)
	SetVehicleMod(medicVeh, 13, 2)
	SetVehicleEnginePowerMultiplier(medicVeh, 35.0)
	SetVehicleOnGroundProperly(medicVeh)
	SetVehicleHasBeenOwnedByPlayer(medicVeh,true)
	local netid = NetworkGetNetworkIdFromEntity(medicVeh)
	SetNetworkIdCanMigrate(netid, true)
	-- NetworkRegisterEntityAsNetworked(VehToNet(medicVeh))
	TaskWarpPedIntoVehicle(playerPed, medicVeh, -1)
	SetEntityInvincible(medicVeh, false)
	SetEntityAsMissionEntity(medicVeh, true, true)

	Menu.hidden = true
	TriggerServerEvent("police:spawnVehGarage", carPrice)
	currentVeh = medicVeh
	timeVeh = GetGameTimer()
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
	elseif annimName == "medic:kneel" then
		TriggerEvent("anim:Play", "medic:kneel")
		return
	elseif annimName == "medic:tendtodeath" then
		TriggerEvent("anim:Play", "medic:tendtodeath")
		return
	elseif annimName == "medic:timeofdeath" then
		TriggerEvent("anim:Play", "medic:timeofdeath")
		return
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
		TriggerServerEvent("imedic:checkId", GetPlayerServerId(t))
	else
		TriggerEvent("pNotify:notifyFromServer", "Il n'y a personne à proximité. Tu ne peux pas faire cette action.", "error", "topCenter", true, 5000)
	end
end

function PutIntoVeh()
	local t, distance = GetClosestPlayer()
	if(distance ~= -1 and distance < 3) then
		TriggerServerEvent("imedic:setPlayerIntoVeh", GetPlayerServerId(t))
	else
		TriggerEvent("pNotify:notifyFromServer", "Il n'y a personne à proximité. Tu ne peux pas faire cette action.", "error", "topCenter", true, 5000)
	end
end

function UnputFromVeh()
	local t, distance = GetClosestPlayer()
	if(distance ~= -1 and distance < 3) then
		TriggerServerEvent("imedic:unSetPlayerIntoVeh", GetPlayerServerId(t))
	else
		TriggerEvent("pNotify:notifyFromServer", "Il n'y a personne à proximité. Tu ne peux pas faire cette action.", "error", "topCenter", true, 5000)
	end
end

function EscortPlayer()
	local t, distance = GetClosestPlayer()
	if(distance ~= -1 and distance < 3) then
		TriggerServerEvent("imedic:dragRequest", GetPlayerServerId(t), isDragged)
	else
		TriggerEvent("pNotify:notifyFromServer", "Il n'y a personne à proximité. Tu ne peux pas faire cette action.", "error", "topCenter", true, 5000)
	end
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

RegisterNetEvent("imedic:checkId")
AddEventHandler("imedic:checkId", function(officerPsid)
	Citizen.CreateThread(function()
		local actualTime = GetGameTimer()
		while GetGameTimer() < actualTime + 10000 do
			Wait(0)
			if IsControlJustPressed(1, 246) then
				TriggerEvent("pNotify:notifyFromServer", "Tu viens de donner ta carte d'identité au médecin.", "error", "topCenter", true, 5000)
				TriggerServerEvent("imedic:accptedToGiveCard", officerPsid)
				return
			elseif IsControlJustPressed(1, 245) then
				TriggerEvent("pNotify:notifyFromServer", "Tu as refusé de donner ta carte d'identité au médecin.", "error", "topCenter", true, 5000)
				TriggerServerEvent("imedic:refusedToGiveCard", officerPsid)
				return
			end
		end
		TriggerEvent("pNotify:notifyFromServer", "Tu as refusé de donner ta carte d'identité au médecin.", "error", "topCenter", true, 5000)
		TriggerServerEvent("imedic:refusedToGiveCard", officerPsid)
	end)
end)

RegisterNetEvent('imedic:forcedEnteringVeh')
AddEventHandler('imedic:forcedEnteringVeh', function()
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

RegisterNetEvent('imedic:forcedLeavingVeh')
AddEventHandler('imedic:forcedLeavingVeh', function()
	local ped = GetPlayerPed(-1) 
	ClearPedTasksImmediately(ped)
	plyPos = GetEntityCoords(GetPlayerPed(-1),  true)
	local xnew = plyPos.x+2
	local ynew = plyPos.y+2
	SetEntityCoords(GetPlayerPed(-1), xnew, ynew, plyPos.z)
end)

RegisterNetEvent("imedic:dragAnswer")
AddEventHandler("imedic:dragAnswer", function(officerPsid)
	isDragged = not(isDragged)
	officerDrag = t
end)