mage_definition : = ActorDefinition.{
    init = mage_init,
    shutdown = mage_shutdown,
    update = mage_update,
    draw = mage_draw,

    idle_animation = .{ "mage_aseprite", "idle" },
    move_animation = .{ "mage_aseprite", "walk" },
};

mage_init :: (using actor: *Actor)
{
    actor.movement.speed = 30;

    c: = actor_add_collider(actor, .{-2,-4,3,7}, PHYSIC_LAYER_BODY);
}

mage_shutdown :: (using actor: *Actor)
{
    
}

mage_update :: (using actor: *Actor, dt: float)
{
}

mage_draw :: (using actor: *Actor)
{
}