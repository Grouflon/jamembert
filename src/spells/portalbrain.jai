// Spell
portalbrain_spell_definition : = SpellDefinition.{
    type = .POSITION,
    icon = .{ "icons_aseprite", "portal_brain" },
    range = 200,
    cast_func = (params: SpellCastParams) -> bool
    {
        portalactor: = create_actor(*portal_definition, params.position.origin);
        portaldata: = portalactor.data.(*PortalData);

        portaldata.caster = params.source.id;
        portaldata.animation = resources.portalbrain_aseprite;
        portaldata.actors_to_spawn = portalbrain_spawn_actors;
        return true;
    },
};

#scope_file
portalbrain_spawn_actors :: (using actor: *Actor)
{
    origin:= actor.position.xy;
    /*//left
    create_actor(*tree_definition, origin + .{-19, 4});
    //top right
    create_actor(*tree_definition, origin + .{10, 18});
    //bottom right
    create_actor(*tree_definition, origin + .{15, -8});*/
}