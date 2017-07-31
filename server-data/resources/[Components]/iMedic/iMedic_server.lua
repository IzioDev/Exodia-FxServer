-- Copyright (C) Izio, Inc - All Rights Reserved
-- Unauthorized copying of this file, via any medium is strictly prohibited
-- Proprietary and confidential
-- Written by Romain Billot <romainbillot3009@gmail.com>, Jully 2017

RegisterServerEvent("print:serverArray")
RegisterServerEvent("police:armurerieToServer")
RegisterServerEvent("police:retrieveArmurerieToServer")

AddEventHandler("print:serverArray", function(toPrint)
	print(json.encode(toPrint))
end)

AddEventHandler("imedic:armurerieToServer", function(result)
	local source = source
	TriggerEvent("es:getPlayerFromId", source, function(user)
		local treatWeapons = {}
		local treatQuantity = {}
		local treatWaitingWeapons = {}
		local allItemInfos = user.get('item')
		local allWeapon = allItemInfos.weapons
		local inventory = user.get('inventory')
		for i = 1, #inventory do
			for j = 1 , #allWeapon do
				if inventory[i].id == allWeapon[j].id then
					if inventory[i].quantity > 0 then
						table.insert(treatWeapons, inventory[i].id)
						table.insert(treatQuantity, inventory[i].quantity)
					end
				end
			end
		end
		if #treatQuantity ~= 0 then
			user.removeQuantityArray(treatWeapons, treatQuantity)
			user.refreshInventory()
			for i = 1, #treatWeapons do
				table.insert(treatWaitingWeapons,{
					quantity = treatQuantity[i],
					id = treatWeapons[i]
				})
			end
			MySQL.Async.execute("UPDATE users SET `waitingWeapons`=@weapons WHERE `identifier`=@identifier AND `id`=@id", {
				['@identifier'] = user.get('identifier'),
				['@id'] = user.get('id'),
				['@weapons'] = json.encode(treatWaitingWeapons)
				})
		else
			user.notify("Tiens tes armes de service.. et euh, je suppose que tu n'as pas d'armes personnelles sur toi " .. user.get('displayName').. '?', "success", "topCenter", true, 5000)
		end
		TriggerClientEvent("imedic:giveServiceWeapons", source, result)
	end)
end)

AddEventHandler("imedic:retrieveArmurerieToServer", function()
	local source = source
	TriggerEvent("es:getPlayerFromId", source, function(user)
		local result = MySQL.Sync.fetchAll("SELECT * FROM users WHERE `identifier`=@identifier AND `id`=@id", {
			["@identifier"] = user.get('identifier'),
			["@id"] = user.get('id')
			})
		if result[1].waitingWeapons ~= nil then -- il a des armes en attente
			local nulled = 0
			local waitingWeapons = json.decode(result[1].waitingWeapons)
			for i = 1, #waitingWeapons do
				if waitingWeapons[i].quantity < 1 then
					nulled = nulled + 1
				end
			end
			if nulled == #waitingWeapons then
				user.notify("Contacter izio, nulled waitingWeapons l.72 iCops_server.lua", "warning", "topCenter", true, 20000)
			else
				--user.notify("Je te rend tes armes comme prévu " .. user.get('displayName').. ".", "success", "topCenter", true, 5000)
				for i = 1, #waitingWeapons do
					user.addQuantity(waitingWeapons[i].id, waitingWeapons[i].quantity)
				end
				user.refreshInventory()
				MySQL.Async.execute("UPDATE users SET `waitingWeapons`=@weapons WHERE `identifier`=@identifier AND `id`=@id", {
					['@identifier'] = user.get('identifier'),
					['@id'] = user.get('id'),
					['@weapons'] = nil
					})
			end
		else
			--user.notify("Oh attend... Je ne trouve pas tes armes, t'es sur d'en avoir déposé " .. user.get('displayName') .. "?", "error", "topCenter", true, 5000)
		end
	end)
end)

AddEventHandler("es:playerLoaded", function(source)
	TriggerEvent("es:getPlayerFromId", source, function(user)
		if user.get('waitingWeapons') ~= nil and user.get('job') == "médecin" then
			local weapons = user.get('waitingWeapons') 
			for i = 1, #weapons do
				user.addQuantity(weapons[i].id, weapons[i].quantity)
			end
			MySQL.Async.execute("UPDATE users SET `waitingWeapons`=@weapons WHERE `identifier`=@identifier AND `id`=@id", {
				['@identifier'] = user.get('identifier'),
				['@id'] = user.get('id'),
				['@weapons'] = nil
			})
		end
	end)
end)
-- Garage : 
RegisterServerEvent("imedic:spawnVehGarage")
AddEventHandler("imedic:spawnVehGarage", function(carPrice)
	local source = source
	TriggerEvent("es:getPlayerFromId", source, function(user)
		TriggerEvent("ijob:getJobFromName", user.get('job'), function(medicJob)
			if not(user.getSessionVar('caution', carPrice)) then
				medicJob.removeCapital(carPrice)
				medicJob.addLost(user, carPrice, "prise de véhicule de fonction.")
				user.setSessionVar('caution', carPrice)
				user.notify("Le gérant te prete un véhicule. Si tu ne le ramène pas, il te demandera de payer la moitié du prix de la voiture. Prends en soin!", "error", "topCenter", true, 5000)
			end
		end)
	end)
end)

