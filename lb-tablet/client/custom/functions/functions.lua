---@return boolean canOpen
function CanOpenTablet()
    if Config.LBPhone and exports["lb-phone"]:IsOpen() then
        debugprint("CanOpenTablet: lb-phone is open")
        return false
    end

    if IsPauseMenuActive() then
        debugprint("CanOpenTablet: pause menu is active")
        return false
    end

    if not HasTabletItem() then
        debugprint("CanOpenTablet: no item")
        return false
    end

    if IsNuiFocused() then
        debugprint("CanOpenTablet: NUI is focused")
        return false
    end

    return true
end

function OnOpen()
    if Config.LBPhone then
        exports["lb-phone"]:ToggleDisabled(true)
    end
end

function OnClose()
    if Config.LBPhone then
        exports["lb-phone"]:ToggleDisabled(false)
    end
end

---@param dict string
---@return string dict
function LoadDict(dict)
    if not HasAnimDictLoaded(dict) then
        RequestAnimDict(dict)

        while not HasAnimDictLoaded(dict) do
            Wait(0)
        end
    end

    return dict
end

---@param model string | number
---@return number | false modelHash
function LoadModel(model)
    assert(type(model) == "string" or type(model) == "number", "model must be a string or number")

    local modelHash = type(model) == "number" and model or joaat(model)

    if not modelHash then
        return false
    end

    if not HasModelLoaded(modelHash) then
        RequestModel(modelHash)

        while not HasModelLoaded(modelHash) do
            Wait(0)
        end
    end

    return modelHash
end

function HideHudComponents()
    HideHudAndRadarThisFrame()
    HideHelpTextThisFrame()
end

---Wait for network id & entity to exist
---@param netId number
---@return number? entity
function WaitForNetworkId(netId)
    local timer = GetGameTimer() + 5000

    while not NetworkDoesNetworkIdExist(netId) do
        Wait(0)

        if GetGameTimer() > timer then
            return
        end
    end

    timer = GetGameTimer() + 5000

    while not DoesEntityExist(NetworkGetEntityFromNetworkId(netId)) do
        Wait(0)

        if GetGameTimer() > timer then
            return
        end
    end

    return NetworkGetEntityFromNetworkId(netId)
end

---@param entity number
---@return boolean success
function TakeControlOfEntity(entity)
    if NetworkHasControlOfEntity(entity) then
        return true
    end

    local timer = GetGameTimer() + 5000

    while not NetworkHasControlOfEntity(entity) and timer > GetGameTimer() do
        NetworkRequestControlOfEntity(entity)
        Wait(0)
    end

    return NetworkHasControlOfEntity(entity)
end

local instructionalButtons = {
    b_194 = "arrow_up",
    b_195 = "arrow_down",
    b_196 = "arrow_left",
    b_197 = "arrow_right",
}

function GetInstructionalButtonName(button)
    local name = instructionalButtons[button]

    if name then
        return name
    end

    infoprint("warning", "Unknown button: " .. button)

    return "??"
end

function RespondToDispatch(dispatch)
    SetNewWaypoint(dispatch.location.coords.x, dispatch.location.coords.y)
end

function OnItemCountChange()
    Wait(500)

    local hasTablet = HasTabletItem()

    if not hasTablet then
        ToggleOpen(false)
    end

    SendReactMessage("setHasTablet", hasTablet)
end

---@param job "Police" | "Ambulance"
function GetPermissions(job)
    local permissions = {}
    local playerJob = GetJob()
    local playerGrade = GetJobGrade()
    local jobPermissions = Config[job].Permissions[playerJob]
    local adminPermissions = Config[job].AdminPermissions

    if not playerJob or not jobPermissions then
        return false
    end

    for permissionName, permissionValues in pairs(jobPermissions) do
        permissions[permissionName] = {}

        for permissionType, permissionGrade in pairs(permissionValues) do
            permissions[permissionName][permissionType] = playerGrade >= permissionGrade
        end
    end

    if IsAdmin() and adminPermissions then
        for permissionName, permissionValues in pairs(adminPermissions) do
            permissions[permissionName] = permissions[permissionName] or {}

            for permissionType, hasPermission in pairs(permissionValues) do
                if hasPermission and not permissions[permissionName][permissionType] then
                    debugprint("has permission " .. permissionName .. "." .. permissionType .. " due to being admin")
                    permissions[permissionName][permissionType] = true
                end
            end
        end
    end

    return permissions
end
