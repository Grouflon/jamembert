#load "resources.jai";
#load "actor.jai";

#load "components/movement_component.jai";

#load "actors/sorcerer.jai";
#load "actors/fireball.jai";
#load "actors/tree.jai";

sorcerer: *Actor;

init :: ()
{
    load_all_resources();

    sorcerer = create_actor(*sorcerer_definition);

    create_actor(*tree_definition, .{30, 10});
}

shutdown :: ()
{
    unload_all_resources();
}

update :: (dt: float)
{
    mouse_screen_pos: = get_mouse_position();
    mouse_world_pos: = screen_to_world(mouse_screen_pos);
    if is_down(.MOUSE_BUTTON_LEFT)
    {
        movement_component_go_to(*sorcerer.movement, mouse_world_pos);
    }

    if is_pressed(.MOUSE_BUTTON_RIGHT)
    {
        f: = shoot_fireball(sorcerer.position.xy, mouse_world_pos);
    }

    actors_update(dt);
}

DRAW_SCALE :: 5;

draw :: ()
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
    }
}

screen_to_world :: (position: Vector2) -> Vector2
{
    w, h: = get_viewport_size();
    half_size: = (Vector2.{xx w, xx h} / 2);
    return Vector2.{position.x - half_size.x, half_size.y - position.y} / DRAW_SCALE;
}

main :: ()
{
    register_resources(*resources);

    // Init
    yae_init(*YAE_COMPILE_TIME_INFO, 800, 600, "jamembert");
    init();

    // Loop
    yae_loop(update, draw);
    if OS == .WASM return; // wasm needs to exit immediately. Everything will happen async later

    // Shutdown
    shutdown();
    yae_shutdown();
}

// === Loads ===
#if OS == .WASM
{
    // @NOTE(remi): We can remove this with functions that send callbacks as argument to wasm
    #load "../modules/yae/wasm_export.jai";
}

// === Imports ===
#scope_file
#import "Basic"()(MEMORY_DEBUGGER = YAE_DEBUG_MEMORY);
#import "String";
#import "System";

#import "Math";
#import "yae";
#import "Input";