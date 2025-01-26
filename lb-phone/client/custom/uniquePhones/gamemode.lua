if Config.Item.Inventory ~= "gamemode" or not Config.Item.Unique or not Config.Item.Require then
    return
end

function GetFirstNumber()
    local PHONES_LIST = exports["gamemode"]:GetItemsBy({
        name = Config.Item.Name;
    });

    for PHONE_ID = 1, (#PHONES_LIST) do
        local PHONE_DATA = PHONES_LIST[PHONE_ID];
        if (((type(PHONE_DATA) == "table") and (type(PHONE_DATA["meta"]) == "table")) and type(PHONE_DATA["meta"]["lbPhoneNumber"]) == "string") then
            return PHONE_DATA["meta"]["lbPhoneNumber"];
        end
    end

    return nil;
end

function HasPhoneNumber(phoneNumber)
    local ITEM_DATA = exports["gamemode"]:GetItemBy({
        name = Config.Item.Name,
        meta = {
            lbPhoneNumber = phoneNumber
        };
    });
    debugprint("HasPhoneNumber", "phoneNumber", phoneNumber, (type(ITEM_DATA) == "table"))
    return (type(ITEM_DATA) == "table");
end

RegisterNetEvent("lb-phone:usePhoneItem", function (item_data)
    if (type(item_data) ~= "table" or item_data["name"] ~= Config.Item.Name) then
        return;
    end

    local ITEM_METADATA = item_data["meta"];
    local PHONE_NUMBER = ITEM_METADATA?.lbPhoneNumber

    local PHONE_NUM_IS_NULL = (PHONE_NUMBER == nil);
    local PHONE_NUM_IS_STRING = (not PHONE_NUM_IS_NULL and (type(PHONE_NUMBER) == "string"));
    
    if (PHONE_NUM_IS_NULL or (PHONE_NUM_IS_STRING and (PHONE_NUMBER ~= currentPhone))) then
        SetPhone(PHONE_NUMBER, true);
        if (not PHONE_NUM_IS_NULL) then
            ESX.ShowNotification(("Le téléphone ~b~%s~s~ a été chargé !"):format(FormatNumber(PHONE_NUMBER)));
        end
    end

    ToggleOpen(not phoneOpen)
end)

local waitingAdded = false
RegisterNetEvent("Inventory:onPlayerItemAdded", function (item_data)
    if ((type(currentPhone) == "string" or waitingAdded == true) or (type(item_data) ~= "table" or item_data["name"] ~= Config.Item.Name)) then
        return;
    end

    waitingAdded = true

    local firstNumber = GetFirstNumber()
    SetPhone(firstNumber, true)

    waitingAdded = false
end)

RegisterNetEvent("Inventory:onPlayerItemRemoved", function (item_data)
    if (type(item_data) ~= "table" or item_data["name"] ~= Config.Item.Name) then
        return;
    end

    if (type(currentPhone) == "string" and not HasPhoneItem(currentPhone)) then
        SetPhone()
    end
end)