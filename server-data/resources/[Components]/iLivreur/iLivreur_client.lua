-- Copyright (C) Izio, Inc - All Rights Reserved
-- Unauthorized copying of this file, via any medium is strictly prohibited
-- Proprietary and confidential
-- Written by Romain Billot <romainbillot3009@gmail.com>, Jully 2017
local userJob
local userRank
local active = false
local isInService = true
local qgDisplayed = false
local currentVeh = nil
local vehFromGarage = nil
local timeVeh = nil
local missionStarted = false
local currentMenu = nil
local askCommande = false

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

local stockedMissionPoints = nil

local blipDelivery = {blipColor = 15, blipSprite = 24}
local blipService = {x = -1312.02,y = -1335.95, z = 4.66}

local pointQg = {x = 245.01, y = 369.01, z = 106.01, blipSprite = 34, blipColor = 2, blipName = "Point de livraison."}

local mainButtonList = { 
	["main"] = {
		title = "Livreur",
		buttons = {
			{name = "Démarer les livraisons", requirment = true, mission = false,targetFunction = "StartLivery", targetArrayParam = {1,2,6,7,8,9,10,11,14,18,19,20,21,22,24,25,26,27,28,29,31,32} },
			{name = "Passer commande (200$)", requirment = true, mission = true, Commande = false,targetFunction = "StartCommand", targetArrayParam = {} },
			{name = "Stopper les livraisons", requirment = true, mission = true,targetFunction = "StopLivery", targetArrayParam = {} },
			{name = "Afficher le point d'approvisionnement", targetFunction = "ShowQg", targetArrayParam = pointQg },
			{name = "Fermer le menu", targetFunction = "CloseMenu", targetArrayParam = {}}
		}
	},
}

AddEventHandler("is:updateJob", function(jobName, rank)
	userJob = jobName
	userRank = rank
	print(userJob)
	if (userJob == "livreur") and not(active) then
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
							DisplayHelpText("Appuyez sur ~INPUT_CONTEXT~ pour " ..result.displayMessageInZone.leave)
						else
							DisplayHelpText("Appuyez sur ~INPUT_CONTEXT~ pour " ..result.displayMessageInZone.take)
						end
						if IsControlJustPressed(1, 38) then
							TriggerEvent("iLivreur:swichService", isInService, result)
						end
					end

					if result.approvisionnement then
						if isInService then
							DisplayHelpText("Appuyez sur ~INPUT_CONTEXT~ pour accèder au " ..result.displayedMessageInZone)
							if IsControlJustPressed(1, 38) then
								ClearMenu()
								GetResultItemInfos(result.items)
							end
						else
							DisplayHelpText(result.messageHavntService)
						end
					end
				else
					if currentMenu == "magasin" and not(Menu.hidden) then
						ClearMenu()
						Menu.hidden = true
					end
				end
			end)
			if IsControlJustPressed(1, 288) then
				if not(IsPedInAnyVehicle(GetPlayerPed(-1), false)) then
					if Menu.hidden then
						OpenMenu(mainButtonList["main"])
					end
				end
			end
		end
	end)
end

function GetResultItemInfos(itemIdArray)
	TriggerServerEvent("iLivreur:getItemInfosFromIdArray", itemIdArray, "magasin")
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
		if menu.buttons[i].requirment then
			if (menu.buttons[i].mission == missionStarted) then
				if menu.buttons[i].Command then
					if menu.buttons[i].Command == askCommande then
						Menu.addButton(menu.buttons[i].name, menu.buttons[i].targetFunction, menu.buttons[i].targetArrayParam)
					end
				else
					Menu.addButton(menu.buttons[i].name, menu.buttons[i].targetFunction, menu.buttons[i].targetArrayParam)
				end
			end
		else
			Menu.addButton(menu.buttons[i].name, menu.buttons[i].targetFunction, menu.buttons[i].targetArrayParam)
		end
	end
	Menu.hidden = false
	currentMenu = "main"
end

function CloseMenu(fake)
	ClearMenu()
	Menu.hidden = true
	currentMenu = nil
end

function StartLivery(itemArray)
	TriggerServerEvent("iLivreur:getItemInfosFromIdArray", itemArray, "mission")
	Menu.hidden = true
