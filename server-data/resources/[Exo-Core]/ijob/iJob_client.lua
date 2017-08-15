-- Copyright (C) Izio, Inc - All Rights Reserved
-- Unauthorized copying of this file, via any medium is strictly prohibited
-- Proprietary and confidential
-- Written by Romain Billot <romainbillot3009@gmail.com>, Jully 2017

allJob = {}
local launchedlegit = false
local launchedillegal = false 
local prokedillegal
local prokedlegit
local userJob = nil
local userRank = nil
local harvestJob = {"Fermier", "Bucheron", "Pompiste"}
-- local config = { 
-- 	jobMessage = { 
-- 		emptyField = {
-- 			["Bucheron"] = { "La forêt semble dévastée.", "Patiente un peu", "La forêt est vide.", "Tu ne peux pas couper du bois maintenant, regarde autour de toi !", "Attends, tu penses pouvoir continuer a nuir au programme écologique !", "Les chinois, d'accord, mais n'abuses pas !", "Tu ne tiens donc pas à l'eco diversité ?", "Impossible de couper des arbres innexistants."},
-- 			["Fermier"] = {"Assieds toi, patiente..", "Tu devrais songer aux engrais mon ami !", "Malhereusement... Je crains que le champ soit vide", "Bah oui, c'est ça de tout vider !", "Oulah mon ami, à part la terre, je ne vois pas ce qu'il y à a récolter ici", "La sécheresse est un vrai problème à Los Santos", "Et non ! Peut être pour la prochaine vague !"},
-- 			["Pompiste"] = {"Le Katar est passé avant toi on dirait", "Au prix du pétrole actuellement, tu veux vraiment faire chutter l'économie toi!", "Tu ne peux pas récolter ton pétrol maintenant", "Tu savais que le pétrol méttait 200Ma à se créer ?", "Attends un peu ! Assieds toi, prends une pause", "Tu ne peux pas pomper maintenant :smirk:", "Ahahah, si j'avais su qu'on serait en pénurie de pétrole un jour..", "Mouais, retravaille ton mouvement"}
-- 		 },
-- 		successedHarvest = {
-- 			["Bucheron"] = {"", "", "", "", "", "", "", ""},
-- 			["Fermier"] = {"", "", "", "", "", "", "", ""},
-- 			["Pompiste"] = {"", "", "", "", "", "", "", ""}
-- 		 }
-- 				}
-- }
local guiOpened = false
local displayedBlip = {}

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

RegisterNetEvent("ijob:updateJob")
AddEventHandler("ijob:updateJob", function(jobName, rank)
	userJob = jobName
	userRank = rank
	if userJob == "Chomeur" or userJob == "Unemployed" then
		userRank = " "
	end
	TriggerEvent("is:updateJob", userJob, userRank)

	if IsHarvestJob(userJob) then
		RunHarvestThread(true)
	end
end)

function IsHarvestJob(string)
	for i = 1, #harvestJob do
		if string.lower(harvestJob[i]) == string.lower(string) then
			return true
		end
	end
	return false
end

RegisterNetEvent("ijob:addBlip")
AddEventHandler("ijob:addBlip", function(myBlips, removeOlder) -- array and bool
	local blip
	if not(removeOlder) then
		for i=1, #myBlips do
			if myBlips[i].visible then
				blip = AddBlipForCoord(tonumber(myBlips[i].x), tonumber(myBlips[i].y), tonumber(myBlips[i].z))
				SetBlipSprite(blip, myBlips[i].sprite)
				SetBlipColour(blip, myBlips[i].color)
				BeginTextCommandSetBlipName("STRING")
				AddTextComponentString(myBlips[i].text)
				EndTextCommandSetBlipName(blip)
				SetBlipAsShortRange(blip,true)
				SetBlipAsMissionCreatorBlip(blip,true)
				table.insert(displayedBlip, blip)
			end
		end
	else
		for i = 1, #displayedBlip do
			if DoesBlipExist(displayedBlip[i]) then
				SetBlipAsMissionCreatorBlip(displayedBlip[i],false)
				Citizen.InvokeNative(0x86A652570E5F25DD, Citizen.PointerValueIntInitialized(displayedBlip[i]))
			end
		end
		displayedBlip = {}
		for i=1, #myBlips do
			if myBlips[i].visible then
				blip = AddBlipForCoord(tonumber(myBlips[i].x), tonumber(myBlips[i].y), tonumber(myBlips[i].z))
				SetBlipSprite(blip, myBlips[i].sprite)
				SetBlipColour(blip, myBlips[i].color)
				BeginTextCommandSetBlipName("STRING")
				AddTextComponentString(myBlips[i].text)
				EndTextCommandSetBlipName(blip)
				SetBlipAsShortRange(blip,true)
				SetBlipAsMissionCreatorBlip(blip,true)
				table.insert(displayedBlip, blip)
			end
		end
	end
end)


