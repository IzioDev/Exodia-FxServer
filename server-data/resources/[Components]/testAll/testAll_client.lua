Citizen.CreateThread(function()
	while true do
		Wait(0)
		if IsControlJustPressed(1, 38) then

			-- local forwardVector = GetEntityForwardVector(GetPlayerPed(-1)) à essayer? peut être un poils plus précis
			local playerPos = GetEntityCoords(GetPlayerPed(-1), 1 )
			local found = false

            for i = 1, 10 do
            	local inFrontOfPlayer = GetOffsetFromEntityInWorldCoords( GetPlayerPed(-1), 0.0, 0.2 * i , 0.0 )
            	local entity = GetEntityInDirection( playerPos, inFrontOfPlayer )
            	-- if DoesEntityExist(entity) then
            	-- 	print("exist")
            	-- 	if IsEntity(entity) then IsEntityA
            	-- 		print("We found an object! :'D")
            	-- 		local model = GetEntityModel(entity)
            	-- 		print("Model is : " .. model)
            	-- 		found = true
            	-- 		break
            	-- 	end
            	-- end
            	print(entity)
            	
            end

            if not(found) then
            	print("We found nothing :'( ")
            end

		end
	end
end)

function GetEntityInDirection( coordFrom, coordTo )
    local rayHandle = CastRayPointToPoint( coordFrom.x, coordFrom.y, coordFrom.z, coordTo.x, coordTo.y, coordTo.z, 10, GetPlayerPed( -1 ), 0 )
    local _, _, _, _, vehicle = GetRaycastResult( rayHandle )
    return vehicle
end