// Spell
skull_spell_definition : = SpellDefinition.{
    type = .PROJECTILE,
    icon = .{ "icons_aseprite", "skull" },
    range = 200,
    cast_func = (params: SpellCastParams) -> bool
    {
        f: = create_actor(*skull_definition, params.projectile.origin);
        f.data.(*SkullData).caster = params.source.id;
        movement_component_go_to(*f.movement, params.projectile.origin + params.projectile.direction * skull_spell_definition.range);

        return true;
    },
};

// Actor
skull_definition : = ActorDefinition.{
    init = skull_init,
    shutdown = skull_shutdown,
    update = skull_update,

    render_layer = .OVERLAY,
    sprite_origin = .{16,16},
    speed = 80,
    idle_animation = .{ "skull_aseprite", "idle" },
};

SkullData :: struct
{
    caster: ID(Actor);
    body: *Collider;
    trail_cd: = 0.0;
    trail_cd_max: = 0.2;
    bounce: = 5;
    dammage: s32 = 1;
    hit_actors: [..]*Actor;
}

skull_init :: (using actor: *Actor)
{
    position.z = 1;
    skull: = New(SkullData);
    skull.body = actor_add_collider(actor, .{ type = .BOX, box = .{.{-5,-5}, .{5,5}} }, PHYSIC_LAYER_SPELL);

    actor.definition.speed = 80;
    data = skull;
}

skull_shutdown :: (using actor: *Actor)
{
    skull: = data.(*SkullData);

    array_free(skull.hit_actors);
}

skull_update :: (using actor: *Actor, dt: float)
{
    skull: = data.(*SkullData);
    
    if !movement.is_moving_to
    {
        request_delete_actor(actor);
        return;
    }

    angle = signed_angle_between(movement.target - position.xy, .{1,0});

    for collider: skull.body.frame_overlaps
    {
        target: = collider.parent.(*Actor);

        if target.id == skull.caster continue;
        if array_find(skull.hit_actors, target) continue;
        if actor_is_dead(target) continue;

        actor_hit(target, skull.dammage, get(skull.caster));
        movement_component_go_to(*actor.movement, rotate(.{200, 0}, random_get_within_range(0, 360)));

        array_add_if_unique(*skull.hit_actors, target);

        if skull.bounce <= 0 request_delete_actor(actor);

        actor.definition.speed += 20;
        skull.dammage += 1;
        skull.bounce -= 1;

        return;
    }


    if skull.trail_cd <= 0
    {
        create_simple_animation_actor(actor.position.xy - .{10, 16}, .{*resources.skull_aseprite, string_hash("trail")} , .OBJECTS);
        skull.trail_cd = skull.trail_cd_max;
    }
    skull.trail_cd -= dt;

}
