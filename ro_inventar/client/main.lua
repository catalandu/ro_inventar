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


ESX = nil
local PlayerData = {}

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end

    while ESX.GetPlayerData().job == nil do
        Citizen.Wait(10)
    end

    PlayerData = ESX.GetPlayerData()
end)

local enableField = false

function toggleField(enable)
    SetNuiFocus(enable, enable)
    enableField = enable

    ESX.TriggerServerCallback('grv_inventory:loadmoney', function(money)
        if enable then
            SendNUIMessage({
                action = 'open',
                money = money
            })
        else
            SendNUIMessage({
                action = 'close'
            })
        end
    end)
    
end

function getPicbyItem(itemname)
    for k,v in pairs(Config.Items) do
        if itemname == k then
            return v.img
        end
    end
    return Config.DefaultPic
end


function ReloadInventory()
    ESX.TriggerServerCallback('grv_inventory:loadmoney', function(money)
        SendNUIMessage({action = 'reset', money = money})
       
        ESX.TriggerServerCallback('grv_inventory:loadTarget', function(data)
            for key, value in pairs(data) do
                SendNUIMessage({
                    action = "add",
                    identifier = value.identifier,
                    item = value.item,
                    count = value.count,
                    name = value.name,
                    label = value.label,
                    limit = value.limit,
                    rare = value.rare,
                    can_remove = value.can_remove,
                    url = getPicbyItem(value.name),
                    useable = value.usable
                })
            end
        end, GetPlayerServerId(PlayerId()))

        SendNUIMessage({
            money = money
        })
    end)
end

function Waffen()
    ESX.TriggerServerCallback('grv_inventory:loadmoney', function(money)
        SendNUIMessage({action = 'reset', money = money})
       
        ESX.TriggerServerCallback('grv_inventory:loadTargetWeapons', function(data)
            for key, value in pairs(data) do
                SendNUIMessage({
                    action = "addw",
                    identifier = value.identifier,
                    item = value.item,
                    count = value.count,
                    name = value.name,
                    label = value.label,
                    rare = value.rare,
                    can_remove = value.can_remove,
                    url = getPicbyItem(value.name),
                })
            end
        end, GetPlayerServerId(PlayerId()))

        SendNUIMessage({
            money = money
        })
    end)
end

function loadAnimDict(dict)
	while (not HasAnimDictLoaded(dict)) do
		RequestAnimDict(dict)
		Citizen.Wait(5)
	end
end

RegisterNUICallback('refresh', function(data, cb)
    ReloadInventory()
    cb('ok')
end)

RegisterNUICallback('use', function(data, cb)
    toggleField(false)
    SetNuiFocus(false, false)
    for i = 1, tonumber(data.amount), 1 do
        TriggerServerEvent('grv_inventory:useItem', data.item)
        Wait(500)
    end

    cb('ok')
end)

RegisterNUICallback('throw', function(data, cb)
    toggleField(false)
    SetNuiFocus(false, false)
    local playerPed = GetPlayerPed(-1)
    loadAnimDict('anim@mp_snowball')

    TaskPlayAnim(PlayerPedId(), 'anim@mp_snowball', 'pickup_snowball', 8.0, -1, -1, 0, 1, 0, 0, 0)
	Citizen.Wait(1300)
	ClearPedTasksImmediately(playerPed) 
    TriggerServerEvent('grv_inventory:throwItem', data.item, tonumber(data.amount))
    ESX.ShowNotification(("Du wirfst %sx %s weg"):format(data.amount, data.label))
    cb('ok')
    DisableControlAction()
end)

--Waffen
RegisterNUICallback('throwweapon', function(data, cb)
    toggleField(false)
    SetNuiFocus(false, false)
    local playerPed = GetPlayerPed(-1)
    loadAnimDict('anim@mp_snowball')

    TaskPlayAnim(PlayerPedId(), 'anim@mp_snowball', 'pickup_snowball', 8.0, -1, -1, 0, 1, 0, 0, 0)
	Citizen.Wait(1300)
	ClearPedTasksImmediately(playerPed) 
    TriggerServerEvent('grv_inventory:throwWeapon', data.item, tonumber(data.amount))
    ESX.ShowNotification(("Du wirfst %sx %s weg"):format(data.amount, data.label))
    cb('ok')
end)

