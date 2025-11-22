goblin_definition : = ActorDefinition.{
    init = goblin_init,
    shutdown = goblin_shutdown,
    update = goblin_update,
    draw = goblin_draw,

    face_position = .{0,7},
    face_dead_position = .{0,2},

    face_idle_animation = "goblin_idle",
    face_mad_animation = "goblin_mad",

    idle_hollow_animation = .{ "goblin_aseprite", "idle_hollow" },
    idle_animation = .{ "goblin_aseprite", "idle" },
    move_animation = .{ "goblin_aseprite", "walk" },
    dead_animation = .{ "goblin_aseprite", "dead" },

    max_health = 3,
    
    attack_cooldown = 0.5,
};

goblin_init :: (using actor: *Actor)
{
    body: = actor_add_collider(actor, .{ type = .BOX, box = .{.{-3, 0}, .{2,9}} }, PHYSIC_LAYER_BODY);
    actor.alterations.burning_collider.shape = .{ type = .BOX, box = dilate(body.shape.box, .{2,1}) };
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