tree_definition : = ActorDefinition.{
    init = tree_init,
    shutdown = tree_shutdown,
    update = tree_update,
    draw = tree_draw,

    idle_animation = .{ "tree_aseprite", "idle" },
};

tree_init :: (using actor: *Actor)
{
    actor_add_collider(actor, .{-2,-7,5,10}, LAYER_BODY, true);
}

tree_shutdown :: (using actor: *Actor)
{
}

tree_update :: (using actor: *Actor, dt: float)
{
}

tree_draw :: (using actor: *Actor)
{
}