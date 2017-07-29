-- Copyright (C) Izio, Inc - All Rights Reserved
-- Unauthorized copying of this file, via any medium is strictly prohibited
-- Proprietary and confidential
-- Written by Romain Billot <romainbillot3009@gmail.com>, Jully 2017

Users = {}
StoppingManager = {
	["tShop"] = {"onVehRestart", "car:retrieveItemRestart"},
	["dAnnimations"] = {"annim:onResourceRestart"},
	["inventory"] = {"inventory:retrieveItemRestart"},
	["iskin"] = {"iSkin:giveSkinToPlayerRestart"},
	["iZone"] = {"onRestartZone"},
	["ijob"] = {"iJob:loadingAfterRestart"},
	["dbank"] = {"resart:dBank"}
}
tickRateEventManager = 40
treating = false
Waiting = {}
WaitingReady = {}
commands = {}
settings = {}
settings.defaultSettings = {
	['pvpEnabled'] = true,
	['permissionDenied'] = false,
	['debugInformation'] = false,
	['startingCash'] = 0,
	['enableRankDecorators'] = false,
	['moneyIcon'] = "€",
	['nativeMoneySystem'] = false,
	['commandDelimeter'] = '/',
	['manageCharacter'] = true,
	['maxChars'] = 5,
	['unEmployed'] = "chomeur", -- default job
	['whiteList'] = false,
	['defaultMessageOnNotWhiteList'] = "Go on http://www.myWebsite.com to create your character. Have a nice day ;)"
}
settings.sessionSettings = {}

AddEventHandler('playerDropped', function()
	local src = tonumber(source)
	if(Users[src]) or Users[src] ~= nil then
		temp = os.date("*t", os.time())
		local minutsLenght = string.len(tostring(temp.min))
		if minutsLenght == 1 then
			temp.min = "0" .. temp.min
		end
		local userIdentity = Users[src].get('identity')
		userIdentity.lastSeen = tostring(temp.hour) .. "h" .. tostring(temp.min) .. " | " .. tostring(temp.month) .. " / " .. tostring(temp.day) .. " / " .. tostring(temp.year)
		MySQL.Sync.execute("UPDATE users SET `money`=@value, `dirty_money`=@v2, `inventory`=@inventory, `identity`=@identity, `bank` = @bank, `lastpos`=@lastpos WHERE identifier = @identifier AND id = @id", {
			['@value'] = Users[src].get('money'),
			['@v2'] = Users[src].get('dirtyMoney'),
			['@inventory'] = json.encode(Users[src].get('inventory')),
			['@identity'] = json.encode(userIdentity),
			['@identifier'] = Users[src].get('identifier'),
			['@id'] = Users[src].get('id'),
			['@bank'] = Users[src].get('bank'),
			['@lastpos'] = json.encode(Users[src].get('coords'))
		})
		print('\nLe joueur : ' .. Users[src].get('identifier') .. ' vient de se déconnecter\n')
		Users[src] = nil
	end
end)

local justJoined = {}

RegisterServerEvent('es:firstJoinProper')
AddEventHandler('es:firstJoinProper', function()
	if settings.defaultSettings.whiteList then
		CheckWhiteList(GetPlayerIdentifiers(tonumber(source))[1], tonumber(source))
	end
	if settings.defaultSettings.manageCharacter then
		-- Wait for the creation or pick
		managePicking(GetPlayerIdentifiers(tonumber(source))[1], tonumber(source))
	else
		registerUser(GetPlayerIdentifiers(tonumber(source))[1], tonumber(source))
		justJoined[source] = true
	end

	if(settings.defaultSettings.pvpEnabled)then
		TriggerClientEvent("es:enablePvp", source)
	end
end)

