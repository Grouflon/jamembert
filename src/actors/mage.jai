mage1_definition : = ActorDefinition.{
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

// Variants
mage2_definition := #run () -> ActorDefinition
{
    def: = mage1_definition;
    def.idle_hollow_animation = .{ "mage2_aseprite", "idle_hollow" };
    def.idle_animation = .{ "mage2_aseprite", "idle" };
    def.move_animation = .{ "mage2_aseprite", "walk" };
    def.dead_animation = .{ "mage2_aseprite", "dead" };
    def.cast_animation = .{ "mage2_aseprite", "cast" };
    return def;
}();

mage3_definition := #run () -> ActorDefinition
{
    def: = mage1_definition;
    def.face_idle_animation = "mage3_idle";
    def.face_mad_animation = "mage3_mad";
    def.idle_hollow_animation = .{ "mage3_aseprite", "idle_hollow" };
    def.idle_animation = .{ "mage3_aseprite", "idle" };
    def.move_animation = .{ "mage3_aseprite", "walk" };
    def.dead_animation = .{ "mage3_aseprite", "dead" };
    def.cast_animation = .{ "mage3_aseprite", "cast" };
    return def;
}();

mage4_definition := #run () -> ActorDefinition
{
    def: = mage1_definition;
    def.face_idle_animation = "mage4_idle";
    def.face_mad_animation = "mage4_mad";
    def.idle_hollow_animation = .{ "mage4_aseprite", "idle_hollow" };
    def.idle_animation = .{ "mage4_aseprite", "idle" };
    def.move_animation = .{ "mage4_aseprite", "walk" };
    def.dead_animation = .{ "mage4_aseprite", "dead" };
    def.cast_animation = .{ "mage4_aseprite", "cast" };
    return def;
}();