if Config.Framework ~= "esx" then
    return
end

local usersCollate = ""
local vehiclesCollate = ""

MySQL.ready(function()
    while not GetCollationsForTables do
        Wait(0)
    end

    local collations = GetCollationsForTables({
        users = "identifier",
        owned_vehicles = "properties"
    })

    usersCollate = collations.users or ""
    vehiclesCollate = collations.owned_vehicles or ""

    Queries = {}
    Queries.Users = {}
    Queries.Users.Search = ([[
        SELECT
            u.identifier AS id,
            CONCAT(
                JSON_UNQUOTE(JSON_EXTRACT(u.identity, '$.firstname')), 
                ' ', 
                JSON_UNQUOTE(JSON_EXTRACT(u.identity, '$.lastname'))
            ) AS `name`,
            JSON_UNQUOTE(JSON_EXTRACT(u.identity, '$.dob')) as dob,
            JSON_UNQUOTE(JSON_EXTRACT(u.identity, '$.sex')) = "0" AS isMale,
            p.avatar
        FROM users u
        LEFT JOIN lbtablet_police_profiles p ON p.id = u.identifier %s
        WHERE
            CONCAT(
                JSON_UNQUOTE(JSON_EXTRACT(u.identity, '$.firstname')),
                ' ',
                JSON_UNQUOTE(JSON_EXTRACT(u.identity, '$.lastname'))
            ) LIKE ?
            {WHERE_FILTER}
        GROUP BY u.identifier, JSON_UNQUOTE(JSON_EXTRACT(u.identity, '$.firstname')), JSON_UNQUOTE(JSON_EXTRACT(u.identity, '$.lastname')), JSON_UNQUOTE(JSON_EXTRACT(u.identity, '$.dob')), JSON_UNQUOTE(JSON_EXTRACT(u.identity, '$.sex')), p.avatar
        LIMIT ?, ?
    ]]):format(usersCollate)
    
    Queries.Users.FetchProfile = ([[
        SELECT
            u.identifier AS id,
            CONCAT(
                JSON_UNQUOTE(JSON_EXTRACT(u.identity, '$.firstname')),
                ' ',
                JSON_UNQUOTE(JSON_EXTRACT(u.identity, '$.lastname'))
            ) AS `name`,
            JSON_UNQUOTE(JSON_EXTRACT(u.identity, '$.dob')) as dob,
            JSON_UNQUOTE(JSON_EXTRACT(u.identity, '$.height')) as height,
            JSON_UNQUOTE(JSON_EXTRACT(u.identity, '$.sex')) = "0" AS isMale,
            p.avatar,
            p.notes,
            j.label AS job
        FROM users u
        LEFT JOIN {PROFILE_JOIN} p ON p.id = u.identifier %s
        LEFT JOIN jobs j ON j.`name` = u.job
        WHERE u.identifier = ?
        GROUP BY u.identifier, JSON_UNQUOTE(JSON_EXTRACT(u.identity, '$.firstname')), JSON_UNQUOTE(JSON_EXTRACT(u.identity, '$.lastname')), JSON_UNQUOTE(JSON_EXTRACT(u.identity, '$.dob')), JSON_UNQUOTE(JSON_EXTRACT(u.identity, '$.sex')), p.avatar
    ]]):format(usersCollate)

    Queries.Users.SearchFilter = {}
    Queries.Users.SearchFilter.Jobs = "AND u.job IN (?)"

    if Config.JailScript == "qalle" then
        Queries.Users.SearchFilter.ExcludeJailed = "AND u.jail = 0"
    elseif Config.JailScript == "esx" then
        Queries.Users.SearchFilter.ExcludeJailed = "AND u.jail_time = 0"
    elseif Config.JailScript == "pickle" then
        Queries.Users.SearchFilter.ExcludeJailed = ("AND NOT EXISTS (SELECT 1 FROM pickle_prisons WHERE identifier %s = u.identifier %s)"):format(usersCollate, usersCollate)
    elseif Config.JailScript == "rcore" then
        Queries.Users.SearchFilter.ExcludeJailed = ("AND NOT EXISTS (SELECT 1 FROM rcore_prison WHERE owner %s = u.identifier %s)"):format(usersCollate, usersCollate)
    end

    local fetchVehicle = ([[
        SELECT
            json_value(v.properties, '$.plate') AS plate,
            v.owner,
            v.properties AS vehicle,
            p.avatar AS picture,
            CONCAT(JSON_UNQUOTE(JSON_EXTRACT(u.identity, '$.firstname')), ' ', JSON_UNQUOTE(JSON_EXTRACT(u.identity, '$.lastname'))) AS `name`
        FROM owned_vehicles v
        LEFT JOIN users u ON u.identifier %s = v.owner %s
        LEFT JOIN lbtablet_police_profiles p ON p.id = json_value(v.properties, '$.plate') %s
    ]]):format(usersCollate, vehiclesCollate, vehiclesCollate)
    
    Queries.Vehicles = {}
    Queries.Vehicles.SelectModelByPlates = "SELECT json_value(properties, '$.plate') AS plate, json_value(properties, '$.model') AS model FROM owned_vehicles WHERE json_value(properties, '$.plate') IN (?)"
    Queries.Vehicles.Fetch = fetchVehicle .. " WHERE json_value(v.properties, '$.plate') = ?"
    Queries.Vehicles.Search = fetchVehicle .. [[
        WHERE json_value(v.properties, '$.plate') LIKE ?
        LIMIT ?, ?
    ]]
    
    Queries.SelectName = "CONCAT(JSON_UNQUOTE(JSON_EXTRACT(u.identity, '$.firstname')), ' ', JSON_UNQUOTE(JSON_EXTRACT(u.identity, '$.lastname')))"
    Queries.SelectDob = "JSON_UNQUOTE(JSON_EXTRACT(u.identity, '$.dob'))"
    Queries.JoinName = ("LEFT JOIN users u ON u.identifier %s = %s"):format(usersCollate, "%s")    
end)

