maxSalary = 2000
blacklistedTime = 86400 -- A VOIR
defaultRank = "Apprenti"
debugg = true
maxCapacity = 200
-- Meta table pour job, mets ta table, ta maman sera contente ;)


function CreateJob(capital, benefit, lost, name, default, rank, employe, zone, blacklist)
	local self = {}
	self.capital = tonumber(capital) -- int (8)
	self.benefit = benefit           -- {p = pl, a = m, re = r, dm = tostring(temp.day) .. " " .. tostring(temp.month)}
	self.lost = lost                 -- {p = pl, a = m, re = r, dmh = tostring(temp.day) .. " " .. tostring(temp.month) .. " " .. tostring(temp.hour)}
	self.name = name                 -- string testname
	self.default = default                   -- int (0)
	self.rank = rank                 -- {name = string, salary = sting/int}
	self.employe = employe           -- { {pl = employe, rank = defaultRank},  {pl = employe2, rank = rankOsef} }
	self.zone = zone                 -- zone contain { zone1 = { }, zone2 = { }, zone3 = { } } OR CAN BE NIL
	self.blacklist = blacklist       -- {p = pl, dhm = tostring(temp.day) .. " " .. tostring(temp.hour) .. " " .. tostring(temp.min)}
	self.haveChanged = false
	self.harvestZone = {}

	for i = 1, #self.zone do
		local a, b = string.find(self.zone[i].nom, "rec")
		if a then
			table.insert(self.harvestZone, self.zone[i])
			if not(debugg) then
				self.harvestZone[#self.harvestZone].capacity = maxCapacity
			else
				self.harvestZone[#self.harvestZone].capacity = maxCapacity - 20
			end
		end
	end

	local rTable = {}

	rTable.addZone = function(zone) -- On ajoute la zone ayant pour nom de catégorie, le nom de job (ex: récolte traitement etc...)
		table.insert(self.zone, zone)
	end
	
	rTable.addEmployeWithRefresh = function(user) -- On ajoute l'employe SteamID64 au Job
		if user.get('job') == "chomeur" then
			for i=1, #self.employe do
				if self.employe[i].pl == user.get('identifier') then
					return "already"
				end
			end
			table.insert(self.employe, {pl = user.get('identifier'), fullname = user.get('dislayName'), rank = defaultRank})
			user.set('job', self.name)
			user.set('rank', self.default.rank)
	
			TriggerClientEvent("ijob:updateJob", user.get('source'), self.name, user.get('rank'))
		
			self.haveChanged = true
			return "Employe ajoute"
		else
			return "hireFirst"
		end
	end
	
	-- rTable.addEmploye = function(employe, nameFull) -- A utiliser si le joueur est offline (pour trouver son fullname, pas le choix, requete SQL)
	-- 	table.insert(self.employe, {pl = employe, fullname =  nameFull, rank = defaultRank})
	
	-- 	TriggerEvent("es:getPlayerFromIdentifier", employe, function(user)
	-- 		user:setJob(self.name)
	-- 		user:setRank(defaultRank)
	-- 	end)
	
	-- 	self.haveChanged = true
	-- 	return "Employe ajoute"
	-- end
	rTable.isEmploye = function(user)
		for i = 1, #self.employe do
			if self.employe[i].pl == user.get('identifier') then
				return self.employe[i].rank
			end
		end
		return false
	end
	
	rTable.removeEmploye = function(employe) -- l'objet utilisateur
		for i=1, #self.employe do
			if self.employe[i].pl == employe.get('identifier') then
				table.remove(self.employe, i)
				employe.set('job',"chomeur")
				employe.set('rank', " ")
				addBlackList(self, employe.get('identifier'))
				self.haveChanged = true
				TriggerClientEvent("ijob:updateJob", employe.get('source'), employe.get('job'), employe.get('rank'))
				-- TriggerEvent("ijob:fireEmploye", employe, self.name) A voir si on le retire direct BDD ou attendre un save (60 sec)
				return "Employe vire"
			end
		end
		return "L employe n a pas ete trouve"
	end
	
	rTable.addRank = function(rank)  -- On ajoute le Rank (cela permettrai au patron d'ajouter différent rank par exemple)
		local rank = tostring(rank)
		table.insert(self.rank, {name = rank, salary = self.pay})
		self.haveChanged = true
		return "Rank ajoute"
	end
	
	rTable.removeRank = function(rankName) -- On retire le rank (Il faudrait ici mettre a jour le rank des employes du job aussi)
		for i = 1, #self.rank do
			if self.rank[i].name == rankName then
				table.remove(self.rank, i)
				for j = 1, #self.employe do -- on retire aussi le rank des joueurs qui avait ce rank (on les met Apprenti, avec la paye par défaut)
					if self.employe[j].rank == rankName then
						self.employe[j].rank = defaultRank -- TODO : prévenir le joueur qu'il à été demote (uniquement s'il est en ligne)
					end
				end
				self.haveChanged = true
				return "Rank efface"
			end
		end
		return "Rank non trouve"
	end
	
	rTable.setRank = function(player, rankName) -- On ajoute le rank donnné au player SteamID64
		for i = 1, #self.rank do
			if self.rank[i].name == rankName then
				for j = 1, #self.employe do
					if self.employe[j] == player then
						self.employe[j] = {pl = player, rank = rankName}
	
						TriggerEvent("es:getPlayerFromIdentifier", employe, function(user)
							user:setRank(rankName)
						end)
	
						self.haveChanged = true
						return "ok"
					end
				end
				return "employe not founded"
			end
		end
		return "rank not founded"
	end
	
	rTable.setRankWithRefresh = function(employe, rankName, source)
		for i = 1, #self.rank do
			if self.rank[i].name == rankName then
				for j = 1, #self.employe do
					if self.employe[j] == player then
						self.employe[j] = {pl = player, rank = rankName}
	
						TriggerEvent("es:getPlayerFromIdentifier", employe, function(user)
							user.set("rank", rankName)
							TriggerClientEvent("ijob:updateJob", source, self.name, rankName)
						end)
	
						self.haveChanged = true
						return "ok"
					end
				end
				return "employe not founded"
			end
		end
		return "rank not founded"
	end
	
	rTable.getEmployeWitRank = function() -- On retourne la table employe contenant autant de {pl = player, rank = rankName} que d'employe
		return self.employe
	end
	
	rTable.getEmployeId = function() -- On retourne le nom des employes (en fait leur steamID64)
		local employeName = {}
		for i = 1, #self.employe do
			table.insert(employeName, self.employe[i].pl)
		end
		return employeName
	end
	
	rTable.getEmployeName = function() -- On retourne leur fullName
		local employeName = {}
		for i = 1, #self.employe do
			table.insert(employeName, self.employe[i].fullname)
		end
	end
	
	rTable.getCapital = function() -- On retourne le capital du métier
		return tonumber(self.capital)
	end
	
	rTable.setCapital = function(m) -- On ajoute ou enleve au capital (on pourrait centraliser avec le benefice ? IDK)
		local prevCap = self.capital
		local newCap = math.ceil(tonumber(m) * 100 ) / 100
	
		self.capital = m
		self.haveChanged = true
		if (prevCap - newCap) < 0 then
			--TriggerServerEvent("ijob:addedCap", math.abs(prevCap - newCap)) On pourra mettre un HUD capital ici (pour que les employés le voit)
		else
			--TriggerServerEvent("ijob:removedCap", math.abs(prevCap - newCap)) Idem
		end
	
		--TriggerServerEvent("ijob:updateCap") Idem
		return "Change capital for  " .. self.name .. " new= " .. tostring(self.capital) .. " prev = " ..tostring(prevCap)
	end
	
	rTable.addCapital = function(m)
		local prevCap = self.capital
		local newCap = self.capital + math.abs(tonumber(m))
	
		self.capital = newCap
		return "New (add) capital for " .. self.name .. " new= " .. tostring(self.capital) .. " prev = " ..tostring(prevCap)
	end
	
	rTable.removeCapital = function(m)
		local prevCap = self.capital
		local newCap = self.capital - math.abs(tonumber(m))
	
		self.capital = newCap
		return "New (remove) capital for " .. self.name .. " = " .. tostring(self.capital) .. " prev = " ..tostring(prevCap)
	end
	
	rTable.getBenefit = function() -- On récupère l'énorme table bénéfice xDD Faudra changer ça, soit faire une class bénéfice, soit diviser les tables. A voir.
		return self.benefit
	end
	
	rTable.addBenefit = function(pl, m, r) -- On ajoute un entré au bénéfice
		local temp = os.date("*t", os.time())
		local m = math.abs(math.ceil(tonumber(m) * 100 ) / 100 )
		table.insert(self.benefit, {p = pl, a = m, re = r, dm = tostring(temp.day) .. " " .. tostring(temp.month)})
		self.haveChanged = true
		return "benefice ajoute"
	end
	
	rTable.addLost = function(pl, m, r) -- player, montant, raison (essence, réparation outil etc..)
		local temp = os.date("*t", os.time())
		local m = - math.abs(math.ceil(tonumber(m) * 100 ) / 100 )
		table.insert(self.benefit, {p = pl, a = m, re = r, dmh = tostring(temp.day) .. " " .. tostring(temp.month) .. " " .. tostring(temp.hour)})
		self.haveChanged = true
		return "lost ajoute"
	end
	
	rTable.addBlacklist = function(pl) -- On ajoute un joueur à la blacklist
		local temp = os.date("*t", os.time())
		table.insert(self.blacklist, {p = pl, dhm = tostring(temp.day) .. " " .. tostring(temp.hour) .. " " .. tostring(temp.min)})
		self.haveChanged = true
		return "blacklist ajoute"
	end
	
	rTable.isBlacklisted = function(pla) -- On vérifie si le joueur est blacklisté, return bool (true/false)
		for i = 1, #self.blacklist do
			if pla == self.blacklist[i].p then
	
				local result = {}
				local actualTime = os.time()
				local temp = os.date("*t", actualTime)
	
				for token in string.gmatch(self.blacklist.dhm, "[^%s]+") do
	  				table.insert(result, token)
				end
	
				local oldTime = os.time({year = temp.year, month = temp.month, day = tonumber(result[1]) , hour = tonumber(result[2]), min = tonumber(result[3])})
	
				if actualTime - oldTime < blacklistedTime then
					return true
				else
					table.remove(self.blacklist, i) -- on enlève le joueur de la blacklist "ban" de Job
					self.haveChanged = true
					return false
				end
			end
		end
		return false
	end
	-- 
	rTable.removeBlacklist = function(pl) -- On retire le joueur de la blacklist
		for k = 1, #self.blacklist do
			if self.balcklist[k] == pl then
				table.remove(self.blacklist, k)
				self.haveChanged = true
				return "ok"
			end
		end
		return "player not found as blacklisted"
	end
	
	rTable.getSalaryForRank = function(rankName) -- On renvoit le salaire du Rank
		for i = 1, #self.rank do
			if self.rank[i].name == rankName then
				return tonumber(self.rank[i].salary)
			end
		end
		return "rank not founded"  
	end
	
	rTable.setSalaryForRank = function(m, rankr) -- On met le salaire au rank
		local m = tonumber(m)
		local m = math.ceil(m)
		if m > 0 and m < maxSalary then
			for i = 1, #self.rank do
				if self.rank[i].name == rankr then
					self.rank[i].salary = m
					self.haveChanged = true
					return "Salaire actualise !"
				end
			end
			return "Rank non trouve"
		end
		--return "Merci de rentrer un nombre compris entre 0 et " .. tostring(maxSalary)
	end

	--Capactity Harvest stuff :
	rTable.addCapacityToAll = function(amount)
		for i=1, #self.harvestZone do
			if self.harvestZone[i].capacity < maxCapacity then
				self.harvestZone[i].capacity = self.harvestZone[i].capacity + amount
				if self.harvestZone[i].capacity > maxCapacity then
					self.harvestZone[i].capacity = maxCapacity
				end
			end
		end
	end

	rTable.removeCapacity = function(zoneName, amount)
		for i=1, #self.harvestZone do
			if self.harvestZone[i].nom == zoneName then
				self.harvestZone[i].capacity = self.harvestZone[i].capacity - amount
				if self.harvestZone[i].capacity < 0 then
					self.harvestZone[i].capacity = 0
				end
			end
		end
	end

	rTable.addCapacity = function(zoneName, amount)
		for i=1, #self.harvestZone do
			if self.harvestZone[i].nom == zoneName then
				self.harvestZone[i].capacity = self.harvestZone[i].capacity + amount
				if self.harvestZone[i].capacity > maxCapacity then
					self.harvestZone[i].capacity = maxCapacity
				end
			end
		end
	end

	rTable.harvest = function(zoneName, amountA, now)
		local somme = 0
		for i = 1, #self.harvestZone do
			if self.harvestZone[i].instructions.displayMessageInZone == zoneName then
				for j = 1, #amountA do
					somme = somme + amountA[j]
				end
				if self.harvestZone[i].capacity >= somme then
					if now then
						self.harvestZone[i].capacity = self.harvestZone[i].capacity - somme
					end
					return true
				else
					return false
				end
			end
		end
	end
	-- Blip stuff
	rTable.getBlip = function()
		local returnedBlipInfos = {}
		for i = 1, #self.zone do
			if self.zone[i].instructions.visible and self.zone[i].instructions.color and self.zone[i].instructions.sprite then
				table.insert(returnedBlipInfos,{
					sprite = self.zone[i].instructions.sprite,
					color = self.zone[i].instructions.color,
					x = self.zone[i].gravityCenter.x,
					y = self.zone[i].gravityCenter.y,
					z = self.zone[i].gravityCenter.z,
					text = self.zone[i].instructions.displayMessageInZone,
					visible = self.zone[i].instructions.visible -- je prévois, sait on jamais
				})
			end
		end
		return returnedBlipInfos
	end
	-- paid stuff
	
	rTable.getPaid = function(user)
		local pay = 0
		print('classe/job.lua --> paye a implenter')
	end

	rTable.set = function(k, v)
		self[k] = v
		if k ~= 60 then
			SetChange(self)
		end
	end

	rTable.get = function(k)
		return self[k]
	end

	return rTable
end

function addBlackList(job, steam64)
	local temp = os.date("*t", os.time())
	table.insert(job.blacklist, {p = pl, dhm = tostring(temp.day) .. " " .. tostring(temp.hour) .. " " .. tostring(temp.min)})
	print("blacklisted player")
	job.haveChanged = true
end

function SetChange(job)
	job.haveChanged = true
end