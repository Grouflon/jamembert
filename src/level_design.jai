
right_point : float = (GAME_WIDTH/DRAW_SCALE)/2; //240
top_point : float = (GAME_HEIGHT/DRAW_SCALE)/2; //135

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

    tilesize:float=16;

    depth_write: = is_depth_write_enabled();
    set_depth_write_enabled(false);

    for x : 0..29
    {
        for y : 0..15
        {
            draw_sprite(.{x*tilesize - right_point, y*tilesize - top_point,0}, ground_tiles[x][y]);
        }
    }

    //Level specific
    if level_selected==
    {
        case 1;
        {
            level_1_ground();
        }
        case 2;
        {
            level_2_ground();
        }
    }

    draw_all_commands();
    set_depth_write_enabled(depth_write);

    //draw circle at origin for debug purposes
    //draw_circle(.{0,0,0}, 4, WHITE);
}

///////LEVELS///////

//LEVEL 1
//Library 1
level_1 :: ()
{
    player_x:float = 150;
    player_y_top:float = 80;
    player_y_bottom:float = 100;
    player1_start_position = .{-player_x,-player_y_bottom};
    player2_start_position = .{player_x,-player_y_bottom};
    player3_start_position = .{-player_x,player_y_top};
    player4_start_position = .{player_x,player_y_top};

    //dark
    //background_color = .{79,59,44,255};
    //light
    //background_color = .{163,150,130,255};
    //
    background_color = .{21,20,22,255};

    right:= 230.0;
    top:= 135.0;

    //trees
    create_actor(*tree_definition, .{right_point-144+20,35});
    create_actor(*tree_definition, .{-right_point+144-18,35});

    //chest
    create_actor(*chest_definition, .{right_point-20,-10});
    create_actor(*chest_definition, .{-right_point+22,-10});

    //cheese
    create_actor(*cheese_definition, .{150,-20});
    create_actor(*cheese_definition, .{-50,0});
    create_actor(*cheese_definition, .{200,75});
    create_actor(*cheese_definition, .{-230,-90});
    create_actor(*cheese_definition, .{180,-100});
    create_actor(*cheese_definition, .{-220,80});


    //Bookshelves
    //top
    create_bookshelves_line(22, .{-right_point,100});
    //middle left
    create_bookshelves_line(5, .{-right_point,30});
    //middle right
    create_bookshelves_line(5, .{right_point,30},true);
    //bottom left
    create_bookshelves_line(8, .{-right_point,-80});
    //bottom right
    create_bookshelves_line(8, .{right_point,-80},true);
}

level_1_ground :: ()
{
    //rug center
    draw_sprite(.{0-32,0-32,0}, resources.rug3_texture.texture);

    //rug players
    draw_sprite(xyz(player1_start_position+.{-32,-32},0), resources.rug4_texture.texture);
    draw_sprite(xyz(player2_start_position+.{-32,-32},0), resources.rug4_texture.texture);
    draw_sprite(xyz(player3_start_position+.{-32,-32},0), resources.rug4_texture.texture);
    draw_sprite(xyz(player4_start_position+.{-32,-32},0), resources.rug4_texture.texture);

    //rug bottom
    draw_sprite(.{0-32,-top_point-32+10,0}, resources.rug5_texture.texture);
    //rug chest
    //right
    draw_sprite(.{230-32-10,-32-10,0}, resources.rug5_texture.texture);
    //left
    draw_sprite(.{-230-32+12,-32-10,0}, resources.rug5_texture.texture);


    //treetray middle right
    draw_sprite(.{right_point-144-32,35-32,0}, resources.treetray_texture.texture);
    //treetray middle left
    draw_sprite(.{-right_point+144-32+2,35-32,0}, resources.treetray_texture.texture);

}

