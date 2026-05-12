-- name: [CS] Asha The Crocodile
-- description: A wrestling crocodile that wants to take on the whole world!

local TEXT_MOD_NAME = "[CS] Asha"

if not _G.charSelectExists then
    djui_popup_create("\\#ffffdc\\\n"..TEXT_MOD_NAME.."\nRequires the Character Select Mod\nto use as a Library!\n\nPlease turn on the Character Select Mod\nand Restart the Room!", 6)
    return 0
end

local E_MODEL_ASHA = smlua_model_util_get_id("asha_geo")
local ICON_ASHA= get_texture_info("asha_icon")
local ASHA_GRAFFITI = get_texture_info("asha_graffiti")

local PALETTE_ASHA = {
    [PANTS]  = "1F1E1E",
    [SHIRT]  = "AD5376",
    [GLOVES] = "FFFFFF",
    [SHOES]  = "FFFFFF",
    [HAIR]   = "261713",
    [SKIN]   = "A7BD5A",
    [CAP]    = "353131",
	[EMBLEM] = "FFFFFF"
}

local PALETTE_ASHA_HUGO = {
    [PANTS]  = "9e3965",
    [SHIRT]  = "ff51aa",
    [GLOVES] = "FFFFFF",
    [SHOES]  = "FFFFFF",
    [HAIR]   = "1F1E1E",
    [SKIN]   = "ffbd87",
    [CAP]    = "353131",
    [EMBLEM] = "FFFFFF"
}
_G.charSelect.character_add_palette_preset(E_MODEL_ASHA, PALETTE_ASHA, "Default")
_G.charSelect.character_add_palette_preset(E_MODEL_ASHA, PALETTE_ASHA_HUGO, "Hugo")

anims = {
    [charSelect.CS_ANIM_MENU] = 'ASHA_MENU_POSE'
}

