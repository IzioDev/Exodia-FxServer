RegisterServerEvent("print:serverArray")
AddEventHandler("print:serverArray", function(toPrint)
	print(json.encode(toPrint))
end)
