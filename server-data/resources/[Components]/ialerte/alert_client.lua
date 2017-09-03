RegisterNetEvent("alert:fromServer")
AddEventHandler("alert:fromServer", function(params) -- params = {title = "", desc = "", params = {"","",25}}
	SendNuiMessage({
		action = "open",
		title = params.title,
		desc = params.desc,
		params = params.params
	})
end)