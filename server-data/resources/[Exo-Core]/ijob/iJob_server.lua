-- Copyright (C) Izio, Inc - All Rights Reserved
-- Unauthorized copying of this file, via any medium is strictly prohibited
-- Proprietary and confidential
-- Written by Romain Billot <romainbillot3009@gmail.com>, Jully 2017

allJob = {}
allZoneJob = {}
addCapactity = 10
timeCapactity = 300000
timePay = 180000
minTimePay = timePay/2
enablePay = false
addjobautomatic = false
debugg = true
local usableTreatItem = {48}-- TO CHANGE


------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------ON RESOURCE START---------------------------------------------
------------------------------------------------------------------------------------------------------------------------
AddEventHandler("onMySQLReady", function()
	TriggerEvent("iJob:startLoading")
end)
AddEventHandler("iJob:loadingAfterRestart", function()
	TriggerEvent("iJob:startLoading")
end)

AddEventHandler("iJob:startLoading", function()

	if addjobautomatic == true then
		
		tableTest = {
			rank = { {name = "gérant hopital", salary = 500}, {name="stagiaire", salary = 100}, {name="interne", salary = 300}},
			blacklist = {{p = "steamTest", dhm = "14 6 5"} },
			lost = { {p = "steamTest2", a = 10, re = "essence", dmh = "14 6 5"}, {p = "steamTest3", a = 10, re = "essence", dmh = "14 6 5"} },
			benefit = { {p = "steamTest2", a = 10, re = "venteTest", dmh = "14 6 5"}, {p = "steamTest3", a = 10, re = "venteTest", dmh = "14 6 5"} },
			capital = 100000,
			name = "médecin",
			employe = { {pl = "steam:110000104bd6595", rank = "interne", displayName = "test Test"} },
			default = {rank = "stagiaire"},
			id = 5
		}

		local encodedRank = json.encode(tableTest.rank)
		local encodedBlacklist = json.encode(tableTest.blacklist)
		local encodedLost = json.encode(tableTest.lost)
		local encodedBenefit = json.encode(tableTest.benefit) 
		local encodedEmploye = json.encode(tableTest.employe)
		local capital = tostring(tableTest.capital)
		local default = json.encode(tableTest.default)

		MySQL.Sync.execute("INSERT INTO job (`capital`, `benefit`, `lost`, `default`, `rank`, `employe`, `blacklist`, `name`, `id`) VALUES (@capital, @benefit, @lost, @default, @rank, @employe, @blacklist, @name, @id)", {
			['@capital'] = capital, 
			['@benefit'] = encodedBenefit, 
			['@lost'] = encodedLost, 
			['@default'] = default, 
			['@rank'] = encodedRank, 
			['@employe'] = encodedEmploye, 
			['@blacklist'] = encodedBlacklist, 
			['@name'] = tableTest.name,
			['@id'] = tableTest.id
			})
	end

	local results = MySQL.Sync.fetchAll("SELECT * FROM job")
	local results2 = MySQL.Sync.fetchAll("SELECT * FROM zone")

	if results[1] ~= nil then
		for i = 1, #results do
			v = 0
			for j = 1, #results2 do
				if (results2[j].categorie == results[i].name or results2[j].categorie == "shared") and results2[j].instructions then
					table.insert(allZoneJob, {
						nom = results2[j].nom,
						coords = json.decode(results2[j].coords),
						gravityCenter = json.decode(results2[j].gravityCenter),
						longestDistance = json.decode(results2[j].longestDistance),
						categorie = results2[j].categorie,
						instructions = json.decode(results2[j].instructions)
					})
					v = 1
				elseif results2[j].categorie == results[i].name then
					table.insert(allZoneJob, {
						nom = results2[j].nom,
						coords = json.decode(results2[j].coords),
						gravityCenter = json.decode(results2[j].gravityCenter),
						longestDistance = json.decode(results2[j].longestDistance),
						categorie = results2[j].categorie
					})
				elseif IsHarvestJob(results[i].name) and results2[j].categorie == "rec" then
					table.insert(allZoneJob, {
						nom = results2[j].nom,
						coords = json.decode(results2[j].coords),
						gravityCenter = json.decode(results2[j].gravityCenter),
						longestDistance = json.decode(results2[j].longestDistance),
						categorie = results2[j].categorie,
						instructions = json.decode(results2[j].instructions)
					})
				end
			end
			if v == 0 then -- to prevent the job without zone assigned (which is not supposed to happend)
				LoadJob(results[i], nil)
			else
				LoadJob(results[i], allZoneJob)
				allZoneJob = {} 
			end
		end
	end
	UpdateJob()
	saveJobIfChanged()

end)

