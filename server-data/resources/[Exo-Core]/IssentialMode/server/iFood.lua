local hungerMult = 0.8
local thirstMult = 0.5

AddEventHandler('es:playerLoaded', function(source)
	TriggerEvent('es:getPlayerFromId', source, function(user)
		TriggerClientEvent('iFood:openNUI', source, user.getHungerMessage(), user.getThirstMessage())
	end)
end)

RegisterServerEvent("iFood:looseNeeds")
AddEventHandler("iFood:looseNeeds", function(needToBeRemoved)
	local source = source
	local hunger = needToBeRemoved * hungerMult
	local thirst = hunger * 2.4 * thirstMult
	TriggerEvent("es:getPlayerFromId", source, function(user)
		user.reduceHunger(math.ceil(hunger * 100)/100)
		user.reduceThirst(math.ceil(thirst * 100)/100)
	end)
end)