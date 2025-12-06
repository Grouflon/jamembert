// Spell
illusion_spell_definition : = SpellDefinition.{
    type = .POSITION,
    icon = .{ "icons_aseprite", "illusion" },
    cast_func = (params: SpellCastParams) -> bool
    {
        ill: = create_actor(*illusion_definition, params.position.origin);
        ill.data.(*IllusionData).caster = params.source.id;
        return true;
    },
};

// Actor
illusion_definition : = ActorDefinition.{
    init = illusion_init,
    update = illusion_update,
    shutdown = illusion_shutdown,

    face_idle_animation = "noface",
    face_dead_animation = "noface",
    face_panic_animation = "noface",
    face_mad_animation = "noface",
    
    idle_hollow_animation = .{ "illusion_aseprite", "idle" },
    idle_animation = .{ "illusion_aseprite", "idle" },
    move_animation = .{ "illusion_aseprite", "idle" },
    dead_animation = .{ "illusion_aseprite", "idle" },


    max_health = -1,
    speed = 0,

    sprite_origin = .{8,4},
    render_layer = .OBJECTS,
};

IllusionData :: struct
{
    caster: ID(Actor);
    affected_actors: [..]*Actor;
    duration : = 10.0;
}



illusion_init :: (using actor: *Actor)
{
    illusion: = New(IllusionData);

    actor_set_sentient(actor, true);

    data = illusion;

    //animation_player_play(*animation, *resources.illusion_aseprite, "idle", true);
}


illusion_update :: (using actor: *Actor, dt: float)
{
    illusion: = data.(*IllusionData);

    targets: = physics_cast(actor.position.xy, .{ type = .CIRCLE, circle = .{ .{}, 128 } }, .[PHYSIC_LAYER_HURTBOX]);

    for target: targets
    {
        actor_target: = target.parent.(*Actor);

        if array_find(illusion.affected_actors, actor_target) continue;
        if !actor_is_sentient(actor_target) continue;
        if !actor_target.ai.is_agressive continue;
        if (actor_target.ai.target==actor) continue;

        //attract
        //log("attract");
        actor_target.ai.target = actor;
        array_add_if_unique(*illusion.affected_actors, actor_target);
        
    }


    //log("%", illusion.duration);
    if illusion.duration <=0
    {
        //log("delete");
        request_delete_actor(actor);
    }
    illusion.duration -= dt;

}

illusion_shutdown :: (using actor: *Actor)
{
    illusion: = data.(*IllusionData);

    for affected_actor: illusion.affected_actors
    {
        affected_actor.ai.target = null;
    }
    array_free(illusion.affected_actors);
}