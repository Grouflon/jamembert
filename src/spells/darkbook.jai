// Spell
darkbook_spell_definition : = SpellDefinition.{
    type = .PROJECTILE,
    icon = .{ "icons_aseprite", "darkbook" },
    range = 200,
    cast_func = (params: SpellCastParams) -> bool
    {
        f: = create_actor(*darkbook_definition, params.projectile.origin);
        f.data.(*DarkbookData).caster = params.source.id;
        movement_component_go_to(*f.movement, params.projectile.origin + params.projectile.direction * darkbook_spell_definition.range);

        return true;
    },
};

// Actor
darkbook_definition : = ActorDefinition.{
    init = darkbook_init,
    update = darkbook_update,

    render_layer = .OVERLAY,
    sprite_origin = .{16,16},
    speed = 30,
    idle_animation = .{ "darkbook_aseprite", "idle" },
};

DarkbookData :: struct
{
    caster: ID(Actor);
    body: *Collider;
    trail_cd: = 0.0;
    trail_cd_max: = 0.2;
    lifetime: = 30.0;
}

darkbook_init :: (using actor: *Actor)
{
    position.z = 1;
    darkbook: = New(DarkbookData);
    //darkbook.body = actor_add_collider(actor, .{ type = .BOX, box = .{.{-5,-5}, .{5,5}} }, PHYSIC_LAYER_SPELL);

    data = darkbook;
}

darkbook_update :: (using actor: *Actor, dt: float)
{
    darkbook: = data.(*DarkbookData);
    
    if !movement.is_moving_to
    {
        request_delete_actor(actor);
        return;
    }

    angle = signed_angle_between(movement.target - position.xy, .{1,0});

    targets: =physics_cast(actor.position.xy, .{ type = .CIRCLE, circle = .{ .{}, 4 } }, .[PHYSIC_LAYER_HURTBOX]);
    for target: targets
    {
        target_actor: = target.parent.(*Actor);
        if target_actor.id == darkbook.caster.id continue;
        if actor_is_dead(target_actor) continue;


        if actor_is_sentient(target_actor)
        {
            actor_hit(target_actor, target_actor.definition.max_health, get(darkbook.caster));
            request_delete_actor(actor);
        }

        return;
    }


    if darkbook.trail_cd <= 0
    {
        create_simple_animation_actor(actor.position.xy - .{10, 16}, .{*resources.darkbook_aseprite, string_hash("trail")} , .OBJECTS);
        darkbook.trail_cd = darkbook.trail_cd_max;
    }
    darkbook.trail_cd -= dt;


    if darkbook.lifetime <= 0
    {
        request_delete_actor(actor);
    }
    darkbook.lifetime -= dt;
}
