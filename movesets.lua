if not charSelectExists then return end

ASHA_ACT_DOUBLE_LARIAT = allocate_mario_action(ACT_FLAG_ATTACKING | ACT_GROUP_MOVING | ACT_FLAG_MOVING)
ASHA_ACT_RUNNING_LARIAT = allocate_mario_action(ACT_FLAG_ATTACKING | ACT_GROUP_MOVING | ACT_FLAG_MOVING)
ASHA_ACT_BODY_PRESS = allocate_mario_action(ACT_FLAG_ATTACKING | ACT_FLAG_INVULNERABLE | ACT_FLAG_AIR | ACT_GROUP_AIRBORNE)
ASHA_ACT_BODY_PRESS_LAND = allocate_mario_action(ACT_FLAG_ATTACKING | ACT_FLAG_INVULNERABLE | ACT_GROUP_MOVING | ACT_FLAG_MOVING)
--from extra chars plus :3
ACTS_HOLD_JUMP        = allocate_mario_action(ACT_GROUP_AIRBORNE | ACT_FLAG_AIR | ACT_FLAG_ALLOW_VERTICAL_WIND_ACTION)
ACTS_HOLD_FREEFALL    = allocate_mario_action(ACT_GROUP_AIRBORNE | ACT_FLAG_AIR | ACT_FLAG_ALLOW_VERTICAL_WIND_ACTION)
ACT_PILEDRIVER = allocate_mario_action(ACT_GROUP_AIRBORNE | ACT_FLAG_AIR | ACT_FLAG_ATTACKING | ACT_FLAG_ALLOW_VERTICAL_WIND_ACTION)
ACT_PILEDRIVER_LAND = allocate_mario_action(ACT_GROUP_MOVING | ACT_FLAG_MOVING | ACT_FLAG_ATTACKING)

---@param o Object
local function bhv_shockwave_asha_init(o)
    o.oFlags = OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE | OBJ_FLAG_SET_FACE_ANGLE_TO_MOVE_ANGLE

    o.oDamageOrCoinValue = 4
    o.oNumLootCoins = 0
    o.oHealth = 0
    o.hitboxRadius = 500
    o.hitboxHeight = 80
    o.hurtboxRadius = 60
    o.hurtboxHeight = 80
    o.hitboxDownOffset = 0
    o.oInteractType = 0

    cur_obj_scale(1)
    cur_obj_become_tangible()

    network_init_object(o, true, {})
end

---@param o Object
local function bhv_shockwave_asha_loop(o)
    local m = gMarioStates[network_local_index_from_global(o.globalPlayerIndex)]

    obj_process_attacks(o, bhvAttacks)

    if o.oTimer == 7 then
        obj_mark_for_deletion(o)
    end
end

local id_bhvShockWaveAsha = hook_behavior(nil, OBJ_LIST_DESTRUCTIVE, true, bhv_shockwave_asha_init, bhv_shockwave_asha_loop, "bhvShockWaveAsha")

-- from amy sonic chars, :3
function shockwave_spawn(m)
    local v = {
        x = m.pos.x + sins(m.faceAngle.y) * 1,
        y = m.pos.y,
        z = m.pos.z + coss(m.faceAngle.y) * 1
    }
    spawn_non_sync_object(id_bhvHorStarParticleSpawner, E_MODEL_NONE, v.x, v.y, v.z, nil)
    spawn_non_sync_object(id_bhvMistCircParticleSpawner, E_MODEL_NONE, v.x, v.y, v.z, nil)
    if m.playerIndex == 0 then
        spawn_sync_object(id_bhvShockWaveAsha, E_MODEL_NONE, v.x, v.y, v.z, function(o)
            o.globalPlayerIndex = m.marioObj.globalPlayerIndex
        end)
    end
    play_mario_heavy_landing_sound(m, SOUND_ACTION_TERRAIN_HEAVY_LANDING)
    cur_obj_shake_screen(SHAKE_POS_MEDIUM)
end


