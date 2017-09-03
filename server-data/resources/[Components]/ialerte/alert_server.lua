RegisterServerEvent("alerte:askForAlerte")
AddEventHandler("alerte:askForAlerte", function()
	local source = source
	TriggerEvent("es:getPlayerFromId", source, function(user)
		user.alert("Faire le plein ?", "Les prix sont en baisse, seulement 50$ le litre", {event = "station:unfillTankContainer"})
	end)
end)