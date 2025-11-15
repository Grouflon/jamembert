// Spell
bouledefeu_spell_definition : = SpellDefinition.{
    type = .PROJECTILE,
    icon = .{ "icons_aseprite", "bouledefeu" },
    range = 200,
    cast_func = (params: SpellCastParams)
    {
        f: = create_actor(*bouledefeu_definition, params.source.position.xy);
        f.data.(*bouledefeuData).caster = params.source.id;
        movement_component_go_to(*f.movement, params.source.position.xy + params.projectile.direction * bouledefeu_spell_definition.range);
    },
};

// Actor
bouledefeu_definition : = ActorDefinition.{
    init = bouledefeu_init,
    update = bouledefeu_update,

    idle_animation = .{ "fireball_aseprite", "idle" },
};

bouledefeuData :: struct
{
    caster: ID(Actor);
    body: *Collider;
}

bouledefeu_init :: (using actor: *Actor)
{
    movement.speed = 80;
    position.z = 1;
    bouledefeu: = New(bouledefeuData);
    bouledefeu.body = actor_add_collider(actor, .{-2,-2,4,4}, PHYSIC_LAYER_SPELL);

    data = bouledefeu;
}

bouledefeu_update :: (using actor: *Actor, dt: float)
{
    bouledefeu: = data.(*bouledefeuData);
    
    if !movement.is_moving
    {
        request_delete_actor(actor);
        return;
    }

    angle = signed_angle_between(movement.target - position.xy, .{1,0});

    for o: bouledefeu.body.frame_overlaps
    {
        target: = o.parent.(*Actor);
        if target.id == bouledefeu.caster continue;

        set_burning(target, true);

        request_delete_actor(actor);
        return;
    }
}
