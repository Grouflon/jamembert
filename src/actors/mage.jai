mage_definition : = ActorDefinition.{
    init = mage_init,
    shutdown = mage_shutdown,
    update = mage_update,
    draw = mage_draw,

    face_position = .{0,6},
    face_dead_position = .{0,0},

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
    body: = actor_add_collider(actor, .{ type = .BOX, box = .{.{-3, 0}, .{2,9}} }, PHYSIC_LAYER_BODY);
    actor.alterations.burning_collider.shape = .{ type = .BOX, box = dilate(body.shape.box, .{2,1}) };
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