RegisterNUICallback('give', function(data, cb)
    toggleField(false)
    SetNuiFocus(false, false)
    local playerPed = GetPlayerPed(-1)
    loadAnimDict('anim@mp_snowball')
    local player, dist = ESX.Game.GetClosestPlayer()

    if player == -1 or dist > 3.0 then
        ESX.ShowNotification('Es ist keine Person in der Nähe')
    else
        TaskPlayAnim(PlayerPedId(), 'anim@mp_snowball', 'pickup_snowball', 8.0, -1, -1, 0, 1, 0, 0, 0)
        Citizen.Wait(1300)
        ClearPedTasksImmediately(playerPed)
        TriggerServerEvent('grv_inventory:giveItem', data.item, data.amount, GetPlayerServerId(player))
        ESX.ShowNotification(("Du hast jemanden %sx %s zugesteckt"):format(data.amount, data.label))
    end
    
    cb('ok')
end)
--Waffen
RegisterNUICallback('giveweapon', function(data, cb)
    toggleField(false)
    SetNuiFocus(false, false)
    local playerPed = GetPlayerPed(-1)
    loadAnimDict('anim@mp_snowball')
    local player, dist = ESX.Game.GetClosestPlayer()

    if player == -1 or dist > 3.0 then
        ESX.ShowNotification('Es ist keine Person in der Nähe')
    else
        TaskPlayAnim(PlayerPedId(), 'anim@mp_snowball', 'pickup_snowball', 8.0, -1, -1, 0, 1, 0, 0, 0)
        Citizen.Wait(1300)
        ClearPedTasksImmediately(playerPed)
        TriggerServerEvent('grv_inventory:giveWeapon', data.item, data.amount, GetPlayerServerId(player))
        ESX.ShowNotification(("Du hast jemanden %sx %s zugesteckt"):format(data.amount, data.label))
    end
    
    cb('ok')
end)

RegisterNUICallback('throwCash', function(data, cb)
    toggleField(false)
    SetNuiFocus(false, false)
    TriggerServerEvent('grv_inventory:throwCash', tonumber(data.amount))
    ESX.ShowNotification(('Du wirfst $%s weg'):format(data.amount))
end)

RegisterNUICallback('givecash', function(data, cb)
    toggleField(false)
    SetNuiFocus(false, false)
    local playerPed = GetPlayerPed(-1)
    loadAnimDict('anim@mp_snowball')
    local player, dist = ESX.Game.GetClosestPlayer()

    if player == -1 or dist > 3.0 then
        ESX.ShowNotification('Es ist keine Person in der Nähe')
    else
        TaskPlayAnim(PlayerPedId(), 'anim@mp_snowball', 'pickup_snowball', 8.0, -1, -1, 0, 1, 0, 0, 0)
        Citizen.Wait(1300)
        ClearPedTasksImmediately(playerPed)
        TriggerServerEvent('grv_inventory:giveCash', tonumber(data.amount), GetPlayerServerId(player))
        ESX.ShowNotification(('Du hast jemanden %s$ zugesteckt'):format(data.amount))
    end
end)

RegisterNetEvent('grv_inventory:setMax')
AddEventHandler('grv_inventory:setMax', function(max)
    SendNUIMessage({
        action = 'updatemax',
        max = max
    })
end)



AddEventHandler('onResourceStop', function(name)
    if GetCurrentResourceName() ~= name then
        return
    end

    toggleField(false)
end)

RegisterNUICallback('escape', function(data, cb)
    toggleField(false)
    SetNuiFocus(false, false)

    cb('ok')
end)

CreateThread(function()
    while true do
        Wait(0)

        if IsControlJustPressed(0, 289) then
            ReloadInventory()
            Waffen()
            toggleField(true)
        end
    end
end)