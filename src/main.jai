// Spells
#load "spells/attack.jai";
#load "spells/bouledefeu.jai";
#load "spells/lobotomie.jai";
#load "spells/sentification.jai";
#load "spells/explosion.jai";
#load "spells/transposition.jai";
#load "spells/spawngobelin.jai";
#load "spells/reanimation.jai";
#load "spells/mitose.jai";
#load "spells/darkbook.jai";
#load "spells/skull.jai";
#load "spells/cupidon.jai";

spellbook: []*SpellDefinition = .[
    *bouledefeu_spell_definition,
    *sentification_spell_definition,
    *lobotomie_spell_definition,
    *explosion_spell_definition,
    *transposition_spell_definition,
    *spawngobelin_spell_definition,
    *reanimation_spell_definition,
    *mitose_spell_definition,
    *darkbook_spell_definition,
    *skull_spell_definition,
    *cupidon_spell_definition,
];

// Actors
#load "actors/simple_animation.jai";
#load "actors/book.jai";
#load "actors/bookshelf.jai";
#load "actors/mage.jai";
#load "actors/tree.jai";
#load "actors/goblin.jai";
#load "actors/cheese.jai";
#load "actors/chest.jai";

// Other
#load "resources.jai";
#load "actor.jai";
#load "game.jai";
#load "spell.jai";
#load "spellcaster.jai";

#load "components/movement_component.jai";
#load "components/alteration_component.jai";
#load "components/ai_component.jai";

// Render layers
RenderLayer :: enum
{
    GROUND :: 0;
    OBJECTS :: 1;
    OVERLAY :: 2;
    EDITOR :: 3;
    UI :: 4;
}
render_layers: [#run enum_highest_value(RenderLayer) + 1]RenderTexture;

init :: ()
{
    load_all_resources();
    physics_init();
    pool_init(*actors);

    physics_set_layer_response(PHYSIC_LAYER_BODY, PHYSIC_LAYER_BODY, .COLLIDE);
    physics_set_layer_response(PHYSIC_LAYER_BODY, PHYSIC_LAYER_SPELL, .OVERLAP);

    w, h: = get_viewport_size();
    for i: 0..render_layers.count-1
    {
        render_layers[i] = load_render_texture(xx w, xx h);
    }

    game_start();
}

shutdown :: ()
{
    game_stop();

    for i: 0..render_layers.count-1
    {
        unload_render_texture(render_layers[i]);
        render_layers[i] = .{};
    }

    pool_shutdown(*actors);
    physics_shutdown();
    unload_all_resources();
}

main :: ()
{
    register_resources(*resources);

    // Init
    yae_init(800, 600, "jamembert");
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