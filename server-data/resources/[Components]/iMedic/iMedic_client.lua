-- Copyright (C) Izio, Inc - All Rights Reserved
-- Unauthorized copying of this file, via any medium is strictly prohibited
-- Proprietary and confidential
-- Written by Romain Billot <romainbillot3009@gmail.com>, Jully 2017
local userRank = nil 
local userJob = nil
local isInService = true
local isDragged = false
local currentMenu = nil
local active = false
local gaveWeapons = false
local medicDrag = nil
local currentVeh = nil
local vehFromGarage = nil
local timeVeh = nil
local callTaken = false
local launched = false

local function freezePlayer(id, freeze)
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

local subButtonList = { 
	["annimations"] = {
		title = "Annimations",
		name = "annimations",
		buttons = {
			{name = "Circulation", targetFunction = "PlayEmote", targetArrayParam = "circulation" },
			{name = "Prendre des notes", targetFunction = "PlayEmote", targetArrayParam = "note" },
			{name = "Sur les genouts", targetFunction = "PlayEmote", targetArrayParam = "medic:kneel" }, -- medic:kneel medic:tendtodeath medic:timeofdeath
			{name = "Tend to Death", targetFunction = "PlayEmote", targetArrayParam = "medic:tendtodeath" },
			{name = "Time of death", targetFunction = "PlayEmote", targetArrayParam = "medic:timeofdeath" }, -- AddEventHandler("anim:Play", function(name)
			{name = "Bouche à bouche", targetFunction = "PlayEmote", targetArrayParam = "medic:mouthtomouth" },
			{name = "Massage cardiaque", targetFunction = "PlayEmote", targetArrayParam = "medic:pumpchest" },
			{name = "Annuler emote", targetFunction = "PlayEmote", targetArrayParam = "stop" }
		}
	},
	["citoyens"] = {
		title = "Citoyens",
		name = "citoyens",
		buttons = {
			{name = "Carte d'identité", targetFunction = "ShowId", targetArrayParam = {} },
			{name = "Mettre dans le véhicule", targetFunction = "PutIntoVeh", targetArrayParam = {} },
			{name = "Faire sortir du véhicule", targetFunction = "UnputFromVeh", targetArrayParam = {} },
			{name = "Escorter le joueur", targetFunction = "EscortPlayer", targetArrayParam = {} },
			{name = "Premier soin", targetFunction = "firstAid", targetArrayParam = {}}
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
			{name = "Fermer le menu", targetFunction = "CloseMenu", targetArrayParam = {}}
		}
	},
}

AddEventHandler("is:updateJob", function(jobName, rank)
	userJob = jobName
	userRank = rank
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
					local xp, yp, zp = table.unpack(GetEntityCoords(GetPlayerPed(-1), true))
					if result.service and zp <= 28 then
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
						elseif not(isInService) and not(IsPedInAnyVehicle(GetPlayerPed(-1), 0)) then
							DisplayHelpText("Veuillez prendre votre service pour pouvoir interragir.")
						end
					elseif result.to then
						DisplayHelpText("Appuyez sur ~INPUT_CONTEXT~ pour "..result.displayedMessageInZone)
						if IsControlJustPressed(1, 38) then
							TriggerEvent("medic:tpToResult", result)
						end
					end
				end
			end)
		end
	end)
end

AddEventHandler("medic:tpToResult", function(result)
	RequestCollisionAtCoord(result.to.x, result.to.y, result.to.z)
		freezePlayer(PlayerId(), true)
		SetEntityCoords(GetPlayerPed(-1), result.to.x, result.to.y, result.to.z, 0, 0, 0, 0)
		SetEntityHeading(GetPlayerPed(-1), result.to.heading)
		while not HasCollisionLoadedAroundEntity(GetPlayerPed(-1)) do
            Citizen.Wait(0)
        end

        ShutdownLoadingScreen()

        DoScreenFadeIn(500)

        while IsScreenFadingIn() do
            Citizen.Wait(0)
        end
        freezePlayer(PlayerId(), false)
end)

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
		-- SetPedComponentVariation(GetPlayerPed(-1), 9, result.uniform[userRank][Sexe].diff, result.uniform[userRank][Sexe].diffColor, 2)
		-- SetPedComponentVariation(GetPlayerPed(-1), 8,  result.uniform[userRank][Sexe].tshirt_1, result.uniform[userRank][Sexe].tshirt_2, 2)   -- Tshirt
		-- SetPedComponentVariation(GetPlayerPed(-1), 11, result.uniform[userRank][Sexe].torso_1, result.uniform[userRank][Sexe].torso_2, 2)     -- torso parts
		-- SetPedComponentVariation(GetPlayerPed(-1), 10, result.uniform[userRank][Sexe].decals_1, result.uniform[userRank][Sexe].decals_2, 2)   -- decals
		-- SetPedComponentVariation(GetPlayerPed(-1), 4, result.uniform[userRank][Sexe].pants_1, result.uniform[userRank][Sexe].pants_2, 2)      -- pants
		-- SetPedComponentVariation(GetPlayerPed(-1), 6, result.uniform[userRank][Sexe].shoes, result.uniform[userRank][Sexe].shoes_2, 2)  	  -- Shoes
		-- SetPedPropIndex(GetPlayerPed(-1), 1, result.uniform[userRank][Sexe].glasses_1, 0, 2)

		SetPedComponentVariation(GetPlayerPed(-1), 11, 13, 3, 2)
		SetPedComponentVariation(GetPlayerPed(-1), 8, 15, 0, 2)
		SetPedComponentVariation(GetPlayerPed(-1), 4, 9, 3, 2)
		SetPedComponentVariation(GetPlayerPed(-1), 3, 92, 0, 2)
		SetPedComponentVariation(GetPlayerPed(-1), 6, 25, 0, 2)

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
	TriggerServerEvent("imedic:retrieveArmurerieToServer") -- -468.99,"y":-279.74,"z":35.70
