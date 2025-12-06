//dungeon
dungeon_init :: ()
{
    player_x:float = 200;
    player_y_top:float = 40;
    player_y_bottom:float = 60;
    player1_start_position = .{-player_x,-player_y_bottom};
    player2_start_position = .{player_x,player_y_top};
    player3_start_position = .{-player_x,player_y_top};
    player4_start_position = .{player_x,-player_y_bottom};

    //dark
    //background_color = .{255,255,255,255};
    background_color = .{82,82,101,255};

    //chest

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
    //bottom
    create_bookshelves_line(22, .{-right_point,-150});

    create_actor(*bookshelf_definition, .{-right_point+10,-20});
    create_actor(*bookshelf_definition, .{right_point-10,-20});

    //init timer spawn
    ld_timer = random_get_within_range(5,15);
}

dungeon_update :: (dt: float)
{
    //timer to spawn goblin
    if ld_timer <= 0
    {
        ld_timer = random_get_within_range(10,40);

        //goblin spawn pos (match with the grids)
        pos: [6]Vector2 = .[
            .{-120,60},
            .{0,60},
            .{120,60},
            .{-120,-60},
            .{0,-60},
            .{120,-60},
        ];

        _,spawn_pos: = random_get_array_item(pos);
        create_actor(*goblin_definition, spawn_pos);
    }
    ld_timer -= dt;
}

dungeon_draw :: ()
{

    //slabs players
    draw_ground_sprite(resources.slab_texture.texture, player1_start_position);
    draw_ground_sprite(resources.slab_texture.texture, player2_start_position);
    draw_ground_sprite(resources.slab_texture.texture, player3_start_position);
    draw_ground_sprite(resources.slab_texture.texture, player4_start_position);

    //grids
    draw_ground_sprite(resources.grid_texture.texture, .{-120,60});
    draw_ground_sprite(resources.grid_texture.texture, .{0,60});
    draw_ground_sprite(resources.grid_texture.texture, .{120,60});

    draw_ground_sprite(resources.grid_texture.texture, .{-120,-60});
    draw_ground_sprite(resources.grid_texture.texture, .{0,-60});
    draw_ground_sprite(resources.grid_texture.texture, .{120,-60});

}