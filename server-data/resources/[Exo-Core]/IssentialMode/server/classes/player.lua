-- Copyright (C) Izio, Inc - All Rights Reserved
-- Unauthorized copying of this file, via any medium is strictly prohibited
-- Proprietary and confidential
-- Written by Romain Billot <romainbillot3009@gmail.com>, Jully 2017

allItem = nil -- int allItem datas
defaultInvWeight = 8
AddEventHandler('onMySQLReady', function ()
	local result = MySQL.Sync.fetchAll("SELECT * FROM item")
	allItem = result
	local treatWeapons = {}
	for i = 1, #allItem do--
		if allItem[i].hash then
			table.insert(treatWeapons, allItem[i])
		end
	end
	allItem.weapons = treatWeapons
	TriggerEvent("item:getAllItems", allItem)
end)

function CreateUser(source, Issential)
	local self = {}
	local DecodedIdentity = json.decode(Issential.identity)
	local DecodedSkin = json.decode(Issential.skin)
	self.source = tonumber(source)
	self.id = tonumber(Issential.id)
	self.identity = DecodedIdentity
	self.permission_level = Issential.permission_level
	self.money = tonumber(Issential.money)
	self.dirtyMoney = tonumber(Issential.dirty_money)
	self.bank = Issential.bank
	self.inventory = json.decode(Issential.inventory)
	self.job = Issential.job
	self.rank = Issential.rank
	self.displayName = DecodedIdentity.firstName .. " " .. DecodedIdentity.lastName
	self.firstName = DecodedIdentity.firstName
	self.lastName = DecodedIdentity.lastName
	self.age = DecodedIdentity.age
	self.phoneNumber = Issential.phone_number
	self.playTime = tonumber(DecodedIdentity.playTime)
	self.sessionPlayTime = 0
	self.sex = tonumber(DecodedSkin.sex)
	self.skin = DecodedSkin
	self.accountNumber = DecodedIdentity.accountNumber
	self.identifier = Issential.identifier
	self.item = allItem -- on stock ici tous les items avec leur caractéristique
	self.group = Issential.group
	if Issential.waitingWeapons == nil then
		self.weapons = nil
	else
		self.weapons = json.decode(Issential.waitingWeapons)
	end
	self.otherInGameInfos = json.decode(Issential.otherInGameInfos)
	self.lastpos = json.decode(Issential.lastpos)
	self.coords = json.decode(Issential.lastpos)
	self.session = {}
	self.haveChanged = false

	-- iFood
	self.hunger = json.decode(Issential.iFood).hunger
	self.thirst = json.decode(Issential.iFood).thirst

	local rTable = {}

	-- iFood Stuff
	rTable.addHunger = function(m)
		local old = self.hunger 
		local newHunger = self.hunger + tonumber(m)

		ManageHunger(self, newHunger, old)
	end

	rTable.reduceHunger = function(m)
		local old = self.hunger
		local newHunger = self.hunger - tonumber(m)

		ManageHunger(self, newHunger, old)
	end

	rTable.setThirst = function(m)
		local new = tonumber(m)
	end

	-- Money Stuff
	rTable.setMoney = function(m)
		local prevMoney = self.money
		local newMoney = tonumber(m)

		self.money = tonumber(m)

		if((prevMoney - newMoney) < 0)then
			TriggerClientEvent("es:addedMoney", self.source, math.abs(prevMoney - newMoney), settings.defaultSettings.nativeMoneySystem)
		else
			TriggerClientEvent("es:removedMoney", self.source, math.abs(prevMoney - newMoney), settings.defaultSettings.nativeMoneySystem)
		end
		TriggerClientEvent("es:activateMoney", self.source , self.money)
		SetChange(self)
	end

	rTable.setBankBalance = function(m)
		self.bank = tonumber(m)
		SetChange(self)
	end

	rTable.setDityMoney = function(m)
		local prevMoney = self.dirty_money
		local newMoney = tonumber(m)

		self.dirty_money = m

		if((prevMoney - newMoney) < 0)then
			TriggerClientEvent("es:addedDirtyMoney", self.source, math.abs(prevMoney - newMoney))
		else
			TriggerClientEvent("es:removedDirtyMoney", self.source, math.abs(prevMoney - newMoney))
		end
		SetChange(self)
		TriggerClientEvent("es:activateDirtyMoney", self.source , self.dirty_money)
	end

	rTable.addMoney = function(m)
		local newMoney = self.money + math.abs(tonumber(m))

		self.money = newMoney

		TriggerClientEvent("es:addedMoney", self.source, math.abs(tonumber(m)))
		TriggerClientEvent("es:activateMoney", self.source , self.money)
		SetChange(self)
	end

	rTable.addDirtyMoney = function(m)
		local newMoney = self.dirty_money + math.abs(tonumber(m))
		self.dirty_money = newMoney
		TriggerClientEvent("es:addedDirtyMoney", self.source, math.abs(tonumber(m)))
		TriggerClientEvent("es:activateDirtyMoney", self.source , self.dirty_money)
		SetChange(self)
	end

	rTable.removeMoney = function(m)
		local newMoney = self.money - math.abs(tonumber(m))

		self.money = newMoney

		TriggerClientEvent("es:removedMoney", self.source, -math.abs(tonumber(m)))
		TriggerClientEvent("es:activateMoney", self.source , self.money)
		SetChange(self)
	end

	rTable.removeDirtyMoney = function(m)
		local newMoney = self.dirty_money -math.abs(tonumber(m))
		self.dirty_money = newMoney
		TriggerClientEvent("es:removedDirtyMoney", self.source, -math.abs(tonumber(m)))
		TriggerClientEvent('es:activateDirtyMoney', self.source , self.dirty_money)
		SetChange(self)
	end

	rTable.addBank = function(m)
		local newBank = self.bank + math.abs(tonumber(m))
		self.bank = newBank

		TriggerClientEvent("banking:addBalance", self.source, math.abs(tonumber(m)))
		TriggerClientEvent("banking:updateBalance", self.source, self.bank)
		SetChange(self)
	end
	
	rTable.removeBank = function(m)
		local newBank = self.bank - math.abs(tonumber(m))
		self.bank = newBank

		TriggerClientEvent("banking:removeBalance", self.source, -math.abs(tonumber(m)))
		TriggerClientEvent("banking:updateBalance", self.source, self.bank)
		SetChange(self)
	end

	rTable.displayMoney = function(m)
		TriggerClientEvent("es:addedMoney", self.source, m)
	end
	
	rTable.displayBank = function(m)
		TriggerClientEvent("banking:addBalance", self.source, m)
	end
	-- Inv stuff (To repair)
	rTable.addQuantity = function(itemid, quantity)
		local thisItemId = tonumber(itemid)
		local thisQuantity = tonumber(quantity)
		for i = 1, #self.inventory do
			if self.inventory[i].id == tonumber(itemid) then
				self.inventory[i].quantity = self.inventory[i].quantity + tonumber(quantity)
				SetChange(self)
				return 1
			end
		end
		table.insert(self.inventory,{
				id = thisItemId,
				quantity = thisQuantity
			})
		SetChange(self)
		return 2
	end

	rTable.addQuantityArray = function(item, quantity)
		local found = false
		for i=1, #item do
			for j=1, #self.inventory do
				if self.inventory[j].id == tonumber(item[i]) then
					self.inventory[j].quantity = self.inventory[j].quantity + tonumber(quantity[i])
					found = true
				end
			end
			if not(found) then
				table.insert(self.inventory,{
				id = tonumber(item[i]),
				quantity = tonumber(quantity[i])
			})
			else
				found = false
			end
		end
	end
	
	rTable.removeQuantityArray = function(item, quantity)
		for i=1, #item do
			for j=1, #self.inventory do
				if self.inventory[j].id == tonumber(item[i]) then
					self.inventory[j].quantity = self.inventory[j].quantity - tonumber(quantity[i])
					if self.inventory[j].quantity < 1 then
						self.inventory[j].quantity = 0
					end
				end
			end
		end
	end

	rTable.removeQuantity = function(itemid, quantity)
		local thisItemId = tonumber(itemid)
		local thisQuantity = tonumber(quantity)
		for i = 1, #self.inventory do
			if self.inventory[i].id == tonumber(itemid) and self.inventory[i].quantity >= tonumber(quantity) then
				self.inventory[i].quantity = self.inventory[i].quantity - tonumber(quantity)
				SetChange(self)
				return 1
			end
		end
	end

	rTable.sendDatas = function()
		local datasArray = {
		weight = defaultInvWeight,
		id = self.identifier,
		invType = "personal_inventory",
		items = self.inventory
	}
		return json.encode(datasArray)
	end

	rTable.refreshInventory = function()
		local datasArray = {
		weight = defaultInvWeight,
		id = self.identifier,
		invType = "personal_inventory",
		items = self.inventory
		}
		TriggerClientEvent("inventory:change", source, json.encode(datasArray))
	end

	rTable.isAbleToGive = function(itemId, quantity)
		for i = 1, #self.inventory do
			if tonumber(self.inventory[i].id) == tonumber(itemId) then
				if tonumber(quantity) <= tonumber(self.inventory[i].quantity) then
					return true
				else
					return false
				end
			end
		end
		return false
	end

	rTable.isAbleToReceive = function(item, quantity)
		local totalWeight = GetTotalWeight(self, tonumber(item), tonumber(quantity))
		if ( totalWeight <= defaultInvWeight ) then
			return true
		else
			return false
		end
	end

	rTable.isAbleToReceiveItems = function(itemA, quantityA)
		local totalWeight = GetTotalWeightForArray(self, itemA, quantityA) -- deux array
		if ( totalWeight <= defaultInvWeight ) then
			return true
		else
			return false
		end
	end
	-- Weapons Stuff : 
	rTable.returnWeaponInfos = function(weaponHash)
		print(json.encode(self.item.weapons))
		print(weaponHash)
		for i = 1, #self.item.weapons do
			if self.item.weapons[i].hash == weaponHash then
				return self.item.weapons[i]
			end
		end
		return 'not found'
	end

	-- Notify Stuff
	rTable.notify = function(ntext, ntype, nlayout, nprogress, ntimeout)
		TriggerClientEvent("pNotify:notifyFromServer", self.source , ntext, ntype, nlayout, nprogress, ntimeout)
		-- ntext : string | ntype = alert, success, error, warning, info | 
		-- nlayout = top, topLeft, topCenter, topRight, center, centerLeft, centerRight, bottom, bottomLeft, bottomCenter, bottomRight.
		-- nprogress : true, false | ntimeout : number in MS.
	end

	rTable.alert = function(title, desc, params)
		TriggerClientEvent("Issential:alertFromServer", self.source, title, desc, params)
	end

	rTable.sendSms = function(exp, message)
		TriggerClientEvent("gcPhone:receiveMessage", self.source, {
					transmitter = exp, 
					receiver = "test", 
					message = message, 
					isRead = 0,
					owner = 0,
					time = "Bouge ton cul"
				})
	end

	-- Identity Stuff
	rTable.changeName = function(first, last, age)
		self.firstName = first
		self.lastName = last
		self.age = tonumber(age)
		self.displayName = first .. " " .. last
		SetChange(self)
	end

	rTable.changePhoneNumber = function(phoneNb)
		self.phoneNumber = phoneNb
	end

	rTable.incrementPlayTime = function()
		self.playTime = self.playTime + 60
		self.sessionPlayTime = self.sessionPlayTime + 60
		self.identity.playTime = self.playTime
		SetChange(self)
	end

	-- Job&Rank Stuff
	rTable.setJob = function(jobName)
		self.job = jobName
	end

	rTable.setRank = function(rankName)
		self.rank = rankName
	end
	-- Session, get, set stuff, perm and group
	rTable.setSessionVar = function(key, value)
		self.session[key] = value
	end

	rTable.getSessionVar = function(k)
		return self.session[k]
	end

	rTable.setOtherInGameInfos = function(k, v)
		self.otherInGameInfos[k] = v
	end

	rTable.getOtherInGameInfos = function(k)
		return self.otherInGameInfos[k]
	end

	rTable.setIdentity = function(k, v)
		self.identity[k] = v
	end

	rTable.getIdentity = function(k)
		return self.identity[k]
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

	rTable.getPermissions = function()
		return self.permission_level
	end

	rTable.getGroup = function()
		return self.group
	end
	-- Utils stuff
	rTable.kick = function(r)
		DropPlayer(self.source, r)
	end

	rTable.setCoords = function(x, y, z)
		self.coords = {x = x, y = y, z = z}
	end
	-- test Flushing ?
	rTable.flush = function()
		self = nil
	end

	rTable.setGlobal = function(g, default)
		self[g] = default or ""

		rTable["get" .. g:gsub("^%l", string.upper)] = function()
			return self[g]
		end

		rTable["set" .. g:gsub("^%l", string.upper)] = function(e)
			self[g] = e
		end

		Users[self.source] = rTable
	end

	-- iFood Stuff
	rTable.addHunger = function(m)
		local old = self.hunger 
		local newHunger = self.hunger + tonumber(m)

		ManageHunger(self.source, old, newHunger, function(hunger)
			self.hunger = hunger
		end)
	end

	rTable.reduceHunger = function(m)
		local old = self.hunger
		local newHunger = self.hunger - tonumber(m)

		ManageHunger(self.source, old, newHunger, function(hunger)
			self.hunger = hunger
		end)
	end

	rTable.addThirst = function(m)
		local old = self.thirst 
		local newThirst = self.thirst + tonumber(m)

		ManageThirst(self.source, old, newThirst, function(thirst)
			self.thirst = thirst
		end)
	end

	rTable.reduceThirst = function(m)
		local old = self.thirst
		local newThirst = self.thirst - tonumber(m)

		ManageThirst(self.source, old, newThirst, function(thirst)
			self.thirst = thirst
		end)
	end

	return rTable
