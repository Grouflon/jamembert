// Build Parameters
DEBUG_MEMORY :: (OS != .WASM);

TEXTURE_PATH :: "data/oro_avatar.png";

bootstrap_preload :: ()
{
    // Needed for WASM, does nothing on other platforms yet
    preload(TEXTURE_PATH, .IMAGE);
}

bootstrap_init :: ()
{
    texture: = create_texture(TEXTURE_PATH);
    bind_texture(texture, 0);
    shader_uniform_texture(0, "uTexture", 0);
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
    m: = camera_to_vp_matrix(camera);
    push_camera(camera);
    defer pop_camera();

    begin_draw();
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

    draw_triangle(triangle);
}

bootstrap_shutdown :: ()
{
    log("shutdown");
}

main :: ()
{
    #if OS != .WASM
    {
        // normalize working directory
        {
            exe_directory: = path_strip_filename(get_path_of_running_executable());
            root_directory: = tprint("%/..", exe_directory);
            set_working_directory(root_directory);
        }
    }

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

#if OS == .WASM
{
    #load "../modules/yae/wasm_export.jai";
}

#scope_file

#import "Basic"()(MEMORY_DEBUGGER = DEBUG_MEMORY);
#import "String";
#import "System";

#import "Math";
#import "yae";
#import "Input";