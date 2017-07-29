local enableDepositWithdrawTransferCommand = false -- Enable or disable commands /deposit, /withdraw and /transfer
local commandAway = true -- Set to false if you moved your commands to another file

RegisterServerEvent('bank:deposit')
AddEventHandler('bank:deposit', function(amount)
  local source = source
  TriggerEvent('es:getPlayerFromId', source, function(user)
      local rounded = round(tonumber(amount), 0)
      if(string.len(rounded) >= 9) then
        user.notify("La banque refuse la transaction. Le montant est trop élevé.", "error", "topCenter", true, 5000)
        CancelEvent()
      else
      	if(tonumber(rounded) <= tonumber(user.get("money"))) then
          user.removeMoney(rounded)
          user.addBank(rounded)
          local balance = user.get('bank')
          user.notify("Tu as déposé " .. rounded .. " à la banque, nouveau solde: " .. balance, "success", "topCenter", true, 5000)
          TriggerClientEvent("banking:updateBalance", source, balance)
          CancelEvent()
        else
          user.notify("Tu n'as pas " .. rounded .. " sur toi.", "error", "topCenter", true, 5000)
          CancelEvent()
        end
      end
  end)
end)

-- RegisterServerEvent('bank:withdrawAmende')
-- AddEventHandler('bank:withdrawAmende', function(amount)
--   local source = source
--     TriggerEvent('es:getPlayerFromId', source, function(user)
--     user.removeBank(amount)
--     local balance = user.getBank()
-- 		TriggerClientEvent("es_freeroam:notify", source, "CHAR_BANK_MAZE", 1, "Maze Bank", false, "Nouveau solde: ~g~$" .. balance)
-- 		TriggerClientEvent("banking:removeBalance", source, amount)
--     TriggerClientEvent("banking:updateBalance", source, balance)
-- 		CancelEvent()
--     end)
-- end)

RegisterServerEvent('bank:withdraw')
AddEventHandler('bank:withdraw', function(amount)
  local source = source
  TriggerEvent('es:getPlayerFromId', source, function(user)
      local rounded = round(tonumber(amount), 0)
      if(string.len(rounded) >= 9) then
        user.notify("La banque refuse la transaction. Le montant est trop élevé.", "error", "topCenter", true, 5000)
        CancelEvent()
      else
        local balance = user.get('bank')
        if(tonumber(rounded) <= tonumber(balance)) then
          user.removeBank(rounded)
          user.addMoney(rounded)
          balance = user.get('bank')
          user.notify("Tu as retiré " .. rounded .. " à la banque, nouveau solde: " .. balance, "success", "topCenter", true, 5000)
          TriggerClientEvent("banking:updateBalance", source, balance)
          CancelEvent()
        else
          user.notify("Tu n'as pas " .. rounded .. " sur ton compte.", "error", "topCenter", true, 5000)
          CancelEvent()
        end
      end
  end)
end)

RegisterServerEvent('bank:transfer')
AddEventHandler('bank:transfer', function(fromPlayer, toPlayer, amount)
    local source = source
    fromPlayer = source
  if tonumber(fromPlayer) == tonumber(toPlayer) then
    user.notify("Tu ne peux pas donner de l'argent à toi meme.", "error", "topCenter", true, 5000)
    CancelEvent()
  else
    TriggerEvent('es:getPlayerFromId', fromPlayer, function(user)
        local rounded = round(tonumber(amount), 0)
        if(string.len(rounded) >= 9) then
          user.notify("La banque refuse la transaction. Le montant est trop élevé.", "error", "topCenter", true, 5000)
          CancelEvent()
        else
          local bankbalance = user.get('bank')
          if(tonumber(rounded) <= tonumber(bankbalance)) then
            TriggerEvent('es:getPlayerFromId', toPlayer, function(user2)
              if user2 ~= nil then
                user.removeBank(rounded)
                local new_balance = user.get('bank')
                user.notify("Tu viens de transférer: " .. rounded .. "$ à " .. user2.get('displayName') .. ". Nouveau solde: " .. new_balance , "success", "topCenter", true, 5000)
                TriggerClientEvent("banking:updateBalance", source, new_balance)
                user2.addBank(rounded)
                new_balance2 = user2.get('bank')
                user2.notify("Tu viens de recevoir " .. rounded .. "$ de ".. user.get('displayName') .. ". Nouveau solde: " .. new_balance2 .. "$.", "success", "topCenter", true, 5000)
                TriggerClientEvent("banking:updateBalance", toPlayer, new_balance2)
                CancelEvent()
              else
                user.notify("Il n'y a pas de citoyen portant ce nom.", "error", "topCenter", true, 5000)
              end
            end)
            CancelEvent()
          else
            user.notify("Tu n'as pas: ".. rounded .. "$ sur ton compte.", "error", "topCenter", true, 5000)
            CancelEvent()
          end
        end
    end)
  end
end)

