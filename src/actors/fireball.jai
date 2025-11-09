fireball_definition : = ActorDefinition.{
    init = fireball_init,
    shutdown = fireball_shutdown,
    update = fireball_update,
    draw = fireball_draw,

    idle_animation = .{ "fireball_aseprite", "idle" },
};

fireball_init :: (using actor: *Actor)
{
    movement.speed = 80;
    position.z = 1;
}

fireball_shutdown :: (using actor: *Actor)
{
}

fireball_update :: (using actor: *Actor, dt: float)
{
    if !movement.is_moving
    {
        delete_actor(actor);
        return;
    }

    angle = signed_angle_between(movement.target - position.xy, .{1,0});
}

fireball_draw :: (using actor: *Actor)
{
}

shoot_fireball :: (start: Vector2, end: Vector2) -> *Actor
{
    f: = create_actor(*fireball_definition, start);
    movement_component_go_to(*f.movement, end);
    return f;
}