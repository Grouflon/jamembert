mage2_definition : = ActorDefinition.{
    init = mage2_init,
    shutdown = mage2_shutdown,
    update = mage2_update,
    draw = mage2_draw,

    idle_hollow_animation = .{ "mage2_aseprite", "idle_hollow" },
    idle_animation = .{ "mage2_aseprite", "idle" },
    move_animation = .{ "mage2_aseprite", "walk" },
    dead_animation = .{ "mage2_aseprite", "dead" },
    cast_animation = .{ "mage2_aseprite", "cast" },

    max_health = 6,
    speed = 30,

    attack_damage = 0,
};

mage2_init :: (using actor: *Actor)
{
    actor_set_sentient(actor, true);
}

mage2_shutdown :: (using actor: *Actor)
{
    
}

mage2_update :: (using actor: *Actor, dt: float)
{
}

mage2_draw :: (using actor: *Actor)
{
}