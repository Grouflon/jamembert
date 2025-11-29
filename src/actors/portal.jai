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
    caster: ID(Actor);
    radius:= 32.0;
    animation: AsepriteFile;

    actors_to_spawn: #type (actor: *Actor);
    on_finish_growing: #type (actor: *Actor) = portal_delete_actors;

    burn_actors:=false;

    is_growing:= false;
}

portal_init :: (using actor: *Actor)
{
    portal: = New(PortalData);
    data = portal;

    //I realized it's not possible to set data to use in init because the init is called when the actor is created
    //This means this doesn't work so i made a hack in the update
    //animation_player_play(*animation, *portal.animation, "grow", false);
}

portal_update :: (using actor: *Actor, dt: float)
{
    portal: = data.(*PortalData);

    if portal.is_growing
    {
        //finish growing
        if !animation.is_playing
        {
            //log("finish grow");
            //detect actors to delete
            /*targets: = physics_cast(actor.position.xy, .{ type = .CIRCLE, circle = .{ .{}, 64 } }, .[PHYSIC_LAYER_BODY]);
            for target: targets
            {
                actor_target: = target.parent.(*Actor);

                if portal.burn_actors
                {

                }
                else
                {        
                    //delete actors        
                    //avoid deleting actors that collide but are not in the circle
                    dist:=length(actor_target.position.xy - actor.position.xy);
                    if dist > portal.radius continue;
                    //delete only non-sentient actors
                    if actor_is_sentient(actor_target) continue;

                    request_delete_actor(actor_target);
                }

            }*/
            portal.on_finish_growing(actor);

            animation_player_play(*animation, *portal.animation, "idle", true);
            portal.actors_to_spawn(actor);
            //portalgraveyard_spawn_actors(actor);
            portal.is_growing = false;
        }
    }
    else
    {        
        if animation.animation != string_hash("idle")
        {
            animation_player_play(*animation, *portal.animation, "grow", false);
            portal.is_growing = true;
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