function LoadJob(test, test2)
	if test2 ~= nil then
		allJob[test.name] = CreateJob(test.capital, json.decode(test.benefit), json.decode(test.lost), test.name, json.decode(test.default), json.decode(test.rank), json.decode(test.employe), test2, json.decode(test.blacklist)) -- zone contain { zone1 = { }, zone2 = { }, zone3 = { } }
	else -- the job got a zone assigned by the categorie name

		allJob[test.name] = CreateJob(test.capital, json.decode(test.benefit), json.decode(test.lost), test.name, json.decode(test.default), json.decode(test.rank), json.decode(test.employe), nil, json.decode(test.blacklist))

	end

end

function UpdateJob()
	SetTimeout(3000, function()
		TriggerEvent("es:getPlayers", function(Users)
			for k,v in pairs(Users) do
				if v ~= nil then
					print(v.get('source') .. " " .. v.get('job') .. " " .. v.get('rank'))
					TriggerClientEvent("ijob:updateJob", v.get('source'), v.get('job'), v.get('rank'))
					TriggerClientEvent("ijob:addBlip", v.get('source'), allJob[v.get('job')].getBlip(), true)
				end
			end
		end)
	end)
end

AddEventHandler("es:playerLoaded", function(source)
	TriggerEvent("es:getPlayerFromId", source, function(user)
		TriggerClientEvent("ijob:addBlip", source, allJob[user.get('job')].getBlip(), true)
	end)
end)

------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------COMMANDES-----------------------------------------------------
------------------------------------------------------------------------------------------------------------------------


------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------PARTIE API----------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

RegisterServerEvent("ijob:getJobFromName")
AddEventHandler("ijob:getJobFromName", function(jobName, cb)
	if allJob[jobName] then
		cb(allJob[jobName])
	else
		cb(nil)
	end
end)


RegisterServerEvent("ijob:getAllJob")
AddEventHandler("ijob:getAllJob", function(cb)

	cb(allJob)

end)

------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------SAVE----------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

function saveJobIfChanged()

	SetTimeout(60000, function()

			for k,v in pairs(allJob)do
				print("Job changed ? : ".. tostring(v.get('haveChanged')))
				if v.get('haveChanged') then -- only if changed	
					MySQL.Sync.execute("UPDATE job SET `capital`=@vcapital, `benefit`=@vbenefit, `lost`=@vlost, `rank`=@vrank, `employe`=@vemploye, `blacklist`=@vblacklist, `name`=@vname WHERE name = @vname",{
						['@vcapital'] = tostring(v.get('capital')), 
						['@vbenefit'] = json.encode(v.get('benefit')),
						['@vlost'] = json.encode(v.get('lost')), 
						['@vrank'] = json.encode(v.get('rank')), 
						['@vemploye'] = json.encode(v.get('employe')),
						['@vblacklist'] = json.encode(v.get('blacklist')), 
						['@vname'] = v.get('name')
					})
					v.set('haveChanged', false)
					print("Job changed saved to the DB.")
				end

			end

		saveJobIfChanged()

	end)

end

