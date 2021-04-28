ESX = nil


Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end
end)

local menuOpen = false
local wasOpen = false

function DrawText3D(x, y, z, text)
    SetTextScale(0.45, 0.45)
    SetTextFont(6)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x,y,z, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0+0.0125, 0.017+ factor, 0.03, 0, 0, 0, 75)
    ClearDrawOrigin()
end

function playAnim(animDict, animName, duration)
	RequestAnimDict(animDict)
	while not HasAnimDictLoaded(animDict) do Citizen.Wait(0) end
	TaskPlayAnim(PlayerPedId(), animDict, animName, 1.0, -1.0, duration, 49, 1, false, false, false)
	RemoveAnimDict(animDict)
end

RegisterNetEvent('erbay-kokain:hazirkokainjelatin')
AddEventHandler('erbay-kokain:hazirkokainjelatin', function()
    local finished = exports["reload-skillbar"]:taskBar(5000,math.random(5,15))

    if finished ~= 100 then
        TriggerServerEvent('erbay-kokain:jelatinbasarisiz')
    else
        exports["pogressBar"]:drawBar(2000,"Kokaini jelatinliyorsun..")
        playAnim("mp_arresting", "a_uncuff",2000)
        TriggerServerEvent('erbay-kokain:jelatinbasarili')
    end

end)

RegisterNetEvent('erbay-kokain:hazirkokainkullan')
AddEventHandler('erbay-kokain:hazirkokainkullan', function()
	local playerPed = PlayerPedId()
	local maxHealth = GetEntityMaxHealth(playerPed)

        exports["pogressBar"]:drawBar(Config.hazirkokainkullanimsuresi,"Hazır Kokain kullanıyorsun..")
        TriggerServerEvent('erbay-kokain:itemsilhazirkoakin')
        playAnim("mp_player_inteat@burger", "mp_player_int_eat_burger",Config.hazirkokainkullanimsuresi)
        Citizen.Wait(Config.hazirkokainkullanimsuresi)
		SetEntityHealth(playerPed, maxHealth)
        SetRunSprintMultiplierForPlayer(PlayerId(), 1.49)
        Citizen.Wait(Config.hazirkokainetki)
        SetRunSprintMultiplierForPlayer(PlayerId(), 1.0)

end)

Citizen.CreateThread(function()
    while true do
        local ms = 2000
        local player = PlayerPedId()
        local playercoords = GetEntityCoords(player)
        if GetDistanceBetweenCoords(playercoords, Config.Toplamabolgesi1grkokain.x, Config.Toplamabolgesi1grkokain.y, Config.Toplamabolgesi1grkokain.z, true) < Config.Kokaintoplamabolgegenisligi then
            ms = 0
            ESX.ShowHelpNotification('Kokain toplamak için ~INPUT_CONTEXT~ bas.')
            if IsControlJustReleased(0, 38) then
            exports['mythic_progbar']:Progress({
            name = "itemekle1grkokain",
            duration = Config.toplamasuresikokain,
            label = 'Kokain topluyorsun...',
            useWhileDead = false,
            canCancel = false,
            controlDisables = {
                disableMovement = true,
                disableCarMovement = true,
                disableMouse = false,
                disableCombat = true,
            },
            animation = {
                animDict = "amb@world_human_gardener_plant@male@enter",
                anim = "enter",
                flags = 49,
            },
        }, function(cancelled)
            if not cancelled then
                TriggerServerEvent('erbay-kokain:itemekle1grkokain')
            else
                -- Do Something If Action Was Cancelled
            end
        end)
            end
        end
        if GetDistanceBetweenCoords(playercoords, Config.Uretmebolgesijelatin.x, Config.Uretmebolgesijelatin.y, Config.Uretmebolgesijelatin.z + 1.0, true) < 1.5 then
            ms = 0
            DrawText3D(Config.Uretmebolgesijelatin.x, Config.Uretmebolgesijelatin.y, Config.Uretmebolgesijelatin.z , 'Jelatin üretmek için ~g~E~s~ basınız')
            if IsControlJustReleased(0, 38) then
                exports["pogressBar"]:drawBar(Config.jelatinuretimsuresi,"Jelatin üretiyorsun..")
                playAnim("creatures@rottweiler@tricks@", "petting_franklin",Config.jelatinuretimsuresi)
                Citizen.Wait(Config.jelatinuretimsuresi)
                TriggerServerEvent('erbay-kokain:itemeklejelatin')
            end
        end
        Citizen.Wait(ms)
    end
end)

