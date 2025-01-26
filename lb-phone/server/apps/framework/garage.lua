---@alias VehicleStatistics { engine?: number, body?: number, fuel?: number }
---@alias ImpoundReason { reason?: string, retrievable?: number, price?: number, impounder?: string }
---@alias VehicleData { plate: string, type: string, location: string, model: number, impounded: boolean, statistics: VehicleStatistics, impoundReason?: ImpoundReason }

---Check if a vehicle is out
---@param plate string
---@return boolean out
---@return number | nil vehicle
local function IsVehicleOut(plate)
    local vehData = exports["gamemode"]:getSpawnedVehicleFromPlate(plate);
    if (not vehData) then
        return;
    end

    return true, vehData.handle
end

---@param plate string
BaseCallback("garage:findCar", function(source, phoneNumber, plate)
    local out, vehicle = IsVehicleOut(plate)

    if out and vehicle then
        return GetEntityCoords(vehicle)
    end

    SendNotification(phoneNumber, {
        source = source,
        app = "Garage",
        title = L("BACKEND.GARAGE.VALET"),
        content = L("BACKEND.GARAGE.COULDNT_FIND"),
    })

    return false
end)

RegisterNetEvent("garage:ply:locateVeh", function(vehPlate)
    local plySrc = source;
    local xPlayer = ESX.GetPlayerFromId(plySrc);
    if (not xPlayer) then
        return
    end

    ---@param contentString string
    local function SendNotification(contentString)
        return TriggerClientEvent("phone:sendNotification", plySrc, {
            app = "Garage",
            title = ("Voiture (%s)"):format(vehPlate),
            content = ((type(contentString) == "string" and contentString) or "Une erreur est survenue.")
        });
    end

    local vehSelected = exports["gamemode"]:getOwnedVehicleFromPlate(vehPlate);
    if (not vehSelected) then
        return
    end

    local vehSelectedIsStored = ((vehSelected.stored == true) or (vehSelected.stored == 1));
    if (vehSelectedIsStored) then
        return SendNotification("Le véhicule est dans votre garage !");
    end

    local vehSelectedExistOnMap, vehSelectedExistOnMapHandle = IsVehicleOut(vehPlate)
    local vehSelectedIsInPersistent = not vehSelectedExistOnMap and vehSelected.persistentCoords;
    if (not vehSelectedExistOnMap and not vehSelectedIsInPersistent) then
        return SendNotification("Le véhicule est dans une fourrière !");
    end

    local vehCoords = (not vehSelectedIsInPersistent and GetEntityCoords(vehSelectedExistOnMapHandle)) or vehSelected.persistentCoords;
    Events.TriggerNet("PLAYER.MANAGER:WAYPOINT.SET", plySrc, vehCoords["x"], vehCoords["y"]);
    return SendNotification("Coordonnées GPS mis a jour !");
end)

BaseCallback("garage:getVehicles", function(source, phoneNumber)
    return GetPlayerVehicles(source)
end)

---@param plate string
---@param coords vector3
---@param heading number
BaseCallback("garage:valetVehicle", function(source, phoneNumber, plate, coords, heading)
    if IsVehicleOut(plate) then
        SendNotification(phoneNumber, {
            app = "Garage",
            title = L("BACKEND.GARAGE.VALET"),
            content = L("BACKEND.GARAGE.ALREADY_OUT"),
        })

        return
    end

    if Config.Valet.Price and GetBalance(source) < Config.Valet.Price then
        SendNotification(phoneNumber, {
            app = "Garage",
            title = L("BACKEND.GARAGE.VALET"),
            content = L("BACKEND.GARAGE.NO_MONEY"),
        })

        return
    end

    local vehicleData = GetVehicle(source, plate)

    if not vehicleData then
        return
    end

    if Config.Valet.Price and not RemoveMoney(source, Config.Valet.Price) then
        SendNotification(phoneNumber, {
            app = "Garage",
            title = L("BACKEND.GARAGE.VALET"),
            content = L("BACKEND.GARAGE.NO_MONEY"),
        })

        return
    end

    SendNotification(phoneNumber, {
        app = "Garage",
        title = L("BACKEND.GARAGE.VALET"),
        content = L("BACKEND.GARAGE.ON_WAY"),
    })

    if not Config.ServerSideSpawn then
        return vehicleData
    end

    local vehicle = CreateServerVehicle(vehicleData.model, coords, heading)

    if not vehicle then
        AddMoney(source, Config.Valet.Price)
        debugprint("Failed to create vehicle")

        return
    end

    vehicleData.vehNetId = NetworkGetNetworkIdFromEntity(vehicle)

    if Config.Valet.Drive then
        ---@diagnostic disable-next-line: param-type-mismatch
        local ped = CreateServerPed(Config.Valet.Model, coords + vector3(0.0, 1.0, 1.0), heading)

        if not ped then
            AddMoney(source, Config.Valet.Price)
            DeleteEntity(vehicle)
            debugprint("Failed to create ped")
            return
        end

        vehicleData.pedNetId = NetworkGetNetworkIdFromEntity(ped)
    end

    return vehicleData
end)
