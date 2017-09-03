--Register les évents:
RegisterServerEvent("iService:callCops")
RegisterServerEvent("iService:callMedic")
RegisterServerEvent("iService:callTaxi")
RegisterServerEvent("iService:callMecano")
RegisterServerEvent("iServie:acceptedCall")
RegisterServerEvent("iServie:refusedCall")

--Définition des locales:
local callService = {
    ["police"] = {},
    ["médecin"] = {},
    ["mécano"] = {},
    ["taxi"] = {}
}

local config = {
    ["events"] = {
        ["sended"] = "iService:sendTo",
        ["cancel"] = "iService:cancel",
        ["accepted"] = "iService:accepted",
        ["taken"] = "iService:taken",
        ["refused"] = "iService:refused",
        ["timeout"] = "iService:timeOut",
        ["noConnected"] = "iService:noConnected"
    },
}

-- Events:
AddEventHandler("iService:callCops", function(callType)
    local source = source
    local nowTime = os.time()
    if callType == "cancel" then
        SearchForCallToBeCanceled(source)
    else
        if not(IsCallInWaitingFromSource(source)) then
            if callType == "Vole" then
                table.insert(callService["police"], {toJob = {"LSSD", "LSPD"}, callType = "Vole", fromSource = source, fromTime = nowTime})
            elseif callType == "Aggression" then
                table.insert(callService["police"], {toJob = {"LSSD", "LSPD"}, callType = "Aggression", fromSource = source, fromTime = nowTime})
            else
                table.insert(callService["police"], {toJob = {"LSSD", "LSPD"}, callType = callType, fromSource = source, fromTime = nowTime})
            end
        else
            Notify("Tu as déjà un appel en cours.", "error", source)
        end
    end
end)

AddEventHandler("iService:callMedic", function(callType)
    local source = source
    local nowTime = os.time()
    if callType == "cancel" then
        SearchForCallToBeCanceled(source)
    else
        if not(IsCallInWaitingFromSource(source)) then
            if calType == "Aggression" then
                table.insert(callService["médecin"], {toJob = {"médecin"}, callType = "Aggression", fromSource = source, fromTime = nowTime})
            elseif callType == "Vole" then
                table.insert(callService["médecin"], {toJob = {"médecin"}, callType = "Vole", fromSource = source, fromTime = nowTime})
            end
        else
            -- notify already a call in waiting
        end
    end
end)

AddEventHandler("iService:callTaxi", function(callType)
    local source = source
    local nowTime = os.time()
    if callType == "cancel" then
        SearchForCallToBeCanceled(source)
    else
        if not(IsCallInWaitingFromSource(source)) then 
            if callType == "1 personnes" then
                table.insert(callService.taxi, {toJob = {"taxi"}, callType = "1 personnes", fromSource = source, fromTime = nowTime})
            elseif callType == "2 personnes" then
                table.insert(callService.taxi, {toJob = {"taxi"}, callType = "2 personnes", fromSource = source, fromTime = nowTime})
            elseif callType == "3 personnes" then
                table.insert(callService.taxi, {toJob = {"taxi"}, callType = "3 personnes", fromSource = source, fromTime = nowTime})
            end
        else
            -- notify already a call in waiting
        end
    end
end)

AddEventHandler("iService:callMecano", function(callType)
    local source = source
    local nowTime = os.time()
    if callType == "cancel" then
        SearchForCallToBeCanceled(source)
    else
        if not(IsCallInWaitingFromSource(source)) then
            if callType == "Voiture" then
                table.insert(callService['mécano'], {toJob = {"mécanicien"}, callType = "Voiture", fromSource = source, fromTime = nowTime})
            elseif callType == "Camion" then
                table.insert(callService['mécano'], {toJob = {"mécanicien"}, callType = "Camion", fromSource = source, fromTime = nowTime})
            elseif callType == "Camionnette" then
                table.insert(callService['mécano'], {toJob = {"mécanicien"}, callType = "Camionnette", fromSource = source, fromTime = nowTime})
            elseif callType == "Moto" then
                table.insert(callService['mécano'], {toJob = {"mécanicien"}, callType = "Moto", fromSource = source, fromTime = nowTime})
            end
        else
            -- notify already a call in waiting
        end
    end
end)

AddEventHandler("iServie:refusedCall", function(thisCall)
    local source = source
    if IsCallInWaitingFromSource(source) then
        local v,j = GetTheCall(source)
        for n = 1, #v[j].sendedTo do
            if v[j].sendedTo[n].get('source') == source then
                TriggerClientEvent(config["events"]["refused"] .. v[j].sendedTo[n].get('job'), v[j].sendedTo[n].get('source'))
                Notify("Tu viens de refuser l'appel.", "success", v[j].sendedTo[n].get('source'))
                table.remove(v[j].sendedTo, n)
                -- notify the refuser he refuse the call
            end
        end
    else
        print("error server.lua iService refused call")
    end
end)

