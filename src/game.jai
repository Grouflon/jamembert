DRAW_SCALE :: 5;

PHYSIC_LAYER_BODY :: 0;
PHYSIC_LAYER_SPELL :: 1;

spell_index: = 0;
spell_change_cooldown: float = 0;

mage: *Actor;
spellcaster: SpellCaster;
spell_swatch: AsepriteAnimationPlayer;

game_start :: ()
{
    mage = create_actor(*mage_definition);
    create_actor(*tree_definition, .{30, 10});
    create_actor(*tree_definition, .{-30, -10});

    spell_index = 0;
    spellcaster.source = mage;
    spellcaster.cast_offset = .{0, 4};
}

game_stop :: ()
{
    delete_all_actors();
}

game_update :: (dt: float)
{
    mouse_screen_pos: = get_mouse_position();
    mouse_world_pos: = screen_to_world(mouse_screen_pos);
    if is_down(.MOUSE_BUTTON_LEFT)
    {
        movement_component_go_to(*mage.movement, mouse_world_pos);
    }

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
    spellcaster_update(*spellcaster, dt, mouse_world_pos);

    if spellcaster.definition != null
    {
        success, icon_animation: = get_animation_handle(spellcaster.definition.icon);
        if success
        {
            animation_player_play(*spell_swatch, icon_animation);
        }
    }
    animation_player_update(*spell_swatch, dt);
    if is_pressed(.MOUSE_BUTTON_RIGHT)
    {
        spellcaster_cast(*spellcaster);
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

    resize_render_texture(*rt_ground, xx w, xx h);
    resize_render_texture(*rt_objects, xx w, xx h);
    resize_render_texture(*rt_overlay, xx w, xx h);
    resize_render_texture(*rt_ui, xx w, xx h);

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

            begin_render_texture(rt_ground);
            clear_background();
            end_render_texture();

            begin_render_texture(rt_objects);
            clear_background();
            actors_draw();
            end_render_texture();

            begin_render_texture(rt_overlay);
            clear_background();
            spellcaster_draw(*spellcaster);
            end_render_texture();

            begin_render_texture(rt_editor);
            clear_background();
            #if WITH_EDITOR
            {
                editor_draw();
            }
            end_render_texture();
        }

        // UI
        {
            begin_render_texture(rt_ui);
            defer end_render_texture();

            clear_background();

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
            draw_sprite(.{0,0,0}, rt_ground.texture);
            draw_sprite(.{0,0,1}, rt_objects.texture);
            draw_sprite(.{0,0,2}, rt_overlay.texture);
            draw_sprite(.{0,0,3}, rt_editor.texture);
            draw_sprite(.{0,0,4}, rt_ui.texture);
        }

    }
}

screen_to_world :: (position: Vector2) -> Vector2
{
    w, h: = get_viewport_size();
    half_size: = (Vector2.{xx w, xx h} / 2);
    return Vector2.{position.x - half_size.x, half_size.y - position.y} / DRAW_SCALE;
}
