#load "resources.jai";
#load "actor.jai";
#load "game.jai";
#load "spell.jai";
#load "spellcaster.jai";

#load "components/movement_component.jai";
#load "components/alteration_component.jai";

// Spells
#load "spells/bouledefeu.jai";
#load "spells/lobotomie.jai";
#load "spells/sentification.jai";

spellbook: []*SpellDefinition = .[
    *bouledefeu_spell_definition,
    *sentification_spell_definition,
    *lobotomie_spell_definition,
];

// Actors
#load "actors/mage.jai";
#load "actors/tree.jai";

// Render textures
rt_ground: RenderTexture;
rt_objects: RenderTexture;
rt_overlay: RenderTexture;
rt_editor: RenderTexture;
rt_ui: RenderTexture;

init :: ()
{
    load_all_resources();
    physics_init();
    pool_init(*actors);

    physics_set_layer_response(PHYSIC_LAYER_BODY, PHYSIC_LAYER_BODY, .COLLIDE);
    physics_set_layer_response(PHYSIC_LAYER_BODY, PHYSIC_LAYER_SPELL, .OVERLAP);

    w, h: = get_viewport_size();
    rt_ground = load_render_texture(xx w, xx h);
    rt_objects = load_render_texture(xx w, xx h);
    rt_overlay = load_render_texture(xx w, xx h);
    rt_editor = load_render_texture(xx w, xx h);
    rt_ui = load_render_texture(xx w, xx h);

    game_start();
}

shutdown :: ()
{
    game_stop();

    unload_render_texture(rt_ground);
    unload_render_texture(rt_objects);
    unload_render_texture(rt_overlay);
    unload_render_texture(rt_editor);
    unload_render_texture(rt_ui);
    rt_ground = .{};
    rt_objects = .{};
    rt_overlay = .{};
    rt_editor = .{};
    rt_ui = .{};

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