local zoneBike = {x = -1039.15, y = -2664.13, z = 13.83}
local bikeHash = 1131912276
local bikePrice = 50
local xp, yp, zp
local distance

function WTFDisplayHelpText(str)
	SetTextComponentFormat("STRING")
	AddTextComponentString(str)
	DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end

Citizen.CreateThread(function()
	local blip = AddBlipForCoord(zoneBike.x, zoneBike.y, zoneBike.z)
	SetBlipSprite(blip, 494)
	SetBlipColour(blip, 2)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString('Rent a bike')
	EndTextCommandSetBlipName(blip)
	SetBlipAsShortRange(blip,true)
	SetBlipAsMissionCreatorBlip(blip,true)
    while true do
        Citizen.Wait(0)
        xp, yp, zp = table.unpack(GetEntityCoords(GetPlayerPed(-1), 1))
        distance = GetDistanceBetweenCoords(zoneBike.x, zoneBike.y, zoneBike.z, xp, yp, zp, 0)
        if distance <= 75 then
        	DrawMarker(0, zoneBike.x, zoneBike.y, zoneBike.z - 1, 0, 0, 0, 0, 0, 0, 2.0001, 2.0001, 2.0001, 255, 255, 0, 165, 0, 0, 0,0)
        end
		if distance <= 4 then
			WTFDisplayHelpText('Press ~INPUT_CONTEXT~ to rent a bike for ~r~ ' .. bikePrice .. '$')
			if IsControlJustPressed(1, 38) then
				TriggerServerEvent("rent:payMyBike", bikePrice)
			end
		end
    end
end)

RegisterNetEvent("bike:okbuy")
AddEventHandler("bike:okbuy", function()
	SpawnMyBike(bikeHash)
end)

RegisterNetEvent("bike:notif")
AddEventHandler("bike:notif", function(string)
	drawNotification(string)
end)

function drawNotification(text)
	SetNotificationTextEntry("STRING")
	AddTextComponentString(text)
	DrawNotification(false, false)
end

function SpawnMyBike(hash)
	local car = hash
	local playerPed = GetPlayerPed(-1)
	RequestModel(car)
	while not HasModelLoaded(car) do
			Citizen.Wait(0)
	end
	local playerCoords = GetEntityCoords(playerPed)
	myVeh = CreateVehicle(car, playerCoords, 90.0, true, false)
	SetVehicleOnGroundProperly(myVeh)
	SetVehicleHasBeenOwnedByPlayer(myVeh,true)
	local netid = NetworkGetNetworkIdFromEntity(myVeh)
	SetNetworkIdCanMigrate(netid, true)
	SetEntityAsMissionEntity(myVeh, true, true)
	TaskWarpPedIntoVehicle(playerPed, myVeh, -1)
	SetEntityInvincible(myVeh, false)
	SetEntityAsMissionEntity(myVeh, true, true)
end
