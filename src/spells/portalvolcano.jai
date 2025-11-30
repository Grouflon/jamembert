// Spell
portalvolcano_spell_definition : = SpellDefinition.{
    type = .POSITION,
    icon = .{ "icons_aseprite", "portal_volcano" },
    range = 200,
    cast_func = (params: SpellCastParams) -> bool
    {
        portal: = create_portal(params.position.origin, *resources.portalvolcano_aseprite, portalvolcano_spawn_actors, portal_burn_actors);
        portal.data.(*PortalData).delete_actors_on_spawn = false;
        return true;
    },
};

#scope_file
portalvolcano_spawn_actors :: (using actor: *Actor)
{
    origin:= actor.position.xy;
}

portal_burn_actors :: (using actor: *Actor)
{
    portal: = data.(*PortalData);

    targets: = physics_cast(actor.position.xy, .{ type = .CIRCLE, circle = .{ .{}, 64 } }, .[PHYSIC_LAYER_BODY]);
    for target: targets
    {
        actor_target: = target.parent.(*Actor);
            
        //avoid burning actors that collide but are not in the circle
        dist:=length(actor_target.position.xy - actor.position.xy);
        if dist > portal.radius continue;

        actor_set_burning(actor_target, true);
    }
}