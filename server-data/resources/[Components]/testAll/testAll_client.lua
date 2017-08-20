-- Citizen.CreateThread(function()
--     while true do
--         Wait(0)
--         if IsControlJustPressed(1, 38) then -- "E"
--             if not (DoesDoorExist(732442693)) then 
--                 AddDoorToSystem(732442693, GetHashKey("prop_strip_door_01"), 127.96, -1298.51, 29.42, 1, 1, 0)
--             end
--             Citizen.InvokeNative(0x6F8838D03D1DC226, 732442693, GetHashKey("prop_strip_door_01"), 127.96, -1298.51, 29.42, 1, 1, 0)
--             Citizen.Trace(tostring(Citizen.InvokeNative(0xC153C43EA202C8C1, 732442693)))
--             Citizen.Trace(tostring(DoesDoorExist(732442693)))

--             SetDoorAjarAngle(732442693, 0.0, 1, 0)
--             SetDoorAccelerationLimit(732442693, 1, 1, 0)
--         end
--     end
-- end)

local point = { ['heading'] = 85.685806274414, ['x'] = 449.91482543945, ['y'] = -1019.6806030273, ['z'] = 28.470764160156 }
-- point.heading --> 85.685806274414
local vehHash = -591610296
local vehSpawned = false

Citizen.CreateThread(function()
    while true do
        Wait(0)
        if IsNearPoint(point, 5.0) and not(vehSpawned) then
            vehSpawned = true

            RequestModel(vehHash)

            local i = 0
            while not(HasModelLoaded(vehHash)) and i<5 do
                Wait(1000)
                i = i + 1
            end

            if i>5 then
                print("Model incorrect")
            end

            CreateVehicle(vehHash, point.x, point.y, point.z, point.heading, true, 1)
        end
    end
end)

function IsNearPoint(point, radius)
    local x,y,z = table.unpack(GetEntityCoords(GetPlayerPed(-1), true))
    if GetDistanceBetweenCoords(x, y, z, point.x, point.y, point.z, true) <= radius then
        return true
    else
        return false
    end
end