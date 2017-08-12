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

local DeliveryPoints = {
	{x = -561.57, y = -131.9, z = 38.44},
	{x = -1177.87, y = -891.3, z = 13.79},
	{x = -1081.96, y = -248.39, z = 37.77},
	{x = -1334.16, y = -338.77, z = 36.7},
	{x = -159.96, y = 128.54, z = 70.23},
	{x = -150.42, y = 123.2, z = 70.23},
	{x = -151.6, y = 293.61, z = 97.85},
	{x = -370.67, y = 277.29, z = 86.43},
	{x = -336.83, y = 207.75, z = 88.58},
	{x = -375.96, y = 378.8, z = 106.96},
	{x = -66.36, y = 490.82, z = 144.7},
	{x = -406.52, y = 566.56, z = 124.62},
	{x = -494.78, y = 739.13, z = 163.04},
	{x = -775.08, y = 876.16, z = 203.37},
	{x = -972.69, y = 753.01, z = 176.39},
	{x = -1254.3, y = 666.19, z = 142.84},
	{x = -1346.86, y = 561.51, z = 130.54},
	{x = -1372.26, y = 444.36, z = 105.86},
	{x = -350.68, y = -49.08, z = 49.04},
	{x = 195.47, y = -406.13, z = 45.26},
	{x = 49.05, y = -460.42, z = 96.35, pourboire = true},
	{x = -119.52, y = -612.68, z = 36.29},
	{x = -451.47, y = -893.33, z = 47.99},
	{x = 350.99, y = 172.85, z = 103.1},
	{x = 107.38, y = -1305.19, z = 28.77},
	{x = -242.69, y = -1995.46, z = 25.78},
	{x = -1161.97, y = -527.26, z = 32.59},
	{x = -1116.64, y = -502.85, z = 35.81},
	{x = 461.82, y = -717.28, z = 27.36},
	{x = 1388.64, y = -709.7, z = 67.18},
	{x = 1054.52, y = -1954.43, z = 31.02},
	{x = 941.22, y = -2142.82, z = 30.51},
	{x = -1206.35, y = -1554.54, z = 4.38}
}

local blipDelivery = {blipColor = 15, blipSprite = 24}
local blipService = {x = -1312.02,y = -1335.95, z = 4.66}

local pointQg = {x = 245.01, y = 369.01, z = 106.01, blipSprite = 34, blipColor = 2, blipName = "Point de livraison."}

local mainButtonList = { 
	["main"] = {
		title = "Livreur",
		buttons = {
			{name = "Démarer des livraisons", targetFunction = "StartLivery", targetArrayParam = {} },
			{name = "Afficher le point de livraison", targetFunction = "ShowQg", targetArrayParam = pointQg },
			{name = "Fermer le menu", targetFunction = "CloseMenu", targetArrayParam = {}}
		}
	},
}

