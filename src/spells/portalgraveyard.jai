// Spell
portalgraveyard_spell_definition : = SpellDefinition.{
    type = .POSITION,
    icon = .{ "icons_aseprite", "portal_graveyard" },
    range = 200,
    cast_func = (params: SpellCastParams) -> bool
    {
        portalactor: = create_actor(*portal_definition, params.position.origin);
        portaldata: = portalactor.data.(*PortalData);

        portaldata.caster = params.source.id;
        portaldata.animation = resources.portalgraveyard_aseprite;
        portaldata.actors_to_spawn = portalgraveyard_spawn_actors;
        return true;
    },
};

#scope_file
portalgraveyard_spawn_actors :: (using actor: *Actor)
{
    portalpos:= actor.position.xy;

    tombs: []*ActorDefinition = .[
        *tomb1_definition,
        *tomb2_definition,
    ];

    //left
    _, tomb: = random_get_array_item(tombs);
    create_actor(tomb, portalpos + .{-19, 4});
    //top right
    _, tomb = random_get_array_item(tombs);
    create_actor(tomb, portalpos + .{10, 18});
    //bottom right
    _, tomb = random_get_array_item(tombs);
    create_actor(tomb, portalpos + .{15, -8});
}