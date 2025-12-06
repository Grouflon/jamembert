// Spell
reanimation_spell_definition : = SpellDefinition.{
    type = .POSITION,
    icon = .{ "icons_aseprite", "reanimation" },
    cast_func = (params: SpellCastParams) -> bool
    {
        circ: = create_actor(*reanimation_definition, params.position.origin);
        circ.data.(*ReanimationData).caster = params.source.id;
        return true;
    },
};


// Actor
reanimation_definition : = ActorDefinition.{
    init = reanimation_init,
    update = reanimation_update,

    sprite_origin = .{32,32},
    render_layer = .GROUND,
};

ReanimationData :: struct
{
    caster: ID(Actor);
    body: *Collider;
    duration : = 10.0;
}



reanimation_init :: (using actor: *Actor)
{
    reanimation: = New(ReanimationData);
    //reanimation.body = actor_add_collider(actor, .{ type = .BOX, box = .{.{-15,-15}, .{15,15}} }, PHYSIC_LAYER_SPELL);

    data = reanimation;

    animation_player_play(*animation, *resources.reanimation_aseprite, "idle", true);
}


reanimation_update :: (using actor: *Actor, dt: float)
{
    reanimation: = data.(*ReanimationData);

    if reanimation.duration <=0
    {
        request_delete_actor(actor);
    }

    targets: =physics_cast(actor.position.xy, .{ type = .CIRCLE, circle = .{ .{}, 64 } }, .[PHYSIC_LAYER_HURTBOX]);

    for target: targets
    {
        actor_target: = target.parent.(*Actor);
        if actor_is_dead(actor_target)
        {
            //resurect
            actor_modify_health(actor_target, actor_target.definition.max_health);
        }
        
    }

    reanimation.duration -= dt;

}