function act_double_lariat(m)
    init_locals(m)
     -- turn heavy objects into light
    local lariatsound = audio_sample_load("LariatMoves.ogg")
    if m.actionTimer == 0 then
        play_sound(SOUND_ACTION_SPIN, m.marioObj.header.gfx.cameraToObject)
        audio_sample_play(lariatsound, m.marioObj.header.gfx.cameraToObject, 0)
        m.invincTimer = 80
    end
    set_mario_animation(m, MARIO_ANIM_TWIRL)

    local speed = 9.5
    mario_set_forward_vel(m, speed)
    set_turn_speed(0x800)
    local stepResult = perform_ground_step(m)
    if stepResult == GROUND_STEP_LEFT_GROUND then
        m.action = ACT_FREEFALL
    end
    spawn_particle(m, PARTICLE_SPARKLES)
    e.gfxAngleY = e.gfxAngleY + 0x2000
    m.marioObj.header.gfx.angle.y = e.gfxAngleY

    if m.actionTimer > 80 or not buttonZdown then
        m.invincTimer = 0
        m.actionTimer = 0
        return set_mario_action(m, ACT_IDLE, 0)
    end

    m.actionTimer = m.actionTimer + 1
    return 0
end
hook_mario_action(ASHA_ACT_DOUBLE_LARIAT, act_double_lariat, INT_KICK)

function act_running_lariat(m)
    init_locals(m)

    local lariatsound = audio_sample_load("LariatMoves.ogg")

    if buttonApress then
        m.vel.y = 50.0
        m.invincTimer = 0
        m.actionTimer = 0
        return set_mario_action(m, ASHA_ACT_BODY_PRESS, 0)
    end

     -- turn heavy objects into light

    if m.actionTimer == 0 then
        play_sound(SOUND_ACTION_SPIN, m.marioObj.header.gfx.cameraToObject)
        audio_sample_play(lariatsound, m.marioObj.header.gfx.cameraToObject, 0)
        m.invincTimer = 30
    end
    set_mario_animation(m, MARIO_ANIM_TWIRL)

    local speed = 50.0
    mario_set_forward_vel(m, speed)
    set_turn_speed(0x800)
    local stepResult = perform_ground_step(m)
    if stepResult == GROUND_STEP_LEFT_GROUND then
        m.action = ACT_FREEFALL
    end
    spawn_particle(m, PARTICLE_SPARKLES)
    e.gfxAngleY = e.gfxAngleY + 0x2000
    m.marioObj.header.gfx.angle.y = e.gfxAngleY

    if not buttonZdown then
        m.invincTimer = 0
        m.actionTimer = 0
        return set_mario_action(m, ACT_WALKING, 0)
    end

    m.actionTimer = m.actionTimer + 1
    return 0
end
hook_mario_action(ASHA_ACT_RUNNING_LARIAT, act_running_lariat, INT_KICK)

-- patch for the hold jump for piledriver(also from extra chars plus QwQ)
function acts_hold_jump(m)
    if (m.marioObj.oInteractStatus & INT_STATUS_MARIO_DROP_OBJECT) ~= 0 then
        return drop_and_set_mario_action(m, ACT_FREEFALL, 0)
    end

    if (m.input & INPUT_B_PRESSED) ~= 0 and (m.heldObj and (m.heldObj.oInteractionSubtype & INT_SUBTYPE_HOLDABLE_NPC) ~= 0) then
        return set_mario_action(m, ACT_AIR_THROW, 0)
    end

    if (m.input & INPUT_Z_PRESSED) ~= 0 then
        return set_mario_action(m, ACT_PILEDRIVER, 0)
    end

    play_mario_sound(m, SOUND_ACTION_TERRAIN_JUMP, 0)
    common_air_action_step(m, ACT_HOLD_JUMP_LAND, MARIO_ANIM_JUMP_WITH_LIGHT_OBJ,
                           AIR_STEP_CHECK_LEDGE_GRAB)
    return false
end
hook_mario_action(ACTS_HOLD_JUMP, acts_hold_jump)

