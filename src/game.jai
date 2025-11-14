DRAW_SCALE :: 5;

PHYSIC_LAYER_BODY :: 0;
PHYSIC_LAYER_SPELL :: 1;

mage: *Actor;
spellcaster: SpellCaster;

game_start :: ()
{
    mage = create_actor(*mage_definition);
    create_actor(*tree_definition, .{30, 10});
    create_actor(*tree_definition, .{-30, -10});

    spellcaster.source = mage;
    spellcaster.definition = *fireball_spell_definition;
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
    spellcaster_update(*spellcaster, dt, mouse_world_pos);
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
    half_size: = Vector2.{xx w, xx h} / (2 * DRAW_SCALE);
    camera: = Camera.{
        position = .{},
        rotation = .{},
        type = .ORTHOGRAPHIC,
        orthographic = .{
            top = half_size.y,
            left = -half_size.x,
            bottom = -half_size.y,
            right = half_size.x,
            near = -10,
            far = 10
        }
    };

    {
        begin_camera(camera);
        defer end_camera();

        clear_background(.{0,30,61,255});

        actors_draw();
        spellcaster_draw(*spellcaster);
    }
}

screen_to_world :: (position: Vector2) -> Vector2
{
    w, h: = get_viewport_size();
    half_size: = (Vector2.{xx w, xx h} / 2);
    return Vector2.{position.x - half_size.x, half_size.y - position.y} / DRAW_SCALE;
}