Citizen.CreateThread(function()
	TriggerServerEvent("ijob:retreiveIfRestart")
	while true do
		Wait(10)
		TriggerEvent("izone:isPlayerInZone", "poleemploi", function(isInZone) ----------------- POLE EMPLOIS
			if isInZone ~= nil and isInZone and not(guiOpened) then
			 	DisplayHelpText("Press ~INPUT_CONTEXT~ to choose a ~b~job~w~.")
			end

			if isInZone ~= nil and isInZone and IsControlJustPressed(1, 38) then
				guiOpened = true
				DisableAllControlActions(1)
				SetNuiFocus(true, true)
				SendNUIMessage({
					action = "open"
				})

			elseif guiOpened and not(isInZone) then
				guiOpened = false
				SendNUIMessage({
				 	action = "close"
				})
			end

		end)

		if launchedillegal == nil then
			local oldTime = GetGameTimer()
			local newTime = 4500
			while launchedillegal == nil and (GetGameTimer() - oldTime) < newTime do
				Wait(0)
				displayedMessage = "."
				for i=1, 3 do -- 3 tours boucle
					DisplayHelpText("Veuillez attendre 5 secondes avant de relancer"..displayedMessage)
					Wait(500)
					displayedMessage = displayedMessage .. "."
				end
			end---
			launchedillegal = false
		end

		TriggerEvent("izone:isPlayerInIllZone", function(result) --------------------- Illegal
			if result ~= nil then -- si on est dans une zone illégale
				DisplayHelpText("Appuyer sur ~INPUT_CONTEXT~ pour commencer "..result.displayMessageInZone)
				if IsControlJustPressed(1, 38) then
					if result.tool then
						if not(IsGottingItem(result.tool)) then
							TriggerEvent("pNotify:notifyFromServer", "Vous devez avoir un outil pour faire cette action", "error", "centerLeft", true, 5000)
							return
						else
							TriggerEvent("ProcessIllHarvest", result)
							return
						end
					end
					if result.need then
						if not(IsGottingItems(result.need)) then
							TriggerEvent("pNotify:notifyFromServer", "Vous devez avoir un ou des matériaux pour faire cette action", "error", "centerLeft", true, 5000)
							return
						else
							TriggerEvent("ProcessIllOther", result) --
						end
					end
				end
			elseif result == nil and launchedillegal then
				prokedlegit = true
				launchedillegal = nil
			end
		end)
	end
end)

Citizen.CreateThread(function()
	while true do
		Wait(0)
		TriggerEvent("izone:isPlayerInZoneReturnInstructions", "magasinoutillage", function(isInZone)
			if isInZone and not(IsPedInAnyVehicle(GetPlayerPed(-1), false)) then
				Menu.renderGUI()
				if Menu.hidden then 
					DisplayHelpText("Appuyez sur ~INPUT_CONTEXT~ pour regarder les objets à la vente")
				end
				if IsControlJustPressed(1, 38) then
					Menu.hidden = not Menu.hidden
					ClearMenu()
					GetResultItemInfos(isInZone.items)
				end
			end
		end)

		TriggerEvent("izone:isPlayerInZoneReturnInstructions", "buraliste", function(isInZone)
			if isInZone and not(IsPedInAnyVehicle(GetPlayerPed(-1), false)) then
				Menu.renderGUI()
				if Menu.hidden then 
					DisplayHelpText("Appuyez sur ~INPUT_CONTEXT~ pour regarder les objets à la vente")
				end
				if IsControlJustPressed(1, 38) then
					Menu.hidden = not Menu.hidden
					ClearMenu()
					GetResultItemInfos(isInZone.items)
				end
			end
		end)

		TriggerEvent("izone:isPlayerInAnyWarpSharedZone", function(result)
			DisplayHelpText("Appuyez sur ~INPUT_CONTEXT~ pour "..result.displayedMessageInZone)
			if IsControlJustPressed(1, 38) then
				TriggerEvent("medic:tpToResult", result)
			end
		end)
	end
end)

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

