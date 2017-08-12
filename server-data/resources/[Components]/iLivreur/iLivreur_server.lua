-- Copyright (C) Izio, Inc - All Rights Reserved
-- Unauthorized copying of this file, via any medium is strictly prohibited
-- Proprietary and confidential
-- Written by Romain Billot <romainbillot3009@gmail.com>, Jully 2017

RegisterServerEvent("iLivreur:spawnVehGarage")
AddEventHandler("iLivreur:spawnVehGarage", function(carPrice)
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

RegisterServerEvent("iLivreur:retreiveCaution")
AddEventHandler("iLivreur:retreiveCaution", function(carPrice)
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

RegisterServerEvent("iLivery:GenerateNeeds")
AddEventHandler("iLivery:GenerateNeeds", function()
	local source = source
	TriggerEvent("es:getPlayerFromId", source, function(user)

	end)
end)