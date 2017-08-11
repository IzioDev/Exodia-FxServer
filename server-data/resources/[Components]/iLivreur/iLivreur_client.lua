-- Copyright (C) Izio, Inc - All Rights Reserved
-- Unauthorized copying of this file, via any medium is strictly prohibited
-- Proprietary and confidential
-- Written by Romain Billot <romainbillot3009@gmail.com>, Jully 2017
local userJob
local userRank
local active = false
local isInService = false
local qgDisplayed = false
local currentVeh = nil
local vehFromGarage = nil
local timeVeh = nil

local pointDelivery = {
	{x =, y=, z= }
}

local blipDelivery = {blipColor = , blipSprite = }

local pointQg = {x = , y = , z = , blipSprite = , blipColor = , blipName =}

local mainButtonList = { 
	["main"] = {
		title = "Livreur",
		buttons = {
			{name = "Démarer des livraisons", targetFunction = "StartLivery", targetArrayParam = {} },
			{name = "Afficher le QG", targetFunction = "ShowQg", targetArrayParam = pointQg },
			{name = "Fermer le menu", targetFunction = "CloseMenu", targetArrayParam = {}}
		}
	},
}

AddEventHandler("is:updateJob", function(jobName, rank)
	userJob = jobName
	userRank = rank
	print(userJob.. "from Polic")
	if (userJob == "livreur" and not(active) then
		active = true
		RunDeliveryThread()
	else
		active = false
	end
end)

function RunDeliveryThread()
	Citizen.CreateThread(function()
		while true do
			Wait(0)
			if not(Menu.hidden) and isInService then
				Menu.renderGUI()
				if IsPedInAnyVehicle(GetPlayerPed(-1), false) then
					CloseMenu("OSEF")
				end
			end
			if not(Menu.hidden) and not(isInService) then
				CloseMenu("OSEF")
			end
			TriggerEvent("izone:getResultFromPlayerInAnyJobZone", userJob, function(result)
				if result ~= nil then
					if result.garage then
						if isInService and not(IsPedInAnyVehicle(GetPlayerPed(-1), 0)) then
							if currentVeh == nil then
								if timeVeh == nil then
									DisplayHelpText("Appuyez sur ~INPUT_CONTEXT~ pour " ..result.displayedMessageInZone.noCurrentVeh)
									if IsControlJustPressed(1, 38) then
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
					end

					if result.service then
						if isInService then
							DisplayHelpText("Appuyez sur ~INPUT_CONTEXT~ pour " ..result.displayedMessageInZone.leave)
						else
							DisplayHelpText("Appuyez sur ~INPUT_CONTEXT~ pour " ..result.displayedMessageInZone.take)
						end
						if IsControlJustPressed(1, 38) then
							TriggerEvent("iLivreur:swichService", isInService, result)
						end
					end

					if result.approvisionnement then
						if isInService and Menu.hidden then
							DisplayHelpText("Appuyez sur ~INPUT_CONTEXT~ pour " ..result.displayedMessageInZone.haveService)

						else
							DisplayHelpText("Appuyez sur ~INPUT_CONTEXT~ pour " ..result.displayedMessageInZone.havntService)
						end
					end
				end
			end)
			if IsControlJustPressed(1, 288) then
				if not(IsPedInAnyVehicle(GetPlayerPed(-1), false)) then
					OpenMenu(mainButtonList["main"])
				end
			end
		end
	end)
end

function DisplayHelpText(str)
	SetTextComponentFormat("STRING")
	AddTextComponentString(str)
	DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end

AddEventHandler("iLivreur:swichService", function(inService, result)
	if inService then

	else

	end
	isInService = not(isInService)
end)

function OpenMenu(menu)
	ClearMenu()
	MenuTitle = menu.title
	for i = 1, #menu.buttons do
		Menu.addButton(menu.buttons[i].name, menu.buttons[i].targetFunction, menu.buttons[i].targetArrayParam)
	end
	Menu.hidden = false
end

function CloseMenu(fake)
	ClearMenu()
	Menu.hidden = true
	currentMenu = nil
end

function StartLivery(fake)

end

function ShowQg(pointQg)
	local blip = AddBlipForCoord(tonumber(pointQg.x), tonumber(pointQg.y), tonumber(pointQg.z))
	SetBlipSprite(blip, pointQg.blipSprite)
	SetBlipColour(blip, pointQg.blipColor)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString("QG Livreur")
	EndTextCommandSetBlipName(blip)
	SetBlipAsShortRange(blip,true)
	SetBlipAsMissionCreatorBlip(blip,true)
	SetBlipRoute(blip, true)
	SetBlipRouteColour(blip, pointQg.blipColor)
	local nowTime = GetGameTimer()
	while GetGameTimer() <= nowTime + 420000 do -- timer en fonction de la distance.
		local x,y,z = table.unpack(GetEntityCoords(GetPlayerPed(-1), true))
		Wait(500)
		if GetDistanceBetweenCoords(askingCoords.x, askingCoords.y, askingCoords.z, x, y, z, true) <= 5.0 then
			SetBlipAsMissionCreatorBlip(blip, false)
			Citizen.InvokeNative(0x86A652570E5F25DD, Citizen.PointerValueIntInitialized(blip))
			return
		end
	end
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
	-- NetworkRegisterEntityAsNetworked(VehToNet(medicVeh)) NotWorking in this manifest ? 
	TaskWarpPedIntoVehicle(playerPed, medicVeh, -1)
	SetEntityInvincible(medicVeh, false)
	SetEntityAsMissionEntity(medicVeh, true, true)
	local plateText = "ME".. math.random(100,999)
	local a, b, c = Generate3Char()
	plateText = plateText .. a .. b .. c
	SetVehicleNumberPlateText(medicVeh, plateText)

	Menu.hidden = true
	CloseMenu("test")
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