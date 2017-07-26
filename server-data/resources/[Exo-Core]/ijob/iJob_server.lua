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
			rank = { {name = "Capitaine", salary = 500}, {name="Cadet", salary = 100} },
			blacklist = {{p = "steamTest", dhm = "14 6 5"} },
			lost = { {p = "steamTest2", a = 10, re = "essence", dmh = "14 6 5"}, {p = "steamTest3", a = 10, re = "essence", dmh = "14 6 5"} },
			benefit = { {p = "steamTest2", a = 10, re = "venteTest", dmh = "14 6 5"}, {p = "steamTest3", a = 10, re = "venteTest", dmh = "14 6 5"} },
			capital = 100000,
			name = "LSSD",
			pay = 0,
			employe = { {pl = "employe", rank = "defaultRank", fullname = "fullName"} }
		}

		local encodedRank = json.encode(tableTest.rank)
		local encodedBlacklist = json.encode(tableTest.blacklist)
		local encodedLost = json.encode(tableTest.lost)
		local encodedBenefit = json.encode(tableTest.benefit) 
		local encodedEmploye = json.encode(tableTest.employe)
		local capital = tostring(tableTest.capital)
		local pay = tostring(tableTest.pay)

		MySQL.Sync.execute("INSERT INTO job (`capital`, `benefit`, `lost`, `pay`, `rank`, `employe`, `blacklist`, `name`) VALUES (@capital, @benefit, @lost, @pay, @rank, @employe, @blacklist, @name)", {
			['@capital'] = capital, 
			['@benefit'] = encodedBenefit, 
			['@lost'] = encodedLost, 
			['@pay'] = pay, 
			['@rank'] = encodedRank, 
			['@employe'] = encodedEmploye, 
			['@blacklist'] = encodedBlacklist, 
			['@name'] = tableTest.name
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
		allJob[test.name] = CreateJob(test.capital, json.decode(test.benefit), json.decode(test.lost), test.name, test.pay, json.decode(test.rank), json.decode(test.employe), test2, json.decode(test.blacklist)) -- zone contain { zone1 = { }, zone2 = { }, zone3 = { } }
	else -- the job got a zone assigned by the categorie name

		allJob[test.name] = CreateJob(test.capital, json.decode(test.benefit), json.decode(test.lost), test.name, test.pay, json.decode(test.rank), json.decode(test.employe), nil, json.decode(test.blacklist))

	end

end

function UpdateJob()
	SetTimeout(3000, function()
		TriggerEvent("es:getPlayers", function(Users)
			for k,v in pairs(Users) do
				if v ~= nil then
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

				if v.get('haveChanged') then -- only if changed	
					MySQL.Sync.execute("UPDATE job SET `capital`=@vcapital, `benefit`=@vbenefit, `lost`=@vlost, `pay`=@vpay, `rank`=@vrank, `employe`=@vemploye, `blacklist`=@vblacklist, `name`=@vname WHERE name = @vname",{
						['@vcapital'] = tostring(v.get('capital')), 
						['@vbenefit'] = json.encode(v.get('benefit')),
						['@vlost'] = json.encode(v.get('lost')), 
						['@vpay'] = tostring(v.get('pay')),
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

		MySQL.Sync.execute("UPDATE job SET `capital`=@vcapital, `benefit`=@vbenefit, `lost`=@vlost, `pay`=@vpay, `rank`=@vrank, `employe`=@vemploye, `blacklist`=@vblacklist, `name`=@vname WHERE name = @vname",{
			['@vcapital'] = tostring(v.get('capital')), 
			['@vbenefit'] = json.encode(v.get('benefit')),
			['@vlost'] = json.encode(v.get('lost')), 
			['@vpay'] = tostring(v.get('pay')),
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
		local item = {}
		local quantity = {}
		local lucky = false
		local randomReceive = math.random(1, 100)

		if randomReceive < 20 then -- 20% de chance d'avoir un item rare
			item = result.receive.normal
			lucky = true
		elseif randomReceive < 100 then -- 80% de change d'avoir deux item normaux
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
-------------------------------------------------------EVENT JOB--------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------


RegisterServerEvent('ijob:changeJobPoleEmplois') -- Le joueur est nécéssairement Online
AddEventHandler('ijob:changeJobPoleEmplois', function(job)
	local job = string.lower(job)
	--RconPrint("Job Changed to " .. tostring(job))
	TriggerEvent("es:getPlayerFromId", source, function(user)
		if allJob[job].isBlacklisted(user.get('identifier')) then
			user.notify("Tu es <span style='color:red'>blacklisté</span> du métier, attends encore un peu.", error, true, 5000)
		else
			local result = allJob[job].addEmployeWithRefresh(user)
			if result == "already" then
				user.notify("Tu as déjà le métier de <span style='color:yellow' > "..job.. "</span>, tu ne peux pas faire cette action.", success, "topCenter", true, 5000)
			else
				user.notify("Bienvenue chez les <span style='color:yellow' > "..job.. "</span> contact ton patron, il te donnera les infos dont tu as besoin.", success, "topCenter", true, 5000)
				TriggerClientEvent("ijob:updateJob", user.get('source'), user.get('job'), user.get('rank'))
				TriggerClientEvent("ijob:addBlip", user.get('source'), allJob[user.get('job')].getBlip(), true)
			end
		end
	end)

end)

RegisterServerEvent('ijob:changeJobOff') -- Quand le joueur est Offline
AddEventHandler('ijob:changeJobOff', function(job, employe)

	if allJob[job].get('isBlacklisted') then

		-- TriggerClientEvent()  TODO : Faire une notification au joueur comme quoi il est blacklist
	else
		TriggerEvent("es:getPlayerFromIdentifier", employe, function(user)
			allJob[job].addEmploye(employe, user.get('fullname'))
			-- TriggerClientEvent()  TODO : Faire une notification au joueur comme quoi il est ajouté au job
		end)
	end

end)

RegisterServerEvent('ijob:changeJobByAdminOf') -- Quand le joueur est Offline
AddEventHandler('ijob:changeJobOff', function(job, employe)

		TriggerEvent("es:getPlayerFromIdentifier", employe, function(user)
			allJob[job].addEmploye(employe, user.get('fullname'))
			-- TriggerClientEvent()  TODO : Faire une notification au joueur comme quoi il est ajouté au job
		end)

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