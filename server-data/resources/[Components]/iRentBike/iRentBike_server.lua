RegisterServerEvent("rent:payMyBike")
AddEventHandler("rent:payMyBike", function(price)
	print(type(source))
	print(source)
	source = tonumber(source)
	TriggerEvent("es:getPlayerFromId", source, function(user)
		if user.get('money') < price then
			user.notify("<b style='color: red'> Tu n'as pas assez d'argent pour ça.</b>", "error", "topCenter", true, 5000)
		else
			print(user.getSessionVar("waitBike"))
			print(os.time())
			if user.getSessionVar("waitBike") == nil or (user.getSessionVar("waitBike") + 30) < os.time() then
				user.removeMoney(price)
				user.notify("<b style='color: green'> Et voilà! N'oublie pas ton casque de vélo!</b>", "success", "topCenter", true, 5000)
				TriggerClientEvent("bike:okbuy", user.get('source'))
				user.setSessionVar("waitBike", os.time())
			else
				user.notify("<b style='color: red' > Attend, je viens juste de t'en louer un! </b>", "error", "topCenter", true, 5000)
			end
		end
	end)
end)