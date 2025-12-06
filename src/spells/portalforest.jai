// Spell
portalforest_spell_definition : = SpellDefinition.{
    type = .POSITION,
    icon = .{ "icons_aseprite", "portal_forest" },
    cast_func = (params: SpellCastParams) -> bool
    {
        create_portal(params.position.origin, *resources.portalforest_aseprite, portalforest_spawn_actors);
        return true;
    },
};

#scope_file
portalforest_spawn_actors :: (using actor: *Actor)
{
    portalpos:= actor.position.xy;
    /*treecount: = cast(u32) random_get_within_range(3,5);
    for tree : 0..treecount
    {
        pos: Vector2 = .{random_get_within_range(-16,16), random_get_within_range(-22,16)};
        create_actor(*tree_definition, portalpos + pos);
    }*/
    
    create_actor(*tree_definition, portalpos + .{0, 26});
    create_actor(*tree_definition, portalpos + .{18, 18});
    create_actor(*tree_definition, portalpos + .{26, 0});
    create_actor(*tree_definition, portalpos + .{18, -18});
    create_actor(*tree_definition, portalpos + .{0, -26});
    create_actor(*tree_definition, portalpos + .{-18, -18});
    create_actor(*tree_definition, portalpos + .{-26, 0});
    create_actor(*tree_definition, portalpos + .{-18, 18});
    //create_actor(*tree_definition, portalpos + .{10, 18});
    //create_actor(*tree_definition, portalpos + .{15, -8});
}