Actor :: struct
{
    #as using e:Entity;
    angle: float;

    id: ID(Actor);

    definition: *ActorDefinition;

    movement: MovementComponent;
    animation: AsepriteAnimationPlayer;
    face_animation: AsepriteAnimationPlayer;
    alterations: AlterationComponent;
    ai: AIComponent;

    active: bool = true;

    idle_hollow_animation: AsepriteAnimationHandle;
    idle_animation: AsepriteAnimationHandle;
    move_animation: AsepriteAnimationHandle;
    dead_animation: AsepriteAnimationHandle;
    cast_animation: AsepriteAnimationHandle;

    colliders: [..]*Collider;
    data: *void;

    controlling_player: *Player;
    last_hit_time: float = -100;
    current_health: s32;
    attack_cooldown: float;
    is_casting: bool;
}
actors: Pool(Actor);
to_delete_actors: [..]*Actor;

ActorDefinition :: struct
{
    init: #type (actor: *Actor);
    shutdown: #type (actor: *Actor);
    update: #type (actor: *Actor, dt: float);
    draw: #type (actor: *Actor);
    on_hit: #type (actor: *Actor, source: *Actor);

    sprite_origin: Vector2 = .{8, 1};

    face_position: Vector2 = .{0,3};
    face_dead_position: Vector2 = .{0,3};   

    face_idle_animation: = "idle";
    face_dead_animation: = "dead";
    face_panic_animation: = "panic";
    face_mad_animation: = "mad";
    face_sad_animation: = "sad";

    idle_hollow_animation: AsepriteAnimation;
    idle_animation: AsepriteAnimation;
    move_animation: AsepriteAnimation;
    dead_animation: AsepriteAnimation;
    cast_animation: AsepriteAnimation;

    render_layer: RenderLayer = .OBJECTS;

    max_health: s32 = -1;
    speed: float = 20.0;

    cast_position: Vector2 = .{0,4};

    attack_cooldown: float = 1.0;
    attack_range: float = 8.0;
    attack_damage: s32 = 1;
    attack_push: float = 50;
}

create_actor :: (definition: *ActorDefinition = null, position: Vector2 = .{}) -> *Actor
{
    actor, id: = pool_add(*actors);

    actor.id = id;
    actor.position = .{position.x, position.y, 0};

    actor_set_definition(actor, definition);

    return actor;
}

request_delete_actor :: (actor: *Actor)
{
    assert(actor != null);
    array_add_if_unique(*to_delete_actors, actor);
}

delete_all_actors :: ()
{
    for *actor: actors
    {
        delete_actor(actor);
    }
}

actor_set_definition :: (actor: *Actor, definition: *ActorDefinition)
{
    assert(actor != null);
    if actor.definition == definition return;

    if actor.definition != null
    {
        actor_shutdown(actor);
    }

    actor.definition = definition;

    if actor.definition != null
    {
        actor_init(actor);
    }
}

actor_init :: (using actor: *Actor)
{
    assert(actor != null);
    assert(definition != null);

    movement_component_init(*actor.movement, actor);
    alteration_component_init(*actor.alterations, actor);
    ai_component_init(*actor.ai, actor);

    // Cache animation handles
    success: bool;
    if definition.idle_animation.animation_name.count != 0
    {
        success=, idle_animation = get_animation_handle(definition.idle_animation);
        if !success
        {
            log_error("Could not find animation handle for %", definition.idle_animation);
        }
    }
    if definition.move_animation.animation_name.count != 0
    {
        success=, move_animation = get_animation_handle(definition.move_animation);
        if !success
        {
            log_error("Could not find animation handle for %", definition.move_animation);
        }
    }
    if definition.dead_animation.animation_name.count != 0
    {
        success=, dead_animation = get_animation_handle(definition.dead_animation);
        if !success
        {
            log_error("Could not find animation handle for %", definition.dead_animation);
        }
    }
    if definition.idle_hollow_animation.animation_name.count != 0
    {
        success=, idle_hollow_animation = get_animation_handle(definition.idle_hollow_animation);
        if !success
        {
            log_error("Could not find animation handle for %", definition.idle_hollow_animation);
        }
    }
    if definition.cast_animation.animation_name.count != 0
    {
        success=, cast_animation = get_animation_handle(definition.cast_animation);
        if !success
        {
            log_error("Could not find animation handle for %", definition.cast_animation);
        }
    }

    // Init stuff
    current_health = definition.max_health;

    if definition.init != null
    {
        definition.init(actor);
    }
}

