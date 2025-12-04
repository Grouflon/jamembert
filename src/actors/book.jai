book_definition : = ActorDefinition.{
    init = book_init,
    update = book_update,

    idle_hollow_animation = .{ "book_aseprite", "idle_hollow" },
    idle_animation = .{ "book_aseprite", "idle" },
    move_animation = .{ "book_aseprite", "walk" },
    dead_animation = .{ "book_aseprite", "dead" },

    sprite_origin = .{8,1},

    max_health = 1,
    attack_damage = 0,
    speed = 40,
};

BookData :: struct
{
    spell: *SpellDefinition;
    enabled_collisions: bool;
}

book_init :: (using actor: *Actor)
{
    book: = New(BookData);
    data = book;

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
    if !book.enabled_collisions return;

    //Player specific behavior
    if actor.controlling_player
    {
        if(actor.controlling_player.spell_slots[0] != book.spell)
        {
            actor.controlling_player.spell_slots[0] = book.spell;
        }
    }

    //Pickup
    for hitbox: hitboxes
    {
        for collider: hitbox.frame_overlaps
        {
            picking_actor: = collider.parent.(*Actor);
            if !picking_actor.definition.can_pick_objects continue;

            if try_learn_spell(picking_actor, book.spell)
            {
                request_delete_actor(actor);
                return;
            }
        }
    }


}

#scope_file

#import "Random";