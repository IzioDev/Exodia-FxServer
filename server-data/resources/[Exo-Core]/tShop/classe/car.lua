allItem = nil
local defaultInvWeight = 300.0 -- To change

-- We load the Items datas
AddEventHandler('item:getAllItems', function(items)
	allItem = items
end)
-- We load if the resource restart
AddEventHandler('car:retrieveItemRestart', function ()
	local result = MySQL.Sync.fetchAll("SELECT * FROM item", {})
	allItem = result
end)

function CreateCar(carInfos) -- Create Car Object
    local self = {}
    self.plate = carInfos.vehicle_plate
    self.model = carInfos.vehicle_model
    self.state = carInfos.vehicle_state
    self.primaryColor = carInfos.vehicle_colorprimary
    self.secondaryColor = carInfos.vehicle_colorsecondary
    self.plctColor = carInfos.vehicle_pearlescentcolor
    self.wheelsColor = carInfos.vehicle_wheelcolor
    self.lastpos = json.decode(carInfos.lastpos)
    self.inventory = json.decode(carInfos.inventory)
    self.owner = carInfos.identifier
    self.inventoryWeight = tonumber(carInfos.inventoryWeight)
    self.lastpos = json.decode(carInfos.lastpos)
    self.session = {}
    self.haveChanged = false
    self.item = allItem

    local rTable = {}
    -- Inv Stuff
    rTable.isAbleToGive = function(item, quantity)
		for i = 1, #self.inventory do
			if tonumber(self.inventory[i].id) == tonumber(item) then
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
		local fakePlusWeight = (tonumber(self.item[tonumber(item)].weight) / 1000 ) * tonumber(quantity)
		if ( totalWeight < defaultInvWeight ) then
			return true
		else
			return false
		end
	end

    rTable.setQuantityItem = function(itemid, quantity)
    	local thisItemId = tonumber(itemid)
		local thisQuantity = tonumber(quantity)
		for i = 1, #self.inventory do
			if self.inventory[i].itemid == tonumber(itemid) then
				self.inventory[i].quantity = tonumber(quantity)
				SetChange(self)
				return 1
			end
		end
		table.insert(self.inventory,
			{
				itemid = tonumber(thisItemId),
				quantity = tonumber(thisQuantity)
			}
		)
		SetChange(self)
		return 2
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
		table.insert(self.inventory,
			{
				id = thisItemId,
				quantity = thisQuantity
			}
		)
		SetChange(self)
		return 2
	end

    rTable.sendDatas = function()
    	local datasArray = {
		weight = 300.0, -- self.inventoryWeight
		id = "plate:"..self.plate,
		invType = "vehicle_inventory",
		items = self.inventory
		}

		return json.encode(datasArray)
	end
	-- Session, get, set stuff
	rTable.setSessionVar = function(key, value)
		self.session[key] = value
	end

	rTable.getSessionVar = function(k)
		return self.session[k]
	end

	rTable.set = function(k, v)
		self[k] = v
		SetChange(self)
	end

	rTable.get = function(k)
		return self[k]
	end

    return rTable
end

-- Utils Functions
function GetTotalWeight(car, itemid, quantity)
	local total = tonumber(car.item[itemid].weight / 1000 * quantity)
	for i = 1, #car.inventory do
		total = total + ( tonumber(car.item[tonumber(car.inventory[i].id)].weight / 1000 ) * tonumber(car.inventory[i].quantity) )
	end
	return math.ceil((total)*1000)/1000
end

function SetChange(car)
	car.haveChanged = true
end