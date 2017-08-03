-- Copyright (C) Izio, Inc - All Rights Reserved
-- Unauthorized copying of this file, via any medium is strictly prohibited
-- Proprietary and confidential
-- Written by Romain Billot <romainbillot3009@gmail.com>, Jully 2017

local Keys = {
	["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
	["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
	["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
	["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
	["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
	["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
	["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
	["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
	["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}

inUse = false
allZone = {}
allZoneByCat = {}
debugg = true
points = {}

RegisterNetEvent("izone:notification")
AddEventHandler("izone:notification", function(msg, state)
	if state then
		message = "~g~"..msg
	else
		message = "~r~"..msg
	end
	SetNotificationTextEntry("STRING")
    AddTextComponentString(message)
    DrawNotification(false, false)
end)



RegisterNetEvent("izone:okforpoint")
AddEventHandler("izone:okforpoint", function()
	inUse = true
end)

RegisterNetEvent("izone:askforname")
AddEventHandler("izone:askforname", function()
	local editing = true
	DisplayOnscreenKeyboard(true, "FMMC_KEY_TIP8", "", "", "zoneName categorie", "", "", 120)
	while editing do
		Wait(0)
		if UpdateOnscreenKeyboard() == 2 then 
			editing = false
			TriggerEvent("izone:notification","Zone/Point non sauvegardé", false)
			inUse = false
			points = {}
			TriggerServerEvent("izone:notSaved")
		end
		if UpdateOnscreenKeyboard() == 1 then
			editing = false
			resultat = GetOnscreenKeyboardResult()
			TriggerEvent("izone:notification", "Zone/Point enregistré", true)
			local result = {}
		
			for token in string.gmatch(resultat, "[^%s]+") do
  				table.insert(result, token)
			end
			if #result == 2 then
				TriggerServerEvent("izone:savedb", result[1], result[2])
				inUse = false
				points = {}
			else
				TriggerEvent("izone:notification", "Merci de rentrer la categorie, avec un espace entre le nom de la zone et la categorie", false)
			end
		end
	end
end)

RegisterNetEvent("izone:transfertzones")
AddEventHandler("izone:transfertzones", function(allZones)
	allZone = allZones
	for i = 1, #allZone do -- On fait aussi un tri des zones par categorie
		if allZoneByCat[allZone[i].categorie] == nil then
			allZoneByCat[allZone[i].categorie] = {}
		end
		table.insert(allZoneByCat[allZone[i].categorie], allZone[i])
	end
end)

Citizen.CreateThread(function()
	TriggerServerEvent('givemezone')
	while true do
		Wait(0)
		if IsControlJustReleased(1, Keys["L"]) and inUse then
			local x, y, z = table.unpack(GetEntityCoords(GetPlayerPed(-1), true))
			TriggerEvent("izone:notification", "Point ajouté ".. "x = "..tostring(math.ceil(x)) .. " y = " .. tostring(math.ceil(y)) .. " z = " .. tostring(math.ceil(z)), true)
			TriggerServerEvent("izone:addpoint", tostring(x), tostring(y), tostring(z))
			table.insert(points, {xs = x, ys = y, zs = z}) -- We add each point
			Wait(1000)
		end
		if #points > 0 then
			for i = 1, #points do
				DrawMarker(0, points[i].xs, points[i].ys, points[i].zs, 0, 0, 0, 0, 0, 0, 0.1, 0.1, 3.0, 46, 89, 227, 230, 0, 0, 0,0)
				draw3DText(points[i].xs, points[i].ys, points[i].zs + 2.01 , "Point ~r~" .. i, 1, 0.5, 0.5)
			end
		end

		if #points > 1 then
			for i = 1, #points do
				if i ~= #points then
					DrawLine(points[i].xs, points[i].ys, points[i].zs, points[i+1].xs, points[i+1].ys, points[i+1].zs, 244, 34, 35, 230)
				else
					DrawLine(points[i].xs, points[i].ys, points[i].zs, points[1].xs, points[1].ys, points[1].zs, 244, 34, 35, 230)
				end
			end
		end
	end

end)

function draw3DText(x,y,z,textInput,fontId,scaleX,scaleY)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    local dist = GetDistanceBetweenCoords(px,py,pz, x,y,z, 1)

    local scale = (1/dist)*20
    local fov = (1/GetGameplayCamFov())*100
    local scale = scale*fov

    SetTextScale(scaleX*scale, scaleY*scale)
    SetTextFont(fontId)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 150)
    SetTextDropshadow(0, 0, 0, 0, 255)
    SetTextEdge(2, 0, 0, 0, 150)
    SetTextDropShadow()
    SetTextOutline()
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(textInput)
    SetDrawOrigin(x,y,z+2, 0)
    DrawText(0.0, 0.0)
    ClearDrawOrigin()
end


AddEventHandler("izone:getResultFromPlayerInAnyJobZone", function(job, cb)
	local plyCoords = GetEntityCoords(GetPlayerPed(-1), true)
	local x1, y1, z1 = table.unpack(plyCoords) -- on prend les coords du joueur
	local job = string.lower(job) -- the job should be the zoneCatName
	for i = 1, #allZoneByCat[job] do
		if allZoneByCat[job][i].instructions ~= nil then
			if GetDistanceBetweenCoords(x1, y1, z1, tonumber(allZoneByCat[job][i].gravityCenter.x), tonumber(allZoneByCat[job][i].gravityCenter.y), 1.01, false) < tonumber(allZoneByCat[job][i].longestDistance) then
				-- alors il y est peut etre : 
				local n = windPnPoly(allZoneByCat[job][i].coords, plyCoords)
				if n ~= 0 then -- alors il y est
					allZoneByCat[job][i].instructions.nom = allZoneByCat[job][i].nom
					cb(allZoneByCat[job][i].instructions) -- on retourne le résultat !
					return
				end
			end
		end
	end
	cb(nil)
end)

AddEventHandler("izone:isPlayerInAnyWarpSharedZone", function(cb)
	local plyCoords = GetEntityCoords(GetPlayerPed(-1), true)
	local x1, y1, z1 = table.unpack(plyCoords) -- on prend les coords du joueur
	for i = 1, #allZoneByCat["shared"] do
		if allZoneByCat["shared"][i].instructions.to then
			if GetDistanceBetweenCoords(x1, y1, z1, tonumber(allZoneByCat["shared"][i].gravityCenter.x), tonumber(allZoneByCat["shared"][i].gravityCenter.y), 1.01, false) < tonumber(allZoneByCat["shared"][i].longestDistance) then
				-- alors il y est peut etre : 
				local n = windPnPoly(allZoneByCat["shared"][i].coords, plyCoords)
				if n ~= 0 then -- alors il y est
					allZoneByCat["shared"][i].instructions.nom = allZoneByCat["shared"][i].nom
					cb(allZoneByCat["shared"][i].instructions) -- on retourne le résultat !
					return
				end
			end
		end 
	end
end)

AddEventHandler("izone:isPlayerInIllZone", function(cb)
	local plyCoords = GetEntityCoords(GetPlayerPed(-1), true)
	local x1, y1, z1 = table.unpack(plyCoords) -- on prend les coords du joueur
	for i = 1, #allZoneByCat["illegal"] do
		if allZoneByCat["illegal"][i] ~= nil then
			if GetDistanceBetweenCoords(x1, y1, z1, tonumber(allZoneByCat["illegal"][i].gravityCenter.x), tonumber(allZoneByCat["illegal"][i].gravityCenter.y), 1.01, false) < tonumber(allZoneByCat["illegal"][i].longestDistance) then
				-- alors il y est peut etre : 
				local n = windPnPoly(allZoneByCat["illegal"][i].coords, plyCoords)
				if n ~= 0 then -- alors il y est
					allZoneByCat["illegal"][i].instructions.nom = allZoneByCat["illegal"][i].nom
					cb(allZoneByCat["illegal"][i].instructions) -- on retourne le résultat !
					return
				end
			end
		end
	end
	cb(nil)
end)

AddEventHandler("izone:isPlayerInZoneReturnInstructions", function(zoneName, cb)
	found = FindZone(zoneName)
	if not found then
		cb(nil)
	else
		local plyCoords = GetEntityCoords(GetPlayerPed(-1), true)
		local x1, y1, z1 = table.unpack(plyCoords)
		if GetDistanceBetweenCoords(x1, y1, z1, tonumber(allZone[found].gravityCenter.x), tonumber(allZone[found].gravityCenter.y), 1.01, false) < tonumber(allZone[found].longestDistance) then
			local n = windPnPoly(allZone[found].coords, plyCoords)
			if n ~= 0 then
				if allZone[found].instructions then--
					cb(allZone[found].instructions)
				end
			else
				cb(false)
			end
		else
			cb(false)
		end
	end
end)

AddEventHandler("izone:isPlayerInZone", function(zone, cb)
	found = FindZone(zone)
	if not found then
		cb(nil)
	else
		local plyCoords = GetEntityCoords(GetPlayerPed(-1), true)
		local x1, y1, z1 = table.unpack(plyCoords)
		if GetDistanceBetweenCoords(x1, y1, z1, tonumber(allZone[found].gravityCenter.x), tonumber(allZone[found].gravityCenter.y), 1.01, false) < tonumber(allZone[found].longestDistance) then
			local n = windPnPoly(allZone[found].coords, plyCoords)
			if n ~= 0 then
				cb(true)
			else
				cb(false)
			end
		else
			cb(false)
		end
	end
end)


AddEventHandler("izone:isPointInZone", function(xr, yr, zone, cb)
	found = FindZone(zone)
	if not found then
		cb(nil)
	else
		local flag = { x = tonumber(xr), y = tonumber(yr)}
		if GetDistanceBetweenCoords(xr, yr, 1.01, tonumber(allZone[found].gravityCenter.x), tonumber(allZone[found].gravityCenter.y), 1.01, false) < tonumber(allZone[found].longestDistance) then
			local n = windPnPoly(allZone[found].coords, flag)
			if n ~= 0 then
				cb(true)
			else
				cb(false)
			end
		else
			cb(false)
		end
	end
end)

RegisterNetEvent("izone:tpToPointZone")
AddEventHandler("izone:tpToPointZone", function(zone, pointNumber)
	found = FindZone(zone)
	if not found then
		Citizen.Trace("Pas de zone avec ce nom")
	else
		if pointNumber <= #allZone[found].coords then
			local x = allZone[found].coords[pointNumber].x
			local y = allZone[found].coords[pointNumber].y
			local z = allZone[found].coords[pointNumber].z
			TeleportPlayerToCoords(x, y, z)
		else
			Citizen.Trace("Point out of range")
		end
	end

end)

RegisterNetEvent("izone:tpToZone")
AddEventHandler("izone:tpToZone", function(zone)
	found = FindZone(zone)
	if not found then
		Citizen.Trace("Pas de zone avec ce nom")
	else
		local x = allZone[found].coords[1].x
		local y = allZone[found].coords[1].y
		local z = allZone[found].coords[1].z
		TeleportPlayerToCoords(x, y, z)
	end
end)


AddEventHandler("izone:isPlayerInAnyZone", function(cb)
		local arrayReturn = {}
		local plyCoords = GetEntityCoords(GetPlayerPed(-1), true)
		local x1, y1, z1 = table.unpack(plyCoords)

		for i=1, #allZone do
			if GetDistanceBetweenCoords(x1, y1, z1, tonumber(allZone[i].gravityCenter.x), tonumber(allZone[i].gravityCenter.y), 1.01, false) < tonumber(allZone[i].longestDistance) then
				local n = windPnPoly(allZone[i].coords, plyCoords)
				if n ~= 0 then
					table.insert(arrayReturn, allZone[i].nom)
					
				end
			end
		end
		if #arrayReturn == 0 then
			cb(nil)
		else
			cb(arrayReturn)
		end

end)


AddEventHandler("izone:isPointInAnyZone", function(xr, yr, cb)
		local arrayReturn = {}
		local flag = { x = xr, y = yr}

		for i=1, #allZone do
			if GetDistanceBetweenCoords(xr, yr, 1.01, tonumber(allZone[i].gravityCenter.x), tonumber(allZone[i].gravityCenter.y), 1.01, false) < tonumber(allZone[i].longestDistance) then
				local n = windPnPoly(allZone[i].coords, flag)
				if n ~= 0 then
					table.insert(arrayReturn, allZone[i].nom)
					
				end
			end
		end
		if #arrayReturn == 0 then
			cb(nil)
		else
			cb(arrayReturn)
		end
end)

function windPnPoly(tablePoints, flag)
	if tostring(type(flag)) == table then
		py = flag.y
		px = flag.x
	else
		px, py, pz = table.unpack(GetEntityCoords(GetPlayerPed(-1), true))
	end
	wn = 0
	table.insert(tablePoints, tablePoints[1])
	for i=1, #tablePoints do
		if i == #tablePoints then
			break
		end
		if tonumber(tablePoints[i].y) <= py then
			if tonumber(tablePoints[i+1].y) > py then
				if IsLeft(tablePoints[i], tablePoints[i+1], flag) > 0 then
					wn = wn + 1
				end
			end
		else
			if tonumber(tablePoints[i+1].y) <= py then
				if IsLeft(tablePoints[i], tablePoints[i+1], flag) < 0 then
					wn = wn - 1 
				end
			end
		end
	end
	return wn
end
function IsLeft(p1s, p2s, flag)
	p1 = p1s
	p2 = p2s
	if tostring(type(flag)) == "table" then
		p = flag
	else
		p = GetEntityCoords(GetPlayerPed(-1), true)
	end
	return ( ((p1.x - p.x) * (p2.y - p.y))
            - ((p2.x -  p.x) * (p1.y - p.y)) )
end

function FindZone(zone)
	for i = 1, #allZone do
		if allZone[i].nom == zone then
			return i
		end
	end
	return false
end

function TeleportPlayerToCoords(x, y, z)
	local myPly = GetPlayerPed(-1)
	SetEntityCoords(myPly, tonumber(x), tonumber(y), tonumber(z), 1, 0, 0, 1)
end

RegisterNetEvent("izone:tptc")
AddEventHandler("izone:tptc", function(x, y, z)
	TeleportPlayerToCoords(x,y,z)
end)

--RegisterNetEvent("izone:senddebug")
--AddEventHandler("izone:senddebug", function(allZones)
--	allZone = allZones
--	Citizen.Trace(allZone[1].coords[1].x)
--end)