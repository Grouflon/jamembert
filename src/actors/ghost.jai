ghost_definition : = ActorDefinition.{
    init = ghost_init,
    shutdown = ghost_shutdown,
    update = ghost_update,
    draw = ghost_draw,
    on_hit = ghost_on_hit,

    face_idle_animation = "ghost_idle",
    face_dead_animation = "noface",
    face_panic_animation = "ghost_idle",
    face_mad_animation = "ghost_mad",

    idle_hollow_animation = .{ "ghost_aseprite", "idle_hollow" },
    idle_animation = .{ "ghost_aseprite", "idle" },
    move_animation = .{ "ghost_aseprite", "idle" },
    dead_animation = .{ "goblin_aseprite", "idle_hollow" },

    max_health = 1,
    speed = 30,
    
    attack_cooldown = 1,
    attack_range = 5,
};

ghost_init :: (using actor: *Actor)
{
    actor_set_sentient(actor, true);

    //actor.ai.is_agressive = false;
}

ghost_on_hit :: (using actor: *Actor, source: *Actor)
{
    if actor_is_dead(actor)
    {
        request_delete_actor(actor);
    }
}

ghost_shutdown :: (using actor: *Actor)
{
}

ghost_update :: (using actor: *Actor, dt: float)
{
}

ghost_draw :: (using actor: *Actor)
{
}