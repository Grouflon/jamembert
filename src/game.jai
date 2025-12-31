DRAW_SCALE :: 4;

GAME_WIDTH :: 1920;
GAME_HEIGHT :: 1080;

players: [4]Player;

game_start :: ()
{
    t: = get_current_appolo_time();
    random_seed(Some_Big_Time_Value.{t.low, t.high});
    
    // yae_refresh_gamepads();

    for *player: players
    {
        player_init(player);
    }

    //Assign input controllers (gamepad/keyboard)
    gamepads_assigned: = 0;
    for *gamepad: gamepads
    {
        gamepad.left_stick_deadzone = 0.25;
        gamepad.right_stick_deadzone = 0.25;

        if gamepads_assigned >= players.count break;

        if gamepad.connected
        {
            players[gamepads_assigned].input_type = .GAMEPAD;
            players[gamepads_assigned].gamepad = gamepad;
            gamepads_assigned += 1;
        }
    }

    keyboard_mouse_assigned: = 0;
    {
        for *player: players
        {
            if keyboard_mouse_assigned > 0 break;
            if player.input_type != .NONE continue;

            player.input_type = .KEYBOARD_MOUSE;
            keyboard_mouse_assigned += 1;
        }
    }

    //Spell on start
    //players[0].spell_slots[0] = *portalbrain_spell_definition;
    //players[0].spell_slots[1] = *lobotomie_spell_definition;
    //players[0].spell_slots[0] = *portalgraveyard_spell_definition;
    //players[0].spell_slots[1] = *portalbrain_spell_definition;
    //players[0].spell_slots[2] = *portalforest_spell_definition;
    //players[0].spell_slots[1] = *portallibrary_spell_definition;
    //players[0].spell_slots[2] = *portalvolcano_spell_definition;
    //players[0].spell_slots[1] = *spectralform_spell_definition;
    //players[0].spell_slots[2] = *illusion_spell_definition;
    //players[0].spell_slots[2] = *mindswap_spell_definition;
    //players[0].spell_slots[2] = *rage_spell_definition;
    //players[0].spell_slots[1] = *bouledefeu_spell_definition;
    //players[0].spell_slots[0] = *darkbook_spell_definition;
    //players[0].spell_slots[1] = *cupidon_spell_definition;
    //players[0].spell_slots[2] = *skull_spell_definition;
    //players[0].spell_slots[1] = *explosion_spell_definition;
    //players[0].spell_slots[2] = *mitose_spell_definition;
    //players[0].spell_slots[2] = *reanimation_spell_definition;
    //players[0].spell_slots[1] = *transposition_spell_definition;
    //players[0].spell_slots[0] = *spawngobelin_spell_definition;


    //Level Design
    //you can pass a number to init_level to choose a specific level, otherwise it will be random
    select_level();


    //Set player controlled actor
    //generate a random different mage for each player
    mages: [..]*ActorDefinition;
    mages.allocator = temporary_allocator;
    yae_array_add_if_unique(*mages, *mage1_definition);
    yae_array_add_if_unique(*mages, *mage2_definition);
    yae_array_add_if_unique(*mages, *mage3_definition);
    yae_array_add_if_unique(*mages, *mage4_definition);
    mage_gen:*ActorDefinition;

    //player 1
    _,mage_gen= random_get_array_item(mages);
    yae_array_unordered_remove_by_value(*mages, mage_gen);
    mage1: = create_actor(mage_gen, player1_start_position);
    set_controlled_actor(*players[0], mage1);

    //player 2
    _,mage_gen= random_get_array_item(mages);
    yae_array_unordered_remove_by_value(*mages, mage_gen);
    mage2: = create_actor(mage_gen, player2_start_position);
    set_controlled_actor(*players[1], mage2);

    //player 3
    _,mage_gen= random_get_array_item(mages);
    yae_array_unordered_remove_by_value(*mages, mage_gen);
    mage3: = create_actor(mage_gen, player3_start_position);
    set_controlled_actor(*players[2], mage3);

    //player 4
    _,mage_gen= random_get_array_item(mages);
    yae_array_unordered_remove_by_value(*mages, mage_gen);
    mage4: = create_actor(mage_gen, player4_start_position);
    set_controlled_actor(*players[3], mage4);
}

