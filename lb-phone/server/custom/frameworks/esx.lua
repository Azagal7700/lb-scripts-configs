if Config.Framework ~= "esx" then
    return
end

debugprint("Loading ESX")
local export, obj = pcall(function()
    return exports["gamemode"]:getSharedObject()
end)

if export then
    ESX = obj
else
    TriggerEvent("esx:getSharedObject", function(obj)
        ESX = obj
    end)
end
debugprint("ESX loaded")

---@param source number
---@return string | nil
function GetIdentifier(source)
    return ESX.GetPlayerFromId(source)?.identifier
end

local function HasItem(source, itemName)
    if not Config.Item.Require then
        return true
    end

    if Config.Item.Unique then
        return HasPhoneNumber(source, number)
    end

    local item_count = exports["gamemode"]:GetItemQuantityBy(source, {
        name = Config.Item.Name,
    })
    local hasItem = (item_count and item_count > 0)
    
    if not hasItem then
        return false
    end

    return MySQL.Sync.fetchScalar("SELECT 1 FROM phone_phones WHERE id=@id AND phone_number=@number", {
        ["@id"] = GetIdentifier(source),
        ["@number"] = number
    }) ~= nil
end

---Check if a player has a phone with a specific number
---@param source any
---@param number string
---@return boolean
function HasPhoneItem(source, number)
    if not Config.Item.Require then
        return true
    end

    if Config.Item.Unique then
        return HasPhoneNumber(source, number)
    end

    local hasItem

    if Config.Item.Name then
        hasItem = HasItem(source, Config.Item.Name)
    elseif Config.Item.Names then
        for i = 1, #Config.Item.Names do
            if HasItem(source, Config.Item.Names[i].name) then
                hasItem = true
                break
            end
        end
    end

    if not hasItem then
        return false
    end

    if not number then
        return hasItem
    end

    return MySQL.scalar.await("SELECT 1 FROM phone_phones WHERE id=? AND phone_number=?", { GetIdentifier(source), number }) ~= nil
end

---Register an item as usable
---@param item string
---@param cb function
function CreateUsableItem(item, cb)
end