//LEVEL 2
//Library 2
level_2 :: ()
{
    player_x:float = 220;
    player_y_top:float = 82;
    player_y_bottom:float = 100;
    player1_start_position = .{-player_x,-player_y_bottom};
    player2_start_position = .{player_x,-player_y_bottom};
    player3_start_position = .{-player_x,player_y_top};
    player4_start_position = .{player_x,player_y_top};

    //dark
    //background_color = .{79,59,44,255};
    //light
    //background_color = .{163,150,130,255};
    //
    background_color = .{21,20,22,255};

    right:= 230.0;
    top:= 135.0;

    //trees
    tree_x:=130.0;
    create_actor(*tree_definition, .{tree_x,top_point-90+32});
    create_actor(*tree_definition, .{tree_x,top_point-180+32});
    create_actor(*tree_definition, .{tree_x,top_point-270+32});
    //
    create_actor(*tree_definition, .{-tree_x,top_point-90+32});
    create_actor(*tree_definition, .{-tree_x,top_point-180+32});
    create_actor(*tree_definition, .{-tree_x,top_point-270+32});

    //chest
    //create_actor(*chest_definition, .{right_point-20,-10});
    //create_actor(*chest_definition, .{-right_point+22,-10});

    //cheese
    /*create_actor(*cheese_definition, .{150,-20});
    create_actor(*cheese_definition, .{-50,0});
    create_actor(*cheese_definition, .{200,75});
    create_actor(*cheese_definition, .{-230,-90});
    create_actor(*cheese_definition, .{180,-100});
    create_actor(*cheese_definition, .{-220,80});*/


    //Bookshelves
    //left
    create_bookshelves_line(2, .{-right_point,-80});
    create_bookshelves_line(2, .{-right_point,-20});
    create_bookshelves_line(2, .{-right_point,40});
    create_bookshelves_line(2, .{-right_point,100});
    //right
    create_bookshelves_line(2, .{right_point,-80},true);
    create_bookshelves_line(2, .{right_point,-20},true);
    create_bookshelves_line(2, .{right_point,40},true);
    create_bookshelves_line(2, .{right_point,100},true);
    //top
    create_bookshelves_line(4, .{0,100});
    create_bookshelves_line(4, .{0,100},true);
    //center
    create_actor(*bookshelf_definition, .{0,40});
    create_actor(*bookshelf_definition, .{-22,30});
    create_actor(*bookshelf_definition, .{22,30});
    create_actor(*bookshelf_definition, .{-44,20});
    create_actor(*bookshelf_definition, .{44,20});

    create_actor(*bookshelf_definition, .{44,10});
    create_actor(*bookshelf_definition, .{44,0});
    create_actor(*bookshelf_definition, .{44,-10});
    create_actor(*bookshelf_definition, .{44,-20});
    create_actor(*bookshelf_definition, .{44,-30});


    create_actor(*bookshelf_definition, .{-44,10});
    create_actor(*bookshelf_definition, .{-44,0});
    create_actor(*bookshelf_definition, .{-44,-10});
    create_actor(*bookshelf_definition, .{-44,-20});
    create_actor(*bookshelf_definition, .{-44,-30});

    create_actor(*bookshelf_definition, .{0,-60});
    create_actor(*bookshelf_definition, .{-22,-50});
    create_actor(*bookshelf_definition, .{22,-50});
    create_actor(*bookshelf_definition, .{-44,-40});
    create_actor(*bookshelf_definition, .{44,-40});
}

level_2_ground :: ()
{
    //rug center
    draw_sprite(.{0-32,0-32,0}, resources.rug3_texture.texture);

    //rug players
    draw_sprite(xyz(player1_start_position+.{-32,-32},0), resources.rug4_texture.texture);
    draw_sprite(xyz(player2_start_position+.{-32,-32},0), resources.rug4_texture.texture);
    draw_sprite(xyz(player3_start_position+.{-32,-32},0), resources.rug4_texture.texture);
    draw_sprite(xyz(player4_start_position+.{-32,-32},0), resources.rug4_texture.texture);

    //rug bottom
    draw_sprite(.{0-32,-top_point-32+9,0}, resources.rug5_texture.texture);
    //right
    draw_sprite(.{-150-32,top_point-14-32,0}, resources.rug5_texture.texture);
    //left
    draw_sprite(.{150-32,top_point-14-32,0}, resources.rug5_texture.texture);


    //treetray right
    tray_x:=130.0;
    draw_sprite(.{-tray_x-32,top_point-90,0}, resources.treetray_texture.texture);
    draw_sprite(.{-tray_x-32,top_point-180,0}, resources.treetray_texture.texture);
    draw_sprite(.{-tray_x-32,top_point-270,0}, resources.treetray_texture.texture);
    //treetray middle left
    draw_sprite(.{tray_x-32,top_point-90,0}, resources.treetray_texture.texture);
    draw_sprite(.{tray_x-32,top_point-180,0}, resources.treetray_texture.texture);
    draw_sprite(.{tray_x-32,top_point-270,0}, resources.treetray_texture.texture);

}











//LEVEL 0
//This is the level we used for our prototyping with the tree lines and stuff
level_0_test :: ()
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

//Other
create_bookshelves_line :: (number:s64, start_pos: Vector2 = .{}, invert:bool=false)
{    
    bookshelf_w:= 22;

    inverted: = 1;
    if (invert) inverted= -1;

    for i : 0..number-1 
    {
        create_actor(*bookshelf_definition, .{start_pos.x+(i*bookshelf_w*inverted)+(bookshelf_w/2)*inverted, start_pos.y});
    }
}