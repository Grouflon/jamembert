goblin_definition : = ActorDefinition.{
    init = goblin_init,
    shutdown = goblin_shutdown,
    update = goblin_update,
    draw = goblin_draw,

    face_position = .{0,7},
    dead_face_position = .{0,2},

    idle_hollow_animation = .{ "goblin_aseprite", "idle_hollow" },
    idle_animation = .{ "goblin_aseprite", "idle" },
    move_animation = .{ "goblin_aseprite", "walk" },
    dead_animation = .{ "goblin_aseprite", "dead" },

    max_health = 3,
};

goblin_init :: (using actor: *Actor)
{
    actor.movement.speed = 30;

    body: = actor_add_collider(actor, .{ type = .BOX, box = .{.{-3, 0}, .{2,9}} }, PHYSIC_LAYER_BODY);
    actor.alterations.burning_collider.shape = .{ type = .BOX, box = dilate(body.shape.box, .{2,1}) };
    actor_set_sentient(actor, true);
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