actor_shutdown :: (using actor: *Actor)
{
    assert(actor != null);
    assert(definition != null);

    if definition.shutdown != null
    {
        definition.shutdown(actor);
    }

    ai_component_shutdown(*actor.ai);
    alteration_component_shutdown(*actor.alterations);
    movement_component_shutdown(*actor.movement);

    actor_remove_all_colliders(actor);
    free(data);
    data = null;
}

actors_update :: (dt: float)
{
    for *actor: actors
    {
        if !actor.active continue;
        if actor.definition == null continue;

        actor_update(actor, dt);
    }

    for actor: to_delete_actors
    {
        delete_actor(actor);
    }
    to_delete_actors.count = 0;
}

actors_draw :: ()
{
    for *actor: actors
    {
        if !actor.active continue;
        if actor.definition == null continue;

        actor_draw(actor);
    }
}

actor_update :: (using actor: *Actor, dt: float)
{
    ai_component_update(*ai, dt);

    if attack_cooldown > 0
    {
        attack_cooldown -= dt;
    }

    if current_health == 0 && dead_animation.aseprite != null
    {
        animation_player_play(*animation, dead_animation);
    }
    else if is_casting && cast_animation.aseprite != null
    {
        animation_player_play(*animation, cast_animation);
    }
    else if actor_is_sentient(actor) && length_squared(movement.velocity) > 0.1 && move_animation.aseprite != null
    {
        animation_player_play(*animation, move_animation);
    }
    else if idle_animation.aseprite != null
    {
        if !actor_is_sentient(actor) && idle_hollow_animation.aseprite != null
        {
            animation_player_play(*animation, idle_hollow_animation);
        }
        else
        {
            animation_player_play(*animation, idle_animation);
        }
    }

    actor_update_face(actor);

    movement_component_update(*movement, dt);
    animation_player_update(*animation, dt);
    animation_player_update(*face_animation, dt);

    if definition.update
    {
        definition.update(actor, dt);
    }

    alteration_component_update(*alterations, dt);
}

actor_draw :: (using actor: *Actor)
{
    begin_transform();
    defer end_transform();

    if definition.render_layer != .OBJECTS
    {
        begin_render_texture(render_layers[definition.render_layer]);
    }

    transform_translate(.{position.x, position.y, -(position.y + position.z)});
    r: Quaternion;
    set_from_axis_and_angle(*r, .{0,0,1}, angle);
    transform_rotate(r);

    // Sprites
    {
        shader_instance: = begin_shader(resources.sprite_shader.program);
        defer end_shader();

        shader_instance_set_uniform(shader_instance, "uLastHitTime", last_hit_time);

        // Draw body
        animation_player_draw(*animation, -xyz(definition.sprite_origin, 0));

        // Draw face
        face_position: = definition.face_position;
        if actor_is_dead(actor)
        {
            face_position = definition.face_dead_position;
        }
        if animation.aseprite != null
        {
            has_face_override, face_bounds: = aseprite_get_slice(*animation.aseprite.data, "face", animation.current_aseprite_frame, true);
            if has_face_override
            {
                face_position = face_bounds.min - definition.sprite_origin + .{3,1};
                
                //this is a hack to be able to get the face position from an actor
                definition.face_position = face_position;
            }
        }
        animation_player_draw(*face_animation, xyz(face_position - .{8,8}, 0.01));
    }

    // Custom draw
    if definition.draw
    {
        definition.draw(actor);
    }

    // Alterations
    alteration_component_draw(*alterations);

    // Draw Healthbar
    if current_health != definition.max_health && current_health > 0
    {
        begin_render_texture(render_layers[RenderLayer.UI]);

        draw_rectangle(.{0,18,0.1}, .{.{-6,-1}, .{6, 2}}, DARKGRAY);
        draw_rectangle(.{0,18,0.2}, .{.{-5,0}, .{5, 1}}, .{30,30,30,255});

        ratio: = current_health.(float) / definition.max_health.(float);
        draw_rectangle(.{0,18,0.3}, .{.{-5,0}, .{-5 + ratio*10, 1}}, RED);

        end_render_texture();
    }

    if definition.render_layer != .OBJECTS
    {
        end_render_texture();
    }
}

