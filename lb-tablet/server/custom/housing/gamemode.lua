if Config.HousingScript ~= "gamemode" then
    return
end

local selectPropertyQuery = ""
local searchPropertiesQuery = ""

selectPropertyQuery = [[
    SELECT
        p.identifier,
        p.propertyId,
        CONCAT(JSON_UNQUOTE(JSON_EXTRACT(u.identity, '$.firstname')), ' ', JSON_UNQUOTE(JSON_EXTRACT(u.identity, '$.lastname'))) AS `name`

    FROM property p

    LEFT JOIN users u
        ON u.identifier = p.identifier
]]

searchPropertiesQuery = selectPropertyQuery .. [[
    WHERE
        CONCAT(JSON_UNQUOTE(JSON_EXTRACT(u.identity, '$.firstname')), ' ', JSON_UNQUOTE(JSON_EXTRACT(u.identity, '$.lastname'))) LIKE ?
        OR p.propertyId LIKE ?

    LIMIT ?, ?
]]

local function EncodePropertyId(owner, id)
    return "owner:" .. owner .. ",id:" .. id
end

local function DecodePropertyId(id)
    local owner, propertyId = string.match(id, "owner:(.+),id:([^,]+)$")

    return owner, propertyId and tonumber(propertyId)
end

local function FormatPropery(property)
    local propertyData = exports["gamemode"]:propertyGetFromId(property.propertyId)

    property.label = propertyData?.label or property.propertyId
    property.id = EncodePropertyId(property.identifier, property.propertyId)

    property.owner = {
        name = property.name,
        identifier = property.identifier
    }

    property.name = nil
    property.propertyId = nil

    if propertyData?.position then
        debugprint("Setting property location", propertyData.position.x, propertyData.position.y)
        property.location = {
            x = propertyData.position.x,
            y = propertyData.position.y
        }
    end

    debugprint("Formatted property", property)
    return property
end

---@param query string
---@param page? number
---@return table[]
function SearchProperties(query, page)
    query = "%" .. query .. "%"

    local properties = MySQL.query.await(
        searchPropertiesQuery,
        { query, query, (page or 0) * 10, 10 }
    )

    for i = 1, #properties do
        properties[i] = FormatPropery(properties[i])
    end

    return properties
end

function GetProperty(id)
    local owner, propertyId = DecodePropertyId(id)

    if not owner or not propertyId then
        debugprint("Failed to decode property id", id)
        return
    end

    local property = MySQL.single.await(
        selectPropertyQuery .. " WHERE p.identifier = ? AND p.propertyId = ?",
        { owner, propertyId }
    )

    if not property then
        return
    end

    return FormatPropery(property)
end

---@param identifier string
---@return { id: string, label: string }[]
function GetPlayerProperties(identifier)
    local properties = MySQL.query.await("SELECT identifier, propertyId FROM property WHERE identifier = ?", { identifier })

    for i = 1, #properties do
        local property = properties[i]
        local propertyData = exports["gamemode"]:propertyGetFromId(property.propertyId)

        properties[i] = {
            id = EncodePropertyId(property.identifier, property.propertyId),
            label = propertyData?.label or property.propertyId
        }
    end

    return properties
end
