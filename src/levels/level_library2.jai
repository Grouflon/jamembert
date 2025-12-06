//Library 2
library2_init :: ()
{
    player_x:float = 220;
    player_y_top:float = 82;
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
    tree_x:=130.0;
    create_actor(*tree_definition, .{tree_x,top_point-90+32});
    create_actor(*tree_definition, .{tree_x,top_point-180+32});
    create_actor(*tree_definition, .{tree_x,top_point-270+32});
    //
    create_actor(*tree_definition, .{-tree_x,top_point-90+32});
    create_actor(*tree_definition, .{-tree_x,top_point-180+32});
    create_actor(*tree_definition, .{-tree_x,top_point-270+32});

    //chest
    create_actor(*chest_definition, .{0,20});
    create_actor(*chest_definition, .{0,-top_point+9});
    create_actor(*chest_definition, .{-150,top_point-14});
    create_actor(*chest_definition, .{150,top_point-14});


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

library2_update :: (dt: float)
{

}

library2_draw :: ()
{
    //rug center
    draw_ground_sprite(resources.rug3_texture.texture, .{0,0});

    //rug players
    draw_ground_sprite(resources.rug4_texture.texture, player1_start_position);
    draw_ground_sprite(resources.rug4_texture.texture, player2_start_position);
    draw_ground_sprite(resources.rug4_texture.texture, player3_start_position);
    draw_ground_sprite(resources.rug4_texture.texture, player4_start_position);

    //rugs
    draw_ground_sprite(resources.rug5_texture.texture, .{0,-top_point+9});
    draw_ground_sprite(resources.rug5_texture.texture, .{-150,top_point-14});
    draw_ground_sprite(resources.rug5_texture.texture, .{150,top_point-14});


    //treetray right
    tray_x:=130.0;

    draw_ground_sprite(resources.treetray_texture.texture, .{-tray_x,top_point-58});
    draw_ground_sprite(resources.treetray_texture.texture, .{-tray_x,top_point-148});
    draw_ground_sprite(resources.treetray_texture.texture, .{-tray_x,top_point-238});

    draw_ground_sprite(resources.treetray_texture.texture, .{tray_x,top_point-58});
    draw_ground_sprite(resources.treetray_texture.texture, .{tray_x,top_point-148});
    draw_ground_sprite(resources.treetray_texture.texture, .{tray_x,top_point-238});

}