function acts_hold_freefall(m)
    local animation = (m.actionArg == 0) and CHAR_ANIM_FALL_WITH_LIGHT_OBJ or CHAR_ANIM_FALL_FROM_SLIDING_WITH_LIGHT_OBJ

    if (m.marioObj.oInteractStatus & INT_STATUS_MARIO_DROP_OBJECT) ~= 0 then
        return drop_and_set_mario_action(m, ACT_FREEFALL, 0)
    end

    if (m.input & INPUT_B_PRESSED) ~= 0 and (m.heldObj and (m.heldObj.oInteractionSubtype & INT_SUBTYPE_HOLDABLE_NPC) ~= 0) then
        return set_mario_action(m, ACT_AIR_THROW, 0)
    end

    if (m.input & INPUT_Z_PRESSED) ~= 0 then
        return set_mario_action(m, ACT_PILEDRIVER, 0)
    end

    common_air_action_step(m, ACT_HOLD_FREEFALL_LAND, animation, AIR_STEP_CHECK_LEDGE_GRAB)
    return false
end
hook_mario_action(ACTS_HOLD_FREEFALL, acts_hold_freefall)

function act_piledriver(m)
    if m.actionTimer == 0 then
        play_sound(SOUND_ACTION_SPIN, m.marioObj.header.gfx.cameraToObject)
    end
    set_mario_animation(m, MARIO_ANIM_GRAB_BOWSER)

    local stepResult = perform_air_step(m, 0)
    update_air_without_turn(m)
    if stepResult == AIR_STEP_LANDED then
        if should_get_stuck_in_ground(m) ~= 0 then
            queue_rumble_data_mario(m, 5, 80)
            play_sound(SOUND_MARIO_OOOF2, m.marioObj.header.gfx.cameraToObject)
            m.particleFlags = m.particleFlags | PARTICLE_MIST_CIRCLE
            set_mario_action(m, ACT_BUTT_STUCK_IN_GROUND, 0)
        else
            play_mario_heavy_landing_sound(m, SOUND_ACTION_TERRAIN_HEAVY_LANDING)
            if check_fall_damage(m, ACT_HARD_BACKWARD_GROUND_KB) == 0 then
                m.particleFlags = m.particleFlags | PARTICLE_MIST_CIRCLE | PARTICLE_HORIZONTAL_STAR
                -- set facing direction
                -- not part of original Extended Moveset
                m.faceAngle.y = m.intendedYaw
                return set_mario_action(m, ACT_PILEDRIVER_LAND, 0)
            end
        end
    end

    if m.vel.y >= 0 then
        m.angleVel.y = 0
        m.marioObj.header.gfx.angle.y = m.faceAngle.y
    else
        m.angleVel.y = m.angleVel.y + math.abs(m.vel.y) * 0x100
        m.marioObj.header.gfx.angle.y = m.marioObj.header.gfx.angle.y + m.angleVel.y
        m.particleFlags = m.particleFlags | PARTICLE_DUST
    end
    m.actionTimer = m.actionTimer + 1
    return 0
end

hook_mario_action(ACT_PILEDRIVER, act_piledriver)

function act_piledriver_land(m)
    if m.actionTimer == 0 then
        m.invincTimer = 2
        spawn_explosion(m, PARTICLE_MIST_CIRCLE)
    end
    set_mario_animation(m, MARIO_ANIM_SWINGING_BOWSER)

    local stepResult = perform_ground_step(m)

    if stepResult == GROUND_STEP_LEFT_GROUND then
        m.action = ACT_PILEDRIVER
    end

    -- A debuff so that players can't just bounce up slides.
    if (m.input & INPUT_ABOVE_SLIDE) ~= 0 then
        return set_mario_action(m, ACT_BUTT_SLIDE, 0)
    end

    if (m.input & INPUT_UNKNOWN_10) ~= 0 then
        return drop_and_set_mario_action(m, ACT_SHOCKWAVE_BOUNCE, 0)
    end

    if m.actionTimer > 2 then return set_mario_action(m, ACT_RELEASING_BOWSER, 0) end

	m.actionTimer = m.actionTimer + 1
