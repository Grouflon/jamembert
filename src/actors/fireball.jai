fireball_definition : = ActorDefinition.{
    init = fireball_init,
    shutdown = fireball_shutdown,
    update = fireball_update,
    draw = fireball_draw,

    idle_animation = .{ "fireball_aseprite", "idle" },
};

FireballData :: struct
{
    caster: ID(Actor);
}

fireball_init :: (using actor: *Actor)
{
    movement.speed = 80;
    position.z = 1;

    actor_add_collider(actor, .{-2,-2,4,4}, PHYSIC_LAYER_SPELL);
}

fireball_shutdown :: (using actor: *Actor)
{
}

fireball_update :: (using actor: *Actor, dt: float)
{
    if !movement.is_moving
    {
        request_delete_actor(actor);
        return;
    }

    angle = signed_angle_between(movement.target - position.xy, .{1,0});

    for o: colliders[0].frame_overlaps
    {
        target: = cast(*Actor)o.parent;
        if target.id == fireball.caster continue;

        actor_burn(target);

        request_delete_actor(actor);
        return;
    }
}

fireball_draw :: (using actor: *Actor)
{
}

shoot_fireball :: (caster: *Actor, end: Vector2) -> *Actor
{
    f: = create_actor(*fireball_definition, caster.position.xy);
    f.fireball.caster = caster.id;
    movement_component_go_to(*f.movement, end);
    return f;
}