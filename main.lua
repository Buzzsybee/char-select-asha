-- name: [CS] Asha the Crocodile
-- description: A wrestling crocodile that wants to take on the whole world!

local TEXT_MOD_NAME = "[CS] Asha"

if not _G.charSelectExists then
    djui_popup_create("\\#ffffdc\\\n"..TEXT_MOD_NAME.."\nRequires the Character Select Mod\nto use as a Library!\n\nPlease turn on the Character Select Mod\nand Restart the Room!", 6)
    return 0
end

local E_MODEL_ASHA = smlua_model_util_get_id("asha_geo")
--local ICON_ASHA= get_texture_info("asha_icon")
--local ASHA_GRAFFITI = get_texture_info("asha_graffiti")

local PALETTE_ASHA = {
    [PANTS]  = "FFFFFF",
    [SHIRT]  = "FFFFFF",
    [GLOVES] = "FFFFFF",
    [SHOES]  = "FFFFFF",
    [HAIR]   = "FFFFFF",
    [SKIN]   = "FFFFFF",
    [CAP]    = "FFFFFF",
	[EMBLEM] = "FFFFFF"
}

anims = {
    [charSelect.CS_ANIM_MENU] = 'CHAR_MENU_ANIM'
}

_G.charSelect.character_add_palette_preset(E_MODEL_ASHA, PALETTE_ASHA)


CHAR_ASHA = _G.charSelect.character_add(
    "Asha the Crocodile", -- Character Name
    "A wrestling crocodile that wants to take on the whole world!", -- Description
    "Honi", -- Credits
    "FFFFFF",           -- Menu Color
    E_MODEL_ASHA,       -- Character Model
    CT_MARIO,           -- Override Character
    ICON_ASHA, -- Life Icon
    1.2                  -- Camera Scale
)

--if anims then charSelect.character_add_animations(E_MODEL_ASHA, anims) end
--charSelect.character_add_graffiti(CHAR_ASHA, ASHA_GRAFFITI)