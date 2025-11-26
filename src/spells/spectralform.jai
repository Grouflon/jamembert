// Spell
spectralform_spell_definition : = SpellDefinition.{
    type = .PROJECTILE,
    icon = .{ "icons_aseprite", "spectralform" },
    range = 200,
    cast_func = (params: SpellCastParams) -> bool
    {
        spect: = create_actor(*spectralform_definition, params.source.position.xy);
        spect.data.(*spectralformData).caster = params.source.id;
        return true;
    },
};

// Actor
spectralform_definition : = ActorDefinition.{
    init = spectralform_init,
    update = spectralform_update,
    shutdown = spectralform_shutdown,

    idle_hollow_animation = .{ "ghost_aseprite", "idle" },
    idle_animation = .{ "ghost_aseprite", "idle" },
    move_animation = .{ "ghost_aseprite", "idle" },
    dead_animation = .{ "ghost_aseprite", "idle" },

    sprite_origin = .{8,2},
    render_layer = .OVERLAY
};

spectralformData :: struct
{
    caster: ID(Actor);
    init_done: bool = false;
    duration : = 1.5;
}


spectralform_init :: (using actor: *Actor)
{
    spectralform: = New(spectralformData);
    data = spectralform;
}


spectralform_update :: (using actor: *Actor, dt: float)
{
    spectralform: = data.(*spectralformData);
    caster: = get(spectralform.caster);

    //this is a hack because using the caster in the init make the game crash
    if !spectralform.init_done
    {
        //maybe remove some alteration
        actor_set_burning(caster, false);

        // increase speed
        movement_component_set_speed_modifer(*caster.movement, "spectralform", 2.5);

        //disable caster collision
        for collider: caster.colliders
        {
            collider.enabled = false;
        }

        //hide caster sprite
        // ...


        spectralform.init_done = true;
    }

    //force caster to move
    mouse_world_pos: = screen_to_world(get_mouse_position());
    dir: = normalize(mouse_world_pos - caster.position.xy);
    movement_component_add_input(*controlled_actor.movement, dir);

    //snap ghost to caster
    actor.position = caster.position;

    //spell duration
    if spectralform.duration <=0 request_delete_actor(actor);
    spectralform.duration -= dt;
}

spectralform_shutdown :: (using actor: *Actor)
{
    spectralform: = data.(*spectralformData);
    caster: = get(spectralform.caster);

    //reset all
    movement_component_remove_speed_modifer(*caster.movement, "spectralform");
    for collider: caster.colliders
    {
        if collider == caster.alterations.burning_collider continue;
        collider.enabled = true;
    }
    // ...
}