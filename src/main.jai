#load "resources.jai";
#load "actor.jai";
#load "game.jai";
#load "spell.jai";

#load "components/movement_component.jai";
#load "components/alteration_component.jai";

#load "actors/mage.jai";
#load "actors/fireball.jai";
#load "actors/tree.jai";


init :: ()
{
    load_all_resources();
    physics_init();
    pool_init(*actors);

    physics_set_layer_response(PHYSIC_LAYER_BODY, PHYSIC_LAYER_BODY, .COLLIDE);
    physics_set_layer_response(PHYSIC_LAYER_BODY, PHYSIC_LAYER_SPELL, .OVERLAP);

    game_start();
}

shutdown :: ()
{
    game_stop();

    pool_shutdown(*actors);
    physics_shutdown();
    unload_all_resources();
}

main :: ()
{
    register_resources(*resources);

    // Init
    yae_init(*YAE_COMPILE_TIME_INFO, 800, 600, "jamembert");
    init();

    // Loop
    yae_loop(game_update, game_draw);
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