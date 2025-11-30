mage3_definition : = ActorDefinition.{
    init = mage3_init,
    shutdown = mage3_shutdown,
    update = mage3_update,
    draw = mage3_draw,

    face_position = .{0,6},
    face_dead_position = .{0,0},

    face_idle_animation = "mage3_idle",
    face_mad_animation = "mage3_mad",

    idle_hollow_animation = .{ "mage3_aseprite", "idle_hollow" },
    idle_animation = .{ "mage3_aseprite", "idle" },
    move_animation = .{ "mage3_aseprite", "walk" },
    dead_animation = .{ "mage3_aseprite", "dead" },
    cast_animation = .{ "mage3_aseprite", "cast" },

    max_health = 6,
    speed = 30,

    attack_damage = 0,
};

mage3_init :: (using actor: *Actor)
{
    body: = actor_add_collider(actor, .{ type = .BOX, box = .{.{-3, 0}, .{2,9}} }, PHYSIC_LAYER_BODY);
    actor.alterations.burning_collider.shape = .{ type = .BOX, box = dilate(body.shape.box, .{2,1}) };
    actor_set_sentient(actor, true);
}

mage3_shutdown :: (using actor: *Actor)
{
    
}

mage3_update :: (using actor: *Actor, dt: float)
{
}

mage3_draw :: (using actor: *Actor)
{
}