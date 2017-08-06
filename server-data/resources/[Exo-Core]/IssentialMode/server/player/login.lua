-- Copyright (C) Izio, Inc - All Rights Reserved
-- Unauthorized copying of this file, via any medium is strictly prohibited
-- Proprietary and confidential
-- Written by Romain Billot <romainbillot3009@gmail.com>, Jully 2017

local defaultSkin = {
	face = 30,
	pants_2 = 1,
	glasses_2 = 2,
	hair_color_1 = 4,
	shoes = 3,
	helmet_1 = 26,
	decals_2 = 0,
	sex = 0,
	arms = 4,
	hair_color_2 = 2,
	shoes_2 = 3,
	hair_2 = 3,
	beard_4 = 10,
	tshirt_1 = 28,
	beard_1 = 10,
	decals_1 = 0,
	pants_1 = 10,
	beard_3 = 61,
	torso_1 = 28,
	glasses_1 = 7,
	torso_2 = 1,
	tshirt_2 = 0,
	skin = 9,
	helmet_2 = 0,
	beard_2 = 7,
	hair_1 = 19
}
local saveTime = 60000

function LoadUser(identifier, source, new)
	local result = MySQL.Sync.fetchAll("SELECT * FROM users WHERE identifier=@name", {['@name'] = identifier})

	-- Create player Object
	Users[source] = CreateUser(source, result[1])

	-- Client Stuff
	TriggerClientEvent('es:setPlayerDecorator', source, 'rank', Users[source].getPermissions(), true)
	TriggerClientEvent('es:setMoneyIcon', source,settings.defaultSettings.moneyIcon)

	--PlayerLoaded
	TriggerEvent("es:playerLoaded", Users[source].get('source'))

	--Pvp :
	TriggerClientEvent("es:enablePvp", Users[source].get('source'))

	-- We put the UI Money & Dirty Money stuff
	TriggerClientEvent('es:activateMoney', source, Users[source].get('money'))
	TriggerClientEvent('es:activateDirtyMoney', source, Users[source].get('dirtyMoney'))
	TriggerClientEvent('ijob:updateJob', source, Users[source].get('job'), Users[source].get('rank'))

	if(new)then
		TriggerEvent('es:newPlayerLoaded', source, Users[source])
	end
end

RegisterServerEvent("es:LoadChar")
AddEventHandler("es:LoadChar", function(firstname, lastname, age, new)
	LoadUserFromPicking(firstname, lastname, age, new, tonumber(source), new)
end)

function LoadUserFromPicking(firstname, lastname, age, new, source, new2)
	local identifier = GetPlayerIdentifiers(source)[1]
	if new then
		RegisterANewChar(identifier, source, firstname, lastname, age, new2)
	else
		local result = MySQL.Sync.fetchAll("SELECT * FROM users WHERE identifier=@name", {['@name'] = identifier})
		local treatId
		local founded
		for i = 1, #result do -- search the good Character
			treatId = json.decode(result[i].identity)
			if treatId.firstName == firstname and treatId.lastName == lastname and tonumber(treatId.age) == tonumber(age) then
				founded = i
				break
			end
		end -- Mabe make a verification after that ? like if not founded and founded == nil then DropConnection ?
		-- Create player Object
		Users[source] = CreateUser(source, result[founded])

		-- Client Stuff
		TriggerClientEvent('es:setPlayerDecorator', source, 'rank', Users[source].getPermissions(), true)
		TriggerClientEvent('es:setMoneyIcon', source,settings.defaultSettings.moneyIcon)

		--PlayerLoaded
		TriggerEvent("es:playerLoaded", Users[source].get('source'))
		--Pvp :
		TriggerClientEvent("es:enablePvp", Users[source].get('source'))

		--Unfreeeze UnInvicible the player + change location
		TriggerClientEvent("es:afterSelection", Users[source].get('source'), Users[source].get('lastpos'))

		-- We put the UI Money & Dirty Money stuff &Job Stuff
		TriggerClientEvent('es:activateMoney', source, Users[source].get('money'))
		TriggerClientEvent('es:activateDirtyMoney', source, Users[source].get('dirtyMoney'))
		TriggerClientEvent('ijob:updateJob', source, Users[source].get('job'), Users[source].get('rank'))
		
		if(new2)then
			TriggerEvent('es:newPlayerLoaded', source, Users[source])
		end
	end
end