local VOICETABLE_ASHA = {
    [CHAR_SOUND_OKEY_DOKEY] =        'CharStartGame.ogg', -- Starting game
	[CHAR_SOUND_LETS_A_GO] =         'CharStartLevel.ogg', -- Starting level
	[CHAR_SOUND_GAME_OVER] =         'CharLeaveLevel.ogg', -- Game Overed
	[CHAR_SOUND_PUNCH_YAH] =         'CharPunch1.ogg', -- Punch 1
	[CHAR_SOUND_PUNCH_WAH] =         'CharPunch2.ogg', -- Punch 2
	[CHAR_SOUND_PUNCH_HOO] =         'CharPunch3.ogg', -- Punch 3
	[CHAR_SOUND_YAH_WAH_HOO] =       {'CharJump1.ogg', 'CharJump2.ogg', 'CharJump3.ogg'}, -- First Jump Sounds
	[CHAR_SOUND_HOOHOO] =            'CharDoubleJump.ogg', -- Second jump sound
	[CHAR_SOUND_YAHOO_WAHA_YIPPEE] = {'CharTripleJump1.ogg', 'CharTripleJump2.ogg'}, -- Triple jump sounds
	[CHAR_SOUND_UH] =                'CharBonkSoft.ogg', -- Soft wall bonk
	[CHAR_SOUND_UH2] =               'CharLedgeGetUp.ogg', -- Quick ledge get up
	[CHAR_SOUND_UH2_2] =             'CharLongJumpLand.ogg', -- Landing after long jump
	[CHAR_SOUND_DOH] =               'CharBonk.ogg', -- Hard wall bonk
	[CHAR_SOUND_OOOF] =              'CharBonk.ogg', -- Attacked in air
	[CHAR_SOUND_OOOF2] =             'CharBonk.ogg', -- Land from hard bonk
	[CHAR_SOUND_HAHA] =              'CharTripleJumpLand.ogg', -- Landing triple jump
	[CHAR_SOUND_HAHA_2] =            'CharWaterLanding.ogg', -- Landing in water from big fall
	[CHAR_SOUND_YAHOO] =             'CharLongJump.ogg', -- Long jump
	[CHAR_SOUND_DOH] =               'CharBonk.ogg', -- Long jump wall bonk
	[CHAR_SOUND_WHOA] =              'CharGrabLedge.ogg', -- Grabbing ledge
	[CHAR_SOUND_EEUH] =              'CharClimbLedge.ogg', -- Climbing over ledge
	[CHAR_SOUND_WAAAOOOW] =          'CharFalling.ogg', -- Falling a long distance
	[CHAR_SOUND_TWIRL_BOUNCE] =      'CharFlowerBounce.ogg', -- Bouncing off of a flower spring
	[CHAR_SOUND_GROUND_POUND_WAH] =  'CharGroundPound.ogg', -- Ground Pound after startup
	[CHAR_SOUND_WAH2] =              'CharThrow.ogg', -- Throwing something
	[CHAR_SOUND_HRMM] =              'CharLift.ogg', -- Lifting something
	[CHAR_SOUND_HERE_WE_GO] =        'CharGetStar.ogg', -- Star get
	[CHAR_SOUND_SO_LONGA_BOWSER] =   'CharThrowBowser.ogg', -- Throwing Bowser
--DAMAGE
	[CHAR_SOUND_ATTACKED] =          'CharDamaged.ogg', -- Damaged
	[CHAR_SOUND_PANTING] =           'CharPanting.ogg', -- Low health
	[CHAR_SOUND_PANTING_COLD] =      'CharPanting.ogg', -- Getting cold
	[CHAR_SOUND_ON_FIRE] =           'CharBurned.ogg', -- Burned
--SLEEP SOUNDS
	[CHAR_SOUND_IMA_TIRED] =         'CharTired.ogg', -- Mario feeling tired
	[CHAR_SOUND_YAWNING] =           'CharYawn.ogg', -- Mario yawning before he sits down to sleep
	[CHAR_SOUND_SNORING1] =          'CharSnore.ogg', -- Snore Inhale
	[CHAR_SOUND_SNORING2] =           nil, -- Exhale
	[CHAR_SOUND_SNORING3] =           nil, -- Sleep talking / mumbling
--COUGHING (USED IN THE GAS MAZE)
	[CHAR_SOUND_COUGHING1] =         'CharCough1.ogg', -- Cough take 1
	[CHAR_SOUND_COUGHING2] =         'CharCough2.ogg', -- Cough take 2
	[CHAR_SOUND_COUGHING3] =         'CharCough3.ogg', -- Cough take 3
--DEATH
	[CHAR_SOUND_DYING] =             'CharDying.ogg', -- Dying from damage
	[CHAR_SOUND_DROWNING] =          'CharDrowning.ogg', -- Running out of air underwater
	[CHAR_SOUND_MAMA_MIA] =          'CharGameOver.ogg' -- Booted out of level
}

local CAPS_ASHA = {
    normal = smlua_model_util_get_id("asha_cap_geo"),
    wing = smlua_model_util_get_id("asha_wingcap_geo"),
    metal = smlua_model_util_get_id("asha_metalcap_geo"),
}


CHAR_ASHA = _G.charSelect.character_add(
    "Asha The Crocodile", -- Character Name
    "A wrestling crocodile that wants to take on the whole world!", -- Description
    "Honi", -- Credits
    "00AF03",           -- Menu Color
    E_MODEL_ASHA,       -- Character Model
    CT_MARIO,           -- Override Character
    ICON_ASHA, -- Life Icon
    1.4                  -- Camera Scale
)

if anims then charSelect.character_add_animations(E_MODEL_ASHA, anims) end
charSelect.character_add_voice(E_MODEL_ASHA, VOICETABLE_ASHA)
charSelect.character_add_graffiti(CHAR_ASHA, ASHA_GRAFFITI)
charSelect.character_add_caps(E_MODEL_ASHA, CAPS_ASHA)