AddEventHandler("resart:dBank", function()
  SetTimeout(1500, function()
    TriggerEvent("es:getPlayers", function(Users)
      for k,v in pairs(Users) do
        if v ~= nil then
          print(v.get("bank"))
          TriggerClientEvent("banking:updateBalance", v.get('source'), 15508.5)
        end
      end
    end)
  end)
end)

-- RegisterServerEvent('bank:givecash')
-- AddEventHandler('bank:givecash', function(toPlayer, amount)
--   local source = source
-- 	TriggerEvent('es:getPlayerFromId', source, function(user)
-- 		if (tonumber(user.getMoney()) >= tonumber(amount)) then
-- 			local player = user.identifier
-- 			user.removeMoney(amount)
-- 			TriggerEvent('es:getPlayerFromId', toPlayer, function(recipient)
-- 				recipient.addMoney(amount)
-- 				TriggerClientEvent("es_freeroam:notify", source, "CHAR_BANK_MAZE", 1, "Maze Bank", false, "Argent donne: ~r~-$".. amount .." ~n~~s~Porte-feuille: ~g~$" .. user.getMoney())
-- 				TriggerClientEvent("es_freeroam:notify", toPlayer, "CHAR_BANK_MAZE", 1, "Maze Bank", false, "Argent recu: ~g~$".. amount .." ~n~~s~Porte-feuille: ~g~$" .. recipient.getMoney())
-- 			end)
-- 		else
-- 			if (tonumber(user.money) < tonumber(amount)) then
--         TriggerClientEvent('chatMessage', source, "", {0, 0, 200}, "^1Pas assez d'argent^0")
--         CancelEvent()
-- 			end
-- 		end
-- 	end)
-- end)

-- RegisterServerEvent('bank:givedirty')
-- AddEventHandler('bank:givedirty', function(toPlayer, amount)
--   local source = source
-- 	TriggerEvent('es:getPlayerFromId', source, function(user)
-- 		if (tonumber(user.getDirtyMoney()) >= tonumber(amount)) then
-- 			user.removeDirtyMoney(amount)
-- 			TriggerEvent('es:getPlayerFromId', toPlayer, function(recipient)
-- 				recipient.addDirtyMoney(amount)
--         local new_balance = user.getDirtyMoney()
--         local new_balance2 = recipient.getDirtyMoney()
-- 				TriggerClientEvent("es_freeroam:notify", source, "CHAR_BANK_MAZE", 1, "Maze Bank", false, "Tu as donné ~r~".. amount .."€~n~ d'argent sale.~n~~s~ Porte-feuille: ~g~$" .. new_balance)
-- 				TriggerClientEvent("es_freeroam:notify", toPlayer, "CHAR_BANK_MAZE", 1, "Maze Bank", false, "Tu as reçu ~g~".. amount .."€~n~ d'argent sale.~n~~s~ Porte-feuille: ~g~$" .. new_balance2)
-- 			end)
-- 		else
-- 			if (tonumber(user.getDirtyMoney()) < tonumber(amount)) then
--         TriggerClientEvent('chatMessage', source, "", {0, 0, 200}, "^1Tu n'as pas assez d'argent^0")
--         CancelEvent()
-- 			end
-- 		end
-- 	end)
-- end)

