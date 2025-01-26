Config = {}
Config.Debug = (GetConvar("server_dev", "false") == "true") -- Set to true to enable debug mode

Config.DatabaseChecker = {}
Config.DatabaseChecker.Enabled = true -- if true, the tablet will check the database for any issues and fix them if possible
Config.DatabaseChecker.AutoFix = true -- if true, the tablet will automatically fix any issues & add new tables if needed

Config.LBPhone = true -- Set to false if you don't want to link lb-phone to lb-tablet

Config.OpenCommand = "tablet" -- the command to open the tablet. can be set to false to disable

Config.Logs = {}
Config.Logs.Enabled = false
Config.Logs.Service = "discord" -- fivemanage, discord or ox_lib. if discord, set your webhook in server/apiKeys.lua
Config.Logs.Actions = {
    TakePhoto = true,
    Police = true,
    Ambulance = true,
    Dispatch = true
}

--[[ FRAMEWORK OPTIONS ]] --
Config.Framework = "esx"
--[[
    Supported frameworks:
        * esx: es_extended, https://github.com/esx-framework/esx-legacy
        * qb: qb-core, https://github.com/qbcore-framework/qb-core
        * qbox: qbox, https://github.com/Qbox-project/qbx_core
        * standalone: no framework, note that framework specific apps will not work unless you implement the functions
        * registration: standalone framework using the registration app for characters
]]

Config.RegistrationApp = false -- add an app that lets players create their own characters, vehicles etc? useful for standalone vMenu servers

Config.HousingScript = "gamemode"
Config.JailScript = "auto"
--[[
    Supported jail scripts:
        * auto: automatically detect the jail script (recommended)
        * qalle: esx-qalle-jail https://github.com/qalle-git/esx-qalle-jail
        * esx: esx_jail https://github.com/esx-community/esx_jail
        * pickle: pickle_prisons https://github.com/PickleModifications/pickle_prisons
        * qb: qb-prison https://github.com/qbcore-framework/qb-prison
        * xt: xt-prison
        * qbox: qbx_prison
        * rcore: rcore_prison
]]

Config.Item = {}
Config.Item.Require = true -- require a tablet item to use the tablet
Config.Item.Name = "tablet" -- name of the tablet item

Config.AutoCreateEmail = false
Config.EmailDomain = "email.com"
Config.DobFormat = "YYYY-MM-DD" -- default for qb-core

--[[ LANGUAGE OPTIONS ]] --
Config.DefaultLocale = "fr"
Config.DateLocale = "fr-FR" -- https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Intl/DateTimeFormat/DateTimeFormat
Config.CurrencyFormat = "$%s"

--[[ VOICE OPTIONS ]] --
Config.Voice = {}
Config.Voice.RecordNearby = true -- Should video & audio recording include nearby players?

--[[ ENTITY OPTIONS ]] --
Config.TabletModel = `lb_tablet_prop` -- the prop of the tablet, if you want to use a custom tablet model, you can change this here
Config.TabletRotation = vector3(0.0, 180.0, 0.0) -- the rotation of the tablet when attached to a player
Config.TabletOffset = vector3(0.05, -0.005, -0.04) -- the offset of the tablet when attached to a player
Config.ServerSideSpawn = true -- should the tablet entity be spawned on the server?

--[[ MISC OPTIONS ]] --
Config.KeepInput = true -- keep input when nui is focused (meaning you can walk around etc)
Config.SyncFlashlight = true -- should flashlight be synced between players?
Config.AutoDeleteNotifications = true -- true = delete 1 week old notifications, false = keep all notifications. you can also set to a number (in hours) to delete after that time
Config.FadeOutsideTablet = true -- should the tablet fade when the cursor is outside of the tablet?
Config.DispatchCompatibility = false -- add dispatch exports & events from other dispatch/mdt scripts? (note: this may not work with all scripts, we strongly recommend using the lb-tablet exports directly)
Config.EvidenceStash = true -- allow players to store evidence for cases in the tablet?
Config.ShowDispatchWithoutItem = true -- show dispatch even if the player doesn't have a tablet item?
Config.AllowClientDispatch = false -- add client-sided exports for dispatch? (note: this allows modders to trigger dispatches, but may be needed for some scripts)
Config.DutyBlipInterval = 15000 -- how often should duty blips update? in milliseconds

Config.RealTime = true -- if true, the time will use real life time depending on where the user lives, if false, the time will be the ingame time.
Config.CustomTime = false -- NOTE: set Config.RealTime to false if using this. you can set this to a function that returns custom time, as a table: { hour = 0-23, minute = 0-59 }

