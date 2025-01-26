---@param source number
---@param job "Police" | "Ambulance"
---@param permission string
---@param permissionType string
---@return boolean
function HasPermission(source, job, permission, permissionType) -- TODO: Make it
    local playerJob = GetJob(source)
    local jobPermissions = Config[job].Permissions[playerJob.name]

    if not playerJob or not jobPermissions then
        return false
    end

    if not jobPermissions[permission] or not jobPermissions[permission][permissionType] then
        infoprint("warning", ("Permission %s.%s does not exist"):format(permission, permissionType))
        return false
    end

    if playerJob.grade >= jobPermissions[permission][permissionType] then
        return true
    end

    if IsAdmin(source) and Config[job].adminPermissions?[permission]?[permissionType] then
        debugprint("Player has permission due to being admin")
        return true
    end

    return false
end

local charsetsToCollation = {
    ["UTF8MB4"] = "COLLATE UTF8MB4_UNICODE_CI",
    ["UTF8MB3"] = "COLLATE UTF8MB3_UNICODE_CI",
}

---@param tables { [string]: string }
---@return { [string]: string }
function GetCollationsForTables(tables)
    local collations = {}
    local databaseInfo = MySQL.single.await("SELECT DATABASE() AS `name`, VERSION() as `version`")

    for tableName, _ in pairs(tables) do
        collations[tableName] = ""
    end

    if not databaseInfo or not databaseInfo.name or not databaseInfo.version then
        return collations
    end

    if not databaseInfo.version:find("MariaDB") then
        return collations
    end

    local major, minor, patch = databaseInfo.version:match("(%d+)%.(%d+)%.(%d+)")

    major = major and tonumber(major)
    minor = minor and tonumber(minor)
    patch = patch and tonumber(patch)

    if not major or not minor or not patch then
        return collations
    end

    if major < 10 or (major == 10 and minor < 11) then
        return collations
    end

    local function GetCharset(tableName, columnName)
        local charset = MySQL.scalar.await([[
            SELECT
                CHARACTER_SET_NAME
            FROM INFORMATION_SCHEMA.COLUMNS
            WHERE
                TABLE_SCHEMA = ?
                AND TABLE_NAME = ?
                AND COLUMN_NAME = ?
        ]], { databaseInfo.name, tableName, columnName }) or "utf8mb4"

        return string.upper(charset)
    end


    for tableName, column in pairs(tables) do
        local charset = GetCharset(tableName, column)

        if charsetsToCollation[charset] then
            collations[tableName] = charsetsToCollation[charset]
        else
            debugprint("Unknown charset for " .. tableName, "table:", charset)
        end
    end

    return collations
end