RegisterNUICallback('close', function(data, cb)
	SetNuiFocus(false, false)
	EnableAllControlActions(1)
	cb("ok")
	guiOpened = false
end)

RegisterNUICallback('selectedJob', function(data, cb)
  Citizen.Trace(json.encode(data))
  SetNuiFocus(false, false)
  EnableAllControlActions(1)
  TriggerServerEvent('ijob:changeJobPoleEmplois', data.id)
  cb('ok')
  guiOpened = false
end)

function RunHarvestThread(bool)
	if bool then
		Citizen.CreateThread(function()
			local waitingCheckProcess = nil
			while true do
				Wait(10)
				if launchedlegit == nil then
					local oldTime = GetGameTimer()
					local newTime = 5000
					while launchedlegit == nil and (GetGameTimer() - oldTime) < newTime do
						Wait(0)
						displayedMessage = "."
						for i=1, 3 do
							local nowTime = GetGameTimer()
							while GetGameTimer() < nowTime + 500 do
								Wait(0)
								DisplayHelpText("Veuillez attendre 5 secondes avant de relancer"..displayedMessage)
							end
							displayedMessage = displayedMessage .. "."
						end
					end
					launchedlegit = false
				end
				TriggerEvent("izone:getResultFromPlayerInAnyJobZone", userJob, function(result)
					-- result.nom = zoneName
					if result ~= nil and not(launchedlegit) then -- on est soit dans une zone de récolte/traitement/vente de notre job.
						DisplayHelpText("Appuyez sur ~INPUT_CONTEXT~ pour commencer ".. result.displayMessageInZone)
						if IsControlJustPressed(1, 38) then
							if (result.harvest) then
								if result.tool then
									if IsGottingItem(result.tool) then -- on à l'item
										--CheckHarvestProcessOperation(result)
										TriggerEvent("ijob:checkClientHarvest", result)
									else
										TriggerEvent("pNotify:notifyFromServer", "Vous devez avoir votre outil pour faire cette action", "error", "topCenter", true, 5000)
										return
									end
								else
									TriggerEvent("ijob:checkClientHarvest", result)
								end
							elseif (result.treatment) then

								if result.tool and not(IsGottingItem(result.tool)) then 
									TriggerEvent("pNotify:notifyFromServer", "Vous devez avoir votre outil pour faire cette action", "error", "topCenter", true, 5000)
									return
								end

								trust = 0
								for i = 1, #result.need do
									if IsGottingItem(result.need[i]) then
										trust = trust + 1
									end
								end
								if trust == #result.need then
									TriggerEvent("CheckProcessOperation", result)
								else
									TriggerEvent("pNotify:notifyFromServer", "Vous devez avoir des matériaux pour cette cette action", "error", "topCenter", true, 5000)
								end
							elseif (result.selling) then

							end
						end
					elseif result == nil and launchedlegit then
						launchedlegit = nil
					end
				end)
			end
		end)
	else
		RunToolShop(bool)
		return
	end
end

function CheckHarvestProcessOperation(result) -- for harvest
	TriggerServerEvent("iJob:checkHarvest" , result)
end

AddEventHandler("CheckProcessOperation", function(result)
	launchedlegit = true
	prokedlegit = false
	local inWaiting = false
	while launchedlegit do
		Wait(0)
		DisplayHelpText("Appuyez sur ~INPUT_CONTEXT~ pour stopper ")
		if IsControlJustPressed(1, 38) then
			launchedlegit = nil
			break
			CancelEvent()
			return
		end
		if not(inWaiting) and launchedlegit then 
			inWaiting = true
			TriggerEvent("anim:Play", result.annimation)
			SetTimeout(result.time ,function()
				if not(prokedlegit) then
					trust = 0
					for i = 1, #result.need do
						if IsGottingItem(result.need[i]) then
							trust = trust + 1
						end
					end
					if trust == #result.need then
						TriggerServerEvent("ijob:process", result)
					else
						launchedlegit = nil
						prokedlegit = true
					end
				end
				inWaiting = false
			end)
		end
	end
end)

