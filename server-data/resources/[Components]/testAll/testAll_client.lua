Citizen.CreateThread(function()
    while true do
        Wait(0)
        if IsControlJustPressed(1, 38) then -- "E"
            if not (DoesDoorExist(732442693)) then 
                AddDoorToSystem(732442693, GetHashKey("prop_strip_door_01"), 127.96, -1298.51, 29.42, 1, 1, 0)
            end
            Citizen.InvokeNative(0x6F8838D03D1DC226, 732442693, GetHashKey("prop_strip_door_01"), 127.96, -1298.51, 29.42, 1, 1, 0)
            Citizen.Trace(tostring(Citizen.InvokeNative(0xC153C43EA202C8C1, 732442693)))
            Citizen.Trace(tostring(DoesDoorExist(732442693)))

            SetDoorAjarAngle(732442693, 0.0, 1, 0)
            SetDoorAccelerationLimit(732442693, 1, 1, 0)
        end
    end
end)
