local opened = false

RegisterNetEvent('iFood:openNUI')
AddEventHandler('iFood:openNUI', function(hungerMsg, thirstMsg)
	if(not opened)then
		SendNuiMessage({
		    action = "open",
		    hungerMessage = hungerMsg,
		    thirstMessage = thirstMsg
		})
		opened = true
	end
end)

RegisterNetEvent('iFood:updateNUI')
AddEventHandler('iFood:updateNUI', function(what, msg)
	if(what == 'hunger')then
		SendNuiMessage({
		    action = "updateHunger",
		    hungerMessage = msg
		})
	else
		SendNuiMessage({
		    action = "updateThirst",
		    thirstMessage = msg
		})
	end
end)