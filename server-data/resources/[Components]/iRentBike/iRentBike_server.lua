RegisterServerEvent("rent:payMyBike")
AddEventHandler("rent:payMyBike", function(price)
	print(type(source))
	print(source)
	source = tonumber(source)
	TriggerEvent("es:getPlayerFromId", source, function(user)
		if user.get('money') < price then
			user.notify("<b style='color: red'> You don't have enough cash for this.</b>", "error", "centerLeft", true, 5000)
		else
			print(user.getSessionVar("waitBike"))
			print(os.time())
			if user.getSessionVar("waitBike") == nil or (user.getSessionVar("waitBike") + 30) < os.time() then
				user.removeMoney(price)
				user.notify("<b style='color: green'> There it is, don't forget your bycicle helmet.</b>", "success", "centerLeft", true, 5000)
				TriggerClientEvent("bike:okbuy", user.get('source'))
				user.setSessionVar("waitBike", os.time())
			else
				user.notify("<b style='color: red' > Wait, I just gave you one ! </b>", "error", "centerLeft", true, 5000)
			end
		end
	end)
end)