AddEventHandler("is:updateJob", function(jobName, rank)
	userJob = jobName
	userRank = rank
	if (userJob == "livreur") and not(active) then
		print("test")
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
			Menu.renderGUI()
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

					if result.uniform then
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
	TriggerServerEvent("iLivery:GenerateNeeds", "mission")
end

RegisterNetEvent("iLivery:getItemInfosFromIdArray")
AddEventHandler("iLivery:getItemInfosFromIdArray", function(result, typeI)
	if typeI == "mission" then
		GenerateItem(result)
		local tstamp = os.date("*t", os.time())
    	local time = os.date(tstamp.year .. "-" .. tstamp.month .. "-" .. tstamp.day .. " " .. tstamp.hour .. ":" .. tstamp.min .. ":" .. tstamp.sec)
		TriggerEvent("gcPhone:receiveMessage", {
				transmitter = "Mon patron", 
				receiver = "test", 
				message = messageToSend, 
				isRead = , 
				owner = 0, 
				time = time
			})
	elseif typeI == "magasin" then
		LaunchMenu(result)
	end
end)

function GenerateItem(result)
	local MissionPoints = {}
	local nombrePoints = math.random(1, 8)
	for i =1, nombrePoints do
		local numberFood = math.random(1, 3)
		local foods = {}
		for j = 1, #numberFood do
			table.insert(foods, result[math.random(1, #result)])
		end
		table.insert(MissionPoints, {point = DeliveryPoints[math.random(1, #DeliveryPoints)], foods = foods})
	end
	return MissionPoints
end

function LaunchMenu(Items)
	ClearMenu()
	MenuTitle = "Magasin d outils"
	for i = 1, #Items do
		Menu.addButton(Items[i].name .. " : " .. Items[i].price.."$", "ItemsInfos", {Items,i})
	end
end

function ItemsInfos(Result)
	local choice = Result[2]
	print(choice)
	local Items = Result[1]
	ClearMenu()
	print(Items[choice])
	MenuTitle = Items[choice].name .. " pese " .. Items[choice].weight .. "g"
	Menu.addButton("Acheter pour "..Items[choice].price.."$", "BuyItem", Items[choice])
	Menu.addButton("Retour", "LaunchMenu", Items)
end

function BuyItem(item)
	TriggerServerEvent('inv:buyItemByItemId', item.id)
	Menu.hidden = not(Menu.hidden)
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
	Citizen.CreateThread(function()
		while GetGameTimer() <= nowTime + 420000 do -- timer en fonction de la distance.
			local x,y,z = table.unpack(GetEntityCoords(GetPlayerPed(-1), true))
			Wait(500)
			if GetDistanceBetweenCoords(pointQg.x, pointQg.y, pointQg.z, x, y, z, true) <= 5.0 then
				SetBlipAsMissionCreatorBlip(blip, false)
				Citizen.InvokeNative(0x86A652570E5F25DD, Citizen.PointerValueIntInitialized(blip))
				return
			end
		end
	end)
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
			Menu.addButton(this[i].name .. ":" .. this[i].price .. "$", "SpawnVeh", {point = result.spawnPoints, car = this[i].carHash, price = this[i].price, livery = this[i].livery})
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
	local deliveryVeh = nil
	for i = 1, #args.point do
		RequestCollisionAtCoord(args.point[i].x, args.point[i].y, args.point[i].z)
		closestVeh = GetClosestVehicle(x, y, z, 2.0, 0, 70)
		if closestVeh ~= nil then
			deliveryVeh = CreateVehicle(car, args.point[i].x, args.point[i].y, args.point[i].z, args.point[i].heading, true, false)
			break
		end
	end
	if deliveryVeh == nil then
		deliveryVeh = CreateVehicle(car, playerCoords, 90.0, true, false)
	end
	SetVehicleMod(deliveryVeh, 11, 2)
	SetVehicleMod(deliveryVeh, 12, 2)
	SetVehicleMod(deliveryVeh, 13, 2)
	SetVehicleEnginePowerMultiplier(deliveryVeh, 35.0)
	SetVehicleOnGroundProperly(deliveryVeh)
	SetVehicleHasBeenOwnedByPlayer(deliveryVeh,true)
	SetVehicleDirtLevel(deliveryVeh, 0)
	if args.livery then
		SetVehicleLivery(deliveryVeh, args.livery)
	end
	local netid = NetworkGetNetworkIdFromEntity(deliveryVeh)
	SetNetworkIdCanMigrate(netid, true)
	-- NetworkRegisterEntityAsNetworked(VehToNet(medicVeh)) NotWorking in this manifest ? 
	TaskWarpPedIntoVehicle(playerPed, deliveryVeh, -1)
	SetEntityAsMissionEntity(deliveryVeh, true, true)
	local plateText = "DE".. math.random(100,999)
	local a, b, c = Generate3Char()
	plateText = plateText .. a .. b .. c
	SetVehicleNumberPlateText(deliveryVeh, plateText)

	Menu.hidden = true
	CloseMenu("test")
	TriggerServerEvent("iLivreur:spawnVehGarage", carPrice)
	currentVeh = deliveryVeh
	timeVeh = GetGameTimer()
end

function Generate3Char()
	local a = math.random(1,26)
	local b = math.random(1,26)
	local c = math.random(1,26)
	local alphabet = {"A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"}
	return alphabet[a], alphabet[b], alphabet[c]
end