-- Copyright (C) Izio, Inc - All Rights Reserved
-- Unauthorized copying of this file, via any medium is strictly prohibited
-- Proprietary and confidential
-- Written by Romain Billot <romainbillot3009@gmail.com>, Jully 2017

AddEventHandler('iSkin:giveSkinToPlayerRestart', function()
	SetTimeout(5000, function()
		TriggerEvent("es:getPlayers", function(Users)
			for k,v in pairs(Users) do
				if v ~= nil then
					print(json.encode(v.get("skin")))
					TriggerClientEvent('esx_skin:responsePlayerSkinInfos', v.get('source'), json.encode(v.get("skin")), false)
				end
			end
		end)
	end)
end)

RegisterServerEvent("es:playerLoadedDelay")
AddEventHandler('es:playerLoadedDelay', function()
	TriggerEvent('es:getPlayerFromId', source, function(user)
		print(user.get('freeSkin'))
		if user.get('freeSkin') then
			print("free")
			TriggerClientEvent('esx_skin:responsePlayerSkinInfos', user.get('source'), json.encode(user.get('skin')), true)
		else
			print("not free")
			TriggerClientEvent('esx_skin:responsePlayerSkinInfos', user.get('source'), json.encode(user.get('skin')), false)
		end
	end)

end)

RegisterServerEvent('skin:notFirstSpawn')
AddEventHandler('skin:notFirstSpawn', function()

	TriggerEvent('es:getPlayerFromId', source, function(user)
		TriggerClientEvent('esx_skin:responsePlayerSkinInfos', user.get('source'), json.encode(user.get('skin')), false)

	end)

end)

RegisterServerEvent("skin:retrieveOnExitMenu")
AddEventHandler('skin:retrieveOnExitMenu', function()

	TriggerEvent('es:getPlayerFromId', source, function(user)
		TriggerClientEvent('esx_skin:responsePlayerSkinInfos', user.get('source'), json.encode(user.get('skin')), false)

	end)

end)

AddEventHandler('es:newPlayerLoaded', function(newServerId, newUser)
	newUser.setGlobal('freeSkin', true)
end)

RegisterServerEvent('esx_skin:savePlayerSkinInfos')
AddEventHandler('esx_skin:savePlayerSkinInfos', function(skin)
	local msg = "You don't have enough money, come back with <b style='color: red'> 500$!</b>"
	TriggerEvent('es:getPlayerFromId', source, function(user)
		if user.get('money') >= 500 or user.get('freeSkin') ~= nil and user.get('freeSkin') then
			user.set('skin', skin)
			MySQL.Sync.execute("UPDATE users SET skin = @skin WHERE identifier = @identifier AND id = @id", {
				['@identifier'] = user.get('identifier'),
				['@skin'] = json.encode(skin),
				['@id'] = user.get('id')
				})
			if not(user.get('freeSkin')) then
				user.removeMoney(500)
				msg = "<b style='color:green'>Your new clothes are here! </b> Give me <b style='color : red'> 500$!</b> Now."
			else
				msg = "Welcome in that <b style='color:green'> beautifull </b> city !"
			end
			user.notify(msg, "success", "centerLeft", true, 5000)
		else
			user.notify(msg, "error", "centerLeft", true, 5000)
		end
	end)
end)

TriggerEvent('es:addGroupCommand', 'skin', "owner", function(source, args, user)
	if #args~=2 then
		user.notify("Utilisation : /skin [PID]", "error", "topCenter", true, 5000)
	else
		TriggerEvent("es:getPlayerFromId", tonumber(args[2]), function(targetUser)
			if targetUser ~= nil then
				targetUser.setGlobal('freeSkin', true)
				targetUser.notify("Un admin vous a donné un acces gratuit au changement de skin", "success", "topCenter", true, 5000)
				TriggerClientEvent('esx_skin:responsePlayerSkinInfos', targetUser.get('source'), json.encode(user.get('skin')), true)
			else
				user.notify("Le joueur n'est pas en ligne", "error", "topCenter", true, 5000)
			end
		end)
	end
end, function(source, args, user)
	user.notify("Tu n'es pas admin mon coco :p", "error", "topCenter", true, 5000)
end)

TriggerEvent('es:addGroupCommand', 'saveskin', "owner", function(source, args, user)
	TriggerClientEvent('esx_skin:saveSkinRequest', source)
end, function(source, args, user)
	TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Insufficient Permissions.")
end)