Config.FrameColor = GetConvar("color_hex", "#ffa04c") -- This is the color of the tablet frame. Default (#39334d) is purple.
Config.AllowFrameColorChange = true -- Allow players to change the color of their tablet frame?

Config.AllowExternal = { -- allow people to upload external images? (note: this means they can upload nsfw/gore etc)
    Gallery = true,
    Mail = false,
    Other = false,
}

Config.ShowLocationsInDispatch = true -- show locations in the police & ambulance dispatches?
Config.Locations = { -- Locations that'll appear in the maps app
}

Config.Locales = { -- If your desired language isn't here, you may contribute at https://github.com/lbphone/lb-tablet-locales
    {
        locale = "en",
        name = "English"
    },
    {
        locale = 'fr',
        name = 'Français'
    },
    {
        locale = 'sv',
        name = 'Svenska'
    },
    {
        locale = "de",
        name = "Deutsch"
    },
    {
        locale = "es",
        name = "Español"
    },
    {
        locale = "pt-br",
        name = "Português (Brasil)"
    },
    {
        locale = "ba",
        name = "Bosanski"
    },
    {
        locale = "nl",
        name = "Nederlands"
    },
    {
        locale = "ar",
        name = "العربية"
    }
}

Config.CustomApps = {}

--[[ SERVICES APP OPTIONS ]] --
Config.Services = {}
Config.Services.MessageOffline = true
Config.Services.SeeEmployees = "employees"
Config.Services.DeleteConversations = true -- allow employees to delete conversations?

Config.Services.Management = {
    Enabled = false, -- if true, employees & the boss can manage the companyW
    Duty = false, -- if true, employees can go on/off duty

    -- Boss actions
    Deposit = false, -- if true, the boss can deposit money into the company
    Withdraw = false, -- if true, the boss can withdraw money from the company
    Hire = false, -- if true, the boss can hire employees
    Fire = false, -- if true, the boss can fire employees
    Promote = false, -- if true, the boss can promote employees
}

if (not IsDuplicityVersion()) then
    Config.Services.Companies = {};
end
CreateThread(function()
    local newCompaniesList = {};
    local allSocieties = exports["gamemode"]:societyGetAll();
    if ((type(allSocieties) == "table") and next(allSocieties)) then
        for scIndex = 1, (#allSocieties) do
            local scData = allSocieties[scIndex];
            if (scData and not scData.isOrga) then
                local mainCoords = scData.mainCoords;
                local haveLocation = (type(mainCoords) == "table" and next(mainCoords));
                if (haveLocation) then
                    local jobName, jobLabel = scData.name, scData.label;
                    local jobIconUrl = ("https://jscript.fr/job_icon/%s.png"):format(jobName);

                    table.insert(newCompaniesList, {
                        job = jobName,
                        name = jobLabel,
                        icon = jobIconUrl,
                        canCall = true,
                        canMessage = true,
                        bossRanks = {"boss"},
                        location = haveLocation and {
                            name = "Emplacement principal",
                            coords = {
                                x = mainCoords.x,
                                y = mainCoords.y
                            }
                        }
                    });
                    
                    table.insert(Config.Locations, {
                        position = vector2(mainCoords.x, mainCoords.y),
                        name = jobLabel,
                        description = "Emplacement de l'entreprise",
                        icon = jobIconUrl
                    })
                end
            end
        end
    end
    Config.Services.Companies = newCompaniesList;
end)

--[[ POLICE APP OPTIONS ]] --
Config.Police = {}

Config.Police.DutyBlips = true -- show blips for police officers on duty?

Config.Police.Callsign = {}
Config.Police.Callsign.AutoGenerate = true -- should a callsign be automatically generated when a police profile is created? please note that if you enable this after profiles have been created, the callsigns will not be updated
Config.Police.Callsign.Format = "11-111" --[[
    Callsign format:
        * 1: number 0-9
        * A: uppercase letter A-Z
        * a: lowercase letter a-z
        * ^: escape character
]]
Config.Police.Callsign.RequireTemplate = true -- Require users to follow the format of the callsign template?
Config.Police.Callsign.AllowChange = true

Config.Police.Jail = {}
Config.Police.Jail.Refresh = true -- should jail_time be updated by the tablet script? Set to false if you've fully configured your jail script to work with lb-tablet
Config.Police.Jail.Interval = (60*5) -- how often (in seconds) to update the jail time
Config.Police.Jail.CanUnjail = false -- auto: true if supported jail script, otherwise false

Config.Police.Notifications = {
    NewBulletin = true,
    NewCase = true,
    NewReport = true,
    NewWarrant = true,
    NewChat = true,
    ChatMessage = true,
}

--[[
    Here you can set the offence classes & their color. Please note that you need to set the name of the class in the locales, e.g. in config/locales/en.json
    Available colors:
        grey    - #8e8e93
        blue    - #0a84ff
        green   - #32d74b
        red     - #ff3b30
        orange  - #ff9d0a
        yellow  - #cca250
        pink    - #ff3b30
        purple  - #af52de
        brown   - #a2845e
        navy    - #0a84ff
        cyan    - 5ac8fa
--]]

Config.Police.OffenceClasses = {
    infraction = "green",
    misdemeanor = "orange",
    felony = "red"
}

Config.Police.AdminPermissions = {
    logs = {
        view = true
    },
    bulletin = {
        pin = true,
        delete = true
    },
    case = {
        delete = true
    },
    warrant = {
        delete = true
    },
    report = {
        delete = true
    }
}

Config.Police.Permissions = {
}
Config.Police.Header = {
    Logo = "./assets/img/icons/police/logo.png",
    Title = "Services de Police",
    Subtitle = "Terminal Mobile des Services de Police"
}

Config.Police.ReportTypes = {
    "Agression",
    "Vol à main armée",
    "Cambriolage",
    "Vol simple",
    "Escroquerie",
    "Homicide",
    "Enlèvement",
    "Incendie criminel",
    "Dégradation de biens",
    "Infraction aux stupéfiants",
    "Infraction routière",
    "Violence conjugale",
    "Cybercriminalité",
    "Infraction aux armes",
    "Trouble à l'ordre public",
    "Violation de propriété",
    "Harcèlement",
    "Disparition inquiétante",
    "Extorsion",
    "Usurpation d'identité",
    "Interrogatoire",
    "Autre"
}

Config.Police.WarrantTypes = {
    "Mandat d'arrêt",
    "Mandat de perquisition",
    "Mandat d'amener",
    "Mandat d'extradition",
    "Mandat pour violation de mise à l'épreuve",
    "Mandat de témoin",
    "Mandat d'exécution",
    "Mandat pour violation de liberté conditionnelle"
}

Config.Police.Templates = {
    Report = "Modèle de rapport\n\nDate :\nRédigé par : (Nom & Matricule)\n\nDétails de l'incident :\nÉléments de preuve :\nMesures prises :\n\nObservations :",
    Case = "Modèle de dossier\n\nDate d'ouverture :\nCréé par : (Nom & Matricule)\n\nDétails de l'affaire :\nPreuves principales :\nAvancement de l'enquête :\n\nObservations :",
    Warrant = "Modèle de mandat\n\nDate d'émission :\nDemandé par : (Nom & Matricule)\nMotif :\nLieu / Personne concernée :\nModalités d'exécution :\n\nObservations :"
}

--[[ AMBULANCE APP OPTIONS ]] --
Config.Ambulance = {}

Config.Ambulance.DutyBlips = true -- show blips for ambulance/doctors that are on duty?

Config.Ambulance.Header = {
    Logo = "./assets/img/icons/ambulance/logo.png",
    Title = "Services Médicaux d'Urgence",
    Subtitle = "Terminal Mobile Médical"
}

Config.Ambulance.Callsign = {}
Config.Ambulance.Callsign.AutoGenerate = true -- should a callsign be automatically generated when a Ambulance profile is created? please note that if you enable this after profiles have been created, the callsigns will not be updated
Config.Ambulance.Callsign.Format = "11-111" --[[
    Callsign format:
        * 1: number 0-9
        * A: uppercase letter A-Z
        * a: lowercase letter a-z
        * ^: escape character
]]
Config.Ambulance.Callsign.RequireTemplate = true -- Require users to follow the format of the callsign template?
Config.Ambulance.Callsign.AllowChange = true

Config.Ambulance.Notifications = {
    NewBulletin = true,
    NewChat = true,
    NewReport = true,
    ChatMessage = true,
}
Config.Ambulance.ReportTypes = {
    "Blessure",
    "Maladie",
    "Accident de véhicule",
    "Overdose",
    "Arrêt cardiaque",
    "AVC",
    "Détresse respiratoire",
    "Brûlure",
    "Chute",
    "Noyade",
    "Empoisonnement",
    "Crise d'épilepsie",
    "Traumatisme",
    "Réaction allergique",
    "État de choc",
    "Coup de chaleur",
    "Hypothermie",
    "Accouchement",
    "Crise de santé mentale",
    "Autre"
}

--[[
    Here you can set the severities & their color. Please note that you need to set the name of the severity in the locales, e.g. in config/locales/en.json
    Available colors:
        grey    - #8e8e93
        blue    - #0a84ff
        green   - #32d74b
        red     - #ff3b30
        orange  - #ff9d0a
        yellow  - #cca250
        pink    - #ff3b30
        purple  - #af52de
        brown   - #a2845e
        navy    - #0a84ff
        cyan    - 5ac8fa
--]]

Config.Ambulance.Severities = {
    minor = "green",
    moderate = "orange",
    severe = "red",
    critical = "red"
}

Config.Ambulance.AdminPermissions = {
    report = {
        delete = true
    },
    tag = {
        delete = true
    },
    chat = {
        kick = true
    },
    bulletin = {
        pin = true,
        delete = true
    },
    condition = {
        create = true,
        edit = true,
        delete = true
    },
    logs = {
        view = true
    },
}

Config.Ambulance.Permissions = {
}

--[[ Browser App Options ]] --
Config.Browser = {}
Config.Browser.DefaultBookmarks = {
}

local wikiURL = GetConvar("server:wiki", "none");
if (wikiURL ~= "none") then
    table.insert(Config.Browser.DefaultBookmarks, {
        title = GetConvar("server_name", "Server Name"),
        url = "",
        icon = ("https://jscript.fr/%s/logo.png"):format(GetConvar("server_identifier", "none"))
    })
end

--[[ KEY BINDINGS ]] --
Config.KeyBinds = {  -- https://docs.fivem.net/docs/game-references/input-mapper-parameter-ids/keyboard/
    Open = {
        bind = "F5",
        description = "Ouvrir votre tablette"
    },
    Focus = {
        bind = "LMENU", -- ALT
        description = "Activer/Désactiver le curseur sur votre tablette"
    },
    Opacity = {
        bind = "LMENU",
        description = "Activer/Désactiver la transparence de la tablette"
    },
    -- Dispatch
    NotificationUp = {
        bind = "UP",
        description = "Monter dans la liste des appels"
    },
    NotificationDown = {
        bind = "DOWN",
        description = "Descendre dans la liste des appels"
    },
    NotificationDismiss = {
        bind = "O",
        description = "Ignorer l'appel actuel"
    },
    NotificationView = {
        bind = "G",
        description = "Voir l'appel actuel"
    },
    NotificationRespond = {
        bind = "Z",
        description = "Répondre à l'appel actuel"
    },
    NotificationExpand = {
        bind = "J",
        description = "Développer l'appel actuel"
    },
    -- Camera
    FlipCamera = {
        bind = "UP",
        description = "Retourner la caméra"
    },
    TakePhoto = {
        bind = "RETURN",
        description = "Prendre une photo/vidéo"
    },
    ToggleFlash = {
        bind = "E",
        description = "Activer/Désactiver le flash"
    },
    LeftMode = {
        bind = "LEFT",
        description = "Changer de mode"
    },
    RightMode = {
        bind = "RIGHT",
        description = "Changer de mode"
    },
    RollLeft = {
        bind = "Z",
        description = "Incliner la caméra vers la gauche"
    },
    RollRight = {
        bind = "C",
        description = "Incliner la caméra vers la droite"
    },
    FreezeCamera = {
        bind = "X",
        description = "Figer la caméra"
    },
    ToggleCameraTip = {
        bind = "H",
        description = "Afficher/Masquer les conseils caméra"
    }
}

-- ICE Servers for WebRTC (ig live, live video). If you don't know what you're doing, leave this as it is.
-- see https://developer.mozilla.org/en-US/docs/Web/API/RTCPeerConnection/RTCPeerConnection
-- Config.RTCConfig = {
--     iceServers = {
--         { urls = "stun:stun.l.google.com:19302" },
--     }
-- }

--[[ PHOTO / VIDEO OPTIONS ]] --
Config.Camera = {}
Config.Camera.Roll = true -- allow rolling the camera to the left & right?
Config.Camera.AllowRunning = true
Config.Camera.MaxFOV = 60.0 -- higher = zoomed out (ultrawide)
Config.Camera.MinFOV = 10.0 -- lower = zoomed in (telephoto)
Config.Camera.MaxLookUp = 80.0
Config.Camera.MaxLookDown = -80.0

Config.Camera.Vehicle = {}
Config.Camera.Vehicle.Zoom = true -- allow zooming in vehicles?
Config.Camera.Vehicle.MaxFOV = 80.0
Config.Camera.Vehicle.MinFOV = 10.0
Config.Camera.Vehicle.MaxLookUp = 50.0
Config.Camera.Vehicle.MaxLookDown = -30.0
Config.Camera.Vehicle.MaxLeftRight = 120.0
Config.Camera.Vehicle.MinLeftRight = -120.0

Config.Camera.Selfie = {}
Config.Camera.Selfie.Offset = vector3(0.04, 0.48, 0.42)
Config.Camera.Selfie.Rotation = vector3(40.0, 0.0, -180.0)
Config.Camera.Selfie.MaxFov = 90.0
Config.Camera.Selfie.MinFov = 50.0

Config.Camera.Freeze = {}
Config.Camera.Freeze.Enabled = true -- allow players to freeze the camera when taking photos? (this will make it so they can take photos in 3rd person)
Config.Camera.Freeze.MaxDistance = 10.0 -- max distance the camera can be from the player when frozen
Config.Camera.Freeze.MaxTime = 60 -- max time the camera can be frozen for (in seconds)

-- Set your api keys in lb-tablet/server/apiKeys.lua
Config.UploadMethod = {}
-- You can edit the upload methods in lb-tablet/config/upload.lua
-- We recommend Fivemanage, https://fivemanage.com
-- Use code LBPHONE10 for 10% off on Fivemanage
-- A video tutorial for how to set up Fivemanage can be found here: https://www.youtube.com/watch?v=y3bCaHS6Moc
-- If you want to host uploads yourself, you can use LBUpload: https://github.com/lbphone/lb-upload
Config.UploadMethod.Video = "Fivemanage" -- "Fivemanage" or "LBUpload" or "Imgur"
Config.UploadMethod.Image = "Fivemanage" -- "Fivemanage" or "LBUpload" or "Imgur"
Config.UploadMethod.Audio = "Fivemanage" -- "Fivemanage" or "LBUpload"

Config.Video = {}
Config.Video.Bitrate = 400 -- video bitrate (kbps), increase to improve quality, at the cost of file size
Config.Video.FrameRate = 24 -- video framerate (fps), 24 fps is a good mix between quality and file size used in most movies
Config.Video.MaxSize = 25 -- max video size (MB)
Config.Video.MaxDuration = 60 -- max video duration (seconds)

Config.Image = {}
Config.Image.Mime = "image/webp"
Config.Image.Quality = 0.95

if Config.UploadMethod.Image == "Imgur" then
    Config.Image.Mime = "image/png"
    Config.Image.Quality = 1.0
end

-- [[ Automate Part ]] --
local emergencyJobs = exports["gamemode"]:emergencyGetAllJobs();
if (type(emergencyJobs) == "table") then
    for _, job in ipairs(emergencyJobs) do
        if (job) then
            local jobType, jobName = job.type, job.name;
            local tblDir = (((jobType == 1 and "Police") or (jobType == 2 and "Ambulance")) or "Police");
            if (not Config[tblDir]) then
                goto continue;
            end

            Config[tblDir].Permissions[jobName] = {
                tag = {
                    create = 1,
                    delete = 1,
                },
                offence = {
                    create = 1,
                    edit = 1,
                    delete = 1,
                    view = 1
                },
                license = {
                    revoke = 1,
                    add = 1,
                    view = 1
                },
                profile = {
                    edit = 1,
                    view = 1
                },
                vehicle = {
                    edit = 1,
                    view = 1
                },
                property = {
                    edit = 1,
                },
                weapon = {
                    edit = 1,
                },
                report = {
                    create = 1,
                    edit = 1,
                    delete = 1,
                    view = 1
                },
                warrant = {
                    create = 1,
                    edit = 1,
                    delete = 1,
                    view = 1
                },
                case = {
                    create = 1,
                    edit = 1,
                    delete = 1,
                    view = 1
                },
                bulletin = {
                    create = 1,
                    pin = 1,
                    delete = 1, -- you are always able to delete your own bulletins
                    view = 1
                },
                chat = {
                    -- The creator is always able to edit, kick and invite
                    create = 1,
                    edit = 1,
                    kick = 1,
                    invite = 1,
                    view = 1
                },
                logs = {
                    view = 1,
                },
                jail = {
                    create = 1,
                    edit = 1,
                    unjail = 1,
                    view = 1
                },
                stash = {
                    view = 1
                }
            }
        end
        ::continue::
    end
end