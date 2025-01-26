---@param officer [number, string, string?, string?, [ number, number ], number, boolean ]
---@return StrippedOfficer
local function FormatOfficer(officer)
    ---@type StrippedOfficer
    return {
        source = officer[1],
        name = officer[2],
        callsign = officer[3],
        avatar = officer[4],
        coords = vector2(officer[5][1], officer[5][2]),
        heading = officer[6],
        inVehicle = officer[7]
    }
end

---@param event string
---@param nuiEvent string
---@param hasJob fun(): boolean
function RegisterDutyBlipsListener(event, nuiEvent, hasJob)
    ---@param officerBlips StrippedOfficer
    RegisterNetEvent(event, function(officerBlips)
        if not hasJob() then
            debugprint(event .. ": does not have job")
            return
        end

        local formattedOfficers = {}
        local playerSource = GetPlayerServerId(PlayerId())

        for i = 1, #officerBlips do
            local officer = FormatOfficer(officerBlips[i])

            if officer.source ~= playerSource then
                formattedOfficers[#formattedOfficers+1] = officer
            end
        end

        SendReactMessage(nuiEvent, formattedOfficers)
    end)
end
