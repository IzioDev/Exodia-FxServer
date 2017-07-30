-- Copyright (C) Izio, Inc - All Rights Reserved
-- Unauthorized copying of this file, via any medium is strictly prohibited
-- Proprietary and confidential
-- Written by Romain Billot <romainbillot3009@gmail.com>, Jully 2017

local permission = {
	kick = 1,
	ban = 4
}

local weapons = {
	"WEAPON_KNIFE", "WEAPON_NIGHTSTICK", "WEAPON_HAMMER", "WEAPON_BAT", "WEAPON_GOLFCLUB",
	"WEAPON_CROWBAR", "WEAPON_PISTOL", "WEAPON_COMBATPISTOL", "WEAPON_APPISTOL", "WEAPON_PISTOL50",
	"WEAPON_MICROSMG", "WEAPON_SMG", "WEAPON_ASSAULTSMG", "WEAPON_ASSAULTRIFLE",
	"WEAPON_CARBINERIFLE", "WEAPON_ADVANCEDRIFLE", "WEAPON_MG", "WEAPON_COMBATMG", "WEAPON_PUMPSHOTGUN",
	"WEAPON_SAWNOFFSHOTGUN", "WEAPON_ASSAULTSHOTGUN", "WEAPON_BULLPUPSHOTGUN", "WEAPON_STUNGUN", "WEAPON_SNIPERRIFLE",
	"WEAPON_HEAVYSNIPER", "WEAPON_GRENADELAUNCHER", "WEAPON_GRENADELAUNCHER_SMOKE", "WEAPON_RPG", "WEAPON_MINIGUN",
	"WEAPON_GRENADE", "WEAPON_STICKYBOMB", "WEAPON_SMOKEGRENADE", "WEAPON_BZGAS", "WEAPON_MOLOTOV",
	"WEAPON_FIREEXTINGUISHER", "WEAPON_PETROLCAN", "WEAPON_FLARE", "WEAPON_SNSPISTOL", "WEAPON_SPECIALCARBINE",
	"WEAPON_HEAVYPISTOL", "WEAPON_BULLPUPRIFLE", "WEAPON_HOMINGLAUNCHER", "WEAPON_PROXMINE", "WEAPON_SNOWBALL",
	"WEAPON_VINTAGEPISTOL", "WEAPON_DAGGER", "WEAPON_FIREWORK", "WEAPON_MUSKET", "WEAPON_MARKSMANRIFLE",
	"WEAPON_HEAVYSHOTGUN", "WEAPON_GUSENBERG", "WEAPON_HATCHET", "WEAPON_RAILGUN", "WEAPON_COMBATPDW",
	"WEAPON_KNUCKLE", "WEAPON_MARKSMANPISTOL", "WEAPON_FLASHLIGHT", "WEAPON_MACHETE", "WEAPON_MACHINEPISTOL",
	"WEAPON_SWITCHBLADE", "WEAPON_REVOLVER", "WEAPON_COMPACTRIFLE", "WEAPON_DBSHOTGUN", "WEAPON_FLAREGUN",
	"WEAPON_AUTOSHOTGUN", "WEAPON_BATTLEAXE", "WEAPON_COMPACTLAUNCHER", "WEAPON_MINISMG", "WEAPON_PIPEBOMB",
	"WEAPON_POOLCUE", "WEAPON_SWEEPER", "WEAPON_WRENCH"
}

