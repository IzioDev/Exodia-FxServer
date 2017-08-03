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

AddEventHandler("police:armurerieToServer", function(result)
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
			user.notify("Bon ".. user.get('displayName') .. " tu connais la procédure, je prend tes armes personnelles, je te donnes des armes de service et tu viens les reprendre après avoir quitté ton service.", "success", "topCenter", true, 5000)
		else
			user.notify("Tiens tes armes de service.. et euh, je suppose que tu n'as pas d'armes personnelles sur toi " .. user.get('displayName').. '?', "success", "topCenter", true, 5000)
		end
		TriggerClientEvent("icops:giveServiceWeapons", source, result)
	end)
end)

AddEventHandler("police:retrieveArmurerieToServer", function()
	local source = source
	TriggerEvent("es:getPlayerFromId", source, function(user)
		local result = MySQL.Sync.fetchAll("SELECT * FROM users WHERE `identifier`=@identifier AND `id`=@id", {
			["@identifier"] = user.get('identifier'),
			["@id"] = user.get('id')
			})
		print(json.encode(result))
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
				user.notify("Je te rend tes armes comme prévu " .. user.get('displayName').. ".", "success", "topCenter", true, 5000)
				for i = 1, #waitingWeapons do
					user.addQuantity(waitingWeapons[i].id, waitingWeapons[i].quantity)
				end
				user.refreshInventory()
				MySQL.Async.execute("UPDATE users SET `waitingWeapons`=@weapons WHERE `identifier`=@identifier AND `id`=@id", {
					['@identifier'] = user.get('identifier'),
					['@id'] = user.get('id'),
					['@weapons'] = nil
					})
				TriggerClientEvent("police:returnFromServerRetreiving", user.get('source'))
			end
		else
			user.notify("Oh attend... Je ne trouve pas tes armes, t'es sur d'en avoir déposé " .. user.get('displayName') .. "?", "error", "topCenter", true, 5000)
		end
	end)
end)

