if not charSelectExists then return end

ASHA_ACT_DOUBLE_LARIAT = allocate_mario_action(ACT_FLAG_ATTACKING | ACT_FLAG_INVULNERABLE | ACT_FLAG_MOVING)
ASHA_ACT_RUNNING_LARIAT = allocate_mario_action(ACT_FLAG_ATTACKING | ACT_FLAG_INVULNERABLE | ACT_FLAG_MOVING)
ASHA_ACT_BODY_PRESS = allocate_mario_action(ACT_FLAG_ATTACKING | ACT_FLAG_INVULNERABLE | ACT_FLAG_AIR | ACT_GROUP_AIRBORNE)
--from extra chars plus :3
ACT_PILEDRIVER = allocate_mario_action(ACT_GROUP_AIRBORNE | ACT_FLAG_AIR | ACT_FLAG_ATTACKING | ACT_FLAG_ALLOW_VERTICAL_WIND_ACTION)
ACT_PILEDRIVER_LAND = allocate_mario_action(ACT_GROUP_MOVING | ACT_FLAG_MOVING | ACT_FLAG_ATTACKING)

function act_double_lariat(m)
    init_locals(m)
     -- turn heavy objects into light
    local lariatsound = audio_sample_load("LariatMoves.ogg")
    if m.actionTimer == 0 then
        play_sound(SOUND_ACTION_SPIN, m.marioObj.header.gfx.cameraToObject)
        audio_sample_play(lariatsound, m.marioObj.header.gfx.cameraToObject, 0)
    end
    set_mario_animation(m, MARIO_ANIM_TWIRL)

    local stepResult = perform_ground_step(m)
    if stepResult == GROUND_STEP_LEFT_GROUND then
        m.action = ACT_FREEFALL
    end
    spawn_particle(m, PARTICLE_SPARKLES)
    e.gfxAngleY = e.gfxAngleY + 0x2000
    m.marioObj.header.gfx.angle.y = e.gfxAngleY

    if m.actionTimer > 120 then
        m.invincTimer = 0
        m.actionTimer = 0
        return set_mario_action(m, ACT_IDLE, 0)
    end

    m.actionTimer = m.actionTimer + 1
    return 0
end
hook_mario_action(ASHA_ACT_DOUBLE_LARIAT, act_double_lariat)

function act_piledriver(m)
    if m.actionTimer == 0 then
        play_sound(SOUND_ACTION_SPIN, m.marioObj.header.gfx.cameraToObject)
        play_character_sound(m, CHAR_SOUND_SO_LONGA_BOWSER)
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
    set_mario_animation(m, MARIO_ANIM_FORWARD_KB)

    local stepResult = perform_ground_step(m)

    if stepResult == GROUND_STEP_LEFT_GROUND then
        m.action = ACT_PILEDRIVER
    end

    if (m.input & INPUT_ABOVE_SLIDE) ~= 0 then
        return set_mario_action(m, ACT_BUTT_SLIDE, 0)
    end

    if (m.input & INPUT_UNKNOWN_10) ~= 0 then
        return drop_and_set_mario_action(m, ACT_SHOCKWAVE_BOUNCE, 0)
    end

    if is_anim_past_end(m) then
        return set_mario_action(m, ACT_IDLE, 0)
    end

	m.actionTimer = m.actionTimer + 1
end
hook_mario_action(ACT_PILEDRIVER_LAND, act_flying_body_press_land)

function act_flying_body_press(m)
    if m.actionTimer == 0 then
        play_sound(SOUND_ACTION_SPIN, m.marioObj.header.gfx.cameraToObject)
        play_character_sound(m, CHAR_SOUND_YAHOO)
    end

    m.particleFlags = m.particleFlags | PARTICLE_DUST

    common_air_action_step(m, ACT_JUMP_LAND, CHAR_ANIM_WING_CAP_FLY, AIR_STEP_NONE)

    if buttonZpress then
        local rc = set_mario_action(m, ACT_GROUND_POUND, 0)
        m.actionTimer = 5
        return rc
    end

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