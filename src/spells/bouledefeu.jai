// Spell
bouledefeu_spell_definition : = SpellDefinition.{
    type = .PROJECTILE,
    icon = .{ "icons_aseprite", "bouledefeu" },
    range = 200,
    cast_func = (params: SpellCastParams) -> bool
    {
        f: = create_actor(*bouledefeu_definition, params.projectile.origin);
        f.data.(*BouledefeuData).caster = params.source.id;
        movement_component_go_to(*f.movement, params.projectile.origin + params.projectile.direction * bouledefeu_spell_definition.range);

        return true;
    },
};

// Actor
bouledefeu_definition : = ActorDefinition.{
    init = bouledefeu_init,
    update = bouledefeu_update,

    render_layer = .OVERLAY,
    sprite_origin = .{16,16},
    speed = 80,
    idle_animation = .{ "fireball_aseprite", "idle" },
};

BouledefeuData :: struct
{
    caster: ID(Actor);
    body: *Collider;
    trail_cooldown: = 0.0;
    trail_duration: = 0.2; // Does not need to be a variable
}

bouledefeu_init :: (using actor: *Actor)
{
    position.z = 1;
    bouledefeu: = New(BouledefeuData);
    data = bouledefeu;
}

bouledefeu_update :: (using actor: *Actor, dt: float)
{
    bouledefeu: = data.(*BouledefeuData);
    
    if !movement.is_moving_to
    {
        request_delete_actor(actor);
        return;
    }

    angle = signed_angle_between(movement.target - position.xy, .{1,0});

    for hitbox: hitboxes
    {
        for collider: hitbox.frame_overlaps
        {
            target: = collider.parent.(*Actor);
            if target.id == bouledefeu.caster continue;
            if actor_is_dead(target) continue;

            actor_set_burning(target, true);

            request_delete_actor(actor);
            return;
        }
    }

    if bouledefeu.trail_cooldown <= 0
    {
        create_simple_animation_actor(actor.position.xy - .{10, 16}, .{*resources.fireball_aseprite, string_hash("trail")} , .OBJECTS);
        bouledefeu.trail_cooldown = bouledefeu.trail_duration;
    }
    bouledefeu.trail_cooldown -= dt;
}