function saveJob()

	for k,v in pairs(allJob)do

		MySQL.Sync.execute("UPDATE job SET `capital`=@vcapital, `benefit`=@vbenefit, `lost`=@vlost,`rank`=@vrank, `employe`=@vemploye, `blacklist`=@vblacklist, `name`=@vname WHERE name = @vname",{
			['@vcapital'] = tostring(v.get('capital')), 
			['@vbenefit'] = json.encode(v.get('benefit')),
			['@vlost'] = json.encode(v.get('lost')), 
			['@vrank'] = json.encode(v.get('rank')), 
			['@vemploye'] = json.encode(v.get('employe')),
			['@vblacklist'] = json.encode(v.get('blacklist')), 
			['@vname'] = v.get('name')
		})
		allJob[v.name].set('haveChanged', false)

	end

	print("Job changed saved to the DB.")

end
------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------NewPlayer--------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
AddEventHandler("es:newPlayerLoaded", function(userSource, user)
	allJob["chomeur"].addEmployeWithRefresh(user)
end)
------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------Harvest---------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
function AddHarvestCapacity()
	SetTimeout(timeCapactity, function()
		for k,v in pairs(allJob) do
			v.addCapacityToAll(addCapactity)
		end
		AddHarvestCapacity()
	end)
end
AddHarvestCapacity()

RegisterServerEvent("iJob:harvestillegal")
AddEventHandler("iJob:harvestillegal", function(result)
	local source = source -- Thanks FXS
	TriggerEvent("es:getPlayerFromId", source, function(user)

		local item = {}
		local quantity = {}
		local lucky = false
		local randomHarvest = math.random(1, 100)

		if randomHarvest < 20 then -- 20% de change d'avoir deux item normaux
			item = result.receive.normal
			lucky = true
		else -- et 80% de chance d'avoir jsute un item normal
			item = result.receive.normal
		end
	
		for i=1, #item do
			if lucky then
				quantity[i] = 2
			else
				quantity[i] = 1
			end
		end

		local resultFromHarvest = allJob["illegal"].harvest(result.displayMessageInZone, quantity, false)
		if resultFromHarvest then
			ProcessHarvest(source, result, item, quantity)
		else
			TriggerClientEvent("ijob:stopHarvest", source)
			user.notify("Tu ne peux pas récolter, la zone de récolte est vide. Attends un peu", "error", "centerLeft", true, 5000)
			TriggerClientEvent("anim:Play", source, "stopAll")
		end
	end)
end)

RegisterServerEvent("iJob:otherIllegal")
AddEventHandler("iJob:otherIllegal", function(result)
	local source = source -- Thanks FXS
	TriggerEvent("es:getPlayerFromId", source, function(user)
		local item = result.receive.normal
		local quantity = {}

		for i=1, #item do
			quantity[i] = 1
		end
		
		ProcessOther(source, result, item, quantity)
	end)
end)

RegisterServerEvent("iJob:checkHarvest")
AddEventHandler("iJob:checkHarvest", function(result)
	local source = source -- Thanks FXS
	local job
	TriggerEvent("es:getPlayerFromId", source, function(user)

		if not(IsHarvestJob(user.get('job'))) then
			user.notify("Tu n'as pas ce métier.", "error", "centerLeft", true, 5000)
			CancelEvent()
			return
		end

		local item = {}
		local quantity = {}
		local lucky = false
		local randomHarvest = math.random(1, 100)

		if randomHarvest < 2 then -- 2% de chance d'avoir un item rare
			item = result.receive.rare
		elseif randomHarvest < 17 then -- 15% de change d'avoir deux item normaux
			item = result.receive.normal
			lucky = true
		else -- et 83% de chance d'avoir jsute un item normal
			item = result.receive.normal
		end
	
		for i=1, #item do
			if lucky then
				quantity[i] = 2
			else
				quantity[i] = 1
			end
		end

		job = string.lower(user.get('job')) --
		local resultFromHarvest = allJob[job].harvest(result.displayMessageInZone, quantity, false)
		if resultFromHarvest then
			ProcessHarvest(source, result, item, quantity)
		else
			TriggerClientEvent("ijob:stopHarvest", source)
			user.notify("Tu ne peux pas récolter, la zone de récolte est vide. Attends un peu", "error", "centerLeft", true, 5000)
			TriggerClientEvent("anim:Play", source, "stopAll")
		end
	end)

end)

