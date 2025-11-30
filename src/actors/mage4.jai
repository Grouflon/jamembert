mage4_definition : = ActorDefinition.{
    init = mage4_init,
    shutdown = mage4_shutdown,
    update = mage4_update,
    draw = mage4_draw,

    face_position = .{0,6},
    face_dead_position = .{0,0},

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
    body: = actor_add_collider(actor, .{ type = .BOX, box = .{.{-3, 0}, .{2,9}} }, PHYSIC_LAYER_BODY);
    actor.alterations.burning_collider.shape = .{ type = .BOX, box = dilate(body.shape.box, .{2,1}) };
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