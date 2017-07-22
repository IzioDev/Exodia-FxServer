local launched = false

AddEventHandler("playerSpawned", function()
    -- sexe = 0
    -- TriggerServerEvent("ask_sex")
    ClearPedTasksImmediately(player) -- Sans ça, les animations ne se lancent pas à moins de restart le script ou de clear les tasks du joueur ... Mais avec, par je ne sais quelle magie, c'est bon ;)
end)

-- Sex will be gotten only one time. And it will be the server which send it, not a asking from user.
-- For now, let's define it by a male as default one.
sexe = 1 -- Why define male as 0 ? Male > Female, never forget that !
RegisterNetEvent("get_sex")
AddEventHandler("get_sex", function(sex)
    sexe = sex
end)

RegisterNetEvent("anim:Play")
AddEventHandler("anim:Play", function(name) -- PlayScenario(char* Scenario_name, bool* enter, bool* playExit, *char dictionnary_name, *char animation_name, float* duration)

    player = GetPlayerPed(-1)
    local name = name
                                            -- Playing scenario with playExit (e.g) = PlayScenario("WORLD_HUMAN_PUSH_UPS", true, true, "amb@world_human_push_ups@male@exit", "exit", 0.285)
    if name then                            -- Playing scenario without playExit (e.g) = PlayScenario("WORLD_HUMAN_PUSH_UPS", true, false)

        if sexe == 0 then

            if name == "player:smokeCig" then PlayScenario("WORLD_HUMAN_SMOKING", true, 3, true, "amb@world_human_smoking@male@male_a@exit", "exit", 1) end

            if name == "atm:withdraw" then
                PlayEmote("random@atmrobberygen@male", "enter", 0, 1, 0, 0)
                PlayEmote("random@atmrobberygen@male", "idle_c", 9, 1, 0, 1, 6)
                PlayEmote("random@atmrobberygen@male", "exit", 0, 1, 0, 0)
            end

            if name == "player:drinkBeer" then -- ADD OBJECT IZIO
                PlayEmote("amb@world_human_drinking@beer@male@enter", "enter", 0, 1, 0, 0)
                PlayEmote("amb@world_human_drinking@beer@male@idle_a", "idle_a", 9, 1, 0, 1, 1.8)
                PlayEmote("amb@world_human_drinking@beer@male@exit", "exit", 0, 1, 0, 0)
            end

            if name == "mobile:call" then -- ADD OBJECT LE
                PlayEmote("amb@world_human_stand_mobile@male@standing@call@enter", "enter", 0, 1, 0, 0)
                PlayEmote("amb@world_human_stand_mobile@male@standing@call@base", "base", 9, 1, 0, 1, 1.8)
                PlayEmote("amb@world_human_stand_mobile@male@standing@call@exit", "exit", 0, 1, 0, 0)
            end

            if name == "mobile:text" then -- ADD OBJECT PETIT
                PlayEmote("amb@world_human_stand_mobile@male@text@enter", "enter", 0, 1, 0, 0)
                PlayEmote("amb@world_human_stand_mobile@male@text@base", "base", 9, 1, 0, 1)
                PlayEmote("amb@world_human_stand_mobile@male@text@exit", "exit", 0, 1, 0, 0)
            end

        elseif sexe == 1 then

            if name == "player:smokeCig" then PlayScenario("WORLD_HUMAN_SMOKING", true, 3, true, "amb@world_human_smoking@female@exit", "exit", 1) end
            if name == "prostitute:high" then PlayScenario("WORLD_HUMAN_PROSTITUTE_HIGH_CLASS", true, 4, false) end
            if name == "prostitute:low" then PlayScenario("WORLD_HUMAN_PROSTITUTE_LOW_CLASS", true, 3, false) end

            if name == "atm:withdraw" then
                PlayEmote("random@atmrobberygen@female", "enter", 0, 1, 0, 0)
                PlayEmote("random@atmrobberygen@female", "idle_c", 9, 1, 0, 1, 6)
                PlayEmote("random@atmrobberygen@female", "exit", 0, 1, 0, 0)
            end

            if name == "player:drinkBeer" then -- ADD OBJECT GRIZZLY
                PlayEmote("amb@world_human_drinking@beer@female@enter", "enter", 0, 1, 0, 0)
                PlayEmote("amb@world_human_drinking@beer@female@idle_a", "idle_a", 9, 1, 0, 1, 1.8)
                PlayEmote("amb@world_human_drinking@beer@female@exit", "exit", 0, 1, 0, 0)
            end

            if name == "mobile:call" then -- ADD OBJECT LONG
                PlayEmote("amb@world_human_stand_mobile@female@standing@call@enter", "enter", 0, 1, 0, 0)
                PlayEmote("amb@world_human_stand_mobile@female@standing@call@base", "base", 9, 1, 0, 1)
                PlayEmote("amb@world_human_stand_mobile@female@standing@call@exit", "exit", 0, 1, 0, 0)
            end

            if name == "mobile:text" then -- ADD OBJECT DUZBOUB
                PlayEmote("amb@world_human_stand_mobile@female@text@enter", "enter", 0, 1, 0, 0)
                PlayEmote("amb@world_human_stand_mobile@female@text@base", "base", 9, 1, 0, 1)
                PlayEmote("amb@world_human_stand_mobile@female@text@exit", "exit", 0, 1, 0, 0)
            end

            if name == "player:lap_dance" then
                PlayEmote("mini@strip_club@lap_dance@ld_girl_a_intro", "ld_girl_a_intro_f", 0, 1, 0, 0)
                PlayEmote("mini@strip_club@lap_dance@ld_girl_a_song_a_p1", "ld_girl_a_song_a_p1_f", 9, 1, 0, 1, 5.75)
                PlayEmote("mini@strip_club@lap_dance@ld_girl_a_exit", "ld_girl_a_exit_f", 0, 1, 0, 0)
            end

            if name == "player:lap_dance_2" then
                PlayEmote("mp_am_stripper", "lap_dance_girl", 0, 1, 0, 1)
                PlayEmote(0, 0, 0, 0, 1, 0)
            end

            if name == "player:lap_dance_3" then
                PlayEmote("mp_safehouse", "lap_dance_girl", 0, 1, 0, 1)
                PlayEmote(0, 0, 0, 0, 1, 0)
            end

        end


        -- ## Jobs ## ---------------------------------------------------------------------------------------------------------------
        if name == "cop:idle" then PlayScenario("WORLD_HUMAN_COP_IDLES", true, 0.4, false) end
        if name == "cop:clipboard" then PlayScenario("WORLD_HUMAN_CLIPBOARD", true, 0.2, false) end
        if name == "player:recoltePierre" then PlayScenario("WORLD_HUMAN_CONST_DRILL", true, 0.5, false) end
        if name == "sdf:freeway" then PlayScenario("WORLD_HUMAN_BUM_FREEWAY", true, 0.2, false) end
        if name == "player:phishing" then PlayScenario("WORLD_HUMAN_STAND_FISHING", true, 0.2, false) end
        if name == "mecha:souder" then PlayScenario("WORLD_HUMAN_WELDING", true, 0.2, false) end
        if name == "medic:kneel" then PlayScenario("CODE_HUMAN_MEDIC_KNEEL", true, 2.5, false) end
        if name == "medic:note" then PlayScenario("CODE_HUMAN_MEDIC_TIME_OF_DEATH", true, 6, false) end
        if name == "cop:park_attendant" then PlayScenario("WORLD_HUMAN_CAR_PARK_ATTENDANT", true, 0.4, false) end
        if name == "player:gardening" then PlayScenario("WORLD_HUMAN_GARDENER_PLANT", true, 5, false) end

        if name == "player:busted_by_cop" then PlayEmote("busted", "idle_a", 9, 1, 0, 1, 0.5) end
        -- ## Jobs End ## -----------------------------------------------------------------------------------------------------------

        -- ## DEFAULT ACTIONS ## ----------------------------------------------------------------------------------------------------
        if name == "player:drink" then end -- ADD OBJECT
        if name == "player:eat" then end -- ADD OBJECT

        if name == "player:come_here" then
            PlayEmote("gestures@m@standing@casual", "gesture_come_here_hard", 0, 1, 0, 0)
            PlayEmote(0, 0, 0, 0, 1, 0) -- Quitter l'animation (uniquement lorsqu'il n y a pas d'Exit)
        end

        if name == "player:pointing_sky" then
            PlayEmote("missmartin1@pointing_sky1@enter", "enter", 0, 1, 0, 0)
            PlayEmote("missmartin1@pointing_sky1@base", "base", 9, 1, 0, 1)
            PlayEmote("missmartin1@pointing_sky1@exit", "exit", 0, 1, 0, 0)
        end

        if name == "player:pickup_01" then
            PlayEmote("pickup_object", "pickup_low", 0, 1, 0, 0)
            PlayEmote(0, 0, 0, 0, 1, 0)
        end

        if name == "player:pickup_02" then
            PlayEmote("random@atmrobberygen", "pickup_low", 0, 1, 0, 0)
            PlayEmote(0, 0, 0, 0, 1, 0)
        end

        if name == "player:busted_by_himself" then
            PlayEmote("busted", "idle_2_hands_up", 0, 1, 0, 0)
            PlayEmote("busted", "idle_a", 9, 1, 0, 1)
            PlayEmote("busted", "hands_up_2_idle", 0, 1, 0, 0)
        end

        if name == "player:peeing" then
            PlayEmote("misscarsteal2peeing", "peeing_intro", 0, 1, 0, 0)
            PlayEmote("misscarsteal2peeing", "peeing_loop", 9, 1, 0, 1, 7)
            PlayEmote("misscarsteal2peeing", "peeing_outro", 0, 1, 0, 0)
        end

        if name == "mobile:photo" then -- ADD OBJECT
            PlayEmote("cellphone@", "cellphone_photo_ent", 0, 1, 0, 0)
            PlayEmote("cellphone@", "cellphone_photo_idle", 9, 1, 0, 1)
            PlayEmote("cellphone@", "cellphone_photo_exit", 0, 1, 0, 0)
        end

        if name == "mobile:selfie" then -- ADD OBJECT
            PlayEmote("cellphone@self", "selfie_in", 0, 1, 0, 0)
            PlayEmote("cellphone@self", "selfie", 9, 1, 0, 1)
            PlayEmote("cellphone@self", "selfie_out", 0, 1, 0, 0)
        end

        if name == "player:tyler_dance" then
            PlayEmote("rcmnigel1bnmt_1b", "dance_intro_tyler", 0, 1, 0, 0)
            PlayEmote("rcmnigel1bnmt_1b", "dance_loop_tyler", 9, 1, 0, 1, 0)
        end
        -- to stop all annim:
        if name == "stopAll" then PlayEmote("osef", "maisGenreVraiment", "EtTaMERE?", "KEKLEL" , 1, "KEKLEL", "KEKLEL") launched = false end

        if name == "player:press_button" then PlayEmote("missheistdocksprep1ig_1", "ig_1_button", 0, 1, 0, 0) end
        if name == "player:jog_standing" then PlayScenario("WORLD_HUMAN_JOG_STANDING", true, 0.4, false) end
        if name == "player:strip_watch_stand" then PlayScenario("WORLD_HUMAN_STRIP_WATCH_STAND", true, 0.4, false) end
        if name == "player:lookmap" then PlayScenario("WORLD_HUMAN_TOURIST_MAP", true, 0.2, false) end
        if name == "player:sunbathe_back" then PlayScenario("WORLD_HUMAN_SUNBATHE_BACK", true, 2, false) end
        if name == "player:sunbathe" then PlayScenario("WORLD_HUMAN_SUNBATHE", true, 2, false) end
        if name == "player:stupor" then PlayScenario("WORLD_HUMAN_STUPOR", false, 3, false) end
        if name == "player:musician" then PlayScenario("WORLD_HUMAN_MUSICIAN", true, 0.2, false) end
        if name == "player:yoga" then PlayScenario("WORLD_HUMAN_YOGA", true, 1, false) end
        if name == "player:sitting" then PlayScenario("WORLD_HUMAN_PICNIC", false, 1.9, false) end
        if name == "player:drinkCoffee" then PlayScenario("WORLD_HUMAN_DRINKING", true, 1, false) end
        if name == "player:pushUp" then PlayScenario("WORLD_HUMAN_PUSH_UPS", true, 1.7, false) end
        if name == "player:sitUp" then PlayScenario("WORLD_HUMAN_SIT_UPS", true, 5, false) end
        if name == "player:smokeWeed" then PlayScenario("WORLD_HUMAN_SMOKING_POT", true, 0.2, false) end
        if name == "player:binoculars" then PlayScenario("WORLD_HUMAN_BINOCULARS", true, 3, false) end
        if name == "player:cheering" then PlayScenario("WORLD_HUMAN_CHEERING", true, 0.5, false) end
    end
end)