AddEventHandler("iServie:acceptedCall", function(thisCall)
    local source = source
    if IsCallInWaitingFromSource(thisCall.fromSource) then
        local v,j = GetTheCall(thisCall.fromSource)
        TriggerEvent("es:getPlayerFromId", source, function(user)
            for n = 1, #v[j].sendedTo do
                if not(v[j].sendedTo[n].get('source') == source) then
                    Notify("L'appel à été pris par " .. user.get('displayName') .. ".", "error", v[j].sendedTo[n].get('source'))
                    local eventName = config["events"]["taken"] .. v[j].sendedTo[n].get('job')
                    TriggerClientEvent(eventName, v[j].sendedTo[n].get('source'), thisCall.fromSource)
                end
            end
            TriggerEvent("es:getPlayers", function(Users)
                TriggerClientEvent(config["events"]["accepted"]..Users[source].get('job'), source, Users[thisCall.fromSource].get('coords'))
                Notify("Tu viens de prendre l'appel, rends toi vite sur les lieux.", "success", user.get('source'))
                Notify("Quelqu'un à prit ton appel, il est en route!", "success", v[j].fromSource)
            end)
            table.remove(v, j)
        end)
    else
        print("error server.lua iService accepted call")
    end
end)

--Tritement des appels de service:
Citizen.CreateThread(function()
    while true do
        Wait(2000)
        for k,v in pairs(callService) do
            for j = 1, #v do
                local thisCall = v[j]
                if not(thisCall.isWaiting) then
                    thisCall.sendedTo = {}
                    print(json.encode(thisCall))
                    for n = 1, #thisCall.toJob do
                        TriggerEvent('es:getPlayers', function(User)
                            local Users = User
                            if Users ~= nil then
                                local toBeReturned = {}
                                for k,v in pairs(Users) do
                                    if v ~= nil then
                                        if v.get('job') == thisCall.toJob[n] and thisCall.fromSource ~= v.get('source') then
                                            table.insert(toBeReturned, v)
                                        end
                                    end
                                end
                                if #toBeReturned ~= 0 then
                                    thisCall.sendedTo = toBeReturned -- To change
                                end
                                local eventName = config["events"]["sended"] .. thisCall.toJob[n]
                                print(eventName)
                                for k = 1, #thisCall.sendedTo do
                                    if thisCall.sendedTo[k].getSessionVar('isInService') then
                                        Notify("Tu as un appel de service, raison : </br> <center> <strong> ".. thisCall.callType .. "</strong> </center> </br>Appuie sur <strong>[F5]</strong> pour accepter et sur <strong>[F6]</strong> pour refuser.", "success", thisCall.sendedTo[k].get('source'))
                                        TriggerClientEvent(eventName, thisCall.sendedTo[k].get('source'), thisCall.callType ,thisCall.fromSource)
                                        print("sended to User" .. thisCall.sendedTo[k].get('displayName'))
                                    else
                                        table.remove(thisCall.sendedTo, k)
                                    end
                                end
                            end
                        end)
                    end
                    if #thisCall.sendedTo == 0 then -- si il n'y a pas de joueur avec le job de connecté
                        table.remove(v, j) -- on supprime l'appel
                        Notify("Il n'y a personne au bout du fil. </br>Appel échoué.","error", thisCall.fromSource)
                    else
                        thisCall.isWaiting = true -- on passe l'appel en attente
                        Notify("Appel en cours. </br>Patiente.","success", thisCall.fromSource)
                    end
                else
                    -- pour le timeout:
                    if thisCall.fromTime < os.time() - 15 then -- si l'appel est timeout
                        local theseReceiver = v[j].sendedTo --
                        for n = 1, #theseReceiver do -- on parcours tous les utilisateurs qui ont été notifié par l'appel
                            for k = 1, #theseReceiver[n] do
                                TriggerClientEvent(config["events"]["timeout"]..theseReceiver[n][k].get('job'), theseReceiver[n][k].get('source'), thisCall.fromSource)
                            end
                        end --
                        Notify("Appel sans suite.","error", thisCall.fromSource)
                        table.remove(v, j) -- on supprime l'appel
                    else
                        if #thisCall.sendedTo == 0 then
                            Notify("Appel refusé.","error", thisCall.fromSource)
                            table.remove(v, j)
                        end
                    end
                end
            end
        end
    end
end)

--Fonctions:
function SearchForCallToBeCanceled(source)
    local founded = nil
    for k,v in pairs(callService) do
        for j = 1, #v do
            local thisCall = v[j]
            if thisCall.fromSource == source then
                -- We found the call
                for k = 1, #thisCall.sendedTo do
                    local eventName = config["events"]["canceled"]..thisCall.sendedTo[k].get('job')
                    TriggerClientEvent(eventName, thisCall.sendedTo[k].get('source'), thisCall.fromSource)
                    Notify("Le correspondant à raccroché.", "success", thisCall.sendedTo[k].get('source'))
                    founded = j
                end
            end
        end
        if founded then
            table.remove(v, founded)
            break
        end
    end
    if founded then
        Notify("Tu as raccroché.", "success", source)
    else
        Notify("Tu n'avais pas d'appel en cours.", "success", source)
    end
end

function IsCallInWaitingFromSource(source) -- Todo
    for k,v in pairs(callService) do
        for j = 1, #v do
            local thisCall = v[j]
            print(thisCall.fromSource)
            print(source)
            if thisCall.fromSource == source then
                return true
            end
        end
    end
    return false
end

function GetTheCall(source)
    for k,v in pairs(callService) do
        for j = 1, #v do
            local thisCall = v[j]
            if thisCall.fromSource == source then
                return v,j
            end
        end
    end
end

function Notify(message, type, source)
    TriggerEvent("es:getPlayerFromId", source, function(user)
        user.notify(message, type, "topCenter", true, 5000)
    end)
end

function GetUserFromSource(source)
    TriggerEvent("es:getPlayerFromId", source, function(user)
        return user
    end)
end