end

hook_mario_action(ACT_PILEDRIVER_LAND, act_piledriver_land, INT_GROUND_POUND_OR_TWIRL)

function act_flying_body_press_land(m)
    if m.actionTimer == 0 then
        shockwave_spawn(m)
        play_mario_heavy_landing_sound(m, SOUND_ACTION_TERRAIN_HEAVY_LANDING)
    end
    set_mario_animation(m, MARIO_ANIM_FORWARD_KB)


    local stepResult = perform_ground_step(m)
    mario_set_forward_vel(m, 0)

    if stepResult == GROUND_STEP_LEFT_GROUND then
        m.action = ACT_PILEDRIVER
    end

    if (m.input & INPUT_ABOVE_SLIDE) ~= 0 then
        return set_mario_action(m, ACT_BUTT_SLIDE, 0)
    end

    if m.actionTimer > 30 then return set_mario_action(m, ACT_IDLE, 0) end

	m.actionTimer = m.actionTimer + 1
    return 0
end
hook_mario_action(ASHA_ACT_BODY_PRESS_LAND, act_flying_body_press_land)

function act_flying_body_press(m)
    if m.actionTimer == 0 then
        play_sound(SOUND_ACTION_SPIN, m.marioObj.header.gfx.cameraToObject)
        play_character_sound(m, CHAR_SOUND_YAHOO)
    end
    set_mario_animation(m, MARIO_ANIM_AIR_FORWARD_KB)

    m.particleFlags = m.particleFlags | PARTICLE_DUST

    local air = perform_air_step(m, 0)
    update_air_without_turn(m)
    if air == AIR_STEP_LANDED then
        return set_mario_action(m, ASHA_ACT_BODY_PRESS_LAND, 0)
    end
    if air == AIR_STEP_HIT_WALL then
        return set_mario_action(m, ACT_HARD_BACKWARD_AIR_KB, 0)
    end


    if buttonZpress then
        local rc = set_mario_action(m, ACT_GROUND_POUND, 0)
        m.actionTimer = 5
        return rc
    end
    m.actionTimer = m.actionTimer + 1
    return 0
end
hook_mario_action(ASHA_ACT_BODY_PRESS, act_flying_body_press)

function asha_before_phys_step(m)
    local hScale = 1.0
    local vScale = 1.0

    -- faster holding item
    if m.action == ACT_HOLD_WALKING then
        hScale = hScale * 2
    end

    m.vel.x = m.vel.x * hScale
    m.vel.z = m.vel.z * hScale
end

function on_set_action_a(m)
    init_locals(m)

    if m.action == ACT_HOLD_JUMP then
        m.action = ACTS_HOLD_JUMP
    end

    if m.action == ACT_HOLD_FREEFALL then
        m.action = ACTS_HOLD_FREEFALL
    end

    if m.action == ACT_SLIDE_KICK then
        m.action = ASHA_ACT_RUNNING_LARIAT
    end
    
end

---comment
---@param m MarioState
local function update_asha(m)
    init_locals(m)
     -- turn heavy objects into light
    if m.action == ACT_HOLD_HEAVY_IDLE then
        return set_mario_action(m, ACT_HOLD_IDLE, 0)
    end

    if m.action == ACT_GROUND_POUND_LAND then
        set_camera_shake_from_point(SHAKE_POS_MEDIUM, m.pos.x, m.pos.y, m.pos.z)
    end

    if m.action == ACT_PUNCHING and m.prevAction == ACT_CROUCHING then
        set_mario_action(m, ASHA_ACT_DOUBLE_LARIAT, 0)
    end

end
charSelect.character_hook_moveset(CHAR_ASHA, HOOK_MARIO_UPDATE, update_asha)
charSelect.character_hook_moveset(CHAR_ASHA, HOOK_ON_SET_MARIO_ACTION, on_set_action_a)
charSelect.character_hook_moveset(CHAR_ASHA, HOOK_BEFORE_PHYS_STEP, asha_before_phys_step)
