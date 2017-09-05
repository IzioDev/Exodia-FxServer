local hungerMult = 1.0
local thirstMult = 1.0

AddEventHandler('es:playerLoaded', function(source)
	TriggerEvent('es:getPlayerFromId', source, function(user)
		print(tostring(user.get('hunger')) .. tostring(user.get('thirst')) )
		TriggerClientEvent('iFood:openNUI', source, user.get('hunger'), user.get('thirst'))
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