end)

RegisterNetEvent("imedic:giveServiceWeapons")
AddEventHandler("imedic:giveServiceWeapons", function(result)
	gaveWeapons = true
	print(result.weapons)
	for i = 1, #result.armurerie[userRank] do
		GiveWeaponToPed(GetPlayerPed(-1), GetHashKey(result.armurerie[userRank][i]), 500, false, false)
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
		if #this == 0 then
			TriggerEvent("pNotify:notifyFromServer", "Vous n'avez pas la permission de faire cela.", "error", "topCenter", true, 5000)
			return
		end
		for i = 1, #this do
			Menu.addButton(this[i].name .. ":" .. this[i].price .. "$", "SpawnVeh", {point = result.spawnPoints, car = this[i].carHash, price = this[i].price})
		end
		vehFromGarage = result.nom
		Menu.hidden = false
		currentMenu = "main"
	else
		if DoesEntityExist(currentVehi) then
			local x,y,z = table.unpack(GetEntityCoords(currentVehi, true))
			TriggerEvent("izone:isPointInZone", x, y, vehFromGarage, function(isVehInZone)
				if isVehInZone then
					Citizen.InvokeNative(0xEA386986E786A54F, Citizen.PointerValueIntInitialized(currentVeh))
					if GetVehicleEngineHealth(currentVehi) >= 100 then
						TriggerServerEvent("police:retreiveCaution")
					else
						TriggerEvent("pNotify:notifyFromServer", "Ton véhicule de fonction est endommagé. La caution va etre salée.", "error", "topCenter", true, 5000)
					end
					currentVeh = nil
					ClearMenu()
				else
					print(GetVehicleEngineHealth(currentVehi))
					if GetVehicleEngineHealth(currentVehi) >= 100 then
						TriggerEvent("pNotify:notifyFromServer", "Ton véhicule n'est pas devant le garage d'où tu as prit le véhicule.", "error", "topCenter", true, 5000)
					else
						TriggerEvent("pNotify:notifyFromServer", "Ton véhicule de fonction est endommagé. La caution va etre salée.", "error", "topCenter", true, 5000)
					end
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
	SetVehicleDirtLevel(medicVeh, 0)
	local netid = NetworkGetNetworkIdFromEntity(medicVeh)
	SetNetworkIdCanMigrate(netid, true)
	-- NetworkRegisterEntityAsNetworked(VehToNet(medicVeh))
	TaskWarpPedIntoVehicle(playerPed, medicVeh, -1)
	SetEntityInvincible(medicVeh, false)
	SetEntityAsMissionEntity(medicVeh, true, true)
	local plateText = "ME".. math.random(100,999)
	local a, b, c = Generate3Char()
	plateText = plateText .. a .. b .. c
	SetVehicleNumberPlateText(medicVeh, plateText)

	Menu.hidden = true
	TriggerServerEvent("imedic:spawnVehGarage", carPrice)
	currentVeh = medicVeh
	timeVeh = GetGameTimer()
end

function Generate3Char()
	local a = math.random(1,26)
	local b = math.random(1,26)
	local c = math.random(1,26)
	local alphabet = {"A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"}
	return alphabet[a], alphabet[b], alphabet[c]
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
	elseif annimName == "medic:mouthtomouth" then
		TriggerEvent("anim:Play", "medic:mouthtomouth")
		return
	elseif annimName == "medic:pumpchest" then
		TriggerEvent("anim:Play", "medic:pumpchest")
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

AddEventHandler("playerDead", function()
	Citizen.CreateThread(function()
		TriggerServerEvent("iMedic:areMedicsConnected")
		StartScreenEffect("DeathFailOut", 0, 0)
		ShakeGameplayCam("DEATH_FAIL_IN_EFFECT_SHAKE", 1.0)
		local scaleform = RequestScaleformMovie("MP_BIG_MESSAGE_FREEMODE")
		while not(HasScaleformMovieLoaded(scaleform)) do
			Citizen.Wait(0)
		end
		PushScaleformMovieFunction(scaleform, "SHOW_SHARD_WASTED_MP_MESSAGE")
		BeginTextComponent("STRING")
		AddTextComponentString("Tu es gravement bléssé")
		EndTextComponent()
		PopScaleformMovieFunctionVoid()
		Citizen.Wait(500)
			while IsEntityDead(PlayerPedId()) do
		  		Citizen.Wait(0)
				DrawScaleformMovieFullscreen(scaleform, 255, 255, 255, 255)
		  	end
		StopScreenEffect("DeathFailOut")
	end)
end)

function ResPlayerInOneMinute()
	Citizen.CreateThread(function()
		exports.spawnmanager:setAutoSpawn(false)
		local nowTime = GetGameTimer()
		while GetGameTimer() <= nowTime + 60000 do
			Wait(0)
		end
		ResPlayer()
	end)
end

function ResPlayer()
	-- TriggerServerEvent('es_em:sv_removeMoney')
	-- TriggerServerEvent("item:reset")
	-- TriggerServerEvent("skin_customization:SpawnPlayer")
	-- RemoveAllPedWeapons(GetPlayerPed(-1),true)
	local x,y,z = table.unpack(GetEntityCoords(GetPlayerPed(-1), 1))
	TriggerServerEvent("iMedic:onRespawn", x, y, z)
end

RegisterNetEvent("iMedic:returnNearestHopital")
AddEventHandler("iMedic:returnNearestHopital", function(nearestHopital)
	NetworkResurrectLocalPlayer(nearestHopital.x, nearestHopital.y, nearestHopital.z, true, true, false)
	SetEntityHeading(GetPlayerPed(-1), nearestHopital.heading)
end)

RegisterNetEvent("iMedic:returnAreMedicsConnected")
AddEventHandler("iMedic:returnAreMedicsConnected", function(isMedics)
	exports.spawnmanager:setAutoSpawn(false)
	if not(isMedics) then
		ResPlayerInOneMinute()
	else
		Citizen.CreateThread(function()
			local nowTime = GetGameTimer()
			while GetGameTimer() <= nowTime + 600000 do
				Citizen.Wait(0)
				if IsControlJustPressed(1, 246) then
					TriggerServerEvent("iMedic:askAmbulance")
					return
				end
			end
			ResPlayer()
		end)
	end
end)

RegisterNetEvent("iMedic:actionCallWithoutFollow")
AddEventHandler("iMedic:actionCallWithoutFollow", function()
	ResPlayerInOneMinute()
end)

RegisterNetEvent("iMedic:returnRespawnThePlayerAfterAnnim")
AddEventHandler("iMedic:returnRespawnThePlayerAfterAnnim", function(askingCoords)
	ResPlayerHere(askingCoords)
end)

RegisterNetEvent("iMedic:commandAdmin")
AddEventHandler("iMedic:commandAdmin", function(askingCoords)
	ResPlayer(askingCoords)
end)

function ResPlayerHere(askingCoords)
	print(json.encode(askingCoords))
	NetworkResurrectLocalPlayer(askingCoords.x, askingCoords.y, askingCoords.z, true, true, false)
end

RegisterNetEvent("iMedic:askToMedicForAmbulance")
AddEventHandler("iMedic:askToMedicForAmbulance", function(askingSource, askingCoords)
	Citizen.CreateThread(function()
		callTaken = false
		TriggerEvent("pNotify:notifyFromServer", "Un citoyen est dans le coma et est en train d'appeler. Appuies sur Y pour y répondre.", "success", "topCenter", true, 15000)
		local nowTime = GetGameTimer()
		while GetGameTimer() <= nowTime + 15000 and not(callTaken) do
			Wait(0)
			if IsControlJustPressed(1, 246) then
				TriggerServerEvent("iMedic:callAmbulanceTaken", askingSource)
				StartAmulanceMission(askingSource, askingCoords)
				return
			end
		end
		if not(callTaken) then
			TriggerServerEvent("iMedic:callWithoutFollow", askingSource)
		end
		callTaken = false
	end)
end)

RegisterNetEvent("iMedic:returnCallTaken")
AddEventHandler("iMedic:returnCallTaken", function()
	callTaken = true
end)

function StartAmulanceMission(askingSource, askingCoords)
	Citizen.CreateThread(function()
		local blip = AddBlipForCoord(tonumber(askingCoords.x), tonumber(askingCoords.y), tonumber(askingCoords.z))
		SetBlipSprite(blip, 1)
		SetBlipColour(blip, 3)
		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString("Appel Médecin")
		EndTextCommandSetBlipName(blip)
		SetBlipAsShortRange(blip,true)
		SetBlipAsMissionCreatorBlip(blip,true)
		SetBlipRoute(blip, true)
		SetBlipRouteColour(blip, 38)
		local playerPed = GetPlayerFromServerId(askingSource)
		local playerDead = true
		local nowTime = GetGameTimer()
		while GetGameTimer() <= nowTime + 420000 and playerDead do -- timer en fonction de la distance.
			local x,y,z = table.unpack(GetEntityCoords(GetPlayerPed(-1), true))
			Wait(100)
			DisplayHelpText("Il te reste ".. math.ceil((nowTime + 420000 - GetGameTimer())/1000).. "secondes pour te rendre sur les lieux.")

			playerDead = IsEntityDead(playerPed)

			if GetDistanceBetweenCoords(askingCoords.x, askingCoords.y, askingCoords.z, x, y, z, true) <= 5.0 then
				SetBlipAsMissionCreatorBlip(blip, false)
				Citizen.InvokeNative(0x86A652570E5F25DD, Citizen.PointerValueIntInitialized(blip))
				FixPlayer(askingSource, askingCoords)
				return
			end
		end

		if GetGameTimer() >= nowTime + 420000 then
			-- on pourrait pénaliser le médecin
		elseif playerDead then
			-- le joueur est en vie
		end

	end)
end

function FixPlayer(askingSource, askingCoords)
	Citizen.CreateThread(function()
		while true do
			local x,y,z = table.unpack(GetEntityCoords(GetPlayerPed(-1), true))
			Wait(0)
			if GetDistanceBetweenCoords(askingCoords.x, askingCoords.y, askingCoords.z, x, y, z, true) <= 5.0 then
				DisplayHelpText("Appuies sur Y pour appliquer les premiers soins à la personne morte.")
				if IsControlJustPressed(1, 246) then
					TriggerServerEvent("iMedic:respawnThePlayer", askingSource)
					TaskStartScenarioInPlace(GetPlayerPed(-1), 'CODE_HUMAN_MEDIC_TEND_TO_DEAD', 0, true)
					Citizen.Wait(8000)
					ClearPedTasks(GetPlayerPed(-1))
        	    	TriggerServerEvent("iMedic:respawnThePlayerAfterAnnim", askingSource, askingCoords)
        	    	break
				end
			end
		end
	end)
end

local function PlayEmoteMedic(dict, name, flags, duration ,stop, loop, waitTimeUntilClear)
    if stop ~= 1 then
        ClearPedSecondaryTask(player)
        ClearPedTasks(player)

        local i = 0
        RequestAnimDict(dict)
        while not HasAnimDictLoaded(dict) and i < 500 do
            Wait(10)
            RequestAnimDict(dict)
            i = i+1
        end

        if HasAnimDictLoaded(dict) then
            TaskPlayAnim(player, dict , name, 2.0, 1, -1, flags, 0, 1, 1, 1)
        end

        Wait(0)

        if loop ~= 1 then
            while GetEntityAnimCurrentTime(player, dict, name) <= duration and IsEntityPlayingAnim(player, dict, name, 3) do
                Wait(0)
            end
            ClearPedTasks(player)
        else
            launched = true
            while GetEntityAnimCurrentTime(player, dict, name) <= duration and IsEntityPlayingAnim(player, dict , name, 3) and launched do
                Wait(0)
                 drawTxt("Appuyez sur ~g~E~s~ pour arrêter ~b~l'animation",0,1,0.5,0.8,0.6,255,255,255,255)
                if IsControlJustPressed(1, 38) then
                    StopAnimTask(player, dict, name, 1)
                    Citizen.CreateThread(function()
                        while true do
                            if waitTimeUntilClear == nil or waitTimeUntilClear == 0 then
                                Wait(2500)
                            else
                                waitingTime = (waitTimeUntilClear * 1000)
                                Wait(waitingTime)
                            end
                            ClearPedTasksImmediately(player)
                            break
                        end
                    end)
                end
            end
            launched = false
        end
    else
        ClearPedTasksImmediately(player)
    end
end

AddEventHandler("iMedic:respawnAnnim", function()
	PlayEmoteMedic("mini@cpr@char_a@cpr_str", "cpr_kol_idle", 0, 1, 0, 0)
    PlayEmoteMedic("mini@cpr@char_a@cpr_str", "cpr_kol_to_cpr", 0, 1, 0, 0)
    PlayEmoteMedic("mini@cpr@char_a@cpr_str", "cpr_pumpchest", 9, 1, 0, 1, 5.75)
end)