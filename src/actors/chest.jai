chest_definition : = ActorDefinition.{
    init = chest_init,
    shutdown = chest_shutdown,
    update = chest_update,
    draw = chest_draw,

    face_position = .{0,7},
    face_dead_position = .{0,2},

    face_idle_animation = "noface",
    face_dead_animation = "noface",
    face_panic_animation = "noface",
    face_mad_animation = "noface",

    idle_hollow_animation = .{ "chest_aseprite", "idle_hollow" },
    idle_animation = .{ "chest_aseprite", "idle" },
    move_animation = .{ "chest_aseprite", "walk" },
    dead_animation = .{ "chest_aseprite", "dead" },

    max_health = 8,
    speed = 30,
    
    attack_cooldown = 0.5,
};

chest_init :: (using actor: *Actor)
{
    body: = actor_add_collider(actor, .{ type = .BOX, box = .{.{-6, 0}, .{6,8}} }, PHYSIC_LAYER_BODY);
    actor.alterations.burning_collider.shape = .{ type = .BOX, box = dilate(body.shape.box, .{2,1}) };
    //actor_set_sentient(actor, true);

    //actor.ai.is_agressive = true;
}

chest_shutdown :: (using actor: *Actor)
{
}

chest_update :: (using actor: *Actor, dt: float)
{
}

chest_draw :: (using actor: *Actor)
{
}