RegisterServerEvent("es:deleteChar")
AddEventHandler("es:deleteChar", function( firstname, lastname, lastSeen)
	local founded
	local forDecodedID
	identifier = GetPlayerIdentifiers(source)[1]

	local result = MySQL.Sync.fetchAll("SELECT * FROM users WHERE identifier = @identifier", {
		['identifier'] = identifier
		})
	for i = 1, #result do
		forDecodedId = json.decode(result[i].identity)
		if forDecodedId.lastName == lastname and forDecodedId.firstName == firstname and forDecodedId.lastSeen == lastSeen then
			founded = i
			print("trouvé")
			break
		else
			print("non trouvé")
		end
	end
	if founded then
		print("there is nothing here")
		MySQL.Sync.execute("DELETE FROM users WHERE identifier=@identifier AND identity = @identity", {
			['identifier'] = identifier,
			['identity'] = result[founded].identity
			})
	end
end)

AddEventHandler('es:setSessionSetting', function(k, v)
	settings.sessionSettings[k] = v
end)

AddEventHandler('es:getSessionSetting', function(k, cb)
	cb(settings.sessionSettings[k])
end)

RegisterServerEvent('playerSpawn')
AddEventHandler('playerSpawn', function()
	if(justJoined[source])then
		TriggerEvent("es:firstSpawn", source)
		justJoined[source] = nil
	end
end)

AddEventHandler("es:setDefaultSettings", function(tbl)
	for k,v in pairs(tbl) do
		if(settings.defaultSettings[k] ~= nil)then
			settings.defaultSettings[k] = v
		end
	end

	debugMsg("Default settings edited.")
end)

AddEventHandler('chatMessage', function(source, n, message)
	if(startswith(message, settings.defaultSettings.commandDelimeter))then
		local command_args = stringsplit(message, " ")

		command_args[1] = string.gsub(command_args[1], settings.defaultSettings.commandDelimeter, "") -- on ne prend que les arguments : /test ok --> ok

		local command = commands[command_args[1]]

		if(command)then
			CancelEvent()
			if(command.perm > 0)then -- si la perm de la commande est plus grande que 0
				if(Users[source].getPermissions() >= command.perm or groups[Users[source].getGroup()]:canTarget(command.group))then
					command.cmd(source, command_args, Users[source])
					TriggerEvent("es:adminCommandRan", source, command_args, Users[source])
				else
					command.callbackfailed(source, command_args, Users[source])
					TriggerEvent("es:adminCommandFailed", source, command_args, Users[source])

					if(type(settings.defaultSettings.permissionDenied) == "string" and not WasEventCanceled())then
						TriggerClientEvent('chatMessage', source, "", {0,0,0}, defaultSettings.permissionDenied)
					end

					debugMsg("Non admin (" .. GetPlayerName(source) .. ") attempted to run admin command: " .. command_args[1])
				end
			else
				command.cmd(source, command_args, Users[source])
				TriggerEvent("es:userCommandRan", source, command_args)
			end

			TriggerEvent("es:commandRan", source, command_args, Users[source])
		else
			TriggerEvent('es:invalidCommandHandler', source, command_args, Users[source])

			if WasEventCanceled() then
				CancelEvent()
			end
		end
	else
		TriggerEvent('es:chatMessage', source, message, Users[source])
	end
end)

function addCommand(command, callback)
	commands[command] = {}
	commands[command].perm = 0
	commands[command].group = "user"
	commands[command].cmd = callback

	debugMsg("Command added: " .. command)
end

AddEventHandler('es:addCommand', function(command, callback)
	addCommand(command, callback)
end)

function addAdminCommand(command, perm, callback, callbackfailed)
	commands[command] = {}
	commands[command].perm = perm
	commands[command].group = "superadmin"
	commands[command].cmd = callback
	commands[command].callbackfailed = callbackfailed

	debugMsg("Admin command added: " .. command .. ", requires permission level: " .. perm)
end

AddEventHandler('es:addAdminCommand', function(command, perm, callback, callbackfailed)
	addAdminCommand(command, perm, callback, callbackfailed)
end)

