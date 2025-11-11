// Tree
tree_definition : = ActorDefinition.{
    init = tree_init,
    burn = tree_burn,

    idle_animation = .{ "tree_aseprite", "idle" },
};

tree_init :: (using actor: *Actor)
{
    actor_add_collider(actor, .{-2,-7,5,10}, PHYSIC_LAYER_BODY, true);
}

tree_burn :: (using actor: *Actor)
{
    actor_set_definition(actor, *burning_tree_definition);
}

// Burning Tree
burning_tree_definition : = ActorDefinition.{
    init = burning_tree_init,
    update = burning_tree_update,

    idle_animation = .{ "tree_aseprite", "burning" },
};

BurningTreeData :: struct
{
    timer: float;
};

burning_tree_init :: (using actor: *Actor)
{
    actor_add_collider(actor, .{-2,-7,5,10}, PHYSIC_LAYER_BODY, true);
    burning_tree.timer = 2.0;
}

burning_tree_update :: (using actor: *Actor, dt: float)
{
    burning_tree.timer -= dt;
    if burning_tree.timer <= 0
    {
        actor_set_definition(actor, *burnt_tree_definition);
        return;
    }
}

// Burnt tree
burnt_tree_definition : = ActorDefinition.{
    init = burnt_tree_init,

    idle_animation = .{ "tree_aseprite", "burnt" },
};

burnt_tree_init :: (using actor: *Actor)
{
    actor_add_collider(actor, .{-2,-7,5,6}, PHYSIC_LAYER_BODY, true);
}
