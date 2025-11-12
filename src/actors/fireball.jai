fireball_definition : = ActorDefinition.{
    init = fireball_init,
    update = fireball_update,

    idle_animation = .{ "fireball_aseprite", "idle" },
};

FireballData :: struct
{
    caster: ID(Actor);
    body: *Collider;
}

fireball_init :: (using actor: *Actor)
{
    movement.speed = 80;
    position.z = 1;
    fireball: = New(FireballData);
    fireball.body = actor_add_collider(actor, .{-2,-2,4,4}, PHYSIC_LAYER_SPELL);

    data = fireball;
}

fireball_update :: (using actor: *Actor, dt: float)
{
    fireball: = data.(*FireballData);
    
    if !movement.is_moving
    {
        request_delete_actor(actor);
        return;
    }

    angle = signed_angle_between(movement.target - position.xy, .{1,0});

    for o: fireball.body.frame_overlaps
    {
        target: = o.parent.(*Actor);
        if target.id == fireball.caster continue;

        set_burning(target, true);

        request_delete_actor(actor);
        return;
    }
}

shoot_fireball :: (caster: *Actor, end: Vector2) -> *Actor
{
    f: = create_actor(*fireball_definition, caster.position.xy);
    f.data.(*FireballData).caster = caster.id;
    movement_component_go_to(*f.movement, end);
    return f;
}