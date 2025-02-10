// === Build Parameters ===
DEBUG_MEMORY :: (OS != .WASM);

// === Main ===
main :: ()
{
    // normalize working directory
    #if OS != .WASM
    {
        exe_directory: = path_strip_filename(get_path_of_running_executable());
        root_directory: = tprint("%/..", exe_directory);
        set_working_directory(root_directory);
    }

    // Run application
    params: = ApplicationParameters.{
        width = 800,
        height = 600,
        name = "Bootstrap",

        preload_function = bootstrap_preload,
        init_function = bootstrap_init,
        update_function = bootstrap_update,
        shutdown_function = bootstrap_shutdown,
    };
    application_run(params);

    // Memory leak check
    #if DEBUG_MEMORY
    {
        report: = make_leak_report();
        if report.sorted_summaries.count
        {
            log_error("\n=========\nMemory Leak!!\n=========");
            log_leak_report(report);
            assert(false);
        }
    }
}

// === Game ===
TEXTURE_PATH :: "data/oro_avatar.png";
texture: Texture;

bootstrap_preload :: ()
{
    // Needed for WASM, does nothing on other platforms yet
    preload(TEXTURE_PATH, .IMAGE);
}

bootstrap_init :: ()
{
    texture_load(*texture, TEXTURE_PATH);
}

time: float;
bootstrap_update :: (dt: float)
{
    time += dt;
    if input_button_states[Key_Code.ARROW_LEFT] & .START
    {
        log("left pressed");
    }
    if input_button_states[Key_Code.ARROW_LEFT] & .END
    {
        log("left released");
    }
    if input_button_states[Key_Code.ARROW_RIGHT] & .START
    {
        log("right pressed");
    }
    if input_button_states[Key_Code.ARROW_RIGHT] & .END
    {
        log("right released");
    }

    width, height: = get_viewport_size();
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

    begin_draw(camera);
    defer end_draw();

    clear_color(.{0.0, 1.0, 0.0, 1.0});

    triangle_position: = Vector3.{100, 100, 0};
    v1: = rotate(.{-100, -100}, time);
    v2: = rotate(.{100, -100}, time);
    v3: = rotate(.{0, 100}, time);
    triangle: = Vertex.[
        .{triangle_position + .{v1.x, v1.y, 0.0}, .{0.0, 0.0}, .{1.0, 0.0, 0.0, 1.0} },
        .{triangle_position + .{v2.x, v2.y, 0.0}, .{0.0, 1.0}, .{0.0, 1.0, 0.0, 1.0} },
        .{triangle_position + .{v3.x, v3.y, 0.0}, .{1.0, 1.0}, .{0.0, 0.0, 1.0, 1.0} },
    ];

    renderer_draw_command(triangle, .[0, 1, 2], texture.handle);
    draw_sprite(texture, .{300, 200});
}

bootstrap_shutdown :: ()
{
    log("shutdown");
    texture_unload(*texture);
}

// === Loads ===
#if OS == .WASM
{
    #load "../modules/yae/wasm_export.jai";
}

// === Imports ===
#scope_file
#import "Basic"()(MEMORY_DEBUGGER = DEBUG_MEMORY);
#import "String";
#import "System";

#import "Math";
#import "yae";
#import "Input";