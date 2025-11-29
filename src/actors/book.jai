book_definition : = ActorDefinition.{
    init = book_init,
    update = book_update,

    idle_hollow_animation = .{ "book_aseprite", "idle_hollow" },
    idle_animation = .{ "book_aseprite", "idle" },
    move_animation = .{ "book_aseprite", "walk" },
    dead_animation = .{ "book_aseprite", "dead" },

    sprite_origin = .{8,1},

    max_health = 1,
    speed = 40,
};

BookData :: struct
{
    body: *Collider;
    pickup_trigger: *Collider;
    spell: *SpellDefinition;
    enabled_collisions: bool;
}

book_init :: (using actor: *Actor)
{
    book: = New(BookData);
    data = book;

    book.body = actor_add_collider(actor, .{ type = .BOX, box = .{.{-4, 0}, .{4,8}} }, PHYSIC_LAYER_BODY);
    book.pickup_trigger = actor_add_collider(actor, .{ type = .BOX, box = dilate(book.body.shape.box, .{1,1}) }, PHYSIC_LAYER_SPELL);
    book.body.enabled = false;
    book.pickup_trigger.enabled = false;

    actor.alterations.burning_collider.shape = .{ type = .BOX, box = dilate(book.body.shape.box, .{2,1}) };

    _, spell: = random_get_array_item(spellbook);
    book.spell = spell;
}

book_update :: (using actor: *Actor, dt: float)
{
    book: = data.(*BookData);

    if !book.enabled_collisions
    {
        if length(movement.velocity) < 0.001
        {
            book.enabled_collisions = true;
        }
    }

    for collider: book.pickup_trigger.frame_overlaps
    {
        picking_actor: = collider.parent.(*Actor);
        if try_learn_spell(picking_actor, book.spell)
        {
            request_delete_actor(actor);
            return;
        }
    }

    book.body.enabled = book.enabled_collisions;
    book.pickup_trigger.enabled = book.enabled_collisions && !actor_is_sentient(actor) && !actor_is_dead(actor);
}

#scope_file

#import "Random";