AddEventHandler('es:playerLoaded', function(source)
  local source = source
  TriggerEvent('es:getPlayerFromId', source, function(user)
    local balance = user.get('bank')
      TriggerClientEvent("banking:updateBalance", source, balance)
    end)
end)

function round(num, numDecimalPlaces)
  local mult = 10^(numDecimalPlaces or 0)
  return math.abs(math.floor(num * mult + 0.5) / mult)
end


-- Citizen.CreateThread(function()
--   if enableDepositWithdrawTransferCommand then

--     -- Bank Deposit
--     TriggerEvent('es:addCommand', 'deposit', function(source, args, user)
--       local amount = ""
--       for i=1,#args do
--         amount = args[i]
--       end
--       TriggerClientEvent('bank:deposit', source, amount)
--     end)

--     -- Bank Withdraw
--     TriggerEvent('es:addCommand', 'withdraw', function(source, args, user)
--       local amount = ""
--       for i=1,#args do
--         amount = args[i]
--       end
--       TriggerClientEvent('bank:withdraw', source, amount)
--     end)

--     -- Bank Transfer
--     TriggerEvent('es:addCommand', 'transfer', function(source, args, user)
--       local fromPlayer
--       local toPlayer
--       local amount
--       if (args[1] and args[2] and args[3]) then
--         if (args[2] ~= nil and tonumber(args[3]) > 0) then
--           fromPlayer = tonumber(source)
--           toPlayer = tonumber(args[2])
--           amount = tonumber(args[3])
--           TriggerClientEvent('bank:transfer', source, fromPlayer, toPlayer, amount)
--           else
--           TriggerClientEvent('chatMessage', source, "", {0, 0, 200}, "^1(Erreur) /transfer [id] [amount]")
--           return false
--         end
--       else
--         TriggerClientEvent('chatMessage', source, "", {0, 0, 200}, "^1(Erreur) /transfer [id] [amount]")
--       end
--     end)
--   end

--   if not commandAway then

--     -- Check Bank Balance
--     TriggerEvent('es:addCommand', 'checkbalance', function(source, args, user)
--       TriggerEvent('es:getPlayerFromId', source, function(user)
--         local balance = user.getBank()
--         TriggerClientEvent("es_freeroam:notify", source, "CHAR_BANK_MAZE", 1, "Maze Bank", false, "Votre solde actuel est de: ~g~$".. balance)
--         TriggerClientEvent("banking:updateBalance", source, balance)
--         CancelEvent()
--       end)
--     end)

--     -- Give Cash
--     TriggerEvent('es:addCommand', 'givecash', function(source, args, user)
--       local fromPlayer
--       local toPlayer
--       local amount
--         if (args[1] and args[2] and args[3]) then
--           if (args[2] ~= nil and tonumber(args[3]) > 0) then
--             fromPlayer = tonumber(source)
--             toPlayer = tonumber(args[2])
--             amount = tonumber(args[3])
--             TriggerClientEvent('bank:givecash', source, toPlayer, amount)
--           else
--             TriggerClientEvent('chatMessage', source, "", {0, 0, 200}, "^1(Erreur) /givecash [id] [amount]")
--             return false
--           end
--        else
--         TriggerClientEvent('chatMessage', source, "", {0, 0, 200}, "^1(Erreur) /givecash [id] [amount]")
--        end
--     end)

--     -- Give Dirty
--     TriggerEvent('es:addCommand', 'givedirty', function(source, args, user)
--       local fromPlayer
--       local toPlayer
--       local amount
--       if (args[1] and args[2] and args[3]) then
--         if (args[2] ~= nil and tonumber(args[3]) > 0) then
--           fromPlayer = tonumber(source)
--           toPlayer = tonumber(args[2])
--           amount = tonumber(args[3])
--           TriggerClientEvent('bank:givedirty', source, toPlayer, amount)
--         else
--           TriggerClientEvent('chatMessage', source, "", {0, 0, 200}, "^1(Erreur) /givedirty [id] [amount]")
--           return false
--         end
--       else
--         TriggerClientEvent('chatMessage', source, "", {0, 0, 200}, "^1(Erreur) /givecash [id] [amount]")
--       end
--     end)
--   end
-- end)
