// Tree
tree_definition : = ActorDefinition.{
    init = tree_init,

    sprite_origin = .{15,1},
    idle_hollow_animation = .{ "tree_aseprite", "idle_hollow" },
    idle_animation = .{ "tree_aseprite", "idle" },
    move_animation = .{ "tree_aseprite", "walk" },
    dead_animation = .{ "tree_aseprite", "dead" },
    max_health = 10,
    speed = 10,
    is_static = true,
};

tree_init :: (using actor: *Actor)
{
}
