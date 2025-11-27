ghost_definition : = ActorDefinition.{
    init = ghost_init,
    shutdown = ghost_shutdown,
    update = ghost_update,
    draw = ghost_draw,
    on_hit = ghost_on_hit,

    face_position = .{0,7},

    face_idle_animation = "noface",
    face_dead_animation = "noface",
    face_panic_animation = "noface",
    face_mad_animation = "noface",

    idle_hollow_animation = .{ "ghost_aseprite", "idle_hollow" },
    idle_animation = .{ "ghost_aseprite", "idle" },
    move_animation = .{ "ghost_aseprite", "idle" },
    dead_animation = .{ "goblin_aseprite", "idle_hollow" },

    max_health = 1,
    speed = 30,
    
    attack_cooldown = 1,
    attack_range = 5,
};

ghost_init :: (using actor: *Actor)
{
    body: = actor_add_collider(actor, .{ type = .BOX, box = .{.{-3, 3}, .{2,13}} }, PHYSIC_LAYER_BODY);
    actor.alterations.burning_collider.shape = .{ type = .BOX, box = dilate(body.shape.box, .{2,1}) };
    actor_set_sentient(actor, true);

    //actor.ai.is_agressive = false;
}

ghost_on_hit :: (using actor: *Actor, source: *Actor)
{
    if actor_is_dead(actor)
    {
        request_delete_actor(actor);
    }
}

ghost_shutdown :: (using actor: *Actor)
{
}

ghost_update :: (using actor: *Actor, dt: float)
{
}

ghost_draw :: (using actor: *Actor)
{
}