// Spell
bouledefeu_spell_definition : = SpellDefinition.{
    type = .PROJECTILE,
    icon = .{ "icons_aseprite", "bouledefeu" },
    range = 200,
    cast_func = (params: SpellCastParams)
    {
        f: = create_actor(*bouledefeu_definition, params.projectile.origin);
        f.data.(*BouledefeuData).caster = params.source.id;
        movement_component_go_to(*f.movement, params.projectile.origin + params.projectile.direction * bouledefeu_spell_definition.range);
    },
};

// Actor
bouledefeu_definition : = ActorDefinition.{
    init = bouledefeu_init,
    update = bouledefeu_update,

    draw_offset = .{-8,-8},
    idle_animation = .{ "fireball_aseprite", "idle" },
};

BouledefeuData :: struct
{
    caster: ID(Actor);
    body: *Collider;
}

bouledefeu_init :: (using actor: *Actor)
{
    movement.speed = 80;
    position.z = 1;
    bouledefeu: = New(BouledefeuData);
    bouledefeu.body = actor_add_collider(actor, .{ type = .BOX, box = .{.{-2,-2}, .{2,2}} }, PHYSIC_LAYER_SPELL);

    data = bouledefeu;
}

bouledefeu_update :: (using actor: *Actor, dt: float)
{
    bouledefeu: = data.(*BouledefeuData);
    
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