function RegisterANewChar(identifier, source, firstname, lastname, age, ok)
	local temp = os.date("*t", os.time())
	local minutsLenght = string.len(tostring(temp.min))
	if minutsLenght == 1 then
		temp.min = "0" .. temp.min
	end
	local lastSeen = tostring(temp.hour) .. "h" .. tostring(temp.min) .. " | " .. tostring(temp.month) .. " / " .. tostring(temp.day) .. " / " .. tostring(temp.year)
	MySQL.Sync.execute("INSERT INTO users (`identifier`, `permission_level`, `money`, `group`, `rank`, `job`, `inventory`, `identity`, `skin`, `bank`, `lastpos`, `otherInGameInfos`) VALUES (@username, @permission_level, @money, 'user', @rank, @job, @inventory, @identity, @skin, @bank, @lastpos, @otherInGameInfos)", {
	    ['@username'] = identifier,
	    ['@permission_level'] = 0,
	    ['@money'] = 500,
	    ['@rank'] = " ",
	    ['@job'] = settings.defaultSettings.unEmployed,
	    ['@inventory'] = json.encode({}),
	    ['@identity'] = json.encode({firstName = firstname, lastName = lastname, age = age, phoneNumber = "NOOBI", playTime = "0", accountNumber = "0", lastSeen = lastSeen}),
	    ['@skin'] = json.encode(defaultSkin),
	    ['@lastpos'] = json.encode({x = -1038.99, y = -2740.23, z = 13.86}),
	    ['@bank'] = 250,
	    ['@otherInGameInfos'] = json.encode({
	    		garage = false
	    	})
	})
 	LoadUserFromPicking(firstname, lastname, age, false, source, ok)
end

function getPlayerFromId(id)
	return Users[id]
end

function stringsplit(inputstr, sep)
        if sep == nil then
                sep = "%s"
        end
        local t={} ; i=1
        for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
                t[i] = str
                i = i + 1
        end
        return t
end

AddEventHandler('es:getPlayers', function(cb)
	cb(Users)
end)

function hasAccount(identifier)
	local result = MySQL.Sync.fetchAll("SELECT * FROM users WHERE identifier = @name", {['@name'] = identifier})
	if(result[1] == nil) then
		return false
	else
		return true
	end
end

function registerUser(identifier, source)
 	if not hasAccount(identifier) then
 		local temp = os.date("*t", os.time())
		local lastSeen = tostring(temp.min) .. " : " .. tostring(temp.hour) .. " | " .. tostring(temp.month) .. " / " .. tostring(temp.day) .. " / " .. tostring(temp.year)
		MySQL.Sync.execute("INSERT INTO users (`otherInGameInfos`, `identifier`, `permission_level`, `money`, `group`, `rank`, `job`, `inventory`, `identity`, `skin`, `bank`, `lastpos`) VALUES (@otherInGameInfos, @username, @permission_level, @money, 'user', @rank, @job, @inventory, @identity, @skin, @bank, @lastpos)", {
		    ['@username'] = identifier,
		    ['@permission_level'] = 0,
		    ['@money'] = 500,
		    ['@rank'] = " ",
		    ['@job'] = "Chomeur",
		    ['@inventory'] = json.encode({}),
		    ['@identity'] = json.encode({firstName = "Ana", lastName = "Nass", age = "20", phoneNumber = "NOOBI", playTime = "0", accountNumber = "0", lastSeen = lastSeen}),
		    ['@skin'] = json.encode(defaultSkin),
		    ['@lastpos'] = json.encode({x = -1038.99, y = -2740.23, z = 13.86}),
		    ['@bank'] = 250,
		    ['@otherInGameInfos'] = json.encode({
	    		garage = false
	    	})
		}, function (rowsUpdate)
		    print('\nUn nouveau joeur vient de s enregistrer\n')
		end)
 		LoadUser(identifier, source, true)
 	else
 		LoadUser(identifier, source, false)
 	end
end

function managePicking(identifier, source)
	if not hasAccount(identifier) then
		TriggerClientEvent("es:choicePicker", source, {}, 0, settings.defaultSettings.maxChars)
	else
		local chars, number = getAllInfosNeeded(identifier, source)
		TriggerClientEvent("es:choicePicker", source, chars, number, settings.defaultSettings.maxChars)
	end
end

