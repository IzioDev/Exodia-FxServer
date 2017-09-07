local opened = false
local active = false

RegisterNetEvent("iFood:die")
AddEventHandler("iFood:die", function()
    active = true
    SetPlayerHealthRechargeMultiplier(PlayerId(), 0.0)
end)

RegisterNetEvent("iFood:cancelDeath")
AddEventHandler("iFood:cancelDeath", function()
    active = false
    SetPlayerHealthRechargeMultiplier(PlayerId(), 1.0)
end)

Citizen.CreateThread(function()
    while true do
        Wait(5000)
        if active then
            SetEntityHealth(GetPlayerPed(-1), GetEntityHealth(GetPlayerPed(-1)) - 15.0 )
            SendNuiMessage({
                action = "playSound"
            })
            if IsPedDeadOrDying(GetPlayerPed(-1), 1) then
                active = false
                SetPlayerHealthRechargeMultiplier(PlayerId(), 1.0)
            end
        end
    end
end)

RegisterNetEvent('iFood:openNUI')
AddEventHandler('iFood:openNUI', function(hungerMsg, thirstMsg)
	local hungerMsg = tostring(hungerMsg)
	local thirstMsg = tostring(thirstMsg)
	if not(opened) then
		SendNUIMessage({
		    foodAction = "openFood",
		    hungerMessage = hungerMsg,
		    thirstMessage = thirstMsg
		})
		opened = true
	end
end)

RegisterNetEvent('iFood:updateNUI')
AddEventHandler('iFood:updateNUI', function(what, msg)
	if(what == 'hunger')then
		SendNUIMessage({
		    action = "updateHunger",
		    hungerMessage = msg
		})
	else
		SendNUIMessage({
		    action = "updateThirst",
		    thirstMessage = msg
		})
	end
end)

Citizen.CreateThread(function()
	while true do
		Wait(0)
		if opened then
			local nowTime = GetGameTimer()
			local nowNeeds = 0
			while GetGameTimer() < nowTime + 10000 do
				Wait(0)
				if IsPedSprinting(GetPlayerPed(-1)) then
 					nowNeeds = nowNeeds + 4
				elseif IsPedRunning(GetPlayerPed(-1)) then
					nowNeeds = nowNeeds + 3
				elseif IsPedWalking(GetPlayerPed(-1)) then
					nowNeeds = nowNeeds + 2
				elseif IsPedStopped(GetPlayerPed(-1)) then
					nowNeeds = nowNeeds + 1
				end
			end
			nowNeeds = nowNeeds / 1800
			TriggerServerEvent("iFood:looseNeeds", nowNeeds)
		end
	end
end)