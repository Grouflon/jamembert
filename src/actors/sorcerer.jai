sorcerer_definition : = ActorDefinition.{
    init = sorcerer_init,
    shutdown = sorcerer_shutdown,
    update = sorcerer_update,
    draw = sorcerer_draw,

    idle_animation = .{ "sorcerer_aseprite", "idle" },
    move_animation = .{ "sorcerer_aseprite", "walk" },
};

sorcerer_init :: (using actor: *Actor)
{
    actor.movement.speed = 30;

    c: = actor_add_collider(actor, .{-2,-4,3,7}, LAYER_BODY);
}

sorcerer_shutdown :: (using actor: *Actor)
{
    
}

sorcerer_update :: (using actor: *Actor, dt: float)
{
}

sorcerer_draw :: (using actor: *Actor)
{
}