--[[TriggerServerEvent("ask_sex") -- JUSTE LA POUR EVITER DE DECO/RECO APRES CHAQUE TEST POUR NE PAS PERDRE LA VARIABLE SEXE

Citizen.CreateThread(function()
    while true do
        Wait(0)
        if IsControlJustPressed(1, 303) then
            TriggerEvent("anim:Play", "player:dance")
            Citizen.Trace(player)
        end
        if IsControlJustPressed(1, 311) then
            ClearPedTasksImmediately(player)
        end
    end
end)]]

function PlayScenario(obj, enter, waitTimeUntilClear, playExit, dict, name, duration)
    if not IsPedUsingAnyScenario(player) then
        local waitingTime = (waitTimeUntilClear * 1000)
        local param = true
        TaskStartScenarioInPlace(player, obj, 0, enter)
        while param do
           Wait(0)
           drawTxt("Appuyez sur ~g~E~s~ pour arrêter ~b~l'animation",0,1,0.5,0.8,0.6,255,255,255,255)
           if IsControlJustPressed(1, 38) then

               if playExit then
                   PlayEmote(dict, name, 32, duration, 0, 0)
                   Citizen.CreateThread(function()
	                   	while true do
	                   		Wait(waitingTime)
	                   		ClearPedTasksImmediately(player)
	                   		break
	                   	end
                   end)
               else
                   ClearPedTasks(player)
                   Citizen.CreateThread(function()
	                   	while true do
	                   		Wait(waitingTime)
	                   		ClearPedTasksImmediately(player)
	                   		break
	                   	end
                   end)
               end
               param = false
           end
       end
   end
