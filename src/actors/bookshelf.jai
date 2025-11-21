bookshelf_definition : = ActorDefinition.{
    init = bookshelf_init,
    on_hit = bookshelf_on_hit,

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

bookshelf_on_hit :: (using actor: *Actor, source: *Actor)
{
    if actor_is_dead(actor) return;

    projection_angle: = random_get_within_range(D2R * 200, D2R * 340);
    projection_strength: = random_get_within_range(80, 110);

    book: = create_actor(*book_definition, actor.position.xy);

    movement_component_push(*book.movement, rotate(.{projection_strength, 0}, projection_angle));
}