RegisterServerEvent("ijob:process")
AddEventHandler("ijob:process", function(result)
	local source = source -- Thanks FXS
	local job
	TriggerEvent("es:getPlayerFromId", source, function(user)
		local item = {}
		local quantity = {}
		local lucky = false
		local randomReceive = math.random(1, 100)

		if randomReceive < 2 then -- 2% de chance d'avoir un item rare
			item = result.receive.rare
		elseif randomReceive < 17 then -- 15% de change d'avoir deux item normaux
			item = result.receive.normal
			lucky = true
		else -- et 83% de chance d'avoir jsute un item normal
			item = result.receive.normal
		end
	
		for i=1, #item do
			if lucky then
				quantity[i] = 2
			else
				quantity[i] = 1
			end
		end
		ProcessOther(source, result, item, quantity)
	end)
end)

function IsHarvestJob(job)
	if string.lower(job) == string.lower("Fermier") or string.lower(job) == string.lower("Bucheron") or string.lower(job) == string.lower("Pompiste") then
		return true
	else
		return false
	end
end

function ProcessHarvest(source, result, item, quantity) -- create = true / false
	TriggerEvent("es:getPlayerFromId", source, function(user)

		local bool = user.isAbleToReceiveItems(item , quantity) -- deux array
		if bool then
			user.addQuantityArray(item, quantity)
			local itemInfos = user.get('item')
			local test = GetMessage(item, quantity, itemInfos)
			user.notify("Tu viens de récolter" .. test .. ".", "success", "centerLeft", true, 5000)
			allJob[user.get('job')].harvest(result.displayMessageInZone, {100}, true)
			TriggerClientEvent("inventory:change", source, json.decode(user.sendDatas()))
		else
			user.notify("Tu n'as pas assez de place dans ton inventaire", "error", "centerLeft", true, 5000)
			TriggerClientEvent("anim:Play", source, "stopAll")
			TriggerClientEvent("ijob:stopHarvest", source)
		end
	end)
end

function ProcessOther(source, result, item, quantity)
	TriggerEvent("es:getPlayerFromId", source, function(user)
		local quantityToRemove = {}
			user.addQuantityArray(item, quantity)
			for i = 1, #result.need do
				table.insert(quantityToRemove, 1)
			end
			for i=1, #result.need do
				for j=1, #usableTreatItem do
					if result.need[i] == usableTreatItem[j] then
						table.remove(result.need, i)
					end
				end
			end
			user.removeQuantityArray(result.need, quantityToRemove)
			local itemInfos = user.get('item')
			local test = GetMessage(item, quantity, itemInfos)
			user.notify("Tu viens de recevoir" .. test .. ".", "success", "centerLeft", true, 5000)
			TriggerClientEvent("inventory:change", source, json.decode(user.sendDatas()))
	end)
end

function GetMessage(item, quantity, itemInfos)
	local message = ""
	for i=1, #item do
		-- name est nill visiblement
		message = message .. " " .. quantity[i] .. " " .. itemInfos[item[i]].name
		if i ~= 1 and i ~= #item then
			message = message .. " et "
		end
	end
	return message
