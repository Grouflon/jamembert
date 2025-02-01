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

    begin_draw();

    clear_color(.{0.0, 1.0, 0.0, 1.0});

    v1: = rotate(.{-0.5, -0.5 }, time);
    v2: = rotate(.{0.5, -0.5 }, time);
    v3: = rotate(.{0.0, 0.5 }, time);
    triangle: = Vertex.[
        .{.{v1.x, v1.y, 0.0}, .{0.0, 0.0}, .{1.0, 0.0, 0.0, 1.0} },
        .{.{v2.x, v2.y, 0.0}, .{0.0, 1.0}, .{0.0, 1.0, 0.0, 1.0} },
        .{.{v3.x, v3.y, 0.0}, .{1.0, 1.0}, .{0.0, 0.0, 1.0, 1.0} },
    ];
    draw_triangle(triangle);

    end_draw();
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