RegisterServerEvent("imedic:retreiveCaution")
AddEventHandler("imedic:retreiveCaution", function(carPrice)
	local source = source
	TriggerEvent("es:getPlayerFromId", source, function(user)
		TriggerEvent("ijob:getJobFromName", user.get('job'), function(medicJob)
			medicJob.addCapital(user.getSessionVar('caution'))
			medicJob.addBenefit(user, user.getSessionVar('caution'), "Ajout du véhicule au garage.")
			user.setSessionVar("caution", nil)
			user.notify("Tu viens de ramener le véhicule au garage.", "success", "topCenter", true, 5000)
		end)
	end)
end)

AddEventHandler("is:playerDropped", function(user)
	if user.get('job') == "médecin" then
		if user.getSessionVar("caution") ~= nil then
			user.removeBank(user.getSessionVar("caution")/2)
		end
	end
end)
-- Fonctions du menu médecin :

-- Partie checkID
RegisterServerEvent("imedic:checkId")
AddEventHandler("imedic:checkId", function(psid)
	local source = source
	TriggerEvent("es:getPlayerFromId", source, function(user)
		TriggerEvent("es:getPlayerFromId", psid, function(targetUser)
			if targetUser~=nil then
				user.notify("Tu viens de demander au citoyen de te montrer sa carte d'identité", "error", "topCenter", true, 10000)
				targetUser.notify("Un médecin vient de te demander ta carte d'identité. Aide: Appuies sur Y pour lui donner  et sur T pour refuser de lui donner.", "success", "topCenter", true, 5000)
				TriggerClientEvent("imedic:checkId", psid, source)
			else
				user.notify("Contacter Izio iCops_server can't retreive PSID", "error", "topCenter", true, 5000)
			end
		end)
	end)
end)

RegisterServerEvent("imedic:accptedToGiveCard")
AddEventHandler("imedic:accptedToGiveCard", function(officerPsid)
	local source = source
	TriggerEvent("es:getPlayerFromId", officerPsid, function(officerUser)
		TriggerEvent("es:getPlayerFromId", source, function(user)
			officerUser.notify("Tu es en train de regarder la carte d'identité d'une personne. </br> <ul> <li><strong>Nom: </strong>".. user.get('lastName') ..".</li> <li> <strong>Prénom: </strong>".. user.get('firstName') .." </li> <li><strong>Age: </strong>".. user.get('age') .. " </li> <li><strong>Matricule: </strong>".. "TODO" .." </li> </ul>", "success", "topCenter", true, 10000)
		end)
	end)
end)

RegisterServerEvent("imedic:refusedToGiveCard")
AddEventHandler("imedic:refusedToGiveCard", function(officerPsid)
	local source = source
	TriggerEvent("es:getPlayerFromId", officerPsid, function(officerUser)
		officerUser.notify("Le citoyen vient de refuser de te montrer sa carte d'identité.", "error", "topCenter", true, 10000)
	end)
end)

-- Partie Getout / put into veh:
RegisterServerEvent("imedic:setPlayerIntoVeh") -- TODO, vérifier que le véhicule soit un véhicule de médecin (plate : ME)
AddEventHandler("imedic:setPlayerIntoVeh", function(psid)
	local source = source
	TriggerEvent("es:getPlayerFromId", source, function(user)
		TriggerEvent("es:getPlayerFromId", psid, function(targetUser)
			user.notify("Tu as forcé le citoyen à rentrer dans ton véhicule", "success", "topCenter", true, 5000)
			targetUser.notify("Un médecin vient de te faire rentrer dans le véhicule", "success", "topCenter", true, 5000)
			TriggerClientEvent("imedic:forcedEnteringVeh", psid)
		end)
	end)
end)

RegisterServerEvent("imedic:unSetPlayerIntoVeh") -- TODO, vérifier que le véhicule soit un véhicule de médecin (plate : ME)
AddEventHandler("imedic:unSetPlayerIntoVeh", function(psid)
	local source = source
	TriggerEvent("es:getPlayerFromId", source, function(user)
		TriggerEvent("es:getPlayerFromId", psid, function(targetUser)
			user.notify("Tu as forcé le citoyen à sortir de ton véhicule", "success", "topCenter", true, 5000)
			targetUser.notify("Un médecin vient de te faire sortir du le véhicule", "success", "topCenter", true, 5000)
			TriggerClientEvent("imedic:forcedLeavingVeh", psid)
		end)
	end)
end)

-- Partie DragPlayer:
RegisterServerEvent("imedic:dragRequest")
AddEventHandler("imedic:dragRequest", function(psid, isDragged)
	local source = source
	TriggerEvent("es:getPlayerFromId", source, function(user)
		TriggerEvent("es:getPlayerFromId", psid, function(targetUser)
			if not(isDragged) then
				user.notify("Tu escortes le citoyen.", "success", "topCenter", true, 5000)
				targetUser.notify("Un médecin est en train de te porter.", "success", "topCenter", true, 5000)
				TriggerClientEvent("imedic:dragAnswer", psid, source)
			else
				user.notify("Tu laches le citoyen.", "success", "topCenter", true, 5000)
				targetUser.notify("Un médecin vient de vous lacher.", "success", "topCenter", true, 5000)
				TriggerClientEvent("imedic:dragAnswer", psid, source)
			end
		end)
	end)
end)