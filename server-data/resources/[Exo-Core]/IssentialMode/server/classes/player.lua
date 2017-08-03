-- Copyright (C) Izio, Inc - All Rights Reserved
-- Unauthorized copying of this file, via any medium is strictly prohibited
-- Proprietary and confidential
-- Written by Romain Billot <romainbillot3009@gmail.com>, Jully 2017

allItem = nil -- init allItem datas
defaultInvWeight = 3
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
	self.phoneNumber = DecodedIdentity.phoneNumber
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
	self.lastpos = json.decode(Issential.lastpos)
	self.coords = json.decode(Issential.lastpos)
	self.session = {}
	self.haveChanged = false

	local rTable = {}

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
		TriggerClientEvent("banking:updateBalance", self.source, math.abs(tonumber(m)))
		SetChange(self)
	end
	
	rTable.removeBank = function(m)
		local newBank = self.bank - math.abs(tonumber(m))
		self.bank = newBank

		TriggerClientEvent("banking:removeBalance", self.source, -math.abs(tonumber(m)))
		TriggerClientEvent("banking:updateBalance", self.source, -math.abs(tonumber(m)))
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
		TriggerClientEvent("inventory:change", source, datasArray)
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
	print("notified")
		TriggerClientEvent("pNotify:notifyFromServer", self.source , ntext, ntype, nlayout, nprogress, ntimeout)
		-- ntext : string | ntype = alert, success, error, warning, info | 
		-- nlayout = top, topLeft, topCenter, topRight, center, centerLeft, centerRight, bottom, bottomLeft, bottomCenter, bottomRight.
		-- nprogress : true, false | ntimeout : number in MS.
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