end


function PlayEmote(dict, name, flags, duration ,stop, loop, waitTimeUntilClear)
    if stop ~= 1 then
        ClearPedSecondaryTask(player)
        ClearPedTasks(player)

        local i = 0
        RequestAnimDict(dict)
        while not HasAnimDictLoaded(dict) and i < 500 do
            Wait(10)
            RequestAnimDict(dict)
            i = i+1
        end

        if HasAnimDictLoaded(dict) then
            TaskPlayAnim(player, dict , name, 2.0, 1, -1, flags, 0, 1, 1, 1)
        end

        Wait(0)

        if loop ~= 1 then
            while GetEntityAnimCurrentTime(player, dict, name) <= duration and IsEntityPlayingAnim(player, dict, name, 3) do
                Wait(0)
            end
            ClearPedTasks(player)
        else
            launched = true
            while GetEntityAnimCurrentTime(player, dict, name) <= duration and IsEntityPlayingAnim(player, dict , name, 3) and launched do
                Wait(0)
                 drawTxt("Appuyez sur ~g~E~s~ pour arrêter ~b~l'animation",0,1,0.5,0.8,0.6,255,255,255,255)
                if IsControlJustPressed(1, 38) then
                    StopAnimTask(player, dict, name, 1)
                    Citizen.CreateThread(function()
                        while true do
                            if waitTimeUntilClear == nil or waitTimeUntilClear == 0 then
                                Wait(2500)
                            else
                                waitingTime = (waitTimeUntilClear * 1000)
                                Wait(waitingTime)
                            end
                            ClearPedTasksImmediately(player)
                            break
                        end
                    end)
                end
            end
            launched = false
        end
    else
        ClearPedTasksImmediately(player)
    end
end

function drawTxt(text,font,centre,x,y,scale,r,g,b,a)
    SetTextFont(font)
    SetTextProportional(0)
    SetTextScale(scale, scale)
    SetTextColour(r, g, b, a)
    SetTextDropShadow(0, 0, 0, 0,255)
    SetTextEdge(1, 0, 0, 0, 255)
    SetTextDropShadow()
    SetTextOutline()
    SetTextCentre(centre)
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x , y)
end
