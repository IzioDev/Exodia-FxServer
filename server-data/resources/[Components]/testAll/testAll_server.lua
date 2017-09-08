TriggerEvent('es:addGroupCommand', 'addPumpStation', 'owner', function(source, args, user)
	if #args ~= 1 then
		user.notify("Utilisez la commande de cette manière : /addPumpStation [ID], utilisez le meme ID pour une même station", "error", "topCenter", true, 5000)
		CancelEvent()
	else
		local result = MySQL.Sync.fetchAll('SELECT * FROM AddPlace')

		local resultDecoded = nil

		if result[1].pumpStation == nil then
			resultDecoded = {}
		else
			resultDecoded = json.decode(result[1].pumpStation)
		end

		table.insert(resultDecoded, {x = math.ceil(user.get('coords').x*10)/10, y = math.ceil(user.get('coords').y*10)/10, z = math.ceil(user.get('coords').z*10)/10, id = tonumber(args[2])})
		MySQL.Sync.execute("UPDATE AddPlace SET `pumpStation`=@pumpStation WHERE id=1", {
			['@pumpStation'] = json.encode(resultDecoded)
		})

		user.notify("Point ajouté avec succès", "success", "topCenter", true, 5000)
	end
end)

TriggerEvent('es:addGroupCommand', 'addGasStation', 'owner', function(source, args, user)
	if #args ~= 2 then
		user.notify("Utilisez la commande de cette manière : /addGasStation [ID], utilisez le meme ID pour une même station", "error", "topCenter", true, 5000)
		CancelEvent()
	else
		local result = MySQL.Sync.fetchAll('SELECT * FROM AddPlace')

		local resultDecoded = nil

		if result[1].gasStation == nil then
			resultDecoded = {}
		else
			resultDecoded = json.decode(result[1].gasStation)
		end

		table.insert(resultDecoded, {x = math.ceil(user.get('coords').x*10)/10, y = math.ceil(user.get('coords').y*10)/10, z = math.ceil(user.get('coords').z*10)/10, id = tonumber(args[2])})
		MySQL.Sync.execute("UPDATE AddPlace SET `gasStation`=@gasStation WHERE id=1", {
			['@gasStation'] = json.encode(resultDecoded)
		})

		user.notify("Point ajouté avec succès à la station numéro : " .. args[2], "success", "topCenter", true, 5000)
	end
end)