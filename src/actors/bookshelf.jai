bookshelf_definition : = ActorDefinition.{
    init = bookshelf_init,
    update = bookshelf_update,
    on_hit = bookshelf_on_hit,

    idle_hollow_animation = .{ "bookshelf_aseprite", "idle_hollow" },
    idle_animation = .{ "bookshelf_aseprite", "idle" },
    move_animation = .{ "bookshelf_aseprite", "walk" },
    dead_animation = .{ "bookshelf_aseprite", "dead" },

    sprite_origin = .{16,1},

    max_health = 10,
    speed = 3,
    is_static = true,

    attack_cooldown = 5,
    attack_range = 20,
    attack_push = 100,
};

BookshelfData :: struct
{
    spell_gen_timer:= false;
    spell_gen_counter:= -1.0;
    spell_gen_cooldown:= 4.0;
}

bookshelf_init :: (using actor: *Actor)
{
    data = New(BookshelfData);
}

bookshelf_on_hit :: (using actor: *Actor, source: *Actor)
{
    if actor_is_dead(actor) return;

    projection_angle: = random_get_within_range(D2R * 200, D2R * 340);
    projection_strength: = random_get_within_range(80, 110);

    book: = create_actor(*book_definition, actor.position.xy);

    movement_component_push(*book.movement, rotate(.{projection_strength, 0}, projection_angle));
}

bookshelf_update :: (using actor: *Actor, dt: float)
{
    bookshelf: = data.(*BookshelfData);
    
    //when controlled by player
    if actor.controlling_player
    {
        spells:[SPELL_SLOTS_COUNT]*SpellDefinition=actor.controlling_player.spell_slots;

        if spells[0]==null && spells[1]==null && spells[2]==null && !bookshelf.spell_gen_timer
        {
            //start timer
            bookshelf.spell_gen_timer = true;
            bookshelf.spell_gen_counter = bookshelf.spell_gen_cooldown;
        }

        if bookshelf.spell_gen_timer
        {
            //decrease timer
            bookshelf.spell_gen_counter -= dt;

            //cancel timer
            if spells[0]!=null || spells[1]!=null || spells[2]!=null bookshelf.spell_gen_timer = false;


            if bookshelf.spell_gen_counter <= 0
            {
                //generate spell
                _, spell: = random_get_array_item(spellbook);
                actor.controlling_player.spell_slots[0]=spell;

                //stop timer
                bookshelf.spell_gen_timer = false;
            }
        }
    }
}
