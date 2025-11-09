my_actor_definition : = ActorDefinition.{
    init = my_actor_init,
    shutdown = my_actor_shutdown,
    update = my_actor_update,
    draw = my_actor_draw,

    idle_animation = .{ "my_actor_aseprite", "idle" },
};

my_actor_init :: (using actor: *Actor)
{
}

my_actor_shutdown :: (using actor: *Actor)
{
}

my_actor_update :: (using actor: *Actor, dt: float)
{
}

my_actor_draw :: (using actor: *Actor)
{
}