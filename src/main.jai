// SPELLS
//Pyromancy         (color : orange / idx-5 / df7126)
#load "spells/bouledefeu.jai";
#load "spells/explosion.jai";
#load "spells/rage.jai";
//Neuromancy      (color : pink / idx-29 / d77bba)
#load "spells/lobotomie.jai";
#load "spells/sentification.jai";
#load "spells/mindswap.jai";
#load "spells/cupidon.jai";
//Bibliomancy       (color : brown / idx-4 / 8f563b)
#load "spells/darkbook.jai";
//Necromancy        (color : green / idx-11 / 37946e)
#load "spells/reanimation.jai";
#load "spells/skull.jai";
#load "spells/spectralform.jai";
//Portals
#load "spells/portalbrain.jai";
#load "spells/portalforest.jai";
#load "spells/portalgraveyard.jai";
#load "spells/portallibrary.jai";
#load "spells/portalvolcano.jai";
//Misc              (color : skyblue / idx-19 / 5fcde4)
#load "spells/attack.jai";
#load "spells/transposition.jai";
#load "spells/spawngobelin.jai";
#load "spells/mitose.jai";
#load "spells/illusion.jai";

spellbook: []*SpellDefinition = .[
    //Pyromancy
    *bouledefeu_spell_definition,
    *explosion_spell_definition,
    *rage_spell_definition,
    //Neuromancy
    *sentification_spell_definition,
    *lobotomie_spell_definition,
    *mindswap_spell_definition,
    *cupidon_spell_definition,
    //Bibliomancy
    *darkbook_spell_definition,
    //Necromancy
    *skull_spell_definition,
    *reanimation_spell_definition,
    *spectralform_spell_definition,
    //portals
    *portalbrain_spell_definition,
    *portalforest_spell_definition,
    *portalgraveyard_spell_definition,
    *portallibrary_spell_definition,
    *portalvolcano_spell_definition,
    //Misc
    *transposition_spell_definition,
    *spawngobelin_spell_definition,
    *mitose_spell_definition,
    *illusion_spell_definition,
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
#load "actors/ghost.jai";
#load "actors/tomb1.jai";
#load "actors/tomb2.jai";
#load "actors/portal.jai";
#load "actors/brain.jai";

// Other
#load "resources.jai";
#load "actor.jai";
#load "game.jai";
#load "game_constants.jai";
#load "mind_state.jai";
#load "player.jai";
#load "spell.jai";
#load "spellcaster.jai";
#load "tools.jai";

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

PHYSIC_LAYER_BODY :: 0;
PHYSIC_LAYER_HURTBOX :: 1;
PHYSIC_LAYER_HITBOX :: 2;

init :: ()
{
    load_all_resources();
    physics_init();
    pool_init(*actors);

    physics_set_layer_response(PHYSIC_LAYER_BODY, PHYSIC_LAYER_BODY, .COLLIDE);
    physics_set_layer_response(PHYSIC_LAYER_HURTBOX, PHYSIC_LAYER_HITBOX, .OVERLAP);

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