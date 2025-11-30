mage4_definition : = ActorDefinition.{
    init = mage4_init,
    shutdown = mage4_shutdown,
    update = mage4_update,
    draw = mage4_draw,

    face_idle_animation = "mage4_idle",
    face_mad_animation = "mage4_mad",

    idle_hollow_animation = .{ "mage4_aseprite", "idle_hollow" },
    idle_animation = .{ "mage4_aseprite", "idle" },
    move_animation = .{ "mage4_aseprite", "walk" },
    dead_animation = .{ "mage4_aseprite", "dead" },
    cast_animation = .{ "mage4_aseprite", "cast" },

    max_health = 6,
    speed = 30,

    attack_damage = 0,
};

mage4_init :: (using actor: *Actor)
{
    actor_set_sentient(actor, true);
}

mage4_shutdown :: (using actor: *Actor)
{
    
}

mage4_update :: (using actor: *Actor, dt: float)
{
}

mage4_draw :: (using actor: *Actor)
{
}