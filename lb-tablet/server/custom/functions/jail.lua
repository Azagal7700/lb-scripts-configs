if not Config.Police.Jail?.Refresh then
    return
end

local interval = (Config.Police.Jail.Interval or 60) * 1000

Wait(5000)

local function UpdateJailTimes()
    debugprint("Updating jail time remaining...")

    MySQL.update([[
        UPDATE
            lbtablet_police_jail
        SET
            jail_time = GREATEST(
                original_time - LEAST(
                    TIMESTAMPDIFF(SECOND, jailed_at, NOW()),
                    original_time
                ),
                0
            )

        WHERE jail_time > 0
    ]], {}, function()
        debugprint("Jail time updated.")
    end)
end

SetInterval(UpdateJailTimes, interval)
