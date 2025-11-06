#load "components/movement_component.jai";

resources: struct
{
    sorcerer_texture: TextureFile = .{ path = "data://aseprite/sorcerer.png" };
    sorcerer_aseprite: AsepriteFile = .{ path = "data://aseprite/sorcerer.json" };

    fireball_texture: TextureFile = .{ path = "data://aseprite/fireball.png" };
    fireball_aseprite: AsepriteFile = .{ path = "data://aseprite/fireball.json" };
};

Fireball :: struct
{
    #as using e:Entity;

    movement: MovementComponent;
    animation: AsepriteAnimationPlayer;
    active: bool;
}

sorcerer: Entity;

fireballs: [32]Fireball;

fireball_init :: (using fireball: *Fireball)
{
    <<fireball = .{};
    movement.owner = fireball;
    movement.speed = 400;

    animation_player_play(*animation, *resources.fireball_aseprite, "idle");
}

fireball_update :: (using fireball: *Fireball, dt: float)
{
    movement_component_update(*movement, dt);
    animation_player_update(*animation, dt);

    if !movement.is_moving
    {
        active = false;
        return;
    }
}

shoot_fireball :: (start: Vector2, end: Vector2) -> *Fireball
{
    for *f: fireballs
    {
        if f.active continue;

        fireball_init(f);
        f.position = .{start.x, start.y, 0.5};
        movement_component_go_to(*f.movement, end);
        f.active = true;

        return f;
    }
    return null;
}

movement: MovementComponent = .{ owner = *sorcerer, speed = 200.0 };
animation_player: AsepriteAnimationPlayer;

init :: ()
{
    load_all_resources();
}

shutdown :: ()
{
    unload_all_resources();
}

update :: (dt: float)
{
    mouse_pos: = get_mouse_position();
    world_pos: = screen_to_world(mouse_pos);
    if is_down(.MOUSE_BUTTON_LEFT)
    {
        movement_component_go_to(*movement, world_pos);
    }

    if is_pressed(.MOUSE_BUTTON_RIGHT)
    {
        f: = shoot_fireball(sorcerer.position.xy, world_pos);
    }

    movement_component_update(*movement, dt);
    animation_player_play(*animation_player, *resources.sorcerer_aseprite, ifx movement.is_moving then "walk" else "idle");
    animation_player_update(*animation_player, dt);

    for *f: fireballs
    {
        if !f.active continue;

        fireball_update(f, dt);
    }
}

draw :: ()
{
    w, h: = get_viewport_size();
    half_size: = Vector2.{xx w, xx h} / 2;
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

        DRAW_SCALE :: Vector3.{5, 5, 1};

        {
            begin_transform();
            defer end_transform();

            transform_translate(sorcerer.position);
            transform_scale(DRAW_SCALE);
            animation_player_draw(*animation_player, .{-8, -8, 0});
        }

        for *f: fireballs
        {
            if !f.active continue;

            begin_transform();
            defer end_transform();

            transform_translate(f.position);
            transform_scale(DRAW_SCALE);
            animation_player_draw(*f.animation, .{-8, -8, 0});
        }
    }
}

screen_to_world :: (position: Vector2) -> Vector2
{
    w, h: = get_viewport_size();
    half_size: = Vector2.{xx w, xx h} / 2;
    return .{position.x - half_size.x, half_size.y - position.y};
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