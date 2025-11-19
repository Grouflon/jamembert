// Spell
attack_spell_definition : = SpellDefinition.{
    type = .PROJECTILE,
    cast_func = (params: SpellCastParams)
    {
        attack: = create_actor(*attack_definition, params.projectile.origin + params.projectile.direction * 8);
        attack.angle = signed_angle_between(params.projectile.direction, .{1,0});
        attack.data.(*AttackData).caster = params.source.id;
    },
};

// Actor
attack_definition : = ActorDefinition.{
    init = attack_init,
    update = attack_update,
    shutdown = attack_shutdown,

    sprite_origin = .{8,8},
    render_layer = .OVERLAY,
};

AttackData :: struct
{
    caster: ID(Actor);
    body: *Collider;
    hit_actors: [..]*Actor;
}

attack_init :: (using actor: *Actor)
{
    attack: = New(AttackData);
    attack.body = actor_add_collider(actor, .{ type = .BOX, box = .{.{-5,-5}, .{5,5}} }, PHYSIC_LAYER_SPELL);
    data = attack;
    
    animation_player_play(*animation, *resources.attack_smear_aseprite, "attack", false);
}

attack_shutdown :: (using actor: *Actor)
{
    attack: = data.(*AttackData);
    array_free(attack.hit_actors);
}


attack_update :: (using actor: *Actor, dt: float)
{
    attack: = data.(*AttackData);

    if !animation.is_playing
    {
        request_delete_actor(actor);
        return;
    }

    for collider: attack.body.frame_overlaps
    {
        target: = collider.parent.(*Actor);
        if target.id == attack.caster continue;
        if array_find(attack.hit_actors, target) continue;

        actor_hit(target, get(attack.caster));
        array_add_if_unique(*attack.hit_actors, target);
    }
}
