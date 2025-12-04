

level_1 :: ()
{
    player_x:float = 150;
    player_y_top:float = 80;
    player_y_bottom:float = 100;
    player1_start_position = .{-player_x,-player_y_bottom};
    player2_start_position = .{player_x,player_y_top};
    player3_start_position = .{-player_x,player_y_top};
    player4_start_position = .{player_x,-player_y_bottom};

    //dark
    //background_color = .{79,59,44,255};
    //light
    //background_color = .{163,150,130,255};
    //
    background_color = .{21,20,22,255};

    create_outside_colliders();



    right:= 230.0;
    top:= 135.0;

    //trees
    create_actor(*tree_definition, .{right-144+10,35});
    create_actor(*tree_definition, .{-right+144-8,35});

    //chest
    create_actor(*chest_definition, .{right-10,-10});
    create_actor(*chest_definition, .{-right+12,-10});

    //cheese
    create_actor(*cheese_definition, .{150,-20});
    create_actor(*cheese_definition, .{-50,0});
    create_actor(*cheese_definition, .{200,75});
    create_actor(*cheese_definition, .{-230,-90});
    create_actor(*cheese_definition, .{180,-100});
    create_actor(*cheese_definition, .{-220,80});


    //Bookshelves
    bookshelf_w:= 22;
    //top
    for i : 0..21 
    {
        create_actor(*bookshelf_definition, .{-right+(i*bookshelf_w)+1, 100.0});
    }
    //middle left
    for i : 0..5 
    {
        create_actor(*bookshelf_definition, .{-right+(i*bookshelf_w)+1, 30});
    }
    //middle right
    for i : 0..5 
    {
        create_actor(*bookshelf_definition, .{right-(i*bookshelf_w)-1, 30});
    }

    //bottom left
    for i : 0..8 
    {
        create_actor(*bookshelf_definition, .{-right+(i*bookshelf_w)+1, -80});
    }
    //bottom right
    for i : 0..8 
    {
        create_actor(*bookshelf_definition, .{right-(i*bookshelf_w)-1, -80});
    }




}

ground_tiles: [30][16]Texture;
init_ground_tiles :: ()
{
    all_tiles: [11]Texture = .[
    //repeat those tile so they are more common
    resources.tile1_texture.texture,
    resources.tile1_texture.texture,
    resources.tile1_texture.texture,
    resources.tile1_texture.texture,
    //
    resources.tile2_texture.texture,
    resources.tile2_texture.texture,
    resources.tile2_texture.texture,
    resources.tile2_texture.texture,
    //other tiles 
    resources.tile3_texture.texture,
    resources.tile4_texture.texture,
    resources.tile5_texture.texture,
    ];
    tile: Texture;

    for x : 0..29 
    {
        for y : 0..15
        {
            _,tile= random_get_array_item(all_tiles);
            ground_tiles[x][y] = tile;
        }
    }
}

draw_ground ::()
{
    //Tiles
    left:= 240.0;
    bottom:= 135.0;

    tilesize:float=16;

    depth_write: = is_depth_write_enabled();
    set_depth_write_enabled(false);

    for x : 0..29
    {
        for y : 0..15
        {
            draw_sprite(.{x*tilesize - left, y*tilesize - bottom,0}, ground_tiles[x][y]);
        }
    }

    //rug center
    draw_sprite(.{0-32,0-32,0}, resources.rug3_texture.texture);

    //rug players
    draw_sprite(xyz(player1_start_position+.{-32,-32},0), resources.rug4_texture.texture);
    draw_sprite(xyz(player2_start_position+.{-32,-32},0), resources.rug4_texture.texture);
    draw_sprite(xyz(player3_start_position+.{-32,-32},0), resources.rug4_texture.texture);
    draw_sprite(xyz(player4_start_position+.{-32,-32},0), resources.rug4_texture.texture);

    //rug bottom
    draw_sprite(.{0-32,-bottom-32+10,0}, resources.rug5_texture.texture);
    //rug chest
    //right
    draw_sprite(.{230-32-10,-32-10,0}, resources.rug5_texture.texture);
    //left
    draw_sprite(.{-230-32+12,-32-10,0}, resources.rug5_texture.texture);


    //treetray middle right
    draw_sprite(.{left-144-32,35-32,0}, resources.treetray_texture.texture);
    //treetray middle left
    draw_sprite(.{-left+144-32+2,35-32,0}, resources.treetray_texture.texture);

    draw_all_commands();
    set_depth_write_enabled(depth_write);

    //draw circle at origin for debug purposes
    //draw_circle(.{0,0,0}, 4, WHITE);
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