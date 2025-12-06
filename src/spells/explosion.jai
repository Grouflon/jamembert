// Spell
explosion_spell_definition : = SpellDefinition.{
    type = .POSITION,
    icon = .{ "icons_aseprite", "explosion" },
    cast_func = (params: SpellCastParams) -> bool
    {
        exp: = create_actor(*explosion_definition, params.position.origin);
        exp.data.(*ExplosionData).caster = params.source.id;
        return true;
    },
};


// Actor
explosion_definition : = ActorDefinition.{
    init = explosion_init,
    update = explosion_update,
    shutdown = explosion_shutdown,

    sprite_origin = .{16,16},
    render_layer = .OVERLAY
};

ExplosionData :: struct
{
    caster: ID(Actor);
    hit_actors: [..]ID(Actor);
    explosion_timing: float = 0.05;
}



explosion_init :: (using actor: *Actor)
{
    explosion: = New(ExplosionData);
    data = explosion;

    animation_player_play(*animation, *resources.explosion_aseprite, "idle", false);
}


explosion_update :: (using actor: *Actor, dt: float)
{
    explosion: = data.(*ExplosionData);

    if !animation.is_playing
    {
        request_delete_actor(actor);
        return;
    }

    if explosion.explosion_timing <=0
    {
        //damages
        for hitbox: hitboxes
        {
            for collider: hitbox.frame_overlaps
            {
                target: = collider.parent.(*Actor);

                if yae_array_find(explosion.hit_actors, target.id) continue;

                if target.id == explosion.caster 
                {
                    actor_hit(target, 1, get(explosion.caster));
                }
                else
                {
                    actor_hit(target, 3, get(explosion.caster));
                }

                projection_strength: = random_get_within_range(80, 110);
                direction: = unit_vector(target.position - actor.position);
                movement_component_push(*target.movement, direction.xy * projection_strength);

                yae_array_add_if_unique(*explosion.hit_actors, target.id);

                return;
            }
        }
    }

    explosion.explosion_timing -= dt;

}

explosion_shutdown :: (using actor: *Actor)
{
    explosion: = data.(*ExplosionData);
    array_free(explosion.hit_actors);
}