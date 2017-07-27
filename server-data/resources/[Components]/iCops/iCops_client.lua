local userRank = nil 
local userJob = nil
local isInService = false
local isDragged = false
local isDragging = false
local isHandCuffed = false
local currentMenu = nil
local active = false
local subButtonList = { 
	["annimations"] = {
		title = "Annimations",
		name = "annimations",
		buttons = {
			{name = "Faire la circulation", targetFunction = "PlayEmote", targetArrayParam = "circulation" },
			{name = "Prendre des notes", targetFunction = "PlayEmote", targetArrayParam = "note" },
			{name = "Repos", targetFunction = "PlayEmote", targetArrayParam = "repos" },
			{name = "Repos 2", targetFunction = "PlayEmote", targetArrayParam = "repos2" },
			{name = "Annuler emote", targetFunction = "PlayEmote", targetArrayParam = "stop" }
		}
	},
	["citoyens"] = {
		title = "Citoyens",
		name = "citoyens",
		buttons = {
			{name = "Carte d'identité", targetFunction = "ShowId", targetArrayParam = {} },
			{name = "Fouiller", targetFunction = "Search", targetArrayParam = {} },
			{name = "(Dé)Menotter", targetFunction = "Cuff", targetArrayParam = {} },
			{name = "Confisquer les armes", targetFunction = "TakeWeapon", targetArrayParam = {} },
			{name = "Mettre dans le véhicule", targetFunction = "PutIntoVeh", targetArrayParam = {} },
			{name = "Faire sortir du véhicule", targetFunction = "UnputFromVeh", targetArrayParam = {} },
			{name = "Escorter le joueur", targetFunction = "EscortPlayer", targetArrayParam = {} },
			{name = "Amendes", targetFunction = "Fines", targetArrayParam = {} },
			{name = "Mettre en prison", targetFunction = "Jail", targetArrayParam = {} }
		}
	},
	["vehicle"] = {
		title = "Véhicules",
		name = "vehicle",
		buttons = {
			{name = "Crocheter le véhicule", targetFunction = "ForceVeh", targetArrayParam = {} }
		}
	}
}
local mainButtonList = { 
	["main"] = {
		title = "Actions",
		name = "main",
		buttons = {
			{name = "Annimations", targetFunction = "OpenMenu", targetArrayParam = subButtonList["annimations"] },
			{name = "Citoyens", targetFunction = "OpenMenu", targetArrayParam = subButtonList["citoyens"] },
			{name = "Véhicules", targetFunction = "OpenMenu", targetArrayParam = subButtonList["vehicle"] },
			{name = "Fermer le menu", targetFunction = "CloseMenu", targetArrayParam = {}}
		}
	},
}

AddEventHandler("is:updateJob", function(jobName, rank)
	userJob = jobName
	userRank = rank

	if (userJob == "LSPD" or userJob == "LSSD") and not(active) then
		active = true
		RunCopThread()
	else
		active = false
	end
end)

function RunCopThread()
	Citizen.CreateThread(function() -- Thread Cop
		while true do
			Wait(15)
			if not(active) then
				return
			end
			if IsControlJustPressed(1, 288) and isInService then -- partie menu
				if IsPedInAnyVehicle(GetPlayerPed(-1), false) then -- alors UI check
					local actualVeh = GetVehiclePedIsIn(GetPlayerPed(-1), false)
					local a,b = string.find(GetVehicleNumberPlateText(actualVeh), "PO")
					if a then
						-- On peut ouvrir le menu HTML
					end
				else -- Sinon menu action
					Menu.hidden = not(Menu.hidden)
					if not(Menu.hidden) then
						OpenMenu(mainButtonList["main"])
					end
				end
			elseif IsControlJustPressed(1, 177) and currentMenu ~= nil then
				if currentMenu == "main" then
					CloseMenu()
				else
					OpenMenu(mainButtonList["main"])
				end
			end
			TriggerEvent("izone:getResultFromPlayerInAnyJobZone", userJob, function(result)
				if result ~= nil then
					if result.service then
						if isInService then
							DisplayHelpText("Appuyez sur ~INPUT_CONTEXT~ pour " ..result.displayedMessageInZone.leave)
						else
							DisplayHelpText("Appuyez sur ~INPUT_CONTEXT~ pour " ..result.displayedMessageInZone.take)
						end
						if IsControlJustPressed(1, 38) then
							TriggerEvent("police:swichService", isInService, result)
							print(isInService)
						end
					end
				end
			end)
		end
	end)
end

Citizen.CreateThread(function()
	while true do
		Wait(0)
		if not(Menu.hidden) then
			Menu.renderGUI()
		end
		if not(Menu.hidden) and not(isInService) then
			CloseMenu("OSEF")
		end
	end
end)

AddEventHandler("police:swichService", function(service, result)
	if service then
		TriggerServerEvent("skin:retrieveOnExitMenu")
		isInService = false
	else
		TriggerServerEvent("print:serverArray", result.uniform)
		SetPedComponentVariation(GetPlayerPed(-1), 8,  result.uniform[userJob][userRank].tshirt_1, result.uniform[userJob][userRank].tshirt_2, 2)   -- Tshirt
		SetPedComponentVariation(GetPlayerPed(-1), 11, result.uniform[userJob][userRank].torso_1, result.uniform[userJob][userRank].torso_2, 2)     -- torso parts
		SetPedComponentVariation(GetPlayerPed(-1), 10, result.uniform[userJob][userRank].decals_1, result.uniform[userJob][userRank].decals_2, 2)   -- decals
		SetPedComponentVariation(GetPlayerPed(-1), 4, result.uniform[userJob][userRank].pants_1, result.uniform[userJob][userRank].pants_2, 2)      -- pants
		SetPedComponentVariation(GetPlayerPed(-1), 6, result.uniform[userJob][userRank].shoes, result.uniform[userJob][userRank].shoes_2, 2)  	  -- Shoes
		SetPedPropIndex(GetPlayerPed(-1), 1, result.uniform[userJob][userRank].glasses_1, 0, 2)
		isInService = true
	end
	print(isInService)
end)

Citizen.CreateThread(function() -- Thread Civil
	while true do
		Wait(0)

	end
end)

function DisplayHelpText(str)
	SetTextComponentFormat("STRING")
	AddTextComponentString(str)
	DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end

function OpenMenu(menu)
	ClearMenu()
	MenuTitle = menu.title
	print(MenuTitle)
	for i = 1, #menu.buttons do
		print("test" .. i)
		Menu.addButton(menu.buttons[i].name, menu.buttons[i].targetFunction, menu.buttons[i].targetArrayParam)
	end
	Menu.hidden = false
	currentMenu = menu.name
end

function CloseMenu(fake)
	ClearMenu()
	Menu.hidden = true
	currentMenu = nil
end

function PlayEmote()

end

function ShowId()

end

function Search()

end

function Cuff()

end

function TakeWeapon()

end

function PutIntoVeh()

end

function UnputFromVeh()

end

function EscortPlayer()

end

function Fines()

end

function Jail()

end

function ForceVeh()

end
