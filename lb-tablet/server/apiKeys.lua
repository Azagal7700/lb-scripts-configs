-- Set your API keys for uploading media here.
-- Please note that the API key needs to match the correct upload method defined in Config.UploadMethod and upload.lua
-- The default upload method is Fivemanage
-- You can get your API keys from https://fivemanage.com/
-- Use code LBPHONE10 for 10% off on Fivemanage
-- A video tutorial for how to set up Fivemanage can be found here: https://www.youtube.com/watch?v=y3bCaHS6Moc

API_KEYS = {
    Video = "0acTxWrh4EU8Gjevk6DzBuxL3nK2KMru",
    Image = "hnG3VljXe5268NfPsua6GGBSaBsX1FbS",
    Audio = "qIy1tqyF4xwbhOsxJ1uTPpDY0NBWjhkE",
}

LOG_WEBHOOKS = {
    Default = "https://discord.com/api/webhooks/1331008613262819358/pYQLGar2F7xpaHBxExJtDer96gk65wqZcTe8g4HSWXpMSzLpBfZ4s9QA11MIGB1dbnMJ",
    Police = "https://discord.com/api/webhooks/1331008652903055391/rdMcYabCR6Xan-HqAtZz0xyo-s4PkEm_zQLsvdB_lCbFTwuD4m7khkf92LdUFHw13lTm",
    Ambulance = "https://discord.com/api/webhooks/1331008692258078720/emM3bCthm0k7ZkYuoY_gJDdMuUYG6IIEvb-nO1KUe1ktJRmlcbiTFVcrTHynLcgCqAdi",
    Dispatch = "https://discord.com/api/webhooks/1331008732141981707/5bn283opaeCW8C_SxAaI24mj3tTzwdIbsh1goI44k-1MsOhmlXAOiUQEs3SLT3bxaYWE"
}

DISCORD_TOKEN = nil -- you can set a discord bot token here to get the players discord avatar for logs