Citizen.CreateThread(function()
    while true do
    local ped = PlayerPedId()
    local ms = 2000
            if GetDistanceBetweenCoords(GetEntityCoords(ped), Config.Satmabolgesi.x, Config.Satmabolgesi.y, Config.Satmabolgesi.z, true) < 5 then
                ms = 0
                DrawText3D(Config.Satmabolgesi.x, Config.Satmabolgesi.y, Config.Satmabolgesi.z + 2, " Kokain alıcısı ile gorusmek icin ~g~[E] ~w~ basiniz. ")
                    if IsControlJustReleased(1, 51) then 
                        OpenShop()          
            end
        end
        Citizen.Wait(ms)
    end
end)

function OpenShop()
	ESX.UI.Menu.CloseAll()
	local elements = {}
	menuOpen = true

	for k, v in pairs(ESX.GetPlayerData().inventory) do
		local price = Config.Items[v.name]

		if price and v.count > 0 then
			table.insert(elements, {
				label = ('%s - <span style="color:green;">%s</span>'):format(v.label, (ESX.Math.GroupDigits(price)..'$')),
				name = v.name,
				price = price,

				-- menu properties
				type = 'slider',
				value = v.count,
				min = 1,
				max = v.count
			})
		end
	end

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'shop', {
		title    = 'Toptancı',
		align    = 'top-left',
		elements = elements
	}, function(data, menu)
		TriggerServerEvent('erbay-kokain:Itemsat', data.current.name, data.current.value)
	end, function(data, menu)
		menu.close()
		menuOpen = false
	end)
end


Citizen.CreateThread(function()

    if Config.Toplamabolgesi1grkokainblip == true then

    local blip = AddBlipForCoord(Config.Toplamabolgesi1grkokain.x, Config.Toplamabolgesi1grkokain.y, Config.Toplamabolgesi1grkokain.z)

    
    SetBlipSprite (blip, 403)
    SetBlipDisplay(blip, 4)
    SetBlipScale  (blip, 0.7)
    SetBlipColour (blip, 0)
    SetBlipAsShortRange(blip, true)

    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString('Kokain Toplama')
    EndTextCommandSetBlipName(blip)   

    end


end)

Citizen.CreateThread(function()

    if Config.Uretmebolgesijelatinblip == true then

    local blip = AddBlipForCoord(Config.Uretmebolgesijelatin.x, Config.Uretmebolgesijelatin.y, Config.Uretmebolgesijelatin.z)

    
    SetBlipSprite (blip, 403)
    SetBlipDisplay(blip, 4)
    SetBlipScale  (blip, 0.7)
    SetBlipColour (blip, 3)
    SetBlipAsShortRange(blip, true)

    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString('Jelatin Üretme')
    EndTextCommandSetBlipName(blip)   

    end


end)

Citizen.CreateThread(function()

    if Config.Saticiblip == true then


		local blip = AddBlipForCoord(Config.Satmabolgesi.x, Config.Satmabolgesi.y, Config.Satmabolgesi.z)

		SetBlipSprite (blip, 431)
		SetBlipDisplay(blip, 4)
		SetBlipScale  (blip, 0.7)
		SetBlipColour (blip, 0)
		SetBlipAsShortRange(blip, true)

		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString('Kokain Alıcısı')
		EndTextCommandSetBlipName(blip)

    end

end)



Citizen.CreateThread(function()
    if Config.Saticinpc == true then
        RequestModel(Config.Saticinpcmodel)
        while not HasModelLoaded(Config.Saticinpcmodel) do
            Wait(1)
        end
    
        erbay = CreatePed(1, Config.Saticinpcmodel, Config.Satmabolgesi.x, Config.Satmabolgesi.y, Config.Satmabolgesi.z, Config.Satmabolgesi.h, false, true)
        SetBlockingOfNonTemporaryEvents(erbay, true)
        SetPedDiesWhenInjured(erbay, false)
        SetPedCanPlayAmbientAnims(erbay, true)
        SetPedCanRagdollFromPlayerImpact(erbay, false)
        SetEntityInvincible(erbay, true)
        FreezeEntityPosition(erbay, true)

    end
end)







   

