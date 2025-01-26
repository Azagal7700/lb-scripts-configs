---Function to find a spawn point for a car
---@param minDist? number Minimum distance from the player. Default 150
---@return nil | vector3
---@return number
local function FindCarLocation(minDist)
    return false;
end

local function BringCar(data, cb)
    return false;
end

---Function to find a car
---@param plate string
---@return vector3 | false
local function FindCar(plate)
    return false;
end

function GetVehicleLabel(model)
    local vehicleLabel = GetDisplayNameFromVehicleModel(model):lower()

    if not vehicleLabel or vehicleLabel == "null" or vehicleLabel == "carnotfound" then
        return "Unknown"
    end

    local text = GetLabelText(vehicleLabel)

    if text and text:lower() ~= "null" then
        vehicleLabel = text
    end

    return vehicleLabel
end

RegisterNUICallback("Garage", function(data, cb)
    local action = data.action
    debugprint("Garage:" .. (action or ""))

    if action == "getVehicles" then
        local cars = AwaitCallback("garage:getVehicles")

        for i = 1, #cars do
            local carModel = cars[i].model;
            cars[i].model = GetVehicleLabel(carModel)
            cars[i].type = ESX.GetVehicleType(carModel)
        end

        cb(cars)
    elseif action == "setWaypoint" then
        TriggerServerEvent("garage:ply:locateVeh", data.plate)
        cb("ok")
    end
end)
