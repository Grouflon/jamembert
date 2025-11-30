

level_1 :: ()
{
    player_x:float = 150;
    player_y_top:float = 75;
    player_y_bottom:float = 100;
    player1_start_position = .{-player_x,-player_y_bottom};
    player2_start_position = .{player_x,-player_y_bottom};
    player3_start_position = .{-player_x,player_y_top};
    player4_start_position = .{player_x,player_y_top};

    background_color = .{79,59,44,255};

    create_outside_colliders();



    leftmost_point:= -230.0;




    //Bookshelves
    bookshelf_w:= 22;
    //top
    for i : 0..21 
    {
        create_actor(*bookshelf_definition, .{leftmost_point+(i*bookshelf_w)+2, 100.0});
    }
    //middle left
    for i : 0..5 
    {
        create_actor(*bookshelf_definition, .{leftmost_point+(i*bookshelf_w)+2, 30});
    }
    //middle right
    for i : 0..5 
    {
        create_actor(*bookshelf_definition, .{-leftmost_point-(i*bookshelf_w)-2, 30});
    }

    //bottom left
    for i : 0..8 
    {
        create_actor(*bookshelf_definition, .{leftmost_point+(i*bookshelf_w)+2, -80});
    }
    //bottom right
    for i : 0..8 
    {
        create_actor(*bookshelf_definition, .{-leftmost_point-(i*bookshelf_w)-2, -80});
    }




}

ground_tiles: [..]Texture;
init_ground_tiles :: ()
{
    all_tiles: [11]Texture = .[
    resources.tile1_texture.texture,
    resources.tile1_texture.texture,
    resources.tile1_texture.texture,
    resources.tile1_texture.texture,
    resources.tile2_texture.texture,
    resources.tile3_texture.texture,
    resources.tile4_texture.texture,
    resources.tile5_texture.texture,
    resources.tile5_texture.texture,
    resources.tile5_texture.texture,
    resources.tile5_texture.texture,
    ];
    tile: Texture;

    for y : 0..16 
    {
        for x : 0..30
        {
            _,tile= random_get_array_item(ground_tiles);
            array_add(*ground_tiles,tile);
        }
    }
}

draw_ground ::()
{
    //Tiles
    left_min:= 240.0;
    bottom_min:= 135.0;

    tilesize:float=16;

    /*height:=0;
    width:=0;

    for tile_index: 0..480
    {
        if tile_index%16 == 0
        { 
            height+=1;
            width=0;
        }
        width = tile_index

        draw_sprite(.{width*tilesize - left_min, height*tilesize - bottom_min,0}, ground_tiles[tile_index]);
    }*/

    for y : 0..16 
    {
        for x : 0..30
        {
            draw_sprite(.{x*tilesize - left_min, y*tilesize - bottom_min,-10}, resources.tile1_texture.texture);
        }
    }

    //draw circle at origin for debug purposes
    draw_circle(.{0,0,0}, 4, WHITE);
}


//This is the level we used for our prototyping with the tree lines and stuff
level_test :: ()
{
    //goblin: = create_actor(*goblin_definition, .{70, -30});
    chest: = create_actor(*chest_definition, .{-15, 40});
    create_actor(*cheese_definition, .{-70, 0});
    create_actor(*cheese_definition, .{0, -65});

    //portal books
    book:=create_actor(*book_definition, .{0, 120});
    book.data.(*BookData).spell = *portalbrain_spell_definition;
    book=create_actor(*book_definition, .{-15, 120});
    book.data.(*BookData).spell = *portalvolcano_spell_definition;
    book=create_actor(*book_definition, .{-30, 120});
    book.data.(*BookData).spell = *portallibrary_spell_definition;
    book=create_actor(*book_definition, .{-45, 120});
    book.data.(*BookData).spell = *portalgraveyard_spell_definition;
    book=create_actor(*book_definition, .{-60, 120});
    book.data.(*BookData).spell = *portalforest_spell_definition;

    //create_actor(*tomb1_definition, .{20, 20});
    //create_actor(*tomb2_definition, .{20, 40});
    //create_actor(*ghost_definition, .{-50, -50});

    //create_actor(*brain_definition, .{0, -15});

    //Bookshelves
    create_actor(*bookshelf_definition, .{-75, 40});
    create_actor(*bookshelf_definition, .{75, 40});
    create_actor(*bookshelf_definition, .{-75, -40});
    create_actor(*bookshelf_definition, .{75, -40});

    //Trees
    for i : 0..17 
    {
        //top
        rand_y:= random_get_within_range(60,75);
        rand_x:= random_get_within_range(0,20);
        create_actor(*tree_definition, .{-150+(i*16)+rand_x, rand_y});
    }
    for i : 0..17
    {
        //bottom
        rand_y:= random_get_within_range(-110,-90);
        rand_x:= random_get_within_range(0,20);
        create_actor(*tree_definition, .{-150+(i*16)+rand_x, rand_y});
    }
    for i : 0..17
    {
        //left
        rand_y:= random_get_within_range(0,20);
        rand_x:= random_get_within_range(-160,-130);
        create_actor(*tree_definition, .{rand_x, -75+(i*16)+rand_y});
    }
    for i : 0..17
    {
        //left
        rand_y:= random_get_within_range(0,20);
        rand_x:= random_get_within_range(130,160);
        create_actor(*tree_definition, .{rand_x, -75+(i*16)+rand_y});
    }
    create_actor(*tree_definition, .{30, 45});
    create_actor(*tree_definition, .{-100, -20});
    create_actor(*tree_definition, .{40, 5});
}

create_outside_colliders :: ()
{
    /*left: Actor;
    create_actor()
    left.position = .{0,0,0};
    left.body = actor_add_collider(*left, .{ type = .BOX, box = .{.{-10, 10}, .{10,10}}}, PHYSIC_LAYER_BODY);
    left.body.static = true;*/

    //left.body = physics_add_collider(left, PHYSIC_LAYER_BODY);
    //leftcol.shape = .{ type = .BOX, box = .{.{-10, 10}, .{10,10}} };
    //leftcol.static = true;
}