end

function StopLivery(fake)
	missionStarted = false
	askCommande = false
	commandReady = false
	Menu.hidden = true
end

RegisterNetEvent("iLivery:getItemInfosFromIdArray")
AddEventHandler("iLivery:getItemInfosFromIdArray", function(result, typeI)
	if typeI == "mission" then
		local MissionPoints = GenerateItem(result)
		stockedMissionPoints = MissionPoints
		local messageToSend = GenerateMessage(MissionPoints)
		TriggerEvent("gcPhone:receiveMessage", {
				transmitter = "Mon patron", 
				receiver = "test", 
				message = messageToSend, 
				isRead = 0, 
				owner = 0, 
				time = "Bouge ton cul"
			})
		StartMission(MissionPoints)
	elseif typeI == "magasin" then
		LaunchMenu(result)
	end
end)

function StartCommand(osef)
	commandReady = false
	Menu.hidden = true
	askCommande = true
	Citizen.CreateThread(function()
		Citizen.Wait(math.random(6000,11500))
		TriggerEvent("gcPhone:receiveMessage", {
					transmitter = "Stagiaire", 
					receiver = "test", 
					message = "Je prépare ta commande.", 
					isRead = 0,
					owner = 0,
					time = "Bouge ton cul"
				})
		Citizen.Wait(math.random(30000, 50000))
		TriggerEvent("gcPhone:receiveMessage", {
					transmitter = "Stagiaire", 
					receiver = "test", 
					message = "Viens récupérer ta commande au point d'approvisionnement. C'est prêt.", 
					isRead = 0,
					owner = 0,
					time = "Bouge ton cul"
				})
		commandReady = true
		-- TriggerEvent("pNotify:notifyFromServer", "Viens récupérer ta commande au point d'approvisionnement.</br> <strong>Le stagiaire.</strong>", "success", "topCenter", true, 5000)
	end)
end

function StartMission(MissionPoints)
	Citizen.CreateThread(function()
		for i = 1, #MissionPoints do
			local blip = AddBlipForCoord(tonumber(MissionPoints[i].point.x), tonumber(MissionPoints[i].point.y), tonumber(MissionPoints[i].point.z))
			SetBlipSprite(blip, 280)
			SetBlipColour(blip, 4)
			BeginTextCommandSetBlipName("STRING")
			AddTextComponentString("Point" .. i)
			EndTextCommandSetBlipName(blip)
			SetBlipAsShortRange(blip,true)
			SetBlipAsMissionCreatorBlip(blip,true)
			SetBlipRoute(blip, true)
			SetBlipRouteColour(blip, 6)
			MissionPoints[i].blipId = blip 
		end
		TriggerEvent("pNotify:notifyFromServer", "Vas livrer les personnes aux points indiqués sur la carte, le plus rapide sera le mieux payé. </br> Tu as les indications de ton boss par SMS.", "success", "topCenter", true, 5000)
		missionStarted = true
		local MissionInfos = {time = GetGameTimer(), totalValue = GetTotalValue(MissionPoints), totalShortestDistance = GetShortestDistance(MissionPoints)[2], shortestTravel = GetShortestDistance(MissionPoints)[1]}
		print("shortest distance : " .. MissionInfos.totalShortestDistance)
		while missionStarted and LeftMission(MissionPoints) ~= 0 do
			Wait(200)
			local x,y,z = table.unpack(GetEntityCoords(GetPlayerPed(-1), true))
			for i = 1, #MissionPoints do
				if not(MissionPoints[i].isDone) then
					if GetDistanceBetweenCoords(x, y, z, MissionPoints[i].point.x, MissionPoints[i].point.y, MissionPoints[i].point.z, true) <= 3.0 then
						if GotTheseItems(MissionPoints[i].foods) then
							local messageToPrint = GetMessageForOneMissionPoints(MissionPoints[i])
							SetBlipAsMissionCreatorBlip(MissionPoints[i].blipId, false)
							Citizen.InvokeNative(0x86A652570E5F25DD, Citizen.PointerValueIntInitialized(MissionPoints[i].blipId))
							if LeftMission(MissionPoints) then
								TriggerEvent("pNotify:notifyFromServer", "Tu viens de livrer : </br>" .. messageToPrint .. "</br> Passe à la suite!", "success", "topCenter", true, 4000)
							else
								TriggerEvent("pNotify:notifyFromServer", "Tu viens de livrer : </br>" .. messageToPrint .. "</br> <strong> tu vas recevoir ta paye une fois rendu au centre de livraison.", "success", "topCenter", true, 10000)
								StartEndMission(MissionInfos)
							end
							if not(MissionPoints[i].pouboire) then
								if math.random(1,5) == 3 then
									TriggerServerEvent("iLivreur:pourboire", math.random(12, 66))
								end
							else
								TriggerServerEvent("iLivreur:pourboire", math.random(12, 66))
							end
							TriggerServerEvent("iLivreur:removeObjectsArray", MissionPoints[i].foods)
							MissionPoints[i].isDone = true
						else
							print(json.encode(MissionPoints[i].foods))
							local messageToPrint = GetMessageForOneMissionPoints(MissionPoints[i])
							TriggerEvent("pNotify:notifyFromServer", "Tu n'as pas les objets de livraison qu'il te faut : </br>" .. messageToPrint, "error","topCenter", true, 5000)
							Citizen.Wait(5000)
						end
					end
				end
			end
		end
		if not(missionStarted) then
			for i = 1, #MissionPoints do
				SetBlipAsMissionCreatorBlip(MissionPoints[i].blipId, false)
				Citizen.InvokeNative(0x86A652570E5F25DD, Citizen.PointerValueIntInitialized(MissionPoints[i].blipId))
			end
		end
	end)
