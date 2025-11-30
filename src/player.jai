SPELL_SLOTS_COUNT :: 3;

PlayerInputType :: enum
{
    NONE;
    GAMEPAD;
    KEYBOARD_MOUSE;
}

Player :: struct
{
    input_type: PlayerInputType;
    gamepad: *Gamepad;
    controlled_actor: *Actor;
    cast_target: *Actor;
    cast_position: Vector2;
    attack_target: *Actor;
    last_attack_direction: Vector2;

    spell_slots: [SPELL_SLOTS_COUNT]*SpellDefinition;
    spell_swatches: [SPELL_SLOTS_COUNT]AsepriteAnimationPlayer;
    spell_index: = 0;
    spell_change_cooldown: float = 0;
    spellcaster: SpellCaster;
}

player_init :: (using player: *Player)
{
    input_type = .NONE;
    gamepad = null;
    spell_index = 0;
    spellcaster = .{};
    last_attack_direction = .{1, 0};
}

player_shutdown :: (using player: *Player)
{
    set_controlled_actor(player, null);
    for i: 0..spell_slots.count-1
    {
        spell_slots[i] = null;
    }
}

player_update :: (using player: *Player, dt: float)
{
    player_update_spells(player, dt);
    player_update_actor(player, dt);

    should_restart: bool;

    // Restart game
    if input_type ==
    {
        case .GAMEPAD;
        {
            if 
                is_gamepad_down(.LEFT_STICK_CLICK) && is_gamepad_pressed(.RIGHT_STICK_CLICK) ||
                is_gamepad_pressed(.LEFT_STICK_CLICK) && is_gamepad_down(.RIGHT_STICK_CLICK)
            {
                should_restart = true;
            }
        }

        case .KEYBOARD_MOUSE;
        {
            should_restart = is_down(.CTRL) && is_pressed(#char "r");
        }
    }
    if should_restart
    {
        game_request_restart();
    }
}

player_update_spells :: (using player: *Player, dt: float)
{
    spell_scroll: s32;
    if input_type ==
    {
        case .GAMEPAD;
        {
            if is_gamepad_pressed(.LEFT_SHOULDER) spell_scroll -= 1;
            if is_gamepad_pressed(.RIGHT_SHOULDER) spell_scroll += 1;
        }

        case .KEYBOARD_MOUSE;
        {
            if mouse_delta_z != 0
            {
                spell_scroll = xx sign(mouse_delta_z);
            }
        }
    }
    if spell_change_cooldown <= 0
    {
        if spell_scroll != 0
        {
            if spell_scroll > 0
            {
                select_next_spell(player);
            }
            else
            {
                select_previous_spell(player);
            }
            spell_change_cooldown = 0.12;
        }
    }
    else
    {
        spell_change_cooldown -= dt;
    }

    spellcaster.definition = spell_slots[spell_index];

    for i: 0..spell_slots.count-1
    {
        spell_swatch: = *spell_swatches[i];
        if spell_slots[i] != null
        {
            animation_player_play(spell_swatch, spell_slots[i].icon);
        }
        else
        {
            animation_player_play(spell_swatch, .{"icons_aseprite", "empty"});
        }
        animation_player_update(spell_swatch, dt);
    }
}

player_update_actor :: (using player: *Player, dt: float)
{
    if !can_control_actor(controlled_actor) return;

    move_input: Vector2;

    do_attack: bool;
    attack_position: Vector2;

    begin_cast_spell: bool;
    end_cast_spell: bool;
    cancel_cast_spell: bool;
    cast_target = null;
    attack_target = null;

    cast_origin: = controlled_actor.position.xy + controlled_actor.definition.cast_position;

    if input_type ==
    {
        case .GAMEPAD;
        {
            move_input = player.gamepad.left_stick;

            #if GAMEPAD_TWIN_STICK
            {
                begin_cast_spell = is_gamepad_pressed(player.gamepad, .RIGHT_TRIGGER);
                end_cast_spell = is_gamepad_released(player.gamepad, .RIGHT_TRIGGER);
                cancel_cast_spell = is_gamepad_pressed(player.gamepad, .B);

                if actor_is_casting(controlled_actor)
                {
                    cast_position += player.gamepad.right_stick * CAST_TARGETTING_SPEED * dt;
                }
                else
                {
                    if length_squared(player.gamepad.right_stick) > 0
                    {
                        do_attack = true;
                        cast_position = cast_origin + normalize(player.gamepad.right_stick) * 10;
                        attack_position = cast_position;
                    }
                    else
                    {
                        cast_position = cast_origin;
                    }
                }
            }
            else
            {
                do_attack = is_gamepad_down(player.gamepad, .X);
                begin_cast_spell = is_gamepad_pressed(player.gamepad, .RIGHT_TRIGGER);
                end_cast_spell = is_gamepad_pressed(player.gamepad, .X);
                cancel_cast_spell = is_gamepad_released(player.gamepad, .RIGHT_TRIGGER);

                if actor_is_casting(controlled_actor)
                {
                    cast_position += player.gamepad.left_stick * CAST_TARGETTING_SPEED * dt;
                }
                else
                {
                    cast_position = cast_origin;

                    // Attack
                    proximity_target_range: = controlled_actor.definition.attack_range + 10;
                    proximity_targets: = physics_cast_circle(controlled_actor.position.xy, proximity_target_range, .[PHYSIC_LAYER_BODY]);
                    proximity_target: = get_closest_actor(controlled_actor.position.xy, proximity_targets, player, (actor: *Actor, user_data: *void) -> bool
                    {
                        player: = user_data.(*Player);
                        if player.controlled_actor == actor return false;
                        return true;
                    });

                    if proximity_target != null
                    {
                        attack_position = proximity_target.position.xy;
                        attack_target = proximity_target;
                    }
                    else
                    {
                        attack_direction: = last_attack_direction;
                        if length_squared(move_input) > 0
                        {
                            attack_direction = normalize(move_input);
                        }
                        attack_position = cast_origin + attack_direction * controlled_actor.definition.attack_range;
                        last_attack_direction = attack_direction;
                    }
                }
            }
        }

        case .KEYBOARD_MOUSE;
        {
            mouse_screen_pos: = get_mouse_position();
            mouse_world_pos: = screen_to_world(mouse_screen_pos);

            // Movement
            if is_down(#char "a") || is_down(#char "q")
            {
                move_input += .{-1, 0};
            }
            if is_down(#char "d")
            {
                move_input += .{1, 0};
            }
            if is_down(#char "s")
            {
                move_input += .{0, -1};
            }
            if is_down(#char "w") || is_down(#char "z")
            {
                move_input += .{0, 1};
            }
            if length_squared(move_input) > 1.0
            {
                move_input = normalize(move_input);
            }

            // Attack
            attack_position = mouse_world_pos;
            do_attack =  is_down(.MOUSE_BUTTON_LEFT);

            // Spell
            cast_position = mouse_world_pos;
            begin_cast_spell = is_pressed(.MOUSE_BUTTON_RIGHT);
            end_cast_spell = is_pressed(.MOUSE_BUTTON_RIGHT);
        }
    }
    
    // Movement
    movement_component_add_input(*controlled_actor.movement, move_input);

    // Spell
    if begin_cast_spell && !actor_is_casting(controlled_actor) && get_current_spell(player) != null
    {
        actor_set_casting(controlled_actor, true);
    }

    if (end_cast_spell || cancel_cast_spell) && actor_is_casting(controlled_actor)
    {
        actor_set_casting(controlled_actor, false);
        controlled_actor.attack_cooldown = 1.0;

        if end_cast_spell
        {
            player_cast_spell(player, spell_index);
        }
    }
    spellcaster_update(*spellcaster, dt, cast_position);

    // Attack
    if do_attack
    {
        actor_attack(controlled_actor, attack_position);
    }
}

player_draw :: (using player: *Player)
{
    assert(player != null);

    if !can_control_actor(controlled_actor) return;

    begin_render_texture(render_layers[RenderLayer.OVERLAY]);
    defer end_render_texture();

    // origin: = controlled_actor.position + xyz(controlled_actor.definition.cast_position, 0);
    // direction: = xyz(rotate(.{1,0}, aim_angle), 0);

    // if is_aiming
    // {
    //     draw_line(origin + direction * 7, origin + direction * 20, 3, .{255,255,255,100});
    // }
        
    begin_render_texture(render_layers[RenderLayer.GROUND]);
    if attack_target != null
    {
        draw_scaled_circle_outline(xyz(attack_target.position.xy, 2), 10, .{255,255,255,100});
    }

    if actor_is_casting(controlled_actor) || player.input_type == .KEYBOARD_MOUSE
    {
        draw_scaled_circle_outline(xyz(cast_position, 1), 10, .{255,255,255,40});

        if
            spellcaster.definition != null &&
            spellcaster.definition.type == .TARGET &&
            spellcaster.current_cast.target.target != null
        {
            draw_scaled_circle_outline(xyz(spellcaster.current_cast.target.target.position.xy, 2), 10, .{255,255,255,100});
        }
    }
    end_render_texture();
}

player_draw_ui :: (using player: *Player, origin: Vector2)
{
    spell_swatches_step: = Vector2.{17, 0};
    selector_offset: = Vector2.{8,17};
    for i: 0..player.spell_slots.count-1
    {
        animation_player_draw(*player.spell_swatches[i], xyz(origin + spell_swatches_step * i.(float), 0));
    }
    if player.spell_slots[player.spell_index] != null
    {
        draw_rectangle(xyz(origin + player.spell_index.(float) * spell_swatches_step + selector_offset, 0), .{.{-1,-1}, .{1,1}}, WHITE);
    }
}

player_cast_spell :: (using player: *Player, slot_index: s64) -> bool
{
    if spellcaster_cast(*spellcaster)
    {
        spellcaster.definition = null;
        spell_slots[slot_index] = null;
        if slot_index == spell_index
        {
            select_closest_spell(player);
        }
        return true;
    }
    return false;
}

set_controlled_actor :: (player: *Player, actor: *Actor)
{
    if actor == player.controlled_actor return;

    if player.controlled_actor != null
    {
        assert(player.controlled_actor.controlling_player == player);
        player.controlled_actor.controlling_player = null;
        player.spellcaster.source = null;
        actor_set_casting(player.controlled_actor, false);
    }
    player.controlled_actor = actor;
    if player.controlled_actor != null
    {
        if actor.controlling_player != null
        {
            set_controlled_actor(actor.controlling_player, null);
        }

        assert(player.controlled_actor.controlling_player == null);
        player.controlled_actor.controlling_player = player;
        player.spellcaster.source = player.controlled_actor;
    }
}

can_control_actor :: (actor: *Actor) -> bool
{
    if actor == null return false;
    if actor_is_dead(actor) return false;
    if !actor_is_sentient(actor) return false;
    if actor.ai.state == .PANICKING return false;
    return true;
}

try_learn_spell :: (actor: *Actor, spell: *SpellDefinition) -> bool
{
    if actor == null return false;
    if actor.controlling_player == null return false;

    return try_learn_spell(actor.controlling_player, spell);
}

try_learn_spell :: (using player: *Player, spell: *SpellDefinition) -> bool
{
    if spell == null return false;

    for i: 0..spell_slots.count-1
    {
        if spell_slots[i] == null
        {
            spell_slots[i] = spell;
            select_closest_spell(player);
            return true;
        }
    }
    return false;
}

select_closest_spell :: (using player: *Player)
{
    if player.spell_slots[spell_index] != null return;
    select_previous_spell(player);
}

select_previous_spell :: (using player: *Player)
{
    for i: 1..SPELL_SLOTS_COUNT
    {
        index: = positive_mod(player.spell_index - i, SPELL_SLOTS_COUNT);

        if player.spell_slots[index] != null
        {
            spell_index = index;
            return;
        }
    }
}

select_next_spell :: (using player: *Player)
{
    for i: 1..SPELL_SLOTS_COUNT
    {
        index: = positive_mod(player.spell_index + i, SPELL_SLOTS_COUNT);

        if player.spell_slots[index] != null
        {
            spell_index = index;
            return;
        }
    }
}

get_current_spell :: (using player: *Player) -> *SpellDefinition
{
    return spell_slots[spell_index];
}

#scope_file

draw_scaled_circle_outline :: (position: Vector3, radius: float, color: Color)
{
    begin_transform();
    transform_translate(position);
    transform_scale(.{1,0.4,1});
    draw_circle_outline(.{}, radius, 4, color);
    end_transform();
}

#import "Gamepad";