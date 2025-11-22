// Spell
cupidon_spell_definition : = SpellDefinition.{
    type = .PROJECTILE,
    icon = .{ "icons_aseprite", "cupidon" },
    range = 200,
    cast_func = (params: SpellCastParams) -> bool
    {
        f: = create_actor(*cupidon_definition, params.projectile.origin);
        f.data.(*CupidonData).caster = params.source.id;
        movement_component_go_to(*f.movement, params.projectile.origin + params.projectile.direction * cupidon_spell_definition.range);

        return true;
    },
};

// Actor
cupidon_definition : = ActorDefinition.{
    init = cupidon_init,
    update = cupidon_update,

    render_layer = .OVERLAY,
    sprite_origin = .{16,16},
    speed = 80,
    idle_animation = .{ "cupidon_aseprite", "idle" },
};

CupidonData :: struct
{
    caster: ID(Actor);
    body: *Collider;
    trail_cd: = 0.0;
    trail_cd_max: = 0.2;
}

cupidon_init :: (using actor: *Actor)
{
    position.z = 1;
    cupidon: = New(CupidonData);
    cupidon.body = actor_add_collider(actor, .{ type = .BOX, box = .{.{-3,-3}, .{3,3}} }, PHYSIC_LAYER_SPELL);

    data = cupidon;
}

cupidon_update :: (using actor: *Actor, dt: float)
{
    cupidon: = data.(*CupidonData);
    
    if !movement.is_moving_to
    {
        request_delete_actor(actor);
        return;
    }

    angle = signed_angle_between(movement.target - position.xy, .{1,0});

    for collider: cupidon.body.frame_overlaps
    {
        target: = collider.parent.(*Actor);
        if target.id == cupidon.caster continue;
        if !actor_is_sentient(target) continue;

        if target.ai.is_agressive
        {
            target.ai.target = null;
            target.ai.is_agressive = false;
        }
        
        request_delete_actor(actor);
        return;
    }


    if cupidon.trail_cd <= 0
    {
        create_simple_animation_actor(actor.position.xy - .{10, 16}, .{*resources.cupidon_aseprite, string_hash("trail")} , .OBJECTS);
        cupidon.trail_cd = cupidon.trail_cd_max;
    }
    cupidon.trail_cd -= dt;

}
