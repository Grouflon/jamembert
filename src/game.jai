DRAW_SCALE :: 5;

PHYSIC_LAYER_BODY :: 0;
PHYSIC_LAYER_SPELL :: 1;

spell_index: = 0;
spell_change_cooldown: float = 0;

controlled_actor: *Actor;
spell_swatch: AsepriteAnimationPlayer;
spellcaster: SpellCaster;

game_start :: ()
{
    mage: = create_actor(*mage_definition);
    create_actor(*tree_definition, .{30, 10});
    create_actor(*tree_definition, .{-30, -10});
    goblin: = create_actor(*goblin_definition, .{70, -30});

    set_controlled_actor(mage);
    // set_controlled_actor(goblin);
    // mage.ai.is_agressive = true;
    spell_index = 0;
}

game_stop :: ()
{
    set_controlled_actor(null);
    delete_all_actors();
}

game_update :: (dt: float)
{
    mouse_screen_pos: = get_mouse_position();
    mouse_world_pos: = screen_to_world(mouse_screen_pos);

    actors_update(dt);

    // Spellcaster
    if spell_change_cooldown <= 0
    {
        if mouse_delta_z != 0
        {
            spell_index = positive_mod(spell_index + sign(mouse_delta_z), spellbook.count);
            spell_change_cooldown = 0.04;
        }
    }
    else
    {
        spell_change_cooldown -= dt;
    }
    spellcaster.definition = spellbook[spell_index];
    if spellcaster.definition != null
    {
        success, icon_animation: = get_animation_handle(spellcaster.definition.icon);
        if success
        {
            animation_player_play(*spell_swatch, icon_animation);
        }
    }

    spellcaster_update(*spellcaster, dt, mouse_world_pos);
    animation_player_update(*spell_swatch, dt);

    // Controlled Actor Input
    if can_control_actor(controlled_actor)
    {
        // Movement
        input: Vector2;
        if is_down(#char "a") || is_down(#char "q")
        {
            input += .{-1, 0};
        }
        if is_down(#char "d")
        {
            input += .{1, 0};
        }
        if is_down(#char "s")
        {
            input += .{0, -1};
        }
        if is_down(#char "w") || is_down(#char "z")
        {
            input += .{0, 1};
        }
        if length_squared(input) > 1.0
        {
            input = normalize(input);
        }
        movement_component_add_input(*controlled_actor.movement, input);

        // Attack
        if is_pressed(.MOUSE_BUTTON_LEFT)
        {
            actor_attack(controlled_actor, mouse_world_pos);
        }

        // Spell
        if is_pressed(.MOUSE_BUTTON_RIGHT)
        {
            spellcaster_cast(*spellcaster);
        }

        
    }
    
    physics_update(dt);

    // Restart game
    if is_down(.CTRL) && is_pressed(#char "r")
    {
        game_stop();
        game_start();
    }

    if is_pressed(.ESCAPE)
    {
        yae_request_close();
    }
}

game_draw :: ()
{
    w, h: = get_viewport_size();

    for i: 0..render_layers.count-1
    {
        resize_render_texture(*render_layers[i], xx w, xx h);
        begin_render_texture(render_layers[i]);
        clear_background();
        end_render_texture();
    }

    // Render Pipeline
    {
        // Game
        {
            half_size: = Vector2.{xx w, xx h} / (2 * DRAW_SCALE);
            game_camera: = Camera.{
                position = .{},
                rotation = .{},
                type = .ORTHOGRAPHIC,
                orthographic = .{
                    top = half_size.y,
                    left = -half_size.x,
                    bottom = -half_size.y,
                    right = half_size.x,
                    near = -1000,
                    far = 1000
                }
            };

            begin_camera(game_camera);
            defer end_camera();

            begin_render_texture(render_layers[RenderLayer.OBJECTS]);
            actors_draw();
            end_render_texture();

            begin_render_texture(render_layers[RenderLayer.OVERLAY]);
            if can_control_actor(controlled_actor)
            {
                spellcaster_draw(*spellcaster);
            }
            end_render_texture();

            begin_render_texture(render_layers[RenderLayer.EDITOR]);
            #if WITH_EDITOR
            {
                editor_draw();
            }
            end_render_texture();
        }

        // UI
        {
            begin_render_texture(render_layers[RenderLayer.UI]);
            defer end_render_texture();

            ui_camera: = Camera.{
                position = .{},
                rotation = .{},
                type = .ORTHOGRAPHIC,
                orthographic = .{
                    top = h.(float) / DRAW_SCALE,
                    left = 0,
                    bottom = 0,
                    right = w.(float) / DRAW_SCALE,
                    near = -10,
                    far = 10
                }
            };

            begin_camera(ui_camera);
            defer end_camera();

            animation_player_draw(*spell_swatch, .{3, 3, 0});
        }

        // Compositing
        {
            // We probably need a default camera on the stack
            compositing_camera: = Camera.{
                position = .{},
                rotation = .{},
                type = .ORTHOGRAPHIC,
                orthographic = .{
                    top = h.(float),
                    left = 0,
                    bottom = 0,
                    right = w.(float),
                    near = -10,
                    far = 10
                }
            };

            begin_camera(compositing_camera);
            defer end_camera();

            clear_background(.{0,30,61,255});

            for i: 0..render_layers.count-1
            {
                draw_sprite(.{0,0,i.(float)}, render_layers[i].texture);
            }
        }

    }
}

screen_to_world :: (position: Vector2) -> Vector2
{
    w, h: = get_viewport_size();
    half_size: = (Vector2.{xx w, xx h} / 2);
    return Vector2.{position.x - half_size.x, half_size.y - position.y} / DRAW_SCALE;
}

set_controlled_actor :: (actor: *Actor)
{
    if controlled_actor != null
    {
        assert(controlled_actor.user_controlled);
        controlled_actor.user_controlled = false;
        spellcaster.source = null;
    }
    controlled_actor = actor;
    if controlled_actor != null
    {
        assert(!controlled_actor.user_controlled);
        controlled_actor.user_controlled = true;
        spellcaster.source = controlled_actor;
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