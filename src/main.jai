resources: struct
{
    // oro: TextureFile = .{ path = "./data/oro_avatar.png" };
    sorcerer_texture: TextureFile = .{ path = "./data/aseprite/sorcerer.png" };
    sorcerer_aseprite: AsepriteFile = .{ path = "./data/aseprite/sorcerer.json" };
};

angle: float;
player: AsepriteAnimationPlayer;

main :: ()
{
    register_resources(*resources);

    // Init
    yae_init(*YAE_COMPILE_TIME_INFO, 800, 600, "jamembert");
    load_all_resources();

    animation_player_play(*player, *resources.sorcerer_aseprite, "walk");

    // Loop
    yae_loop(update, draw);
    if OS == .WASM return; // wasm needs to exit immediately. Everything will happen async later

    // Shutdown
    unload_all_resources();
    yae_shutdown();
}

update :: (dt: float)
{
    if is_down(#char "a")
    {
        angle += dt;
    }
    if is_down(#char "d")
    {
        angle -= dt;
    }

    animation_player_update(*player, dt);
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

        begin_transform();
        defer end_transform();

        transform_scale(.{5,5,1});
        animation_player_draw(*player, .{0,0,0});

        // triangle_radius: = 100.0;
        // v1: = rotate(.{0, triangle_radius}, angle);
        // v2: = rotate(.{0, triangle_radius}, angle + D2R * 120);
        // v3: = rotate(.{0, triangle_radius}, angle + D2R * 240);
        // triangle_position: = Vector3.{0, 0, 0};
        // triangle: = Vertex.[
        //     .{triangle_position + .{v1.x, v1.y, 0.0}, .{0.0, 0.0}, .{1.0, 0.0, 0.0, 1.0} },
        //     .{triangle_position + .{v2.x, v2.y, 0.0}, .{0.0, 1.0}, .{0.0, 1.0, 0.0, 1.0} },
        //     .{triangle_position + .{v3.x, v3.y, 0.0}, .{1.0, 1.0}, .{0.0, 0.0, 1.0, 1.0} },
        // ];

        // draw_command(triangle, .[0, 1, 2], resources.oro.texture.handle);
        // draw_sprite(.{100, 100, 0}, resources.oro.texture, .{20, 20, 200, 200}, .{0,0, 100, 100}, false, false, RED);
    }
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