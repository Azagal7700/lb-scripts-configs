if Config.Framework ~= "esx" then
    return
end

debugprint("Loading ESX")

local export, obj = pcall(function()
    return exports.gamemode:getSharedObject()
end)

if export then
    ESX = obj
else
    while not ESX do
        TriggerEvent("esx:getSharedObject", function(obj)
            ESX = obj
        end)

        Wait(500)
    end
end

RegisterNetEvent("esx:playerLoaded", function(playerData)
    ESX.PlayerData = playerData
    ESX.PlayerLoaded = true

    TriggerServerEvent("lb-tablet:frameworkLoaded")
end)

RegisterNetEvent("esx:onPlayerLogout", function()
    FrameworkLoaded = false
    ESX.PlayerLoaded = false

    LogOut()

    while not ESX.PlayerLoaded do
        Wait(500)
    end

    FrameworkLoaded = true
    FetchTabletData()
end)

while not ESX.PlayerLoaded do
    Wait(500)
end

TriggerServerEvent("lb-tablet:frameworkLoaded")

function FormatVehicle(vehicle)
    local vehData = vehicle.vehicle;
    vehicle.vehicle = (((type(vehData) == "table") and vehData) or json.decode(vehicle.vehicle))
    vehicle.color = GetVehicleColor(vehicle.vehicle.color1)
    vehicle.model = GetVehicleLabel(vehicle.vehicle.model)
    vehicle.vehicle = nil

    if vehicle.name then
        vehicle.owner = {
            name = vehicle.name,
            identifier = vehicle.owner
        }

        vehicle.name = nil
    end

    return vehicle
end

---@return boolean
function IsAdmin()
    ---@diagnostic disable-next-line: redundant-return-value
    return AwaitCallback("isAdmin")
end

---@return boolean
function HasTabletItem()
    if not Config.Item.Require then
        return true
    end

    local ITEM_COUNT = exports["gamemode"]:GetItemQuantityBy({
        name = Config.Item.Name
    })
    debugprint("Item count: " .. tostring(ITEM_COUNT))

    return (ITEM_COUNT > 0)
end

RegisterNetEvent("Inventory:onPlayerItemAdded", function (itemValues)
    local itemName = itemValues["name"];
    if (not Config.Item.Require or itemName ~= Config.Item.Name) then
        return
    end
    
    OnItemCountChange();
end)

RegisterNetEvent("Inventory:onPlayerItemRemoved", function (itemValues)
    local itemName = itemValues["name"];
    if (not Config.Item.Require or itemName ~= Config.Item.Name) then
        return
    end
    
    local newItemCount = exports["gamemode"]:GetItemQuantityBy({
		name = itemName
	});
    if (not newItemCount or newItemCount > 0) then
        return
    end

    OnItemCountChange();
end)

---@return string
function GetJob()
    return ESX.PlayerData.job.name
end

---@return number
function GetJobGrade()
    return ESX.PlayerData.job.grade
end

RegisterNetEvent("esx:setJob", function(job)
    local oldJob = ESX.PlayerData.job
    local jobChanged = true

    if oldJob.name == job.name and oldJob.grade == job.grade then
        jobChanged = false
    end

    ESX.PlayerData.job = job

    if jobChanged then
        TriggerEvent("lb-tablet:jobUpdated")
    end
end)

--#region Services

function GetCompanyData()
    -- TODO: Implement this (?)
end

function DepositMoney(amount)
    -- TODO: Implement this (?)
end

function WithdrawMoney(amount)
    -- TODO: Implement this (?)
end

function HireEmployee(source)
    -- TODO: Implement this (?)
end

function FireEmployee(identifier)
    -- TODO: Implement this (?)
end

function SetGrade(identifier, newGrade)
    -- TODO: Implement this (?)
end

function ToggleDuty()
    TriggerServerEvent("tablet:services:toggleDuty")
end

--#endregion

debugprint("ESX loaded")

FrameworkLoaded = true
