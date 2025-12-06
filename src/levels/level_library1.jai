//Library 1

library1_init :: ()
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

    //trees
    create_actor(*tree_definition, .{right_point-144+20,35});
    create_actor(*tree_definition, .{-right_point+144-18,35});

    //chest
    create_actor(*chest_definition, .{right_point-20,-10});
    create_actor(*chest_definition, .{-right_point+22,-10});



    //Bookshelves
    //top
    create_bookshelves_line(22, .{-right_point,100});
    //middle left
    create_bookshelves_line(5, .{-right_point,30});
    //middle right
    create_bookshelves_line(5, .{right_point,30},true);
    //bottom left
    create_bookshelves_line(6, .{-right_point,-80});
    //bottom right
    create_bookshelves_line(6, .{right_point,-80},true);
}

library1_update :: (dt: float)
{

}

library1_draw :: ()
{
    //rug center
    draw_ground_sprite(resources.rug3_texture.texture, .{0,0});

    //rug players
    draw_ground_sprite(resources.rug4_texture.texture, player1_start_position);
    draw_ground_sprite(resources.rug4_texture.texture, player2_start_position);
    draw_ground_sprite(resources.rug4_texture.texture, player3_start_position);
    draw_ground_sprite(resources.rug4_texture.texture, player4_start_position);

    //rug bottom
    draw_ground_sprite(resources.rug5_texture.texture, .{0,-top_point+10});
    //rug chest
    draw_ground_sprite(resources.rug5_texture.texture, .{230-10,-10});
    draw_ground_sprite(resources.rug5_texture.texture, .{-230+12,-10});


    //treetray
    draw_ground_sprite(resources.treetray_texture.texture, .{right_point-124,35});
    draw_ground_sprite(resources.treetray_texture.texture, .{-right_point+124+2,35});

}

