-----------------------------------------------------------------------------------------------------------------------------------
--                                       ONLY EDIT THIS FILE IF YOU KNOW WHAT YOU ARE DOING                                      --
--                                         WE WILL NOT HELP YOU, OR ANSWER ANY QUESTIONS                                         --
-----------------------------------------------------------------------------------------------------------------------------------

UploadMethods = {
    Custom = {
        Video = {
            url = "https://your-custom-url.com/upload?api=API_KEY",
            field = "file", -- The field name (formData)
            headers = { -- headers to send when uploading
                ["Authorization"] = "Key API_KEY"
            },
            error = {
                path = "success", -- The path to the error value (res.success)
                value = false -- If the path is equal to this value, it's an error
            },
            success = {
                path = "url" -- The path to the video file (res.url)
            },
            suffix = "webm", -- Add a suffix to the url (not needed if you return the correct name)
        },
        Image = {
            url = "https://your-custom-url.com/upload?api=API_KEY",
            field = "file", -- The field name (formData)
            headers = { -- headers to send when uploading
                ["Authorization"] = "Key API_KEY"
            },
            error = {
                path = "success", -- The path to the error value (res.success)
                value = false -- If the path is equal to this value, it's an error
            },
            success = {
                path = "url" -- The path to the image file (res.url)
            },
            suffix = "png", -- Add a suffix to the url (not needed if you return the correct name)
        },
        Audio = {
            url = "https://your-custom-url.com/upload?api=API_KEY",
            field = "file", -- The field name (formData)
            headers = { -- headers to send when uploading
                ["Authorization"] = "Key API_KEY"
            },
            error = {
                path = "success", -- The path to the error value (res.success)
                value = false -- If the path is equal to this value, it's an error
            },
            success = {
                path = "url" -- The path to the audio file (res.url)
            },
            suffix = "mp3", -- Add a suffix to the url (not needed if you return the correct name)
        },
    },
    Fivemanage = {
        Video = {
            url = "https://api.fivemanage.com/api/video",
            field = "video",
            headers = {
                ["Authorization"] = "API_KEY"
            },
            success = {
                path = "url"
            },
        },
        Image = {
            url = "https://api.fivemanage.com/api/image",
            field = "image",
            headers = {
                ["Authorization"] = "API_KEY"
            },
            success = {
                path = "url"
            }
        },
        Audio = {
            url = "https://api.fivemanage.com/api/audio",
            field = "recording",
            headers = {
                ["Authorization"] = "API_KEY"
            },
            success = {
                path = "url"
            }
        },
    },
    LBUpload = {
        Video = {
            url = "https://BASE_URL/lb-upload/",
            field = "file",
            headers = {
                ["Authorization"] = "API_KEY"
            },
            error = {
                path = "success",
                value = false
            },
            success = {
                path = "link"
            },
        },
        Image = {
            url = "https://BASE_URL/lb-upload/",
            field = "file",
            headers = {
                ["Authorization"] = "API_KEY"
            },
            error = {
                path = "success",
                value = false
            },
            success = {
                path = "link"
            },
        },
        Audio = {
            url = "https://BASE_URL/lb-upload/",
            field = "file",
            headers = {
                ["Authorization"] = "API_KEY"
            },
            error = {
                path = "success",
                value = false
            },
            success = {
                path = "link"
            },
        },
    },
}
