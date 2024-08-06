PLACEHOLDER_NAME :: "bootstrap";
BUILD_FILE :: "build.jai";

#run {
    // This is not an actual compilation script
    set_build_options_dc(.{do_output=false});

    args := get_build_options().compile_time_command_line;
    project_name: = args[0];

    // Rename project file
    project_file: = tprint("%.sublime-project", PLACEHOLDER_NAME);
    if file_exists(project_file)
    {
        new_project_file_name: = replace(project_file, PLACEHOLDER_NAME, project_name);
        log("Renaming % -> %...", project_file, new_project_file_name);
        file_move(project_file, new_project_file_name);
    }

    // Replace project name in build file
    log("Replacing project name in %...", BUILD_FILE);
    build_file_content: = read_entire_file(BUILD_FILE);
    build_file_content = replace(build_file_content, PLACEHOLDER_NAME, project_name);
    write_entire_file(BUILD_FILE, build_file_content);

    // Removing setup files
    log("Removing setup files...");
    file_delete("setup.jai");
    file_delete("setup.bat");
}

#import "Compiler";
#import "Basic";
#import "File";
#import "File_Utilities";
#import "String";