// PORTAL 
// This actor exist only to get spawn by the portal spells
portal_definition : = ActorDefinition.{
    init = portal_init,
    update = portal_update,

    sprite_origin = .{32,32},
    render_layer = .GROUND,
};

PortalData :: struct
{
    radius:= 32.0;
    aseprite_file: *AsepriteFile;

    actors_to_spawn: #type (actor: *Actor);
    on_finish_growing: #type (actor: *Actor);

    is_growing:= false;
    delete_actors_on_spawn: = true;
}

create_portal :: (position: Vector2, aseprite_file: *AsepriteFile, actors_to_spawn: #type (actor: *Actor) = null, on_finish_growing: #type (actor: *Actor) = null) -> *Actor
{
    portalactor: = create_actor(*portal_definition, position);
    portalactor.position.z = portal_count.(float) * 0.01;
    portaldata: = portalactor.data.(*PortalData);

    portaldata.aseprite_file = aseprite_file;
    portaldata.actors_to_spawn = actors_to_spawn;
    portaldata.on_finish_growing = on_finish_growing;

    animation_player_play(*portalactor.animation, portaldata.aseprite_file, "grow", false);
    portaldata.is_growing = true;
    return portalactor;
}

portal_init :: (using actor: *Actor)
{
    portal: = New(PortalData);
    data = portal;
    actor.y_sort = false;
    portal_count += 1;
}

portal_update :: (using actor: *Actor, dt: float)
{
    portal: = data.(*PortalData);

    if portal.is_growing
    {
        //finish growing
        if !animation.is_playing
        {
            if portal.on_finish_growing != null portal.on_finish_growing(actor);
            if portal.delete_actors_on_spawn portal_delete_actors(actor);

            animation_player_play(*animation, portal.aseprite_file, "idle", true);

            if portal.actors_to_spawn != null portal.actors_to_spawn(actor);

            portal.is_growing = false;
        }
    }
}

portal_delete_actors :: (using actor: *Actor)
{
    portal: = data.(*PortalData);

    //detect actors to delete
    targets: = physics_cast(actor.position.xy, .{ type = .CIRCLE, circle = .{ .{}, 64 } }, .[PHYSIC_LAYER_BODY]);
    for target: targets
    {
        actor_target: = target.parent.(*Actor);

        //delete actors        
        //avoid deleting actors that collide but are not in the circle
        dist:=length(actor_target.position.xy - actor.position.xy);
        if dist > portal.radius continue;

        //delete only non-sentient actors
        if actor_is_sentient(actor_target) continue;

        request_delete_actor(actor_target);
    }
}

portal_count: u32;