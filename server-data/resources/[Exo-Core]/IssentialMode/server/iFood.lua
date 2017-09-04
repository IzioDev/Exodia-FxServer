local hungerMult = 1.0
local thirstMult = 1.0

AddEventHandler('es:playerLoaded', function(source)
	TriggerEvent('es:getPlayerFromId', source, function(user)
		TriggerClientEvent('iFood:openNUI', source, user.get('hunger'), user.get('thirst'))
	end)
end)

RegisterServerEvent("iFood:looseNeeds")
AddEventHandler("iFood:looseNeeds", function(needToBeRemoved)
	local source = source
	local hunger = needToBeRemoved * hungerMult
	local thirst = hunger * 2.4 * thirstMult
	TriggerEvent("es:getPlayerFromId", source, function(user)
		user.reduceHunger(hunger)
		user.reduceThirst(thirst)
	end)
end)