debugprint("Loading ESX")

local export, obj = pcall(function()
    return exports.gamemode:getSharedObject()
end)

if not export then
    TriggerEvent("esx:getSharedObject", function(esx)
        obj = esx
    end)
end

ESX = obj

debugprint("ESX loaded")

---@param source number
---@return string | nil
function GetIdentifier(source)
    return ESX.GetPlayerFromId(source)?.identifier
end

---@param identifier string
---@return number?
function GetSourceFromIdentifier(identifier)
    local xPlayer = ESX.GetPlayerFromIdentifier(identifier)

    if xPlayer then
        return xPlayer.source
    end
end

---@param item string
---@param cb fun(source: number)
function CreateUsableItem(item, cb)
    --ESX.RegisterUsableItem(item, cb)
end

---@param source number
function IsAdmin(source)
    ---@diagnostic disable-next-line: param-type-mismatch
    return ESX.GetPlayerFromId(source)?.getGroup() == "superadmin" or IsPlayerAceAllowed(source, "command.lbtablet_admin") == 1
end

---@param source number
function IsOnDuty(source)
    return (exports["gamemode"]:IS_PLAYER_SERVICE(Player(source).state.uniqueid));
end

---@param source number
---@return { name: string, label: string, grade: number, grade_label: string }
function GetJob(source)
    local xPlayer = ESX.GetPlayerFromId(source)

    return xPlayer.job
end
---@param identifier string
---@return { plate: string, type: string, vehicle: string }[]
function GetVehicles(identifier)
    local vehiclesList = exports["gamemode"]:getAllOwnedVehiclesOfOwner(identifier)
    local returnVehiclesList = {}

    if type(vehiclesList) ~= "table" then
        return returnVehiclesList
    end

    for _, vehData in ipairs(vehiclesList) do
        if type(vehData) == "table" then
            local vehicleProperties = vehData["properties"]
            if type(vehicleProperties) == "table" then
                table.insert(returnVehiclesList, {
                    vehicle = vehicleProperties,
                    plate = tostring(vehicleProperties["plate"])
                })
            end
        end
    end

    return returnVehiclesList
end