end

function LeftMission(MissionPoints)
	local count = 0
	for i = 1, #MissionPoints do
		if not(MissionPoints.isDone) then
			count = count + 1
		end
	end
	return count
end

function StartEndMission(MissionInfos)
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
	while true do
		local x,y,z = table.unpack(GetEntityCoords(GetPlayerPed(-1), true))
		Wait(500)
		if GetDistanceBetweenCoords(pointQg.x, pointQg.y, pointQg.z, x, y, z, true) <= 5.0 then
			SetBlipAsMissionCreatorBlip(blip, false)
			Citizen.InvokeNative(0x86A652570E5F25DD, Citizen.PointerValueIntInitialized(blip))
			TriggerServerEvent("iLivreur:endedMission", MissionInfos, GetGameTimer())
			missionStarted = false
			askCommande = false
		end
	end
end

function GetTotalValue(MissionPoints)
	local total = 0
	for i = 1, #MissionPoints do
		for j = 1, #MissionPoints[i].foods do
			total = total + MissionPoints[i].foods[j].item.price
		end
	end
	return total
end

function GetShortestDistance(MissionPoints)
	local basicDistance, theShortestPoint = GetShortestDistanceFromPed(MissionPoints)
	local Trajet = {theShortestPoint}
	local numberLoop = #MissionPoints
	print("taille trajet " .. #Trajet)
	while #Trajet ~= numberLoop do
		Wait(0)
		local min = 99999
		local actualPoint = 0
		for i = 1, #MissionPoints do
			if i ~= Trajet[#Trajet] then
				print(json.encode(Trajet))
				print(json.encode(MissionPoints[Trajet[#Trajet]]))
				local point = MissionPoints[Trajet[#Trajet]].point
				if GetDistanceBetweenCoords(point.x, point.y, point.z, MissionPoints[i].point.x, MissionPoints[i].point.y, MissionPoints[i].point.z, true) < min and i ~= Trajet[#Trajet] then
					min = GetDistanceBetweenCoords(point.x, point.y, point.z, MissionPoints[i].point.x, MissionPoints[i].point.y, MissionPoints[i].point.z, true)
					actualPoint = i
				end
			end
		end
		print(json.encode(Trajet))
		Trajet[#Trajet+1] = actualPoint
		print(json.encode(Trajet))
	end
	local distance = basicDistance
	for i = 2, #Trajet do
		distance = distance + CalculateTravelDistanceBetweenPoints(MissionPoints[Trajet[i-1]].point.x, MissionPoints[Trajet[i-1]].point.y, MissionPoints[Trajet[i-1]].point.z, MissionPoints[Trajet[i]].point.x, MissionPoints[Trajet[i]].point.y, MissionPoints[Trajet[i]].point.z)
	end
	return {Trajet, distance}
end

function GetShortestDistanceFromPed(MissionPoints)
	local x,y,z = table.unpack(GetEntityCoords(GetPlayerPed(-1), true))
	local min = 90000.0
	local actual = 0
	for i = 1, #MissionPoints do
		if CalculateTravelDistanceBetweenPoints(x, y, z, MissionPoints[i].point.x, MissionPoints[i].point.y, MissionPoints[i].point.z) <= min then
			min = CalculateTravelDistanceBetweenPoints(x, y, z, MissionPoints[i].point.x, MissionPoints[i].point.y, MissionPoints[i].point.z)
			actual = i
		end
	end
	return min, actual
end

function GotTheseItems(foods) -- Todo
	local foodList = {}
	local myBool = nil
	for i = 1, #foods do
		local founded = false
		if #foodList ~= 0 then
			for j = 1, #foodList do
				if foodList[j].id == foods[i].item.id then
					foodList[j].quantity = foodList[j].quantity + foods[i].quantity
					founded = true
				end
			end
			if not(founded) then
				table.insert(foodList, {id = foods[i].item.id, quantity = foods[i].quantity})
			end
		else
			table.insert(foodList, {id = foods[i].item.id, quantity = foods[i].quantity})
		end
	end
	TriggerEvent("inv:gotItemsAndQuantity", foodList, function(bool)
		myBool = bool
	end)
	return myBool
end

-- function IsGottingItems(items)
-- 	local myBool
-- 	TriggerEvent("inv:gotThisItemsById", items, function(bool)
--     	myBool = bool
-- 	end)
-- 	if type(myBool) == "string" then
-- 		print("ERROR STEAM ID INVENTORY")
-- 		return
-- 	end
-- 	return myBool
-- end

function GetMessageForOneMissionPoints(missionPoint)
	local toBeReturned = ""
	for i = 1, #missionPoint.foods do
		if i ~= #missionPoint.foods then
			toBeReturned = toBeReturned .. missionPoint.foods[i].quantity .. " " .. missionPoint.foods[i].item.name .. " et "
		else
			toBeReturned = toBeReturned .. missionPoint.foods[i].quantity .. " " .. missionPoint.foods[i].item.name .. "."
		end
	end
	return toBeReturned
end

function GenerateMessage(MissionPoints)
	local messageToSend = "Vas chercher au point de livraison: "
	local allItem = {}
	for i = 1, #MissionPoints do
		for j = 1, #MissionPoints[i].foods do
			local founded = false
			if #allItem ~= 0 then
				for k = 1, #allItem do
					if MissionPoints[i].foods[j].item.id == allItem[k].item.id then
						allItem[k].quantity = allItem[k].quantity + MissionPoints[i].foods[j].quantity
						founded = true
					end
				end
				if not(founded) then
					table.insert(allItem, {item = MissionPoints[i].foods[j].item, quantity = MissionPoints[i].foods[j].quantity})
				end
			else
				table.insert(allItem, {item = MissionPoints[i].foods[j].item, quantity = MissionPoints[i].foods[j].quantity})
			end
		end
	end

	for i=1, #allItem do
		if i ~= #allItem then
			messageToSend = messageToSend .. allItem[i].quantity .. " " .. allItem[i].item.name .. ", "
		else
			messageToSend = messageToSend .. allItem[i].quantity .. " " .. allItem[i].item.name .. "."
		end
	end
	messageToSend = messageToSend
	return messageToSend
end

function GenerateItem(result)
	local MissionPoints = {}
	local nombrePoints = math.random(1, 8)
	for i =1, nombrePoints do
		local numberFood = math.random(1, 3)
		local foods = {}
		for j = 1, numberFood do
			table.insert(foods, {item = result[math.random(1, #result)], quantity = math.random(1,5) })
		end
		print(GetTotalWeight(foods))
		while GetTotalWeight(foods) >= 3 do
			Wait(0)
			foods = {}
			for j = 1, numberFood do
				table.insert(foods, {item = result[math.random(1, #result)], quantity = math.random(1,5) })
			end
		end
		print("point " ..i .. " : " .. json.encode(foods))
		table.insert(MissionPoints, {point = DeliveryPoints[math.random(1, #DeliveryPoints)], foods = foods})
	end
	return MissionPoints
end

function GetTotalWeight(foods)
	local total = 0
	for i = 1, #foods do
		total = total + (tonumber(foods[i].item.weight) * tonumber(foods[i].quantity))
	end
	return total / 1000
end

function LaunchMenu(Items)
	-- TriggerEvent("pNotify:notifyFromServer")
	ClearMenu()
	MenuTitle = "Approvisionnement livreur"
	if missionStarted and askCommande and commandReady then
		Menu.addButton("Récupérer la commande", "TakeOrder", stockedMissionPoints)
	end
	for i = 1, #Items do
		Menu.addButton(Items[i].name .. " : " .. Items[i].price.."$", "ItemsInfos", {Items,i})
	end
	Menu.hidden = false
	currentMenu = "magasin"
end

function TakeOrder(MissionPoints)
	if DoesEntityExist(currentVeh) then
		local x,y,z = table.unpack(GetEntityCoords(GetPlayerPed(-1), true))
		local x1,y1,z1 = table.unpack(GetEntityCoords(currentVeh, true))
		local x2,y2,z2 = table.unpack(GetEntityCoords(currentVeh, false))
		print(GetDistanceBetweenCoords(x, y, z, x1, y1, z1, true))
		print(GetDistanceBetweenCoords(x, y, z, x2, y2, z2, true))
		print(DoesEntityExist(currentVeh))
		if GetDistanceBetweenCoords(x, y, z, x1, y1, z1, true) <= 15.0 then
			TriggerServerEvent("iLivery:takeOrder", MissionPoints)
		else
			TriggerEvent("pNotify:notifyFromServer", "Place ton véhicule près du point de livraison, que je puisse tout mettre dedans. </br> <strong>Le stagiaire</strong>", "error", "topCenter", true, 5000)
		end
	else
		TriggerEvent("pNotify:notifyFromServer", "Tu as prit un véhicule au moins?", "error", "topCenter", true, 5000)
	end
end

RegisterNetEvent("iLivreur:getReturnedInfosForOrder")
AddEventHandler("iLivreur:getReturnedInfosForOrder", function(bool)
	if bool then
		askCommande = false
	end
end)

function ItemsInfos(Result)
	local choice = Result[2]
	local Items = Result[1]
	ClearMenu()
	MenuTitle = Items[choice].name .. " pese " .. Items[choice].weight .. "g"
	Menu.addButton("Acheter pour "..Items[choice].price.."$", "BuyItem", Items[choice])
	Menu.addButton("Retour", "LaunchMenu", Items)
end

function BuyItem(item)
	prompt(function(amount)
		if amount ~= nil and tonumber(amount) > 0 then
			TriggerServerEvent('inv:buyItemByItemId', item.id, tonumber(amount))
		end
	end)
	Menu.hidden = not(Menu.hidden)
	ClearMenu()
end

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


function ShowQg(pointQg)
	print("start funct")
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
	print("bliped ?")
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
			TriggerEvent("pNotify:notifyFromServer", "Contacter Izio iLivreur_client.lua Entity doesn't exist.", "error", "topCenter", true, 5000)
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
	local plateText = "LI".. math.random(100,999)
	local a, b, c = Generate3Char()
	plateText = plateText .. a .. b .. c
	SetVehicleNumberPlateText(deliveryVeh, plateText)

	Menu.hidden = true
	currentVeh = deliveryVeh
	if timeVeh == nil then
		TriggerServerEvent("iLivreur:spawnVehGarage", carPrice, plateText)
	end
	timeVeh = GetGameTimer()
end

function Generate3Char()
	local a = math.random(1,26)
	local b = math.random(1,26)
	local c = math.random(1,26)
	local alphabet = {"A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"}
	return alphabet[a], alphabet[b], alphabet[c]
end