AddEventHandler('es:playerLoaded', function(source)
	TriggerEvent('es:getPlayerFromId', source, function(user)
		TriggerClientEvent('iFood:openNUI', source, user.get('hunger'), user.get('thirst'))
	end)
end)

RegisterServerEvent("iFood:looseNeeds")
AddEventHandler("iFood:looseNeeds", function(needToBeRemoved)
	local hunger = needToBeRemoved
	local thirst = hunger * 1.8
	
end)