AddEventHandler("ProcessIllHarvest" , function(result)
	launchedillegal = true
	prokedillegal = false
	local inWaiting = false
	while launchedillegal do
		Wait(0)
		DisplayHelpText("Appuyez sur ~INPUT_CONTEXT~ pour stopper ")
		if IsControlJustPressed(1, 38) then
			launchedillegal = nil
			break
			CancelEvent()
			return
		end
		if not(inWaiting) and launchedillegal then
			inWaiting = true
			TriggerEvent("anim:Play", "player:pickup_01")
			SetTimeout(result.time ,function()
				if not(prokedillegal) then
					TriggerServerEvent("iJob:harvestillegal", result)
				end
				inWaiting = false
			end)
		end
	end
end)

AddEventHandler("ProcessIllOther", function(result)
	launchedillegal = true
	prokedillegal = false
	local inWaiting = false
	while launchedillegal do
		Wait(0)
		DisplayHelpText("Appuyez sur ~INPUT_CONTEXT~ pour stopper ")
		if IsControlJustPressed(1, 38) then
			launchedillegal = nil
			break
			CancelEvent()
			return
		end
		if not(inWaiting) and launchedillegal then
			if IsGottingItems(result.need) then
				inWaiting = true
				TriggerEvent("anim:Play", "player:pickup_01")
				SetTimeout(result.time ,function()
					if IsGottingItems(result.need) then
						if not(prokedillegal) then
							TriggerServerEvent("iJob:otherIllegal", result)
						end
						inWaiting = false
					else
						launchedillegal = nil
						TriggerEvent("pNotify:notifyFromServer", "Vous devez avoir un ou des matériaux pour faire cette action", "error", "centerLeft", true, 5000)
						return
					end
				end)
			else
				launchedillegal = nil
				TriggerEvent("pNotify:notifyFromServer", "Vous devez avoir un ou des matériaux pour faire cette action", "error", "centerLeft", true, 5000)
				return
			end
		end
	end
end)

AddEventHandler("ijob:checkClientHarvest", function(result) -- on a check s'il avait le métier server side
	launchedlegit = true
	prokedlegit = false
	local inWaiting = false
	while launchedlegit do
		Wait(0)
		DisplayHelpText("Appuyez sur ~INPUT_CONTEXT~ pour stopper ")
		if IsControlJustPressed(1, 38) then
			launchedlegit = nil
			return
		end
		if not(inWaiting) and launchedlegit then
			if result.need then
				if not(IsGottingItems(result.need)) then
					launchedlegit = nil
					prokedlegit = true
				end
			end
			inWaiting = true
			TriggerEvent("anim:Play", result.annimation)
			SetTimeout(result.time ,function()
				if not(prokedlegit) then
					TriggerServerEvent("iJob:checkHarvest", result)
				end
				Citizen.Wait(500)
				inWaiting = false
			end)
		end
	end
end)

function IsGottingItems(items)

end

RegisterNetEvent("ijob:stopHarvest")
AddEventHandler("ijob:stopHarvest", function()
	launchedlegit = nil
	prokedlegit = true
end)

function IsRecoltZone(zoneName)
	local a, b = string.find(zoneName, "rec")
	if a then
 		return true
	else
		return false
	end
end

function IsGottingItem(item)
	local myBool
	TriggerEvent("inv:gotThisItemById", tonumber(item), function(bool)
    	myBool = bool
	end)
	if type(myBool) == "string" then
		print("ERROR STEAM ID INVENTORY")
		return
	end
	return myBool
end

function IsGottingItems(items)
	local myBool
	TriggerEvent("inv:gotThisItemsById", items, function(bool)
    	myBool = bool 
	end)
	if type(myBool) == "string" then
		print("ERROR STEAM ID INVENTORY")
		return
	end
	return myBool
end

function GetResultItemInfos(itemIdArray)
	TriggerServerEvent("ijob:getItemInfosFromIdArray", itemIdArray)
end

RegisterNetEvent("ijob:getItemInfosFromIdArray")
AddEventHandler("ijob:getItemInfosFromIdArray", function(result)
	--print(json.encode(result)) -- ok 
	LaunchMenu(result)
end)

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

function selectMessage(messageArray)
	local selected = math.random(1, #messageArray)--
	return messageArray[selected]
end

function DisplayHelpText(str)
	SetTextComponentFormat("STRING")
	AddTextComponentString(str)
	DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end
