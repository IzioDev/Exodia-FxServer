-- Copyright (C) Izio, Inc - All Rights Reserved
-- Unauthorized copying of this file, via any medium is strictly prohibited
-- Proprietary and confidential
-- Written by Romain Billot <romainbillot3009@gmail.com>, September 2017

Citizen.CreateThread(function()
	while true do
		Wait(0)
		TriggerEvent("izone:getResultFromPlayerInAnyMagasinZone", function(isInZone)
			if isInZone and not(IsPedInAnyVehicle(GetPlayerPed(-1), false)) then
				Menu.renderGUI()
				if Menu.hidden then 
					DisplayHelpText("Appuyez sur ~INPUT_CONTEXT~ pour regarder les objets à la vente")
				end
				if IsControlJustPressed(1, 38) then
					Menu.hidden = not Menu.hidden
					ClearMenu()
					GetResultItemInfos(isInZone.items)
				end
			end
		end)
	end
end)

function GetResultItemInfos(itemIdArray)
	TriggerServerEvent("ijob:getItemInfosFromIdArray", itemIdArray, "iMagasin:getItemInfosFromIdArray")
end

RegisterNetEvent("iMagasin:getItemInfosFromIdArray")
AddEventHandler("iMagasin:getItemInfosFromIdArray", function(result)
	--print(json.encode(result)) -- ok 
	LaunchMenu(result)
end)
function LaunchMenu(Items)
	ClearMenu()
	MenuTitle = "Superette"
	for i = 1, #Items do
		Menu.addButton(Items[i].name .. " : " .. Items[i].price.."$", "ItemsInfos", {Items,i})
	end
end

function ItemsInfos(Result)
	local choice = Result[2]
	print(choice)
	local Items = Result[1]
	ClearMenu()
	print(Items[choice])
	MenuTitle = Items[choice].name .. " pese " .. Items[choice].weight .. "g"
	Menu.addButton("Acheter pour "..Items[choice].price.."$", "BuyItem", Items[choice])
	Menu.addButton("Retour", "LaunchMenu", Items)
end

function BuyItem(item)
	prompt(function(amount)
		if amount ~= nil and tonumber(amount) > 0 then
			TriggerServerEvent('inv:buyItemByItemId', item.id, tonumber(amount))
		end
	end)
	Menu.hidden = not(Menu.hidden)
end
function DisplayHelpText(str)
	SetTextComponentFormat("STRING")
	AddTextComponentString(str)
	DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end
function prompt(callback)
	Citizen.CreateThread(function()
    	DisplayOnscreenKeyboard(true, "FMMC_KEY_TIP8", "", "", "", "", "", 120)
    	while (UpdateOnscreenKeyboard() == 0) do
    		Wait(0)
    	  DisableAllControlActions(0)
    	end
    	if (GetOnscreenKeyboardResult()) then
    	  quantity =  math.abs(tonumber(GetOnscreenKeyboardResult()))
    	  callback(quantity)
    	end
    end)
end