// Spell
portalvolcano_spell_definition : = SpellDefinition.{
    type = .POSITION,
    icon = .{ "icons_aseprite", "portal_volcano" },
    range = 200,
    cast_func = (params: SpellCastParams) -> bool
    {
        portalactor: = create_actor(*portal_definition, params.position.origin);
        portaldata: = portalactor.data.(*PortalData);

        portaldata.caster = params.source.id;
        portaldata.animation = resources.portalvolcano_aseprite;
        portaldata.actors_to_spawn = portalvolcano_spawn_actors;
        portaldata.on_finish_growing = portal_burn_actors;
        return true;
    },
};

#scope_file
portalvolcano_spawn_actors :: (using actor: *Actor)
{
    origin:= actor.position.xy;
    //left
    /*create_actor(*tomb1_definition, origin + .{-19, 4});
    //top right
    create_actor(*tomb2_definition, origin + .{10, 18});
    //bottom right
    create_actor(*tomb1_definition, origin + .{15, -8});*/
}

portal_burn_actors :: (using actor: *Actor)
{
    portal: = data.(*PortalData);

    targets: = physics_cast(actor.position.xy, .{ type = .CIRCLE, circle = .{ .{}, 64 } }, .[PHYSIC_LAYER_BODY]);
    for target: targets
    {
        actor_target: = target.parent.(*Actor);
        //delete actors        
        //avoid deleting actors that collide but are not in the circle
        dist:=length(actor_target.position.xy - actor.position.xy);
        if dist > portal.radius continue;
        //delete only non-sentient actors
        //if actor_is_sentient(actor_target) continue;

        //request_delete_actor(actor_target);

        actor_set_burning(actor_target, true);
    }
}