end
------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------PARTIE API-------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
AddEventHandler("ijob:getJobFromName", function(name, cb)
	if allJob[name] ~= nil then
		cb(allJob[name])
	else
		cb(nil)
	end
end)
------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------EVENT JOB--------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
RegisterServerEvent('ijob:changeJobPoleEmplois') -- Le joueur est nécéssairement Online
AddEventHandler('ijob:changeJobPoleEmplois', function(job)
	local job = string.lower(job)
	--RconPrint("Job Changed to " .. tostring(job))
	TriggerEvent("es:getPlayerFromId", source, function(user)
		if allJob[job].isBlacklisted(user.get('identifier')) then
			user.notify("Tu es <span style='color:red'>blacklisté</span> du métier, attends encore un peu.", "error", true, 5000)
		else
			local result = allJob[job].addEmployeWithRefresh(user)
			if result == "already" then
				user.notify("Tu viens de quitter le métier de <span style='color:yellow' > " ..job.. "</span>, attends encode un peu.", "error", "leftCenter", true, 5000)
			else
				if result == "hireFirst" then
					user.notify("Tu ne peux pas faire ça, tu es <span style='color:yellow' > ".. user.get('job') .. "</span> quitte d'abord ton emploie.", "error", "centerLeft", true, 5000)
				else
					user.notify("Bienvenue chez les <span style='color:yellow' > "..job.. "</span> contact ton patron, il te donnera les infos dont tu as besoin.", "success", "topCenter", true, 5000)
					TriggerClientEvent("ijob:addBlip", user.get('source'), allJob[user.get('job')].getBlip(), true)
				end
			end
		end
	end)

end)

TriggerEvent('es:addGroupCommand', 'addjob', "mod", function(source, args, user)
	local source = source
	TriggerEvent("es:getPlayerFromId", tonumber(args[2]), function(targetUser) -- job, employeNetId
		if args[2] == "help" or #args ~= 3 then
			print("test")
			TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Usage: /addjob [serverId] [job], ex : /addjob 1 bucheron")
			CancelEvent()
			return
		end
		if targetUser ~= nil then
			print("different de nil")
			if allJob[targetUser.get('job')] ~= nil then
				print("diff nil 2")
				if allJob[targetUser.get('job')].isBlacklisted(targetUser) then
					print("je suis blacklisté ?")
					targetUser.notify("Tu es <span style='color:red'>blacklisté</span> du métier de " .. targetUser.get('job') .. ".", "error", true, 5000)
				else
					print("pas blacklisté")
					if allJob[args[3]] then
						result = allJob[args[3]].addEmployeWithRefresh(targetUser)
						print(result)
						if result == "already" then
							TriggerEvent("es:getPlayerFromId", source, function(user)
								user.set('job', args[3])
								user.set('rank', allJob[args[3]].get('default.rank'))
								TriggerClientEvent("ijob:addBlip", targetUser.get('source'), allJob[targetUser.get('job')].getBlip(), true)
								TriggerClientEvent("ijob:updateJob", targetUser.get('source'), targetUser.get('job'), targetUser.get('rank'))
								TriggerClientEvent("is:updateJob", targetUser.get('source'), targetUser.get('job'), targetUser.get('rank'))
								user.notify("Le joueur à déjà ce job.", "error", "topCenter", true, 5000)
							end)
						elseif result == "hireFirst" then
							allJob[targetUser.get('job')].removeEmploye(targetUser)
							targetUser.notify("Tu es retiré du métier de " .. targetUser.get('job') .. ".", "success", "topCenter", true, 5000)
								print(targetUser.get('job') .. targetUser.get('rank'))
							TriggerEvent('es:getPlayerFromId', tonumber(args[2]), function(targetUserr)
								print(targetUserr.get('job') .. targetUserr.get('rank'))
								allJob[args[3]].addEmployeWithRefresh(targetUser)
								TriggerClientEvent("ijob:updateJob", targetUserr.get('source'), targetUserr.get('job'), targetUserr.get('rank'))
								TriggerClientEvent("ijob:addBlip", targetUserr.get('source'), allJob[targetUserr.get('job')].getBlip(), true)
								targetUser.notify("Tu es ajouté au métier de " .. targetUserr.get('job') .. ".", "success", "topCenter",true, 5000)
							end)
						else
							TriggerClientEvent("ijob:updateJob", targetUser.get('source'), targetUser.get('job'), targetUser.get('rank'))
							TriggerClientEvent("ijob:addBlip", targetUser.get('source'), allJob[targetUser.get('job')].getBlip(), true)
							targetUser.notify("Tu es <span style='color:green'>ajouté</span> au métier de " .. targetUser.get('job') .. ".", "success", "topCenter", true, 5000)
						end
					else
						user.notify("Le job n'existe pas.", "error", "topCenter", true, 5000)
					end
				end
			else
				TriggerEvent("es:getPlayerFromId", source, function(user)
					user.notify("Le job spécifié n'existe pas", "error", "topCenter", true, 5000)
				end)
			end
		else
			TriggerEvent("es:getPlayerFromId", source, function(user)
				user.notify("Le serverId " .. args[2] .. " n'existe pas.", "error", "topCenter", true, 5000)
			end)
		end
	end)
end, function(source, args, user)
	print("TEST")
	local source = source
	TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "permission insuffisante!")