end
-- End rTable

-- Utils Function
function SetChange(user)
	user.haveChanged = true
end

function GetTotalWeight(myUser, item, quantity)
	local wtfItem = item
	local total = 0
	for i = 1, #myUser.inventory do
		total = total + ( tonumber(myUser.item[tonumber(myUser.inventory[i].id)].weight / 1000 ) * tonumber(myUser.inventory[i].quantity) )
	end
	total = total + ( tonumber(myUser.item[wtfItem].weight / 1000 ) * quantity )
	return total
end

function GetTotalWeightForArray(myUser, itemA, quantityA) -- autant d'elements pour item que pour quantity
	local total = 0
	for i = 1, #myUser.inventory do
		total = total + ( tonumber(myUser.item[tonumber(myUser.inventory[i].id)].weight / 1000 ) * tonumber(myUser.inventory[i].quantity) )
	end
	for i=1, #itemA do
		total = total + ( tonumber(myUser.item[tonumber(itemA[i])].weight / 1000 ) * tonumber(quantityA[i]) )
	end
	return total
end

function ManageHunger(source, old, hunger, cb)
	if(hunger < 0 and old <= 0)then
		hunger = 0
		TriggerClientEvent('iFood:die', source)
	elseif(hunger > 0 and old <= 0)then
		TriggerClientEvent('iFood:cancelDeath', source)
	end

	if(hunger <= 100 and hunger > 90)then
		msg = "Je suis rassasié !"
	elseif(hunger <= 90 and hunger > 70)then
		msg = "J'ai bien mangé !"
	elseif(hunger <= 70 and hunger > 50)then
		msg = "Maman, c'est quand l'heure du goûter ?"
	elseif(hunger <= 50 and hunger > 35)then
		msg = "Je commence à avoir faim ..."
	elseif(hunger <= 35 and hunger > 20)then
		msg = "J'ai faim."
	elseif(hunger <= 20 and hunger > 10)then
		msg = "J'ai la tête qui tourne à cause de la faim ..."
	elseif(hunger <= 10 and hunger > 0)then
		msg = "Je me sens faible, il faut absolument que je trouve de quoi manger."
	end

	cb(hunger)
	TriggerClientEvent('iFood:updateUI', source, 'hunger', msg)
end

function ManageThirst(source, old, thirst, cb)
	if(thirst < 0 and old <= 0)then
		thirst = 0
		TriggerClientEvent('iFood:die', source)
	elseif(thirst > 0 and old <= 0)then
		TriggerClientEvent('iFood:cancelDeath', source)
	end

	if(thirst <= 100 and thirst > 90)then
		msg = "Eheh, mon ventre fait glouglou !"
	elseif(thirst <= 90 and thirst > 70)then
		msg = "Je n'ai plus soif !"
	elseif(thirst <= 70 and thirst > 50)then
		msg = "S'hydrater, c'est la santé !"
	elseif(thirst <= 50 and thirst > 35)then
		msg = "Je commence à avoir soif ..."
	elseif(thirst <= 35 and thirst > 20)then
		msg = "J'ai soif."
	elseif(thirst <= 20 and thirst > 10)then
		msg = "Il faut que je trouve quelque chose à boire ..."
	elseif(thirst <= 10 and thirst > 0)then
		msg = "Je suis déshydraté, il faut absolument que je trouve à boire."
	end

	cb(thirst)
	TriggerClientEvent('iFood:updateUI', source, 'thirst', msg)
end