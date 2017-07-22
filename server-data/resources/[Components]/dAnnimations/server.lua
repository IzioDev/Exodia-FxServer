-- No Require anymore

-- RegisterServerEvent("ask_sex")
-- AddEventHandler("ask_sex", function()

--     local identifiers = GetPlayerIdentifiers(source)[1]

--     local executed_query = MySQL:executeQuery("SELECT skin FROM users WHERE identifier = '@name'", {['@name'] = identifiers})
--     local result = MySQL:getResults(executed_query, {"skin"}, "identifier")
--     result = json.decode(result[1].skin)

--     local sex = result.sex

--     if sex then
--         TriggerClientEvent("get_sex", source, sex)
--     else
--         TriggerClientEvent("get_sex", source, 0)
--     end
-- end)

-- Let's get the user.sex (need to be implemented into IssentialMode) :
AddEventHandler("es:playerLoaded", function(source)
    source = tonumber(source) -- Never trust that shit
    local sex = nil
    TriggerEvent("es:getPlayerFromId", source, function(user) -- Get the user object from source
        sex = tonumber(user.get("sex")) -- You can get anything from that object. Just have a look to all the self.shit var into IssentialMode/server/classes/player.lua
    end)
    -- Now just send it to the client. (We also need to get it back on resource restart what I will do just after)
    TriggerClientEvent("get_sex", source, sex)
end)

AddEventHandler("annim:onResourceRestart", function() -- Manage de restart with IssentialMode
    SetTimeout(500, function()
        TriggerEvent("es:getPlayers", function(Users)
            for k,v in pairs(Users) do
                if v ~= nil then -- Just to be sure
                    TriggerClientEvent("get_sex", tonumber(v.get('source')), tonumber(v.get('sex')))
                end
            end
        end)
    end)
end)