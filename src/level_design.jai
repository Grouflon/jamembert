
level_selected:s64=0;

player1_start_position: Vector2 = .{-50,-50};
player2_start_position: Vector2 = .{50,50};
player3_start_position: Vector2 = .{50,-50};
player4_start_position: Vector2 = .{-50,50};

background_color: Color = .{0,30,61,255};

right_point : float = (GAME_WIDTH/DRAW_SCALE)/2; //240
top_point : float = (GAME_HEIGHT/DRAW_SCALE)/2; //135

ground_tiles: [30][17]Texture;

ld_rng: Random_State;
ld_seed: u64;

ld_timer:float=0.0;

select_level :: (level:s64=-1)
{
    //tiles
    wood_tiles: [11]Texture = .[
    //repeat those tile so they are more common
    resources.tile_wood_1_texture.texture,
    resources.tile_wood_1_texture.texture,
    resources.tile_wood_1_texture.texture,
    resources.tile_wood_1_texture.texture,
    //
    resources.tile_wood_2_texture.texture,
    resources.tile_wood_2_texture.texture,
    resources.tile_wood_2_texture.texture,
    resources.tile_wood_2_texture.texture,
    //other tiles 
    resources.tile_wood_3_texture.texture,
    resources.tile_wood_4_texture.texture,
    resources.tile_wood_5_texture.texture,
    ];

    rock_tiles: [3]Texture = .[
        resources.tile_rock_1_texture.texture,
        resources.tile_rock_2_texture.texture,
        resources.tile_rock_3_texture.texture,
    ];

    //rng
    ld_seed = random_get();

    //select level
    if (level > 0) 
    {
        level_selected = level;
    }
    else 
    {
        level_selected = random_range(1,5);
    }

    if level_selected==
    {
        case 1;
        {
            tiles_init(wood_tiles);
            library1_init();
        }
        case 2;
        {
            tiles_init(wood_tiles);
            library2_init();
        }
        case 3;
        {
            forest_init();
        }
        case 4;
        {
            tiles_init(rock_tiles);
            dungeon_init();
        }
    }
}

tiles_init :: (tile_array:[]Texture)
{
    tile: Texture;

    for x : 0..29 
    {
        for y : 0..16
        {
            _,tile= random_get_array_item(tile_array);
            ground_tiles[x][y] = tile;
        }
    }
}

level_update :: (dt: float)
{
    if level_selected==
    {
        case 1;
        {
            library1_update(dt);
        }
        case 2;
        {
            library2_update(dt);
        }
        case 3;
        {
            forest_update(dt);
        }
        case 4;
        {
            dungeon_update(dt);
        }
    }
}

level_draw ::()
{
    depth_write: = is_depth_write_enabled();
    set_depth_write_enabled(false);

    if level_selected==
    {
        case 1;
        {
            tiles_draw();
            library1_draw();
        }
        case 2;
        {
            tiles_draw();
            library2_draw();
        }
        case 3;
        {
            //tiles_draw();
            forest_draw();
        }
        case 4;
        {
            tiles_draw();
            dungeon_draw();
        }
    }

    draw_all_commands();
    set_depth_write_enabled(depth_write);
}

tiles_draw :: ()
{    
    tilesize:float=16;
    for x : 0..29
    {
        for y : 0..16
        {
            draw_sprite(.{x*tilesize - right_point, y*tilesize - top_point,0}, ground_tiles[x][y]);
        }
    }
}



//Other
draw_ground_sprite :: (tex:Texture, position:Vector2, offset:float= 32)
{
    draw_sprite(xyz(position-.{offset,offset},0), tex);
}

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

create_tree_line :: (number:s64, start_pos: Vector2 = .{}, vertical:=false)
{

    for i : 0..number-1 
    {
        tree_w:= random_range(6,12);
        w_offset:= random_range(-12,12);
        if vertical
        {
            create_actor(*tree_definition, .{start_pos.x+w_offset, start_pos.y+(i*tree_w)+(tree_w/2)});
        }
        else
        {
            create_actor(*tree_definition, .{start_pos.x+(i*tree_w)+(tree_w/2), start_pos.y+w_offset});
        }
    }
}


/*
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
*/