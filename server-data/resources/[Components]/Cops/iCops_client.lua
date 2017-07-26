local userRank = nil 
local userJob = nil
local isInService = false
local isDragged = false
local isDragging = false
local isHandCuffed = false
local buttonList = { 
	title = "interraction policière",
	buttons = {
		{name = "Carte d'identité", targetFunction = , targetArrayParam = {} },
		{name = "Fouiller", targetFunction = , targetArrayParam = {} },
		{name = "(Dé)Menotter", targetFunction = , targetArrayParam = {} },
		{name = "Confisquer les armes", targetFunction = , targetArrayParam = {} },
		{name = "Mettre dans le véhicule", targetFunction = , targetArrayParam = {} },
		{name = "Faire sortir du véhicule", targetFunction = , targetArrayParam = {} },
		{name = "Escorter le joueur", targetFunction = , targetArrayParam = {} },
		{name = "Amendes", targetFunction = , targetArrayParam = {} },
		{name = "Plaque d'immatriculation", targetFunction = , targetArrayParam = {} },
		{name = "Crocheter le véhicule", targetFunction = , targetArrayParam = {} },
		{name = "Annimations", targetFunction = , targetArrayParam = {} },
		{name = "Animations", targetFunction = , targetArrayParam = {} },
		{name = "Citoyens", targetFunction = , targetArrayParam = {} },
		{name = "Véhicules", targetFunction = , targetArrayParam = {} },
		{name = "Fermer le menu", targetFunction = , targetArrayParam = {} },
		{name = "Faire la circulation", targetFunction = , targetArrayParam = {} },
		{name = "Prendre des notes", targetFunction = , targetArrayParam = {} },
		{name = "Repos", targetFunction = , targetArrayParam = {} },
		{name = "Repos 2", targetFunction = , targetArrayParam = {} },
		{name = "Annuler emote", targetFunction = , targetArrayParam = {} },
		{name = "Autre montant", targetFunction = , targetArrayParam = {} },
		{name = "Mettre en prison", targetFunction = , targetArrayParam = {} }
	}
}

RegisterNetEvent("ijob:updateJob")
AddEventHandler("ijob:updateJob", function(jobName, rank)
	userJob = jobName
	userRank = rank
	if userJob == "LSPD" or userJob == "LSSD" then
		RunCopThread()
	end
end)

function RunCopThread()
	Citizen.CreateTread(function() -- Thread Cop
		Menu.renderGUI()
		while true do
			Wait(0)
			if IsControlJustPressed(1, 288) then
				Menu.hidden = not(Menu.hidden)
				if not(Menu.hidden) then
					LaunchMenu(copButtonArray)
				end
			end
		end
	end)
end

Citizen.CreateThread(function() -- Thread Civil
	while true do
		Wait(0)

	end
end)

function LaunchMenu(buttonList)
	ClearMenu()
	MenuTitle = buttonList.title
	for i = 1, #buttonList do
		Menu.addButton(buttonList[i].name, buttonList[i].targetFunction, buttonList[i].targetArrayParam)
	end
	Menu.hidden = false
end

function DisplayHelpText(str)
	SetTextComponentFormat("STRING")
	AddTextComponentString(str)
	DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end