end)

-- commande démission (provisoire) :
TriggerEvent('es:addCommand', 'demission', function(source, args, user)
	if #args ~= 1 then
		user.notify("Utilisation : /demission.", "error", "topCenter",true, 5000)
	else
		user.notify("Tu viens de quitter ton métier.", "success", "topCenter",true, 5000)
		local test = allJob[user.get('job')].removeEmploye(user)
		if test == "L employe n a pas ete trouve" then
			local result = nil
			for k,v in pairs(allJob) do
				result = v.isEmploye(user)
				if result then
					user.set("job", k)
					user.set("rank", result)
					TriggerClientEvent("ijob:updateJob", user.get('source'), user.get('job'), user.get('rank'))
					return
					CancelEvent()
				end
			end
			user.set("job", "chomeur")
			user.set("rank", allJob["chomeur"].default.rank)
			TriggerClientEvent("ijob:updateJob", user.get('source'), user.get('job'), user.get('rank'))
		end
	end
end)

------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------PAY--------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
function PayAllPlayer()
	SetTimeout(timePay, function()
		if enablePay then
			TriggerEvent("es:getPlayers", function(Users)
				for i=1, #Users do
					if allJob[Users[i].get('job')] then
						allJob[Users[i].get('job')].getPaid(Users[i])
					else
						print("Job : " .. Users[i].get('job') .. " not reconized by the iJob")
					end
				end
			end)
		else
			print("Pay not enable : see iJob/iJob_server.lua")
		end
		PayAllPlayer()
	end)
end

PayAllPlayer()

------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------OnResourceStop---------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
AddEventHandler("onResourceStop", function(resource)
	if resource == "iJob" then
		saveJob()
	end
end)
------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------DEBUG------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

function PrintAllIndexArray(array)
	for i=1, #array do
		for k,v in pairs(array[i]) do
			print("k : " .. tostring(k) .. "   v : " ..tostring(v))
		end
	end
end

function debugMsg(msg)
  if(msg) and debugg then
    print("iJob_Debug: " .. msg)
  end
end

-------------------Futur poubelle : 

------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------Test Rcon Cmd-------------------------------------------------
------------------------------------------------------------Hardcoding--------------------------------------------------


