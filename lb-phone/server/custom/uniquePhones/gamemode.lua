if Config.Item.Inventory ~= "gamemode" or not Config.Item.Unique or not Config.Item.Require then
    return
end

---Function to check if a player has a phone with a specific number
---@param source any
---@param phoneNumber string
---@return boolean
function HasPhoneNumber(source, phoneNumber)
    local ITEM_DATA = exports["gamemode"]:GetItemBy(source, {
        name = Config.Item.Name,
        meta = {
            lbPhoneNumber = phoneNumber
        };
    });
    return (type(ITEM_DATA) == "table");
end

---Function to set a phone number to a player's empty phone item
---@param source number
---@param phoneNumber string
---@return boolean success
function SetPhoneNumber(source, phoneNumber)
    debugprint("setting phone number to", phoneNumber, "for", source)

    local PHONES_LIST = exports["gamemode"]:GetItemsBy(source, { name = Config.Item.Name });
    for PHONE_ID = 1, #PHONES_LIST do
        local PHONE_ITEM = PHONES_LIST[PHONE_ID];
        if (type(PHONE_ITEM) == "table") then
            local CURRENT_META = (PHONE_ITEM["meta"] or {});
            if (CURRENT_META["lbPhoneNumber"] == nil) then
                CURRENT_META["lbPhoneNumber"] = phoneNumber;
                exports["gamemode"]:SetMetaData(source, { itemHash = PHONE_ITEM.itemHash }, CURRENT_META);

                debugprint("set phone number to", PHONE_ITEM.itemHash, phoneNumber, "for", source)    
                return true;
            end
        end
    end

    return false
end

function SetItemName(source, phoneNumber, name)
    local ITEM_DATA = exports["gamemode"]:GetItemBy(source, {
        name = Config.Item.Name,
        meta = {
            lbPhoneNumber = phoneNumber
        };
    });

    if (not (type(ITEM_DATA) == "table")) then
        return false;
    end

    local CURRENT_META = (ITEM_DATA["meta"] or {});
    CURRENT_META["customName"] = name;

    exports["gamemode"]:SetMetaData(source, { itemHash = ITEM_DATA["itemHash"] }, CURRENT_META);
    return true;
end