-- Copyright (C) Izio, Inc - All Rights Reserved
-- Unauthorized copying of this file, via any medium is strictly prohibited
-- Proprietary and confidential
-- Written by Romain Billot <romainbillot3009@gmail.com>, August 2017

-- local pourboireMessages = {
-- 	"Tiens gamin, t'acheteras un god à ta femelle. *ricanne*",
-- 	"Merci pour ta rapidité, j'toffre un petit billet",
-- 	"Et bien, t'as fait un client fidèle!",
-- 	"Thanks you M8!",
-- 	"Et t'sais pas quoi? Apparemment à la mairie, y'a que l'huile qu'est bonne!",
-- 	"1,2,3.. oh tiens, j'ai la flemme de compter, prend le paquet!",
-- 	"J'viens d'avoir une prime, t'as d'la chance gamin!",
-- 	"Encore toi? Putain, ils t'esclavagisent! Tiens, courage mon vieux.",
-- 	"Cadeau, toujours à l'heure!",
-- 	"J'ai faim, dégage!"
-- }

RegisterServerEvent("iPompiste:spawnVehGarage")
AddEventHandler("iPompiste:spawnVehGarage", function(carPrice, carPlate)
	local source = source
	TriggerEvent("es:getPlayerFromId", source, function(user)
		TriggerEvent("ijob:getJobFromName", user.get('job'), function(medicJob)
			if not(user.getSessionVar('caution', carPrice)) then
				medicJob.removeCapital(carPrice)
				medicJob.addLost(user, carPrice, "prise de véhicule de fonction.")
				user.setSessionVar('caution', carPrice)
				user.notify("Le gérant te prete un véhicule. Si tu ne le ramène pas, il te demandera de payer la moitié du prix du véhicule. Prends en soin!", "error", "topCenter", true, 5000)
			end
		end)
	end)
end)

RegisterServerEvent("iPompiste:spawnTrailer")
AddEventHandler("iPompiste:spawnTrailer", function(carPlate)
	local source = source
	TriggerEvent("es:getPlayerFromId", source, function(user)
		TriggerEvent("tShop:registerNewVeh", carPlate, user.get('identifier'), 450.0)
		user.notify("Tu auras ta cargaison dedans, je te conseille d'en prendre soin !", "error", "topCenter", true, 5000)
	end)
end)

RegisterServerEvent("iLivreur:retreiveCaution")
AddEventHandler("iLivreur:retreiveCaution", function(carPrice)
	local source = source
	TriggerEvent("es:getPlayerFromId", source, function(user)
		TriggerEvent("ijob:getJobFromName", user.get('job'), function(medicJob)
			medicJob.addCapital(user.getSessionVar('caution'))
			medicJob.addBenefit(user, user.getSessionVar('caution'), "Ajout du véhicule au garage.")
			user.setSessionVar("caution", nil)
			user.notify("Tu viens de ramener le véhicule au garage.", "success", "topCenter", true, 5000)
			TriggerEvent("tShop:removeVeh", carPlate)
		end)
	end)
end)

AddEventHandler("is:playerDropped", function(user)
	if user.get('job') == "pompiste" then
		if user.getSessionVar("caution") ~= nil then
			user.removeBank(user.getSessionVar("caution")/2)
			TriggerEvent("tShop:removeVeh", carPlate)
		end
	end
end)

RegisterServerEvent("iPompiste:syncServiceWithServer")
AddEventHandler("iPompiste:syncServiceWithServer", function(isInService)
	local source = source
	TriggerEvent("es:getPlayerFromId", source, function(user)
		local var = nil
		if isInServer then
			var = "prendre"
		else
			var = "quitter"
		end
		user.notify("Tu viens de "..var.. " ton service.", "success", "topCenter", true, 5000)
		user.setSessionVar("inService", isInService)
	end)
end)

-- RegisterServerEvent("iLivreur:removeObjectsArray")
-- AddEventHandler("iLivreur:removeObjectsArray", function(items)
-- 	local source = source
-- 	TriggerEvent("es:getPlayerFromId", source, function(user)
-- 		local item = {}
-- 		local quantity = {}
-- 		for i = 1, #items do
-- 			table.insert(item, items[i].item.id)
-- 			table.insert(item, items[i].quantity)
-- 		end
-- 		user.removeQuantityArray(item, quantity)
-- 		user.refreshInventory()
-- 	end)
-- end)

-- RegisterServerEvent("iLivreur:pourboire")
-- AddEventHandler("iLivreur:pourboire", function(pourboire)
-- 	local source = source
-- 	TriggerEvent("es:getPlayerFromId", source, function(user)
-- 		user.addMoney(pourboire)
-- 		local messageNumber = math.random(1, #pourboireMessages)
-- 		user.notify(pourboireMessages[messageNumber], "success", "topCenter", true, 5000)
-- 	end)
-- end)

-- RegisterServerEvent("iLivreur:endedMission")
-- AddEventHandler("iLivreur:endedMission", function(MissionInfos, nowTime)
-- 	local source = source
-- 	local pallier = {0.75, 1 , 1.48, 1.87}
-- 	local multiplicator = {1.15, 1.25, 1.45, 1.84}
-- 	local timeHePut = time - MissionInfos.time
-- 	local distance = MissionInfos.totalShortestDistance
-- 	local ratio = distance / timeHePut
-- 	local thisPallier = 0
-- 	for i = 1, #pallier do
-- 		if pallier[i] > ratio then
-- 			thisPallier = i
-- 		end
-- 	end
-- 	local givenMoney = math.ceil(MissionInfos.totalValue * multiplicator[thisPallier])
-- 	user.addBank(givenMoney)
-- 	user.notify("Voilà ta paye: " .. givenMoney .. "$, par contre, bouges ton cul la prochaine fois, surtout si c'est toi Hqdez!", "success", "topCenter", true, 5000)
-- end)