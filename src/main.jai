resources: struct
{
    oro: TextureFile = .{ path = "./data/oro_avatar.png" };
};

angle: float;

main :: ()
{
    register_resources(*resources);

    // note: can we remove the compile time argument with a macro ?
    yae_init(*YAE_COMPILE_TIME_INFO, 800, 600, "jamembert");

    load_all_resources();

    yae_loop(update, draw);
    if OS == .WASM return; // wasm needs to exit immediately. Everything will happen async later

    unload_all_resources();
    yae_shutdown();
}

update :: (dt: float)
{
    if is_down(.ARROW_LEFT)
    {
        angle += dt;
    }
    if is_down(.ARROW_RIGHT)
    {
        angle -= dt;
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

        clear_background(GREEN);

        triangle_radius: = 100.0;
        v1: = rotate(.{0, triangle_radius}, angle);
        v2: = rotate(.{0, triangle_radius}, angle + D2R * 120);
        v3: = rotate(.{0, triangle_radius}, angle + D2R * 240);
        triangle_position: = Vector3.{0, 0, 0};
        triangle: = Vertex.[
            .{triangle_position + .{v1.x, v1.y, 0.0}, .{0.0, 0.0}, .{1.0, 0.0, 0.0, 1.0} },
            .{triangle_position + .{v2.x, v2.y, 0.0}, .{0.0, 1.0}, .{0.0, 1.0, 0.0, 1.0} },
            .{triangle_position + .{v3.x, v3.y, 0.0}, .{1.0, 1.0}, .{0.0, 0.0, 1.0, 1.0} },
        ];

        draw_command(triangle, .[0, 1, 2], resources.oro.texture.handle);
        draw_sprite(resources.oro.texture, .{300, 200});
    }
}

// === Loads ===
#if OS == .WASM
{
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