---Get a player's character name
---@param source any
---@return string # Firstname
---@return string # Lastname
function GetCharacterName(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if (not xPlayer) then
        return "Unknown", "Unknown"
    end

    return xPlayer.getIdentityValue("firstname"), xPlayer.getIdentityValue("lastname")
end

---Get an array of player sources with a specific job
---@param job string
---@return table # Player sources
function GetEmployees(job)
    local EMPLOYES = {}
    local EMPLOYES_COUNT = 0

    if ESX.GetExtendedPlayers then
        local xPlayers = ESX.GetExtendedPlayers("job", job)

        for _, xPlayer in pairs(xPlayers) do
            if (exports["gamemode"]:IS_PLAYER_SERVICE(xPlayer.uniqueId)) then
                EMPLOYES_COUNT += 1
                EMPLOYES[EMPLOYES_COUNT] = xPlayer.source
            end
        end
    end

    return EMPLOYES
end

---@param job string
---@return { firstname: string, lastname: string, grade: string, number: string }[] employees
function GetAllEmployees(job)
    local numberTable = Config.Item.Unique and "phone_last_phone" or "phone_phones";
    local employees = {};
    local societyRanks = {};
    local societyRanksData = exports["gamemode"]:GET_RANK_FROM_SOCIETY(job);
    for rankIndex, rank in pairs(societyRanksData) do
        societyRanks[rankIndex] = rank.label;
    end

    local phoneNumber = {};
    local phoneNumberData = MySQL.query.await(([[
    SELECT
        p.phone_number AS `number`,
        u.uniqueId AS `uid`
        FROM users u
        LEFT JOIN %s p ON u.identifier = p.id COLLATE UTF8MB4_GENERAL_CI
        WHERE u.job = ?
    ]]):format(numberTable), { job })
    for phoneIndex, phone in pairs(phoneNumberData) do
        phoneNumber[phone.uid] = phone.number;
    end

    local societyMembers = exports["gamemode"]:GET_SOCIETY_MEMBERS_FROM_NAME(job);
    for i = 1, #societyMembers do
        local member = societyMembers[i];

        member.firstname, member.lastname = member.name:match("^(%S+)%s+(%S+)$")

        table.insert(employees, {
            firstname = member.firstname,
            lastname = member.lastname,
            grade = societyRanks[member.rank],
            number = (phoneNumber[member.identifier] or nil)
        })
    end

    return employees
end

---Get the bank balance of a player
---@param source any
---@return integer
function GetBalance(source)
    local xPlayer = ESX.GetPlayerFromId(source)

    return xPlayer?.getAccount("bank")?.money or 0
end

---Add money to a player's bank account
---@param source any
---@param amount integer
---@return boolean
function AddMoney(source, amount)
    local xPlayer = ESX.GetPlayerFromId(source)

    if not xPlayer or amount < 0 then
        return false
    end

    xPlayer.addAccountMoney("bank", amount)
    return true
end

---@param identifier string
---@param amount number
---@return boolean
function AddMoneyOffline(identifier, amount)
    if amount <= 0 then
        return false
    end

    amount = math.floor(amount + 0.5)

    return MySQL.update.await("UPDATE users SET accounts = JSON_SET(accounts, '$.bank', JSON_EXTRACT(accounts, '$.bank') + ?) WHERE identifier = ?", { amount, identifier }) > 0
end

---Remove money from a player's bank account
---@param source any
---@param amount integer
---@return boolean
function RemoveMoney(source, amount)
    local xPlayer = ESX.GetPlayerFromId(source)

    if not xPlayer or amount < 0 or GetBalance(source) < amount then
        return false
    end

    xPlayer.removeAccountMoney("bank", amount)
    return true
end

---Send a message to a player
---@param source number
---@param message string
function Notify(source, message)
    TriggerClientEvent("esx:showNotification", source, message)
end

-- GARAGE APP

---@param source number
---@return VehicleData[] vehicles An array of vehicles that the player owns
function GetPlayerVehicles(source)
    local RETURN_VEHICLES_LIST = {};

    if (not (type(source) == "number")) then
        return RETURN_VEHICLES_LIST;
    end

    local PLAYER_IDENTIFIER = GetIdentifier(source);
    local VEHICLES_LIST = ((type(PLAYER_IDENTIFIER) == "string") and exports["gamemode"]:getAllOwnedVehiclesOfOwner(PLAYER_IDENTIFIER));

    if (not (type(VEHICLES_LIST) == "table")) then
        return RETURN_VEHICLES_LIST;
    end

    for VEH_INDEX = 1, (#VEHICLES_LIST) do
        local VEH_DATA = VEHICLES_LIST[VEH_INDEX];
        if (type(VEH_DATA) == "table") then
            local VEHICLE_PROPERTIES = VEH_DATA["properties"];
            if (type(VEHICLE_PROPERTIES) == "table") then
                local VEH_MODEL = VEHICLE_PROPERTIES["model"];
                VEH_MODEL = (((type(VEH_MODEL) == "string") and joaat(VEH_MODEL)) or VEH_MODEL);

                local VEH_IS_STORED = tonumber(VEH_DATA["stored"]);
                VEH_IS_STORED = (((type(VEH_IS_STORED) == "number") and VEH_IS_STORED == 1) or false);
                local VEH_ENGINE, VEH_BODY, VEH_FUEL = tonumber(VEHICLE_PROPERTIES["engineHealth"]), tonumber(VEHICLE_PROPERTIES["bodyHealth"]), tonumber(VEHICLE_PROPERTIES["fuelLevel"]);

                local vehNumberPlateText = tostring(VEHICLE_PROPERTIES["plate"]);
                local vehIsSpawned = (VEH_DATA["persistentCoords"] ~= nil or exports["gamemode"]:getSpawnedVehicleFromPlate(vehNumberPlateText) ~= nil);

                table.insert(RETURN_VEHICLES_LIST, {
                    model = VEH_MODEL,
                    plate = vehNumberPlateText,
                    location = ((VEH_IS_STORED and "Garage") or (vehIsSpawned and "Sorti") or "Fourrière"),
                    impounded = (not VEH_IS_STORED and not vehIsSpawned),
                    statistics = {
                        engine = ((type(VEH_ENGINE) == "number") and (math.floor((VEH_ENGINE/10)+0.5)) or nil),
                        body = ((type(VEH_BODY) == "number") and (math.floor((VEH_BODY/10)+0.5)) or nil),
                        fuel = ((type(VEH_FUEL) == "number") and (math.floor(VEH_FUEL+0.5)) or nil);
                    };
                });
            end
        end
    end

    return RETURN_VEHICLES_LIST;
end

---Get a specific vehicle
---@param source number
---@param plate string
---@return table? vehicleData
function GetVehicle(source, plate)
    debugprint("Getting vehicle data for " .. plate)
    return false;
end

function IsAdmin(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    local isAdmin = xPlayer?.getGroup() == "developer"

    return isAdmin
end

---@param PLAYER_SRC number
---@param APP string
---@param USERNAME string
---@param BOOLEAN number
Events.RegisterNative("PHONE:SERVER.VERIFIED", function(PLAYER_SRC, APP, USERNAME, BOOLEAN)
    if (not Value.IsNumber(PLAYER_SRC) and not Value.IsString(APP) and not Value.IsString(USERNAME) and not Value.IsNumber(BOOLEAN)) then
        return;
    end

    local APP_NAME, USERNAME, VERIFIED = APP:lower(), USERNAME, BOOLEAN
    local ALLOWED_APPS = {
        ["twitter"] = true,
        ["instagram"] = true,
        ["tiktok"] = true,
        ["birdy"] = true,
        ["trendy"] = true,
        ["instapic"] = true
    }

    if (not ALLOWED_APPS[APP_NAME]) then
        return showError("No such app " .. tostring(APP_NAME))
    end

    if (not USERNAME) then
        return showError("No username provided")
    end

    if (VERIFIED ~= 1 and VERIFIED ~= 0) then
        return showError("Verified must be 1 or 0")
    end

    ToggleVerified(APP_NAME, USERNAME, VERIFIED == 1)
end);

---@param PLAYER_SRC number
---@param APP string
---@param USERNAME string
---@param PASSWORD string
Events.RegisterNative("PHONE:SERVER.PASSWORD", function(PLAYER_SRC, APP, USERNAME, PASSWORD)
    if (not Value.IsNumber(PLAYER_SRC) and not Value.IsString(APP) and not Value.IsString(USERNAME) and not Value.IsString(PASSWORD)) then
        return;
    end

    local APP_NAME, USERNAME, PASSWORD = APP:lower(), USERNAME, PASSWORD
    local ALLOWED_APPS = {
        ["twitter"] = true,
        ["instagram"] = true,
        ["tiktok"] = true,
        ["birdy"] = true,
        ["trendy"] = true,
        ["instapic"] = true
    }

    if (not ALLOWED_APPS[APP_NAME]) then
        return showError("No such app " .. tostring(APP_NAME))
    end

    if (not USERNAME) then
        return showError("No username provided")
    end

    if (not PASSWORD) then
        return showError("No password provided")
    end

    if (not ChangePassword(APP_NAME, USERNAME, PASSWORD)) then
        return showError("Failed to change password")
    end

    TriggerClientEvent("chat:addMessage", PLAYER_SRC, {
        color = { 0, 255, 0 },
        args = { "Success", "Password changed for " .. USERNAME}
    })
end);

---@param PLAYER_SRC number
---@param TARGET_SRC number
Events.RegisterNative("PHONE:SERVER.RESET_SECURITY", function(PLAYER_SRC, TARGET_SRC)
    if (not Value.IsNumber(PLAYER_SRC) and not Value.IsNumber(TARGET_SRC)) then
        return;
    end

    local PHONE_NUMBER = GetEquippedPhoneNumber(TARGET_SRC);
    if (not PHONE_NUMBER) then
        return showError("No phone number found for player " .. TARGET_SRC)
    end

    ResetSecurity(PHONE_NUMBER)
end);

RegisterNetEvent("phone:services:toggleDuty", function()
    local xPlayer = ESX.GetPlayerFromId(source)
    local job = xPlayer?.job

    if job then
        xPlayer.setJob(job.name, job.grade, not job.onDuty)
    end
end)

---@param source number
---@return string
function GetJob(source)
    return ESX.GetPlayerFromId(source)?.job?.name or "unemployed"
end

function RefreshCompanies()
    for i = 1, #Config.Companies.Services do
        local jobData = Config.Companies.Services[i];
        if (type(jobData) == "table") then
            local PLAYER_COUNT = exports["gamemode"]:GET_JOB_SERVICE_COUNT(jobData.job);

            jobData.open = (PLAYER_COUNT > 0 and true) or false;
        end
    end
end

CreateThread(function ()
    while (not Config.Companies.Services) do
        Wait(1000);
    end
    for i = 1, #Config.Companies.Services do
        local jobData = Config.Companies.Services[i]
        local jobKey = ("%s:count"):format(jobData.job)
    
        AddStateBagChangeHandler(jobKey, "global", function(_, _, value)
            Wait(0) -- prevent print from showing in F8 when using command
    
            if type(value) ~= "number" then
                return
            end
    
            local isOpen = value > 0
    
            if jobData.open ~= isOpen then
                jobData.open = isOpen
                TriggerClientEvent("phone:services:updateOpen", -1, jobData.job, isOpen)
            end
    
            debugprint(("Job count for job ^5%s^7 changed. Is open: %s"):format(jobData.job, jobData.open))
        end)
    end
end)