---@param source number
---@return string firstname
---@return string lastname
function GetCharacterName(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if (not xPlayer) then
        return "Unknown", "Unknown"
    end

    return xPlayer.getIdentityValue("firstname"), xPlayer.getIdentityValue("lastname")
end

---@param identifier string
---@return string?
function GetCharacterNameFromIdentifier(identifier)
    local xPlayer = ESX.GetPlayerFromIdentifier and ESX.GetPlayerFromIdentifier(identifier)
    if xPlayer then
        return xPlayer.getName()
    end
    return MySQL.scalar.await("SELECT CONCAT(JSON_UNQUOTE(JSON_EXTRACT(identity, '$.firstname')), ' ', JSON_UNQUOTE(JSON_EXTRACT(identity, '$.lastname'))) FROM users WHERE identifier = ?", { identifier }) or ""
end

---@type { type: string, label: string }[]
local licenses

-- MySQL.ready(function()
--     licenses = MySQL.query.await("SELECT `type`, label FROM licenses")
-- end)

---@param licenseType string
---@return boolean
local function DoesLicenseExist(licenseType)
    for i = 1, #licenses do
        if licenses[i].type == licenseType then
            return true
        end
    end

    return false
end

---@param identifier string
---@param licenseType string
---@return boolean
function RevokeLicense(identifier, licenseType)
    if not DoesLicenseExist(licenseType) then
        return false
    end

    -- TODO: Make it
end

---@param identifier string
---@param licenseType string
---@return boolean
function AddLicense(identifier, licenseType)
    if not DoesLicenseExist(licenseType) then
        return false
    end

    -- TODO: Make it
end

---@param licenseType string
---@return string
function GetLicenseLabel(licenseType)
    for i = 1, #licenses do
        if licenses[i].type == licenseType then
            return licenses[i].label
        end
    end

    return licenseType
end

---@return { label: string, type: string }[]
function GetAllLicenses()
    return licenses
end

---@param identifier string
---@return { type: string, label: string }[]
function GetPlayerLicenses(identifier)
    return {}
end

---@param jobs string | string[]
---@return { grades: { [string]: { grade: number, label: string }[] }, labels: { [string]: string } }
function GetJobGrades(jobs)
    if type(jobs) == "string" then
        jobs = { jobs }
    end
    local esxJobs = ESX.GetJobs()
    local grades = {}
    local labels = {}
    for i = 1, #jobs do
        local job = jobs[i]
        local jobData = esxJobs[job]
        if not jobData then
            debugprint("Job not found", job)
            goto continue
        end
        grades[job] = {}
        labels[job] = jobData.label
        local amountGrades = 0
        for _, grade in pairs(jobData.grades) do
            amountGrades += 1
            grades[job][amountGrades] = {
                grade = grade.id,
                label = grade.label
            }
        end

        table.sort(grades[job], function(a, b)
            if a.grade == 1 then
                return true
            elseif b.grade == 1 then
                return false
            elseif a.grade == 2 then
                return false
            elseif b.grade == 2 then
                return true
            else
                return a.grade > b.grade
            end
        end)    

        ::continue::
    end
    return {
        grades = grades,
        labels = labels
    }
end

---@param companies string[]
---@return table
function GetEmployees(companies)
    local employees = {}
    local phoneConfig = GetPhoneConfig()
    local numberTable = phoneConfig?.Item.Unique and "phone_last_phone" or "phone_phones"

    for _, company in pairs(companies) do
        local societyRanksData = exports["gamemode"]:GET_RANK_FROM_SOCIETY(company)
        local societyRanks = {}
        for rankIndex, rank in pairs(societyRanksData) do
            societyRanks[rankIndex] = rank.label
        end

        local playersValues = {}
        local usersData = MySQL.query.await(([[
            SELECT
                p.phone_number AS `number`,
                u.uniqueId AS `uid`,
                u.identifier AS `license`,
                a.callsign,
                a.avatar
            FROM users u

            LEFT JOIN lbtablet_police_accounts a ON a.id = u.identifier %s
            LEFT JOIN %s p ON  p.id = u.identifier COLLATE UTF8MB4_GENERAL_CI
            WHERE u.job = ?
        ]]):format(usersCollate, numberTable), { company })

        for _, userData in pairs(usersData) do
            playersValues[userData.uid] = userData
        end

        local societyMembers = exports["gamemode"]:GET_SOCIETY_MEMBERS_FROM_NAME(company)
        for i = 1, #societyMembers do
            local member = societyMembers[i]
            if (not member) then
                goto continue
            end

            local plySelectedData = playersValues[member.identifier]
            if (not plySelectedData) then
                goto continue
            end

            table.insert(employees, {
                id = plySelectedData.license,
                callsign = plySelectedData.callsign,
                avatar = plySelectedData.avatar,
                name = member.name,
                job = company,
                rank = member.rank,
                phoneNumber = plySelectedData.number
            })
            
            ::continue::
        end

        societyRanks = nil;
        playersValues = nil;
    end

    debugprint("GetEmployees", "finished", employees)
    return employees
end

---@param jobs { [string]: any }
---@return { source: number, name: string, rank: string, identifier: string }[]
function GetOnDutyEmployees(jobs)
    local employees = {}
    local players = ESX.GetExtendedPlayers()

    for i = 1, #players do
        local xPlayer = players[i]

        if jobs[xPlayer.job.name] and exports["gamemode"]:IS_PLAYER_SERVICE(xPlayer.uniqueId) then
            employees[#employees+1] = {
                source = xPlayer.source,
                name = xPlayer.name,
                rank = xPlayer.job.grade_label,
                identifier = xPlayer.identifier
            }
        end
    end

    return employees
end

---@param jobs string | string[]
---@return string[]
function GetIdentifiersWithJob(jobs)
    if type(jobs) == "string" then
        jobs = { jobs }
    end

    local identifiers = MySQL.query.await("SELECT identifier FROM users WHERE job IN (?)", { jobs })
    local result = {}

    for i = 1, #identifiers do
        result[i] = identifiers[i].identifier
    end

    return result
end

--#region Services app

RegisterNetEvent("tablet:services:toggleDuty", function()
end)

---@param job string
function GetEmployeeList(job)
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
        local memberRankId = member.rank;

        table.insert(employees, {
            firstname = member.firstname,
            lastname = member.lastname,
            grade = memberRankId,
            gradeLabel = societyRanks[memberRankId],
            number = (phoneNumber[member.identifier] or nil)
        })
    end

    return employees
end

function RefreshCompanies()
    if ESX.JobsPlayerCount then
        debugprint("Using new ESX method for refreshing companies")

        for i = 1, #Config.Services.Companies do
            local jobData = Config.Services.Companies[i]
            local jobKey = ("%s:count"):format(jobData.job)

            jobData.open = (GlobalState[jobKey] or 0) > 0
            debugprint("Job", jobData.job, "is open:", jobData.open)
        end

        return
    end

    debugprint("Using old ESX method for refreshing companies")

    local openJobs = {}
    local xPlayers = ESX.GetExtendedPlayers and ESX.GetExtendedPlayers() or ESX.GetPlayers()

    if ESX.GetExtendedPlayers then
        for _, xPlayer in pairs(xPlayers) do
            openJobs[xPlayer.job.name] = true
        end

        infoprint("warning", "You are running an outdated version of ESX. The script will still work, but you should consider updating. (you can remove this warning in server/custom/frameworks/esx.lua)")
    else
        for _, source in pairs(xPlayers) do
            local job = ESX.GetPlayerFromId(source).job.name

            openJobs[job] = true
        end

        infoprint("warning", "You are running an extremely old version of ESX. The script will still work, but you should consider updating. (you can remove this warning in server/custom/frameworks/esx.lua)")
    end

    for i = 1, #Config.Services.Companies do
        local jobData = Config.Services.Companies[i]

        jobData.open = openJobs[jobData.job] or false
    end
end

---@param jobDataIndex number
function NewCompagnyServer(jobDataIndex)
    local jobData = Config.Services.Companies[jobDataIndex]
    if (not jobData) then
        return;
    end

    local jobKey = ("%s:count"):format(jobData.job)

    AddStateBagChangeHandler(jobKey, "global", function(_, _, value)
        Wait(0) -- prevent print from showing in F8 when using command

        if type(value) ~= "number" then
            return
        end

        local isOpen = value > 0

        if jobData.open ~= isOpen then
            jobData.open = isOpen
            TriggerClientEvent("tablet:services:updateOpen", -1, jobData.job, isOpen)
        end

        debugprint(("Job count for job ^5%s^7 changed. Is open: %s"):format(jobData.job, jobData.open))
    end)
end

CreateThread(function ()
    for i = 1, #Config.Services.Companies do
        NewCompagnyServer(i);
    end
end)

BaseCallback("services:getOnlineIdentifiers", function(source, tabletId)
    local job = GetJob(source).name
    local onlineEmployees = ESX.GetExtendedPlayers("job", job)
    local onlineIdentifiers = {}

    for i = 1, #onlineEmployees do
        onlineIdentifiers[onlineEmployees[i].identifier] = true
    end

    return onlineIdentifiers
end)

--#endregion

function GetWeaponName(weapon)
    local itemData = exports["gamemode"]:itemGetFromName(weapon)
    if  (not itemData) then
        return;
    end
    
    return itemData.label
end

function GetWeaponImage(weapon)
    weapon = weapon:upper()

    if GetResourceState("ox_inventory") == "started" then
        local fileName = "web/images/" .. weapon .. ".png"
        local fileExists = LoadResourceFile("ox_inventory", fileName)

        if fileExists then
            return "https://cfx-nui-ox_inventory/" .. fileName
        end
    end
end

AddEventHandler("esx:setJob", function(src, job, lastJob)
    Wait(0)
    TriggerEvent("lb-tablet:jobUpdated", src, job.name, IsOnDuty(src))
end)

AddEventHandler("esx:playerLogout", function(source)
    PlayerLoggedOut(source)
end)
