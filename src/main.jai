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

    yae_loop(
        // Update
        (dt: float) 
        {
            if input_button_states[Key_Code.ARROW_LEFT] & .DOWN
            {
                angle += dt;
            }
            if input_button_states[Key_Code.ARROW_RIGHT] & .DOWN
            {
                angle -= dt;
            }
        },
        // Draw
        ()
        {
            camera: = Camera.{
                position = .{},
                rotation = .{},
                type = .ORTHOGRAPHIC,
                orthographic = .{
                    top = xx get_window_height(),
                    left = 0,
                    bottom = 0,
                    right = xx get_window_width(),
                    near = -10,
                    far = 10
                }
            };

            {
                begin_camera(camera);
                defer end_camera();

                clear_background(GREEN);

                triangle_position: = Vector3.{100, 100, 0};
                v1: = rotate(.{-100, -100}, angle);
                v2: = rotate(.{100, -100}, angle);
                v3: = rotate(.{0, 100}, angle);
                triangle: = Vertex.[
                    .{triangle_position + .{v1.x, v1.y, 0.0}, .{0.0, 0.0}, .{1.0, 0.0, 0.0, 1.0} },
                    .{triangle_position + .{v2.x, v2.y, 0.0}, .{0.0, 1.0}, .{0.0, 1.0, 0.0, 1.0} },
                    .{triangle_position + .{v3.x, v3.y, 0.0}, .{1.0, 1.0}, .{0.0, 0.0, 1.0, 1.0} },
                ];

                draw_command(triangle, .[0, 1, 2], resources.oro.texture.handle);
                draw_sprite(resources.oro.texture, .{300, 200});
            }
            
        }
    );

    #if OS != .WASM
    {
        unload_all_resources();
        yae_shutdown();
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