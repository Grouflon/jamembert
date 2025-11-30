mage_definition : = ActorDefinition.{
    init = mage_init,
    shutdown = mage_shutdown,
    update = mage_update,
    draw = mage_draw,

    idle_hollow_animation = .{ "mage_aseprite", "idle_hollow" },
    idle_animation = .{ "mage_aseprite", "idle" },
    move_animation = .{ "mage_aseprite", "walk" },
    dead_animation = .{ "mage_aseprite", "dead" },
    cast_animation = .{ "mage_aseprite", "cast" },

    max_health = 6,
    speed = 30,

    attack_damage = 0,
};

mage_init :: (using actor: *Actor)
{
    actor_set_sentient(actor, true);
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