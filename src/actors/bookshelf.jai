bookshelf_definition : = ActorDefinition.{
    init = bookshelf_init,

    idle_hollow_animation = .{ "bookshelf_aseprite", "idle_hollow" },
    idle_animation = .{ "bookshelf_aseprite", "idle" },
    move_animation = .{ "bookshelf_aseprite", "walk" },
    dead_animation = .{ "bookshelf_aseprite", "dead" },

    sprite_origin = .{16,1},

    max_health = -1,
    speed = 3,
};

bookshelf_init :: (using actor: *Actor)
{
    body: = actor_add_collider(actor, .{ type = .BOX, box = .{.{-11, 0}, .{11,26}} }, PHYSIC_LAYER_BODY, true);
    actor.alterations.burning_collider.shape = .{ type = .BOX, box = dilate(body.shape.box, .{2,1}) };
}
