goblin_definition : = ActorDefinition.{
    init = goblin_init,
    shutdown = goblin_shutdown,
    update = goblin_update,
    draw = goblin_draw,

    face_idle_animation = "goblin_idle",
    face_mad_animation = "goblin_mad",

    idle_hollow_animation = .{ "goblin_aseprite", "idle_hollow" },
    idle_animation = .{ "goblin_aseprite", "idle" },
    move_animation = .{ "goblin_aseprite", "walk" },
    dead_animation = .{ "goblin_aseprite", "dead" },

    max_health = 3,
    
    attack_cooldown = 0.5,
    attack_range = 9,
};

goblin_init :: (using actor: *Actor)
{
    actor_set_sentient(actor, true);

    actor.ai.is_agressive = true;
}

goblin_shutdown :: (using actor: *Actor)
{
}

goblin_update :: (using actor: *Actor, dt: float)
{
}

goblin_draw :: (using actor: *Actor)
{
}