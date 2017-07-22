local states = {}
states.frozen = false
states.frozenPos = nil
local vanish = false
local godmode = false



RegisterNetEvent('es_admin:spawnVehicle')
AddEventHandler('es_admin:spawnVehicle', function(v)
	local carid = GetHashKey(v)
	local playerPed = GetPlayerPed(-1)
	if playerPed and playerPed ~= -1 then
		RequestModel(carid)
		while not HasModelLoaded(carid) do
				Citizen.Wait(0)
		end
		local playerCoords = GetEntityCoords(playerPed)

		veh = CreateVehicle(carid, playerCoords, 0.0, true, false)
		SetVehicleAsNoLongerNeeded(veh)
		TaskWarpPedIntoVehicle(playerPed, veh, -1)
	end
end)

RegisterNetEvent('es_admin:doHashes')
AddEventHandler('es_admin:doHashes', function(hashes)
	local done = 1
	Citizen.CreateThread(function()
		while done - 1 < #hashes do
			Citizen.Wait(50)
			TriggerServerEvent('es_admin:givePos', hashes[done] .. "=" .. GetHashKey(hashes[done]) .. "\n")
			TriggerEvent('chatMessage', 'SYSTEM', {255, 0, 0}, 'Vehicles left: ' .. (#hashes - done) )
			done = done + 1
		end
	end)
end)

RegisterNetEvent('es_admin:getHash')
AddEventHandler('es_admin:getHash', function(h)
	TriggerEvent("chatMessage", "HASH", {255, 0, 0}, tostring(GetHashKey(h)))
end)

RegisterNetEvent('es_admin:freezePlayer')
AddEventHandler("es_admin:freezePlayer", function(state)
	local player = PlayerId()

	local ped = GetPlayerPed(-1)

	states.frozen = state
	states.frozenPos = GetEntityCoords(ped, false)

	if not state then
			if not IsEntityVisible(ped) then
					SetEntityVisible(ped, true)
			end

			if not IsPedInAnyVehicle(ped) then
					SetEntityCollision(ped, true)
			end

			FreezeEntityPosition(ped, false)
			--SetCharNeverTargetted(ped, false)
			SetPlayerInvincible(player, false)
	else

			SetEntityCollision(ped, false)
			FreezeEntityPosition(ped, true)
			--SetCharNeverTargetted(ped, true)
			SetPlayerInvincible(player, true)
			--RemovePtfxFromPed(ped)

			if not IsPedFatallyInjured(ped) then
					ClearPedTasksImmediately(ped)
			end
	end
end)

RegisterNetEvent('es_admin:teleportUser')
AddEventHandler('es_admin:teleportUser', function(x, y, z)
	SetEntityCoords(GetPlayerPed(-1), x, y, z)
	states.frozenPos = {x = x, y = y, z = z}
end)

RegisterNetEvent('es_admin:teleportToMarker')
AddEventHandler('es_admin:teleportToMarker', function()
	local myMarker = GetFirstBlipInfoId(8)
	local x, y, z = table.unpack(GetBlipCoords(myMarker))
	if(myMarker) then
		if x and y and z then
			print(x .. " " .. y .. " " .. z)
			SetEntityCoords(GetPlayerPed(-1), tonumber(x), tonumber(y), tonumber(z)+1.1)
			states.frozenPos = {x = x, y = y, z = z}
		end
	end
end)

RegisterNetEvent('es_admin:teleportSomeOneToMyMarker')
AddEventHandler("es_admin:teleportSomeOneToMyMarker", function(targetSource)
	local myMarker = GetFirstBlipInfoId(8)
	local x, y, z = table.unpack(GetBlipCoords(myMarker))
	if(myMarker) then
		if x and y and z then
			TriggerServerEvent("es_admin:sendCoordsTeleportSomeOneToMyMarker", tonumber(x), tonumber(y), tonumber(z)+1.1, targetSource)
		end
	end
end)

RegisterNetEvent('es_admin:slap')
AddEventHandler('es_admin:slap', function()
	local ped = GetPlayerPed(-1)

	ApplyForceToEntity(ped, 1, 9500.0, 3.0, 7100.0, 1.0, 0.0, 0.0, 1, false, true, false, false)
end)

RegisterNetEvent('es_admin:givePosition')
AddEventHandler('es_admin:givePosition', function(myName)
	local pos = GetEntityCoords(GetPlayerPed(-1))
	local heading = GetEntityHeading(GetPlayerPed(-1))
	local string = "{ ['name'] = " .. myName .. ", ['heading'] = " .. heading .. ", ['x'] = " .. pos.x .. ", ['y'] = " .. pos.y .. ", ['z'] = " .. pos.z .. " },\n"
	TriggerServerEvent('es_admin:givePos', string)
	TriggerEvent('chatMessage', 'SYSTEM', {255, 0, 0}, 'Position saved to [Admin]/iAdmin/position.txt file.')
end)

RegisterNetEvent('es_admin:kill')
AddEventHandler('es_admin:kill', function()
	SetEntityHealth(GetPlayerPed(-1), 0)
end)

RegisterNetEvent('es_admin:heal')
AddEventHandler('es_admin:heal', function()
	SetEntityHealth(GetPlayerPed(-1), 200)
end)

RegisterNetEvent('es_admin:crash')
AddEventHandler('es_admin:crash', function()
	while true do
	end
end)

local noclip = false

RegisterNetEvent("es_admin:noclip")
AddEventHandler("es_admin:noclip", function(t)
	local msg = "disabled"
	if(noclip == false)then
		noclip_pos = GetEntityCoords(GetPlayerPed(-1), false)
	end

	noclip = not noclip

	if(noclip)then
		msg = "enabled"
	end

	TriggerEvent("chatMessage", "SYSTEM", {255, 0, 0}, "Noclip has been ^2^*" .. msg)
end)

RegisterNetEvent("is:giveWeaponToPlayer")
AddEventHandler("is:giveWeaponToPlayer", function(weapon, ammo)
	if type(weapon) == "table" then
		for i = 1, #weapon do
			GiveWeaponToPed(GetPlayerPed(-1), GetHashKey(weapon[i]), 300, 0, 0)
		end
	else
		GiveWeaponToPed(GetPlayerPed(-1), GetHashKey(weapon), tonumber(ammo), false, false)
	end
end)

RegisterNetEvent("is:vanishPlayer")
AddEventHandler("is:vanishPlayer", function()
	if vanish then
		SetEntityVisible(GetPlayerPed(-1), true, 1)
	else
		SetEntityVisible(GetPlayerPed(-1), false, 1)
	end
	vanish = not(vanish)
end)

RegisterNetEvent("is:godModPlayer")
AddEventHandler("is:godModPlayer", function()
	if godmod then
		SetPlayerInvincible(PlayerId(-1), false)
	else
		SetPlayerInvincible(PlayerId(-1), true)
	end
	godmod = not(godmod)
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(10)
		if(states.frozen)then
			ClearPedTasksImmediately(GetPlayerPed(-1))
			SetEntityCoords(GetPlayerPed(-1), states.frozenPos)
		end
	end
end)

local heading = 0

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		if(noclip)then
			SetEntityCoordsNoOffset(GetPlayerPed(-1),  noclip_pos.x,  noclip_pos.y,  noclip_pos.z,  0, 0, 0)

			if(IsControlPressed(1,  34))then
				heading = heading + 1.5
				if(heading > 360)then
					heading = 0
				end
				SetEntityHeading(GetPlayerPed(-1),  heading)
			end
			if(IsControlPressed(1,  9))then
				heading = heading - 1.5
				if(heading < 0)then
					heading = 360
				end
				SetEntityHeading(GetPlayerPed(-1),  heading)
			end
			if(IsControlPressed(1,  8))then
				noclip_pos = GetOffsetFromEntityInWorldCoords(GetPlayerPed(-1), 0.0, 1.0, 0.0)
			end
			if(IsControlPressed(1,  32))then
				noclip_pos = GetOffsetFromEntityInWorldCoords(GetPlayerPed(-1), 0.0, -1.0, 0.0)
			end

			if(IsControlPressed(1,  27))then
				noclip_pos = GetOffsetFromEntityInWorldCoords(GetPlayerPed(-1), 0.0, 0.0, 1.0)
			end
			if(IsControlPressed(1,  173))then
				noclip_pos = GetOffsetFromEntityInWorldCoords(GetPlayerPed(-1), 0.0, 0.0, -1.0)
			end
		end
	end
end)