game_stop :: ()
{
    for *player: players
    {
        player_shutdown(player);
    }
    array_clear(*brains_targets);
    portal_count = 0;
    delete_all_actors();
}

should_restart_game: bool;
game_request_restart :: ()
{
    should_restart_game = true;
}


game_update :: (dt: float)
{
    actors_update(dt);

    level_update(dt);

    for *player: players
    {
        player_update(player, dt);
    }
    
    physics_update(dt);

    if is_pressed(.ESCAPE)
    {
        yae_request_close();
    }

    if should_restart_game
    {
        should_restart_game = false;
        game_stop();
        game_start();
    }
}

game_draw :: ()
{
    for i: 0..render_layers.count-1
    {
        resize_render_texture(*render_layers[i], GAME_WIDTH, GAME_HEIGHT);
        begin_render_texture(render_layers[i]);
        clear_background();
        end_render_texture();
    }

    // Render Pipeline
    {
        // Game
        {
            half_size: = Vector2.{GAME_WIDTH, GAME_HEIGHT} / (2 * DRAW_SCALE);
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

            begin_render_texture(render_layers[RenderLayer.GROUND]);
            clear_background(background_color);
            level_draw();
            end_render_texture();

            begin_render_texture(render_layers[RenderLayer.GROUND_OVERLAY]);
            end_render_texture();

            begin_render_texture(render_layers[RenderLayer.OBJECTS]);
            actors_draw();
            end_render_texture();

            begin_render_texture(render_layers[RenderLayer.OVERLAY]);

            //draw_circle(.{10,10,0}, 50, WHITE);
            //draw_circle_outline(.{10,10,0}, 50, 2, RED);

            for *player: players
            {
                player_draw(player);
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
                    top = GAME_HEIGHT / DRAW_SCALE,
                    left = 0,
                    bottom = 0,
                    right = GAME_WIDTH / DRAW_SCALE,
                    near = -10,
                    far = 10
                }
            };

            begin_camera(ui_camera);
            defer end_camera();

            player_draw_ui(*players[0], .{3,3});
            player_draw_ui(*players[1], .{GAME_WIDTH / DRAW_SCALE - 52 , GAME_HEIGHT / DRAW_SCALE - 23});
            player_draw_ui(*players[2], .{3, GAME_HEIGHT / DRAW_SCALE - 23});
            player_draw_ui(*players[3], .{GAME_WIDTH / DRAW_SCALE - 52,3});
        }

        // Compositing
        {
            w, h: = get_viewport_size();

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

            clear_background(.{0,0,0,255});

            draw_rect: = get_compositing_screen_bounds();
            for i: 0..render_layers.count-1
            {
                draw_sprite(.{0,0,i.(float)}, render_layers[i].texture, draw_rect = draw_rect);
            }
        }
    }
}

get_compositing_screen_bounds :: () -> Bounds
{
    w, h: = get_viewport_size();
    ratio: float = GAME_WIDTH.(float) / GAME_HEIGHT.(float);
    viewport_size: = Vector2.{xx w, xx h};
    viewport_ratio: = viewport_size.x / viewport_size.y;
    size: Vector2;
    if viewport_ratio < ratio
    {
        size = .{viewport_size.x, viewport_size.x / ratio};
    }
    else
    {
        size = .{viewport_size.y * ratio, viewport_size.y};
    }
    origin: = (viewport_size - size) * 0.5;
    return .{origin, origin + size};
}

screen_to_world :: (position: Vector2) -> Vector2
{
    bounds: = get_compositing_screen_bounds();
    // Normalized position in screen space
    normalized_position: = (position - bounds.min) / size(bounds);

    // Normalized position in camera space
    normalized_position = .{
        normalized_position.x - 0.5,
        (normalized_position.y - 0.5) * -1,
    };

    return normalized_position * .{GAME_WIDTH, GAME_HEIGHT} / DRAW_SCALE;
}