AddEventHandler('rconCommand', function(commandName, args) -- Je ne fais aucune vérification car je m'en fou, c'est juste pour tester et vous montrer comment ça fonctionne
	
	local msg = table.concat(args, ' ')
	local job = args[2]

    --[[if commandName == "addZone" then

    	local zone = nil
    	allJob[job]:addZone(zone)

        CancelEvent()

    elseif commandName == "addEmploye" then

    	local employe = args[3] -- steamID64 Hexa
    	allJob[job]:addEmploye(employe)

    	CancelEvent()

    elseif commandName == "removeEmploye" then

    	local employe = args[3]
    	allJob[job]:removeEmploye(employe)

    	CancelEvent()

    elseif commandName == "addRank" then

    	local rank = args[3] -- juste un string avec le nom du rank
    	allJob[job]:addRank(rank)

    	CancelEvent()

    elseif commandName == "removeRank" then

    	local rank = args[3]
    	allJob[job]:removeRank(rank)

    	CancelEvent()

    elseif commandName == "setRank" then

    	local player = args[3] -- steam ID 64 Hexa
    	local rank = args[4] -- un rank déjà existant dans le job
    	allJob[job]:setRank(player, rank)

    	CancelEvent()

    elseif commandName == "getEmployeWithRank" then

    	local employe = allJob[job]:getEmployeWithRank() -- employe = { {pl = employe, rank = defaultRank},  {pl = employe2, rank = rankOsef} }

    	CancelEvent()

    elseif commandName == "getEmployeName" then

    	local employeId = allJob[job]:getEmployeId() -- employeId = { {pl = employe1}, {pl = employe2} }

    	CancelEvent()

    elseif commandName == "getCapital" then

    	local capital = allJob[job]:getCapital() -- float ou int 100 / 1542.2 / 486542.36

    	CancelEvent()

    elseif commandName == "setCapital" then

    	local amount = args[3]
    	allJob[job]:setCapital(amount) -- enleve 152.2 au capital. sinon job:setCapital(565) ajoute 565 au capital

    	CancelEvent()

    elseif commandName == "getBenefit" then

    	local allBenefit = allJob[job]:getBenefit() -- { {p = pl, a = m, re = r, dm = tostring(temp.day) .. " " .. tostring(temp.month)}, {p = pl, a = m, re = r, dm = tostring(temp.day) .. " " .. tostring(temp.month)} }
    	
    	CancelEvent()

    elseif commandName == "addBenefit" then

    	local pl = args[3] -- SteamId64 Hex
    	local m = args[4] -- le montant (automatiquement transformé en positif, donc pas de soucis avec le - ou +) et est transformé en number
    	local r = args[5] -- la raison : "vente de drogue", "course taxi" etc..
    	allJob[job]:addBenefit(pl, m, r)

    	CancelEvent()

    elseif commandName == "addLost" then

    	local pl = args[3] -- SteamId64 Hex
    	local m = args[4] -- le montant (automatiquement transformé en négatif, donc pas de soucis avec le - ou +) et est transformé en number
    	local r = args[5] -- la raison : "essence", "achat outils", "réparation vehicule" etc..
    	allJob[job]:addLost(pl, m, r)

    	CancelEvent()

    elseif commandName == "addBlacklist" then

    	local pl = args[3] -- SteamId64 Hex
    	local isReturned = allJob[job]:addBlacklist(pl)
    	print(isReturned)

    	CancelEvent()

    elseif commandName == "isBlacklisted" then -- Ne fonctionne pas pour le moment

    	local pl = args[3] 
    	local isBlacklisted = Job:isBlacklisted(pl)

    	CancelEvent()

    elseif commandName == "removeBlacklist" then

    	local pl = args[3] -- SteamId64 Hex
    	allJob[job]:removeBlacklist(pl)

    	CancelEvent()

    elseif commandName == "getSalaryForRank" then

    	local rank = args[3] -- le rank en string
    	local salary = allJob[job]:getSalaryForRank(rank) -- retourne un number du montant correspondant au rank

    	CancelEvent()

    elseif commandName == "setSalaryForRank" then

    	local m = args[3] -- un montant pour le rank préciser au dessous
    	local rank = args[4] -- le rank en string

    	CancelEvent()

    	allJob[job]:setSalaryForRank(m, rank)

    end ]]
    
end)