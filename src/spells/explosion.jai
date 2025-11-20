// Spell
explosion_spell_definition : = SpellDefinition.{
    type = .TARGET,
    icon = .{ "icons_aseprite", "explosion" },
    range = 200,
    cast_func = (params: SpellCastParams)
    {
        target: = params.target.target;
        if target == null return;

        exp: = create_actor(*explosion_definition, params.target.target.position.xy);
        exp.data.(*ExplosionData).caster = params.source.id;
    },
};

// Actor
explosion_definition : = ActorDefinition.{
    init = explosion_init,
    update = explosion_update,

    sprite_origin = .{16,16},
    idle_animation = .{ "explosion_aseprite", "idle" },
};

ExplosionData :: struct
{
    caster: ID(Actor);
    body: *Collider;
}

explosion_init :: (using actor: *Actor)
{
    explosion: = New(ExplosionData);
    explosion.body = actor_add_collider(actor, .{ type = .BOX, box = .{.{-10,-10}, .{10,10}} }, PHYSIC_LAYER_SPELL);

    data = explosion;

    //dammages
    for collider: explosion.body.frame_overlaps
    {
        target: = collider.parent.(*Actor);

        if target.id == explosion.caster 
        {
            actor_hit(target, 1, get(explosion.caster));
        }
        else
        {
            actor_hit(target, 3, get(explosion.caster));
        }
        
        return;
    }
}


explosion_update :: (using actor: *Actor, dt: float)
{
    //explosion: = data.(*ExplosionData);
    
    if !animation.is_playing
    {
        request_delete_actor(actor);
        return;
    }

}