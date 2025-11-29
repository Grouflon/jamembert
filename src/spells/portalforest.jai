// Spell
portalforest_spell_definition : = SpellDefinition.{
    type = .POSITION,
    icon = .{ "icons_aseprite", "portal_forest" },
    range = 200,
    cast_func = (params: SpellCastParams) -> bool
    {
        portalactor: = create_actor(*portal_definition, params.position.origin);
        portaldata: = portalactor.data.(*PortalData);

        portaldata.caster = params.source.id;
        portaldata.animation = resources.portalforest_aseprite;
        portaldata.actors_to_spawn = portalforest_spawn_actors;
        return true;
    },
};

#scope_file
portalforest_spawn_actors :: (using actor: *Actor)
{
    portalpos:= actor.position.xy;
    treecount: = cast(u32) random_get_within_range(3,5);
    for tree : 0..treecount
    {
        pos: Vector2 = .{random_get_within_range(-16,16), random_get_within_range(-22,16)};
        create_actor(*tree_definition, portalpos + pos);
    }
    //left
    //create_actor(*tree_definition, portalpos + .{-19, 4});
    //top right
    //create_actor(*tree_definition, portalpos + .{10, 18});
    //bottom right
    //create_actor(*tree_definition, portalpos + .{15, -8});
}