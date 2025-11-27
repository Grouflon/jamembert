// Spell
portalgraveyard_spell_definition : = SpellDefinition.{
    type = .POSITION,
    icon = .{ "icons_aseprite", "portal_graveyard" },
    range = 200,
    cast_func = (params: SpellCastParams) -> bool
    {
        portal: = create_actor(*portalgraveyard_definition, params.position.origin);
        portal.data.(*PortalgraveyardData).caster = params.source.id;
        return true;
    },
};


// Actor
portalgraveyard_definition : = ActorDefinition.{
    init = portalgraveyard_init,
    update = portalgraveyard_update,

    sprite_origin = .{32,32},
    render_layer = .GROUND,
};

PortalgraveyardData :: struct
{
    caster: ID(Actor);
    radius:= 32.0;
    has_finish_growing:= false;
}



portalgraveyard_init :: (using actor: *Actor)
{
    portalgraveyard: = New(PortalgraveyardData);

    data = portalgraveyard;

    animation_player_play(*animation, *resources.portalgraveyard_aseprite, "grow", false);
}


portalgraveyard_update :: (using actor: *Actor, dt: float)
{
    portalgraveyard: = data.(*PortalgraveyardData);

    //finish growing
    if !animation.is_playing && !portalgraveyard.has_finish_growing
    {
        //detect actors to delete
        targets: = physics_cast(actor.position.xy, .{ type = .CIRCLE, circle = .{ .{}, 64 } }, .[PHYSIC_LAYER_BODY]);
        for target: targets
        {
            actor_target: = target.parent.(*Actor);

            //avoid deleting actors that collide but are not in the circle
            dist:=length(actor_target.position.xy - actor.position.xy);
            if dist > portalgraveyard.radius continue;
            //delete only non-sentient actors
            if actor_is_sentient(actor_target) continue;

            request_delete_actor(actor_target);
        }

        animation_player_play(*animation, *resources.portalgraveyard_aseprite, "idle", true);
        portalgraveyard_spawn_actors(actor);
        portalgraveyard.has_finish_growing = true;
    }

    /*targets:=physics_cast(actor.position.xy, .{ type = .CIRCLE, circle = .{ .{}, 64 } }, .[PHYSIC_LAYER_BODY]);

    for target: targets
    {
        actor_target: = target.parent.(*Actor);
        if actor_is_dead(actor_target)
        {
            //resurect
            actor_modify_health(actor_target, actor_target.definition.max_health);
        }
        
    }

    portalgraveyard.duration -= dt;*/

}

#scope_file

portalgraveyard_spawn_actors :: (using actor: *Actor)
{
    origin:= actor.position.xy;
    //left
    create_actor(*tomb1_definition, origin + .{-19, 4});
    //top right
    create_actor(*tomb2_definition, origin + .{10, 18});
    //bottom right
    create_actor(*tomb1_definition, origin + .{15, -8});
}