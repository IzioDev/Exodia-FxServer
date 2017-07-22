allJob = {}
local launched = false
local proked
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

RegisterNetEvent("ijob:updateJob")
AddEventHandler("ijob:updateJob", function(jobName, rank)
	userJob = jobName
	userRank = rank
	if userJob == "Chomeur" or userJob == "Unemployed" then
		userRank = " "
	end
	TriggerEvent("is:updateJob", userJob, userRank)
	print(tostring(IsHarvestJob(userJob)))
	if IsHarvestJob(userJob) then
		print("it's ok ok")
		RunHarvestThread()
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
	DisableControlAction(1, 38, false)
	while true do
		Wait(10)
		TriggerEvent("izone:isPlayerInZone", "poleemploi", function(isInZone)
			if isInZone ~= nil and isInZone and not(guiOpened) then
			 	DisplayHelpText("Press ~INPUT_CONTEXT~ to choose a ~b~job~w~.")
			end

			if isInZone ~= nil and isInZone and IsControlJustPressed(1, 38) then

				DisableAllControlActions(1)
				SetNuiFocus(true, true)
				SendNUIMessage({
					action = "open"
				})

			elseif guiOpened and not(isInZone) then

				SendNUIMessage({
				 	action = "close"
				})
			end

		end)

	end

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


RegisterNetEvent("iJob:notifFailed")
AddEventHandler("iJob:notifFailed", function(message)
	-- Todo afficher une belle notification
end)

RegisterNetEvent("iJob:notifSuccessed")
AddEventHandler("iJob:notifSuccessed", function(message, item, amount)
	-- Todo afficher une belle notification
end)


function RunHarvestThread(bool)
	if bool then
		RunToolShop(bool)
		Citizen.CreateThread(function()
			local waitingCheckProcess = nil
			while true do
				Wait(10)
				if launched == nil then
					local oldTime = GetGameTimer()
					local newTime = 5000
					while launched == nil and (GetGameTimer() - oldTime) < newTime do
						Wait(0)
						DisplayHelpText("Veuillez attendre 5 secondes avant de relancer.")
					end
					launched = false
				end
				TriggerEvent("izone:getResultFromPlayerInAnyJobZone", userJob, function(result)
					-- result.nom = zoneName
					if result ~= nil and not(launched) then -- on est soit dans une zone de récolte/traitement/vente de notre job.
						DisplayHelpText("Appuyez sur ~INPUT_CONTEXT~ pour commencer ".. result.displayMessageInZone)
						if IsControlJustPressed(1, 38) then
							if (result.tool) then
								if IsGottingItem(result.tool) then -- on à l'item
									--CheckHarvestProcessOperation(result)
									TriggerEvent("ijob:checkClientHarvest", result)
								else
									TriggerEvent("pNotify:notifyFromServer", "Vous devez avoir votre outil pour faire cette action", "error", "centerLeft", true, 5000)
								end
							else
								-- CheckProcessOperation(result)
							end
						end
					elseif result == nil and launched then
						launched = nil
					end
				end)
				-- Ajouter Traitement et Vente en un seul TriggerResult ;)
			end
		else
			RunToolShop(bool)
			return
		end
	end)
end

function RunToolShop(bool)
	if bool then
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
			end
		end)
	else
		return
	end
end

function CheckHarvestProcessOperation(result) -- for harvest
	TriggerServerEvent("iJob:checkHarvest" , result)
end

function MenuThread()

end

function CheckProcessOperation(result) -- for treatment / sell

end

function ProcessOperation(result)

end

AddEventHandler("ijob:checkClientHarvest", function(result) -- on a check s'il avait le métier server side
	launched = true
	proked = false
	local inWaiting = false
	while launched do
		Wait(0)
		DisplayHelpText("Appuyez sur ~INPUT_CONTEXT~ pour stopper ")
		if IsControlJustPressed(1, 38) then
			launched = nil
			break
			CancelEvent()
			return
		end
		if not(inWaiting) and launched then
			inWaiting = true
			TriggerEvent("anim:Play", "player:pickup_01")
			SetTimeout(result.time ,function()
				if not(proked) then
					TriggerServerEvent("iJob:checkHarvest", result)
				end
				inWaiting = false
			end)
		end
	end
end)

RegisterNetEvent("ijob:stopHarvest")
AddEventHandler("ijob:stopHarvest", function()
	launched = nil
	proked = true
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