actor_hit :: (using actor: *Actor, damage: s32, source: *Actor = null)
{
    assert(actor != null);
    assert(definition != null);

    last_hit_time = xx get_time();
    actor_modify_health(actor, -damage);

    if definition.on_hit != null
    {
        definition.on_hit(actor, source);
    }

    if source != null && actor_is_sentient(actor) && actor.controlling_player == null
    {
        ai.target = source;
    }
}

actor_modify_health :: (using actor: *Actor, value: s32)
{
    assert(actor != null);
    if definition.max_health <= 0 return;

    previous_health: = current_health;
    current_health = clamp(current_health + value, 0, definition.max_health);

    if previous_health > 0 && current_health == 0
    {
        movement_component_stop(*movement);
        // die

        // auto cast reanimation for player if possible
        // note: This should end up in the reanimation implementation itself
        if actor.controlling_player != null
        {
            for i : 0..actor.controlling_player.spell_slots.count-1 
            {
                if actor.controlling_player.spell_slots[i] == *reanimation_spell_definition
                {
                    //cast
                    if player_cast_spell(actor.controlling_player, i)
                    {
                        log("cast reanimation");
                        break;
                    }

                    break;
                }
            }
        }
    }
    else if previous_health == 0 && current_health > 0
    {
        // revive
    }
}

actor_is_dead :: (using actor: *Actor) -> bool
{
    assert(actor != null);
    return current_health == 0;
}

actor_add_collider :: (using actor: *Actor, shape: PhysicsShape, layer: u8, static: bool = false) -> *Collider
{
    collider: = physics_add_collider(actor, layer);
    collider.shape = shape;
    collider.static = static;
    array_add(*colliders, collider);
    return collider;
}

actor_remove_collider :: (using actor: *Actor, collider: *Collider)
{
    removed_index: = array_unordered_remove_by_value(*colliders, collider);
    assert(removed_index >= 0);
    physics_remove_collider(collider);
}

actor_remove_all_colliders :: (using actor: *Actor)
{
    for collider : colliders
    {
        physics_remove_collider(collider);
    }
    colliders.count = 0;
}

actor_attack :: (using actor: *Actor, target: Vector2) -> bool
{
    params: SpellCastParams;
    params.source = actor;
    params.projectile.origin = actor.position.xy + actor.definition.cast_position;
    params.projectile.direction = normalize(target - params.projectile.origin);
    return actor_attack(params);
}

actor_attack :: (using actor: *Actor, aim_angle: float) -> bool
{
    params: SpellCastParams;
    params.source = actor;
    params.projectile.origin = actor.position.xy + actor.definition.cast_position;
    params.projectile.direction = rotate(.{1,0}, aim_angle);
    return actor_attack(params);
}

actor_attack :: (params: SpellCastParams) -> bool
{
    if params.source == null return false;
    if params.source.attack_cooldown > 0 return false;

    params.source.attack_cooldown = params.source.definition.attack_cooldown;
    attack_spell_definition.cast_func(params);
    return true;
}

actor_set_casting :: (using actor: *Actor, value: bool)
{
    if is_casting == value return;

    SPEED_MODIFIER_NAME :: "cast";
    if is_casting
    {
        movement_component_remove_speed_modifer(*movement, SPEED_MODIFIER_NAME);
    }
    is_casting = value;
    if is_casting
    {
        movement_component_set_speed_modifer(*movement, SPEED_MODIFIER_NAME, CAST_SPEED_MODIFIER); // Move that value to a settings resource sometime
    }
}

actor_is_casting :: (using actor: *Actor) -> bool
{
    return is_casting;
}

#scope_file

actor_update_face :: (using actor: *Actor)
{
    if actor_is_sentient(actor)
    {
        face_animation_name: = actor.definition.face_idle_animation;
        if current_health == 0
        {
            face_animation_name = actor.definition.face_dead_animation;
        }
        else if actor_is_burning(actor)
        {
            face_animation_name = actor.definition.face_panic_animation;
        }
        else if ai.is_agressive || ai.target != null
        {
            face_animation_name = actor.definition.face_mad_animation;
        }
        animation_player_play(*face_animation, *resources.faces_aseprite, face_animation_name);
    }
    else
    {
        animation_player_stop(*face_animation);

    }
}

delete_actor :: (using actor: *Actor)
{
    actor_set_definition(actor, null);
    array_free(actor.colliders);
    pool_remove(*actors, actor);
}