function addGroupCommand(command, group, callback, callbackfailed)
	commands[command] = {}
	commands[command].perm = math.maxinteger
	commands[command].group = group
	commands[command].cmd = callback
	commands[command].callbackfailed = callbackfailed

	debugMsg("Group command added: " .. command .. ", requires group: " .. group)
end

AddEventHandler('es:addGroupCommand', function(command, group, callback, callbackfailed)
	addGroupCommand(command, group, callback, callbackfailed)
end)

RegisterServerEvent('es:updatePositions')
AddEventHandler('es:updatePositions', function(x, y, z)
	if(Users[source])then
		Users[source].setCoords(x, y, z)
	end
end)

-- Info command
commands['info'] = {}
commands['info'].perm = 0
commands['info'].cmd = function(source, args, user)
	TriggerClientEvent('chatMessage', source, 'SYSTEM', {255, 0, 0}, "^2[^3EssentialMode^2]^0 Version: ^22.0.0")
	TriggerClientEvent('chatMessage', source, 'SYSTEM', {255, 0, 0}, "^2[^3EssentialMode^2]^0 Commands loaded: ^2" .. (returnIndexesInTable(commands) - 1))
end

-- Gestion Restart des resources :
AddEventHandler("onResourceStop", function(resource)
	for k,v in pairs(StoppingManager) do
		if k == resource then
			for j=1, #v do
				table.insert(Waiting, { event = v[j], resourceName = k } )
			end
		end
	end
end)

AddEventHandler("onResourceStart", function(resource)
	if #Waiting ~= 0 then
		for k,v in pairs(StoppingManager) do
			if k == resource then
				for j=1, #v do
					table.insert(WaitingReady, { event = v[j], resourceName = k } )
				end
			end
		end
	end
	if #WaitingReady ~= 0 then
		treating = true
	end
end)

function CheckResourcesEvent()
	if treating then
		local indexToRemoveW = {}
		local indexToRemoveWR = {}
		if #WaitingReady ~= 0 then
			for i = 1, #WaitingReady do
				TriggerEvent(WaitingReady[i].event)
				for j = 1, #Waiting do
					if Waiting[j].event == WaitingReady[i].event and Waiting[j].resourceName == WaitingReady[i].resourceName then
						table.insert(indexToRemoveW, j)
						table.insert(indexToRemoveWR, i)
					end
				end
			end
			if #indexToRemoveW ~= 0 then
				for i=#indexToRemoveW, 1, -1 do
					table.remove(Waiting, i)
				end
				if #indexToRemoveWR ~= 0 then
					for i=#indexToRemoveWR, 1, -1 do
						table.remove(WaitingReady, i)
					end
				end
			end
		end
		treating = false
	end
	SetTimeout(tickRateEventManager, CheckResourcesEvent)
end
CheckResourcesEvent()

-- Essential Functions :
-- function ForceSave()
-- 	TriggerEvent("es:getPlayers", function(users)
-- 		for k,v in pairs(users) do
-- 			v:incrementPlayTime(saveTime)
-- 			if v.haveChanged == true then
-- 				MySQL:executeQuery("UPDATE users SET `money`='@value', `dirty_money`='@v2', `job`='@v3', `identity`= '@v4' WHERE identifier = '@identifier'",
-- 				   {['@value'] = v.money, ['@v2'] = v.dirty_money, ['@v3'] = v.job, ["@v4"] = json.encode(v.identity),['@identifier'] = v.identifier})
-- 			end
-- 		end
-- 	end)
-- end
--
-- -- Essential added Commands :
-- AddEventHandler('rconCommand', function(commandName, args)
-- 	if commandName == "save" and args[2] == "user" then
-- 		ForceSave()
-- 	else
-- 		RconPrint("Usage : /save user (pour le moment, on aura plus de commande après, dont un /save all")
-- 	end
-- end)