AddEventHandler("es:playerLoaded", function(source)
	TriggerEvent("es:getPlayerFromId", source, function(user)
		if user.get('waitingWeapons') ~= nil and (user.get('job') == "lspd" or user.get('job') == "lssd")then
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
RegisterServerEvent("police:spawnVehGarage")
AddEventHandler("police:spawnVehGarage", function(carPrice)
	local source = source
	TriggerEvent("es:getPlayerFromId", source, function(user)
		TriggerEvent("ijob:getJobFromName", user.get('job'), function(policeJob)
			if not(user.getSessionVar('caution', carPrice)) then
				print(carPrice)
				policeJob.removeCapital(carPrice)
				policeJob.addLost(user, carPrice, "prise de véhicule de fonction.")
				user.setSessionVar('caution', carPrice)
				user.notify("La police te prete un véhicule. Si tu ne le ramène pas, ils te demandront de payer la moitié du prix de la voiture. Prends en soin!", "error", "topCenter", true, 5000)
			end
		end)
	end)
end)

RegisterServerEvent("police:retreiveCaution")
AddEventHandler("police:retreiveCaution", function(carPrice)
	local source = source
	TriggerEvent("es:getPlayerFromId", source, function(user)
		TriggerEvent("ijob:getJobFromName", user.get('job'), function(policeJob)
			policeJob.addCapital(user.getSessionVar('caution'))
			policeJob.addBenefit(user, user.getSessionVar('caution'), "Ajout du véhicule au garage.")
			user.setSessionVar("caution", nil)
			user.notify("Tu viens de ramener le véhicule au garage.", "success", "topCenter", true, 5000)
		end)
	end)
end)

AddEventHandler("is:playerDropped", function(user)
	if user.get('job') == "lspd" or user.get('job') == "lssd" then
		if user.getSessionVar("caution") ~= nil then
				user.removeBank(user.getSessionVar("caution")/2)
		end
	end
end)
-- Fonctions du menu policier :

-- Partie checkID
RegisterServerEvent("police:checkId")
AddEventHandler("police:checkId", function(psid)
	local source = source
	TriggerEvent("es:getPlayerFromId", source, function(user)
		TriggerEvent("es:getPlayerFromId", psid, function(targetUser)
			if targetUser~=nil then
				if targetUser.getSessionVar("cuffed") == true then
					targetUser.notify("Un agent de police est en train de regarder ton identitié, tu ne peux pas réagir, tu es menotté.", "error", "topCenter", true, 5000)
					user.notify("Tu es en train de regarder la carte d'identité d'une personne. </br> <ul> <li><strong>Nom: </strong>".. targetUser.get('lastName') ..".</li> <li> <strong>Prénom: </strong>".. targetUser.get('firstName') .." </li> <li><strong>Age: </strong>".. targetUser.get('age') .. " </li> <li><strong>Matricule: </strong>".. "TODO" .." </li> </ul>", "success", "topCenter", true, 10000)
				else
					user.notify("Le citoyen n'est pas menotté, tu viens de lui demandé de te montrer sa carte d'identité", "error", "topCenter", true, 10000)
					targetUser.notify("Un agent de police vient de te demander ta carte d'identité. Aide: Appuies sur Y pour lui donner  et sur T pour refuser de lui donner.", "success", "topCenter", true, 5000)
					TriggerClientEvent("police:checkId", psid, source)
				end
			else
				user.notify("Contacter Izio iCops_server can't retreive PSID", "error", "topCenter", true, 5000)
			end
		end)
	end)
end)

RegisterServerEvent("police:accptedToGiveCard")
AddEventHandler("police:accptedToGiveCard", function(officerPsid)
	local source = source
	TriggerEvent("es:getPlayerFromId", officerPsid, function(officerUser)
		TriggerEvent("es:getPlayerFromId", source, function(user)
			officerUser.notify("Tu es en train de regarder la carte d'identité d'une personne. </br> <ul> <li><strong>Nom: </strong>".. user.get('lastName') ..".</li> <li> <strong>Prénom: </strong>".. user.get('firstName') .." </li> <li><strong>Age: </strong>".. user.get('age') .. " </li> <li><strong>Matricule: </strong>".. "TODO" .." </li> </ul>", "success", "topCenter", true, 10000)
		end)
	end)
end)

RegisterServerEvent("police:refusedToGiveCard")
AddEventHandler("police:refusedToGiveCard", function(officerPsid)
	local source = source
	TriggerEvent("es:getPlayerFromId", officerPsid, function(officerUser)
		officerUser.notify("Le citoyen vient de refuser de te montrer sa carte d'identité.", "error", "topCenter", true, 10000)
	end)
end)

-- Partie Check Inv
RegisterServerEvent("police:targetCheckInventory")
AddEventHandler("police:targetCheckInventory", function(psid)
	local source = source -- FxServer
	TriggerEvent("es:getPlayerFromId", source, function(user)
		TriggerEvent("es:getPlayerFromId", psid, function(targetUser) --
			if targetUser~=nil then
				if targetUser.getSessionVar("cuffed") == true then
					targetUser.notify("Un agent de police est en train de regarder ton inventaire, tu ne peux pas réagir, tu es menotté.", "error", "topCenter", true, 5000)
					local message = GetInventoryMessage(targetUser)
					user.notify("Tu es en train de regarder l'inventaire d'une personne. </br>" .. message, "success", "topCenter", true, 15000)
				else
					user.notify("Le citoyen n'est pas menotté, tu viens de lui demandé de te montrer ses poches.", "error", "topCenter", true, 10000)
					targetUser.notify("Un agent de police vient de te demander de fouiller tes poches. </br> Aide: Appuies sur Y pour lui donner.  </br>Appuies sur T pour refuser de lui donner.", "success", "topCenter", true, 5000)
					TriggerClientEvent("police:checkInventory", psid, source)
				end
			else
				user.notify("Contacter Izio iCops_server can't retreive PSID", "error", "topCenter", true, 5000)
			end
		end)
	end)
end)

RegisterServerEvent("police:refusedToShowPoached")
AddEventHandler("police:refusedToShowPoached", function(officerPsid)
	local source = source
	TriggerEvent("es:getPlayerFromId", officerPsid, function(officerUser)
		officerUser.notify("Le citoyen vient de refuser de te montrer ses poches.", "error", "topCenter", true, 10000)
	end)
end)

RegisterServerEvent("police:acceptedToShowPoached")
AddEventHandler("police:acceptedToShowPoached", function(officerPsid)
	local source = source
	TriggerEvent("es:getPlayerFromId", officerPsid, function(officerUser)
		TriggerEvent("es:getPlayerFromId", source, function(user)
			local message = GetInventoryMessage(user)
			officerUser.notify("Tu es en train de regarder l'inventaire d'une personne. </br>" .. message, "success", "topCenter", true, 15000)
		end)
	end)
end)

function GetInventoryMessage(user) --
	local allItem = user.get('item')
	local userInventory = user.get('inventory')
	local message = "<ul>"
	for i=1, #userInventory do
		message = message .. "<li><strong> " .. userInventory[i].quantity .. " " .. allItem[userInventory[i].id].name .. "</strong></li>" 
	end
	return message .. "</ul>"
end

-- Partie cuff
RegisterServerEvent("police:cuffPlayer")
AddEventHandler("police:cuffPlayer", function(psid)
	local source = source
	TriggerEvent("es:getPlayerFromId", source, function(user)
		TriggerEvent("es:getPlayerFromId", psid, function(targetUser)
			if targetUser~=nil then
				if targetUser.getSessionVar("cuffed") == true then
					TriggerClientEvent("police:coffPlayerReturnFromServer", psid, false)
					targetUser.setSessionVar("cuffed", false)
					user.notify("Tu viens de démenotter la personne devant toi.", "success", "topCenter", true, 5000)
					targetUser.notify("Tu viens d'etre démenotter par un agent de police.", "success", "topCenter", true, 5000)
				else
					TriggerClientEvent("police:coffPlayerReturnFromServer", psid, true)
					targetUser.setSessionVar("cuffed", true)
					user.notify("Tu viens de menotter la personne devant toi.", "success", "topCenter", true, 5000)
					targetUser.notify("Tu viens d'etre menotter par un agent de police.", "success", "topCenter", true, 5000)
				end
			else
				user.notify("Contacter Izio iCops_server can't retreive PSID", "error", "topCenter", true, 5000)
			end
		end)
	end)
end)

-- Partie Getout / put into veh:
RegisterServerEvent("police:setPlayerIntoVeh") -- TODO, vérifier que le véhicule soit un véhicule de police (plate : PO)
AddEventHandler("police:setPlayerIntoVeh", function(psid)
	local source = source
	TriggerEvent("es:getPlayerFromId", source, function(user)
		TriggerEvent("es:getPlayerFromId", psid, function(targetUser)
			user.notify("Tu as forcé le citoyen à rentrer dans ton véhicule", "success", "topCenter", true, 5000)
			targetUser.notify("Un agent de police vient de vous forcer à rentrer dans le véhicule", "success", "topCenter", true, 5000)
			TriggerClientEvent("police:forcedEnteringVeh", psid)
		end)
	end)
end)

RegisterServerEvent("police:unSetPlayerIntoVeh") -- TODO, vérifier que le véhicule soit un véhicule de police (plate : PO)
AddEventHandler("police:unSetPlayerIntoVeh", function(psid)
	local source = source
	TriggerEvent("es:getPlayerFromId", source, function(user)
		TriggerEvent("es:getPlayerFromId", psid, function(targetUser)
			user.notify("Tu as forcé le citoyen à sortir de ton véhicule", "success", "topCenter", true, 5000)
			targetUser.notify("Un agent de police vient de vous forcer à sortir du le véhicule", "success", "topCenter", true, 5000)
			TriggerClientEvent("police:forcedLeavingVeh", psid)
		end)
	end)
end)

--Partie Fines : 
RegisterServerEvent("police:setFineToPlayer")
AddEventHandler("police:setFineToPlayer", function(psid, amount)
	local amount = math.abs(amount)
	local source = source
	TriggerEvent("es:getPlayerFromId", source, function(user)
		TriggerEvent("es:getPlayerFromId", psid, function(targetUser)
			user.notify("Tu viens de mettre un amande à un citoyen d'un montant de " .. amount .. '$.', "success", "topCenter", true, 5000)
			targetUser.notify("Un agent de police vient de vous mettre une amande d'un montant de ".. amount .. '$.', "success", "topCenter", true, 5000)
			targetUser.removeBank(amount)
			TriggerEvent("ijob:getJobFromName", user.get('job'),function(police)
				police.addCapital(amount)
				police.addBenefit(user, amount, "Amende sur un citoyen.")
			end)
		end)
	end)
end)

-- Partie DragPlayer:
RegisterServerEvent("police:dragRequest")
AddEventHandler("police:dragRequest", function(psid, isDragged)
	local source = source
	TriggerEvent("es:getPlayerFromId", source, function(user)
		TriggerEvent("es:getPlayerFromId", psid, function(targetUser)
			if targetUser.getSessionVar("cuffed") == true then
				if not(isDragged) then
					user.notify("Tu escortes le citoyen.", "success", "topCenter", true, 5000)
					targetUser.notify("Un agent de police est en train de t'escorter.", "success", "topCenter", true, 5000)
					TriggerClientEvent("police:dragAnswer", psid, source)
				else
					user.notify("Tu laches le citoyen.", "success", "topCenter", true, 5000)
					targetUser.notify("Un agent de police vient de vous lacher.", "success", "topCenter", true, 5000)
					TriggerClientEvent("police:dragAnswer", psid, source)
				end
			else
				user.notify("Le citoyen concerné n'est pas menotté.", "success", "topCenter", true, 5000)
				targetUser.notify("Un agent de police à essayé de t'escorter, mais tu n'étais pas menotté.", "success", "topCenter", true, 5000)
			end
		end)
	end)
end)