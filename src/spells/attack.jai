// Spell
attack_spell_definition : = SpellDefinition.{
    type = .PROJECTILE,
    cast_func = (params: SpellCastParams)
    {
        a: = create_actor(*attack_definition, params.projectile.origin + params.projectile.direction * 8);
        a.angle = signed_angle_between(params.projectile.direction, .{1,0});
    },
};

// Actor
attack_definition : = ActorDefinition.{
    init = attack_init,
    update = attack_update,

    sprite_origin = .{8,8},
    render_layer = .OVERLAY,
    // idle_animation = .{ "fireball_aseprite", "idle" },
};

attack_init :: (using actor: *Actor)
{
    actor_add_collider(actor, .{ type = .BOX, box = .{.{-5,-5}, .{5,5}} }, PHYSIC_LAYER_SPELL);
    animation_player_play(*animation, *resources.attack_smear_aseprite, "attack", false);
}

attack_update :: (using actor: *Actor, dt: float)
{
    if !animation.is_playing
    {
        request_delete_actor(actor);
    }
}