-- Adding custom groups called owner, inhereting from superadmin. (It's higher then superadmin). And moderator, higher then user but lower then admin
TriggerEvent("es:addGroup", "owner", "superadmin", function(group) end)
TriggerEvent("es:addGroup", "mod", "user", function(group) end)

-- Default commands
TriggerEvent('es:addCommand', 'admin', function(source, args, user)
	TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Level: ^*^2 " .. tostring(user.get('permission_level')))
	TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Group: ^*^2 " .. user.getGroup())
end)

TriggerEvent('es:addCommand', 'hash', function(source, args, user)
	TriggerClientEvent('es_admin:getHash', source, args[2])
end)

-- Default commands
-- TriggerEvent('es:addCommand', 'report', function(source, args, user)
-- 	table.remove(args, 1)
-- 	TriggerClientEvent('chatMessage', source, "REPORT", {255, 0, 0}, " (^2" .. GetPlayerName(source) .." | "..source.."^0) " .. table.concat(args, " "))

-- 	TriggerEvent("es:getPlayers", function(pl)
-- 		for k,v in pairs(pl) do
-- 			TriggerEvent("es:getPlayerFromId", k, function(user)
-- 				if(user.permission_level > 0 and k ~= source)then
-- 					TriggerClientEvent('chatMessage', k, "REPORT", {255, 0, 0}, " (^2" .. GetPlayerName(source) .." | "..source.."^0) " .. table.concat(args, " "))
-- 				end
-- 			end)
-- 		end
-- 	end)
-- end)

-- Append a message
function appendNewPos(msg)
	local file = io.open('positions.txt', "a")
	newFile = msg
	print(newFile)
	io.output(file)
	io.write(newFile)
	io.close()
end

-- Do them hashes
function doHashes()
  lines = {}
  for line in io.lines("resources/[Admin]/iAdmin/input.txt") do
  	lines[#lines + 1] = line
  end

  return lines
end


RegisterServerEvent('es_admin:givePos')
AddEventHandler('es_admin:givePos', function(str)
	appendNewPos(str)
end)

TriggerEvent('es:addGroupCommand', 'hashes', "owner", function(source, args, user) 
	TriggerClientEvent('es_admin:doHashes', source, doHashes())
end, function(source, args, user)end)

--Money
TriggerEvent('es:addGroupCommand', 'addMoney', "superadmin", function(source, args, user) 
	print("ok")
	if #args ~= 3 then
		TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Usage : /setmoney [playerSID] amount")
	else
		TriggerEvent("es:getPlayerFromId", tonumber(args[2]), function(targetUser)
			if targetUser == nil then
				TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Player offline")
			else
				targetUser.addMoney(tonumber(args[3]))
				TriggerClientEvent('chatMessage', source, "SYSTEM", {0, 204, 0}, args[3] .. "$ added to the player.")
				TriggerClientEvent('chatMessage', tonumber(targetUser.get('source')), {0, 204, 0}, user.get('identifier') .. "added " .. args[3] .. "$ added to you.")
			end
		end)
	end
end, function(source, args, user)end)

--Group
TriggerEvent('es:addGroupCommand', 'addGroup', 'owner', function(source, args, user)
	if #args ~= 3 then
		TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Usage : /addgroup [playerSID] owner/superadmin/mod/user")
		CancelEvent()
	else
		TriggerEvent("es:getPlayerFromId", tonumber(args[2]), function(targetUser)
			if targetUser ~= nil then
				targetUser.set('group', args[3])
				TriggerEvent("es:addPlayerGroup", targetUser.get('source'), args[3])
				TriggerClientEvent('es:setPlayerDecorator', tonumber(args[2]), 'group', tonumber(args[3]), true)
			end
		end)
	end
end)
--Weapon
TriggerEvent('es:addGroupCommand', "weapon", "owner", function(source, args, user)
	local choosen = nil 
	if #args ~= 4 then
		TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Usage : /weapon [playerSID] random/Hash ammoCount")
	else
		if args[3] == "random" then
			choosen = math.random(1 ,#weapons)
			TriggerClientEvent("is:giveWeaponToPlayer", tonumber(args[2]), weapons[choosen], 300)
		elseif args[3] == "all" then
		    TriggerClientEvent("is:giveWeaponToPlayer", tonumber(args[2]), weapons, 300)
		    print("ok")
		else
			for i = 1, #weapons do
				if weapons[i] == args[3] then
					choosen = args[3]
				end
			end
			if choosen == nil then
				TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "No Weapon of this name founded")
			else
				TriggerClientEvent("is:giveWeaponToPlayer", tonumber(args[2]), choosen, tonumber(args[4]))
			end
		end
	end
end, function(source, args, user)
	TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Insufficienct permissions!")
end)

--Godmod
TriggerEvent('es:addGroupCommand', 'vanish', "owner", function(source, args, user)
	if #args ~= 2 then
		TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Usage : /vanish [playerSID]")
	else
		TriggerClientEvent("is:vanishPlayer", tonumber(args[2]))
	end
end, function(source, args, user)
	TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Insufficienct permissions!")
end)

-- vanish
TriggerEvent('es:addGroupCommand', 'godmod', "owner", function(source, args, user)
	if #args ~= 2 then
		TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Usage : /godmod [playerSID]")
	else
		TriggerClientEvent("is:godModPlayer", tonumber(args[2]))
	end
end, function(source, args, user)
	TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Insufficienct permissions!")
end)

-- Noclip
TriggerEvent('es:addGroupCommand', 'noclip', "admin", function(source, args, user)
	TriggerClientEvent("es_admin:noclip", source)
end, function(source, args, user)
	TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Insufficienct permissions!")
end)

-- Kicking
TriggerEvent('es:addGroupCommand', 'kick', "mod", function(source, args, user)
		if(GetPlayerName(tonumber(args[2])))then
			local player = tonumber(args[2])

			-- User permission check
			TriggerEvent("es:getPlayerFromId", player, function(target)

				local reason = args
				table.remove(reason, 1)
				table.remove(reason, 1)
				if(#reason == 0)then
					reason = "Kicked: You have been kicked from the server"
				else
					reason = "Kicked: " .. table.concat(reason, " ")
				end

				TriggerClientEvent('chatMessage', -1, "SYSTEM", {255, 0, 0}, "Player ^2" .. GetPlayerName(player) .. "^0 has been kicked(^2" .. reason .. "^0)")
				DropPlayer(player, reason)
			end)
		else
			TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Incorrect player ID!")
		end
end, function(source, args, user)
	TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Insufficienct permissions!")
end)

--WhiteList :
TriggerEvent("es:addGroupCommand", "wl", "mod", function(source, args, user)
	if #args ~= 2 then
		TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Usage : /wl [SteamID64] [1/0], 1 for whitelisted 0 for not.")
	else
		local result = MySQL.Sync.fetchAll("SELECT * FROM whitelist WHERE identifier=@name", {['@name'] = args[1]})
		if result[1] == nil then
			MySQL.Sync.execute("INSERT INTO whitelist (`identifier`, `isWhiteListed`) VALUES (@identifier, @isWhiteListed)", {
				['@identifier'] = args[1],
				['@isWhiteListed'] = tonumber(args[2])
		})
		else
			MySQL.Sync.execute("UPDATE users SET `isWhiteListed`=@value WHERE `identifier`=@identifier", {
				['@isWhiteListed'] = tonumber(args[2]),
				['@identifier'] = args[1]
		})
		end
		TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Succesfully added to the WhiteList!")
	end
end)

function stringsplit(self, delimiter)
  local a = self:Split(delimiter)
  local t = {}

  for i = 0, #a - 1 do
     table.insert(t, a[i])
  end

  return t
end

-- Announcing
TriggerEvent('es:addGroupCommand', 'announce', "admin", function(source, args, user)
	table.remove(args, 1)
	TriggerClientEvent('chatMessage', -1, "ANNONCE: ", {255, 0, 0}, "" .. table.concat(args, " "))
end, function(source, args, user)
	TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Insufficienct permissions!")
end)

-- Freezing
local frozen = {}
TriggerEvent('es:addGroupCommand', 'freeze', "mod", function(source, args, user)
		if(GetPlayerName(tonumber(args[2])))then
			local player = tonumber(args[2])

			-- User permission check
			TriggerEvent("es:getPlayerFromId", player, function(target)

				if(frozen[player])then
					frozen[player] = false
				else
					frozen[player] = true
				end

				TriggerClientEvent('es_admin:freezePlayer', player, frozen[player])

				local state = "unfrozen"
				if(frozen[player])then
					state = "frozen"
				end

				TriggerClientEvent('chatMessage', player, "SYSTEM", {255, 0, 0}, "You have been " .. state .. " by ^2" .. GetPlayerName(source))
				TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Player ^2" .. GetPlayerName(player) .. "^0 has been " .. state)
			end)
		else
			TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Incorrect player ID!")
		end
end, function(source, args, user)
	TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Insufficienct permissions!")
end)

-- Bring
local frozen = {}
TriggerEvent('es:addGroupCommand', 'bring', "mod", function(source, args, user)
		if(GetPlayerName(tonumber(args[2])))then
			local player = tonumber(args[2])

			-- User permission check
			TriggerEvent("es:getPlayerFromId", player, function(target)

				TriggerClientEvent('es_admin:teleportUser', target.get('source'), target.get('coords.x'), target.get('coords.y'), target.get('coords.z'))

				TriggerClientEvent('chatMessage', player, "SYSTEM", {255, 0, 0}, "You have brought by ^2" .. GetPlayerName(source))
				TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Player ^2" .. GetPlayerName(player) .. "^0 has been brought")
			end)
		else
			TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Incorrect player ID!")
		end
end, function(source, args, user)
	TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Insufficienct permissions!")
end)

-- Slap
local frozen = {}
TriggerEvent('es:addGroupCommand', 'slap', "admin", function(source, args, user)
		if(GetPlayerName(tonumber(args[2])))then
			local player = tonumber(args[2])

			-- User permission check
			TriggerEvent("es:getPlayerFromId", player, function(target)

				TriggerClientEvent('es_admin:slap', player)

				TriggerClientEvent('chatMessage', player, "SYSTEM", {255, 0, 0}, "You have slapped by ^2" .. GetPlayerName(source))
				TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Player ^2" .. GetPlayerName(player) .. "^0 has been slapped")
			end)
		else
			TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Incorrect player ID!")
		end
end, function(source, args, user)
	TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Insufficienct permissions!")
end)

-- Freezing
local frozen = {}
TriggerEvent('es:addGroupCommand', 'goto', "mod", function(source, args, user)
		if(GetPlayerName(tonumber(args[2])))then
			local player = tonumber(args[2])

			-- User permission check
			TriggerEvent("es:getPlayerFromId", player, function(target)
				if(target)then

					TriggerClientEvent('es_admin:teleportUser', source, target.get('coords.x'), target.get('coords.y'), target.get('coords.z'))

					TriggerClientEvent('chatMessage', player, "SYSTEM", {255, 0, 0}, "You have been teleported to by ^2" .. GetPlayerName(source))
					TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Teleported to player ^2" .. GetPlayerName(player) .. "")
				end
			end)
		else
			TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Incorrect player ID!")
		end
end, function(source, args, user)
	TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Insufficienct permissions!")
end)

-- Kill yourself
TriggerEvent('es:addCommand', 'die', function(source, args, user)
	TriggerClientEvent('es_admin:kill', source)
	TriggerClientEvent('chatMessage', source, "", {0,0,0}, "^1^*You killed yourself.")
end)

-- Killing
TriggerEvent('es:addGroupCommand', 'slay', "admin", function(source, args, user)
		if(GetPlayerName(tonumber(args[2])))then
			local player = tonumber(args[2])

			-- User permission check
			TriggerEvent("es:getPlayerFromId", player, function(target)

				TriggerClientEvent('es_admin:kill', player)

				TriggerClientEvent('chatMessage', player, "SYSTEM", {255, 0, 0}, "You have been killed by ^2" .. GetPlayerName(source))
				TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Player ^2" .. GetPlayerName(player) .. "^0 has been killed.")
			end)
		else
			TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Incorrect player ID!")
		end
end, function(source, args, user)
	TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Insufficienct permissions!")
end)

-- Crashing
TriggerEvent('es:addGroupCommand', 'crash', "superadmin", function(source, args, user)
		if(GetPlayerName(tonumber(args[2])))then
			local player = tonumber(args[2])

			-- User permission check
			TriggerEvent("es:getPlayerFromId", player, function(target)

				TriggerClientEvent('es_admin:crash', player)

				TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Player ^2" .. GetPlayerName(player) .. "^0 has been crashed.")
			end)
		else
			TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Incorrect player ID!")
		end
end, function(source, args, user)
	TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Insufficienct permissions!")
end)

-- Position
TriggerEvent('es:addGroupCommand', 'pos', "mod", function(source, args, user)
	if #args ~= 2 then
		TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Give a pointName after that!")
	else
		TriggerClientEvent('es_admin:givePosition', source, args[2])
	end
end, function(source, args, user)
	TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Insufficienct permissions!")
end)

--Teleporting (to coords)
TriggerEvent('es:addGroupCommand', 'tptc', "mod", function(source, args, user)
	if #args ~= 4 then
		TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Usage : /tptc x y z")
	else
		TriggerClientEvent('es_admin:teleportUser', source, tonumber(args[2]), tonumber(args[3]), tonumber(args[4]))
	end
end, function(source, args, user)
	TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Insufficienct permissions!")
end)

-- testing : Teleporting to marker
TriggerEvent('es:addGroupCommand', 'tptm', "mod", function(source, args, user)
	if #args ~= 1 then
		TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Usage : /tptm")
	else
		TriggerClientEvent('es_admin:teleportToMarker', source)
	end
end, function(source, args, user)
	TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Insufficienct permissions!")
end)

--testing : tp to interiors :                                 ------------------------------------HERE IZIO !!!! ----------------
TriggerEvent('es:addGroupCommand', 'ipl', "owner", function(source, args, user)
	if #args ~= 2 then 
		TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "usage : /ipl name !")
	else
		--TriggerClientEvent("")
	end
end, function(source, args, user)
	TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Insufficienct permissions!")
end)

-- testing : Teleporting SomeOneToMyMarker
TriggerEvent('es:addGroupCommand', 'tpsotmm', "mod", function(source, args, user)
	if #args ~= 2 then
		TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Usage : /tpsotmm [PSID]")
	else
		TriggerClientEvent('es_admin:teleportSomeOneToMyMarker', source, tonumber(args[2]))
	end
end, function(source, args, user)
	TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Insufficienct permissions!")
end)

RegisterServerEvent("es_admin:sendCoordsTeleportSomeOneToMyMarker")
AddEventHandler("es_admin:sendCoordsTeleportSomeOneToMyMarker", function(x, y, z, targetSource)
	TriggerClientEvent('es_admin:teleportUser', targetSource, tonumber(x), tonumber(y), tonumber(z))
end)

-- Rcon commands
AddEventHandler('rconCommand', function(commandName, args)
	if commandName == 'setadmin' then
		if #args ~= 2 then
				RconPrint("Usage: setadmin [user-id] [permission-level]\n")
				CancelEvent()
				return
		end

		if(GetPlayerName(tonumber(args[1])) == nil)then
			RconPrint("Player not ingame\n")
			CancelEvent()
			return
		end

		TriggerEvent("es:setPlayerData", tonumber(args[1]), "permission_level", tonumber(args[2]), function(response, success)
			RconPrint(response)

			if(true)then
				print(args[1] .. " " .. args[2])
				TriggerClientEvent('es:setPlayerDecorator', tonumber(args[1]), 'rank', tonumber(args[2]), true)
				TriggerClientEvent('chatMessage', -1, "CONSOLE", {0, 0, 0}, "Permission level of ^2" .. GetPlayerName(tonumber(args[1])) .. "^0 has been set to ^2 " .. args[2])
			end
		end)

		CancelEvent()
	elseif commandName == 'setgroup' then
		if #args ~= 2 then
				RconPrint("Usage: setgroup [user-id] [group]\n")
				CancelEvent()
				return
		end

		if(GetPlayerName(tonumber(args[1])) == nil)then
			RconPrint("Player not ingame\n")
			CancelEvent()
			return
		end

		TriggerEvent("es:getAllGroups", function(groups)

			if(groups[args[2]])then
				TriggerEvent("es:addPlayerGroup", tonumber(args[1]), args[2])
				RconPrint("Added group to player.")
				if(true)then
					print(args[1] .. " " .. args[2])
					TriggerClientEvent('es:setPlayerDecorator', tonumber(args[1]), 'group', tonumber(args[2]), true)
					TriggerClientEvent('chatMessage', -1, "CONSOLE", {0, 0, 0}, "Group of ^2^*" .. GetPlayerName(tonumber(args[1])) .. "^r^0 has been set to ^2^*" .. args[2])
				end
			else
				RconPrint("This group does not exist.\n")
			end
		end)

		CancelEvent()
	elseif commandName == 'setmoney' then
			if #args ~= 2 then
					RconPrint("Usage: setmoney [user-id] [money]\n")
					CancelEvent()
					return
			end

			if(GetPlayerName(tonumber(args[1])) == nil)then
				RconPrint("Player not ingame\n")
				CancelEvent()
				return
			end

			TriggerEvent("es:getPlayerFromId", tonumber(args[1]), function(user)
				if(user)then
					user.setMoney(tonumber(args[2]))

					RconPrint("Money set")
					TriggerClientEvent('chatMessage', tonumber(args[1]), "CONSOLE", {0, 0, 0}, "Your money has been set to: ^2^*$" .. tonumber(args[2]))
				end
			end)

			CancelEvent()
		end
end)

-- Logging
AddEventHandler("es:adminCommandRan", function(source, command)

end)

AddEventHandler("es:addPlayerGroup", function(targetSource, group)
	TriggerEvent("es:getPlayerFromId", targetSource, function(user)
		MySQL.Sync.execute("UPDATE users SET `group`=@group WHERE identifier=@identifier AND id=@id", {
			['group'] = group,
			['identifier'] = user.get('identifier'),
			['id'] = user.get('id')
			})
		user.set('group', group)
	end)
end)
