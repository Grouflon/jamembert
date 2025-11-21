// Tree
tree_definition : = ActorDefinition.{
    init = tree_init,

    sprite_origin = .{15,1},
    face_position = .{0,5},
    idle_hollow_animation = .{ "tree_aseprite", "idle_hollow" },
    idle_animation = .{ "tree_aseprite", "idle" },
    move_animation = .{ "tree_aseprite", "walk" },
    dead_animation = .{ "tree_aseprite", "dead" },
    max_health = 10,
    speed = 10,
};

tree_init :: (using actor: *Actor)
{
    body: = actor_add_collider(actor, .{ type = .BOX, box = .{.{-5,0}, .{2,10}} }, PHYSIC_LAYER_BODY, true);
    actor.alterations.burning_collider.shape = .{ type = .BOX, box = .{.{-9,4}, .{9,23}} };
}
