//forest
forest_init :: ()
{
    player_x:float = 150;
    player_y_top:float = 60;
    player_y_bottom:float = 80;
    player1_start_position = .{-player_x,-player_y_bottom};
    player2_start_position = .{player_x,player_y_top};
    player3_start_position = .{-player_x,player_y_top};
    player4_start_position = .{player_x,-player_y_bottom};

    background_color = .{42,57,28,255};

    //top_point
    //right_point

    //trees
    //top
    create_tree_line(50, .{-right_point,top_point-40});
    //bottom
    create_tree_line(50, .{-right_point,-top_point+10});
    //left
    create_tree_line(30, .{-right_point+10,-top_point},true);
    //right
    create_tree_line(30, .{right_point-10,-top_point},true);

    //chest

    //cheese
    /*create_actor(*cheese_definition, .{150,-20});
    create_actor(*cheese_definition, .{-50,0});
    create_actor(*cheese_definition, .{200,75});
    create_actor(*cheese_definition, .{-230,-90});
    create_actor(*cheese_definition, .{180,-100});
    create_actor(*cheese_definition, .{-220,80});*/


    //Bookshelves
    create_actor(*bookshelf_definition, .{-20,-20});
    create_actor(*bookshelf_definition, .{20,20});
    create_actor(*bookshelf_definition, .{-20,20});
    create_actor(*bookshelf_definition, .{20,-20});
}

forest_update :: (dt: float)
{

}

forest_draw :: ()
{
    //center
    draw_ground_sprite(resources.patchlibrary_texture.texture, .{0,0},48);


    //players
    draw_ground_sprite(resources.patchlibrary_texture.texture, player1_start_position,48);
    draw_ground_sprite(resources.patchlibrary_texture.texture, player2_start_position,48);
    draw_ground_sprite(resources.patchlibrary_texture.texture, player3_start_position,48);
    draw_ground_sprite(resources.patchlibrary_texture.texture, player4_start_position,48);

    for i: 0..50
    {
        random_seed(*ld_rng, i.(u64)*ld_seed);
        x:= random_get_within_range(*ld_rng, (-right_point+20.0).(float), (right_point-20.0).(float));
        y:= random_get_within_range(*ld_rng, (-top_point+20.0).(float), (top_point-20.0).(float));
        draw_ground_sprite(resources.bush_texture.texture, .{x,y});
    }
    /*draw_ground_sprite(resources.bush_texture.texture, .{-180,26});
    draw_ground_sprite(resources.bush_texture.texture, .{-50,160});
    draw_ground_sprite(resources.bush_texture.texture, .{-20,-100});
    draw_ground_sprite(resources.bush_texture.texture, .{10,-50});
    draw_ground_sprite(resources.bush_texture.texture, .{75,75});
    draw_ground_sprite(resources.bush_texture.texture, .{50,-80});*/


}