function getAllInfosNeeded(identifier, source)
	local result = MySQL.Sync.fetchAll("SELECT * FROM users WHERE identifier=@name", {['@name'] = identifier})
	local treatId
	local charsInfos = {}
	for i = 1, #result do
		treatId = json.decode(result[i].identity)
		table.insert(charsInfos,
		{
			lastName = treatId.lastName,
			firstName = treatId.firstName,
			job = result[i].job,
			age = tostring(treatId.age),
			bankMoney = tostring(result[i].bank),
			lastSeen = treatId.lastSeen,
			money = tostring(result[i].money)
		}) -- on isère le nom et le prénom du joueur
	end
	return charsInfos, #charsInfos
end

function CheckWhiteList(identifier, source)
	local result = MySQL.Sync.fetchAll("SELECT * FROM whitelist WHERE identifier=@name", {['@name'] = identifier})
	if result[1] == nil then
		MySQL.Sync.execute("INSERT INTO whitelist (`identifier`, `isWhiteListed`) VALUES (@identifier, @isWhiteListed)", {
			['@identifier'] = identifier,
			['@isWhiteListed'] = 0
	})
	else
		if result[1].isWhiteListed == 0 then
			-- Drop
			DropPlayer(source, settings.defaultSettings.defaultMessageOnNotWhiteList)
			print("A not whitelisted player was kicked")
		else
			print("A whitelisted player is connecting")
		end
	end
end

AddEventHandler("es:setPlayerData", function(user, k, v, cb)
	if(Users[user])then
		if(Users[user].get(k))then

			if(k ~= "money") then
				Users[user].set(k, v)
			MySQL.Sync.execute("UPDATE users SET ".. k .. "=@value WHERE identifier = @identifier", 
			    {
			    	['@value'] = v,
			    	['@identifier'] = Users[user].get('identifier')

			    }, function(rowsUpdate)
			    	print("Player Datas edited")
			    end)
			end
			cb("Player data edited.", true)
		else
			cb("Column does not exist!", false)
		end
	else
		cb("User could not be found!", false)
	end
end)

AddEventHandler("es:setPlayerDataId", function(user, k, v, cb)
	MySQL.Sync.execute("UPDATE users SET @key=@value WHERE identifier = @identifier", 
			    {
			    	['@key'] = k,
			    	['@value'] = v,
			    	['@identifier'] = user

			    }, function(rowsUpdate)
			    	print("Player Datas edited")
			    end)

	cb("Player data edited.", true)
end)

AddEventHandler("es:getPlayerFromId", function(user, cb)
	if(Users)then
		if(Users[user])then
			cb(Users[user])
		else
			cb(nil)
		end
	else
		cb(nil)
	end
end)

AddEventHandler("es:getPlayerFromIdentifier", function(identifier, cb)
	local result = MySQL.Sync.fetchAll("SELECT * FROM users WHERE identifier = @name" , {['@name'] = identifier})
	if(result[1])then
		cb(result[1])
	else
		cb(nil)
	end
end)

AddEventHandler("es:getAllPlayers", function(cb)
	local result = MySQL.Sync.fetchAll("SELECT * FROM users" , {})
	if(result)then
		cb(result)
	else
		cb(nil)
	end
end)

-- Function to update player money every 60 seconds.
function savePlayerDatas()
	SetTimeout(saveTime, function()
		TriggerEvent("es:getPlayers", function(users)
			if users ~= nil then
				for k,v in pairs(users) do
					if v ~= nil then -- Pas sûr que cela soit nécéssaire
						v:incrementPlayTime()
						if v.get('haveChanged') == true then
							v.set('haveChanged', false)
							MySQL.Sync.execute("UPDATE users SET `otherInGameInfos`=@otherInGameInfos, `money`=@value, `dirty_money`=@v2, `job`=@v3, `rank`=@v4, `identity`=@v5, `inventory`=@v6, `lastpos`=@v7 WHERE identifier = @identifier AND id = @id",{
								['@value'] = v.get('money'),
								['@v2'] = v.get('dirtyMoney'),
								['@v3'] = v.get('job'),
								['@v4'] = v.get('rank'),
								['@v5'] = json.encode(v.get('identity')),
								['@v6'] = json.encode(v.get('inventory')),
								['@v7'] = json.encode(v.get('coords')),
								['@identifier'] = v.get('identifier'),
								['@id'] = v.get('id'),
								['otherInGameInfos'] = v.get('otherInGameInfos')
							})
						end
					end
				end
			else
				print("Pas de joueurs de connectés, la sauvegarde n'est pas faite.")
			end
		end)
		savePlayerDatas()
	end)
end

savePlayerDatas()
