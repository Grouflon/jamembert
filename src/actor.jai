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
    active: bool = true;

    idle_animation: AsepriteAnimationHandle;
    move_animation: AsepriteAnimationHandle;
    dead_animation: AsepriteAnimationHandle;

    colliders: [..]*Collider;
    data: *void;

    last_hit_time: float = -100;
    current_health: s32;
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
    idle_animation: AsepriteAnimation;
    move_animation: AsepriteAnimation;
    dead_animation: AsepriteAnimation;
    render_layer: RenderLayer = .OBJECTS;
    max_health: s32 = -1;
}

create_actor :: (definition: *ActorDefinition = null, position: Vector2 = .{}) -> *Actor
{
    actor, id: = pool_add(*actors);

    actor.id = id;
    actor.position = .{position.x, position.y, 0};
    actor.movement.owner = actor;

    alteration_component_init(*actor.alterations, actor);

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
    if current_health == 0 && dead_animation.aseprite != null
    {
        animation_player_play(*animation, dead_animation);
    }
    else if movement.is_moving && move_animation.aseprite != null
    {
        animation_player_play(*animation, move_animation);
    }
    else if idle_animation.aseprite != null
    {
        animation_player_play(*animation, idle_animation);
    }

    if is_sentient(actor)
    {
        face_animation_name: = "idle";
        if current_health == 0
        {
            face_animation_name = "dead";
        }
        else if is_burning(actor)
        {
            face_animation_name = "panic";
        }
        animation_player_play(*face_animation, *resources.faces_aseprite, face_animation_name);
    }
    else
    {
        animation_player_stop(*face_animation);

    }

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

    shader_instance: = begin_shader(resources.sprite_shader.program);
    shader_instance_set_uniform(shader_instance, "uLastHitTime", last_hit_time);

    animation_player_draw(*animation, -xyz(definition.sprite_origin, 0));
    animation_player_draw(*face_animation, xyz(definition.face_position - .{8,8}, 0.01));

    end_shader();

    if definition.draw
    {
        definition.draw(actor);
    }
    alteration_component_draw(*alterations);

    if definition.render_layer != .OBJECTS
    {
        end_render_texture();
    }

    if current_health != definition.max_health && current_health > 0
    {
        begin_render_texture(render_layers[RenderLayer.UI]);

        draw_rectangle(.{0,18,0.1}, .{.{-6,-1}, .{6, 2}}, DARKGRAY);
        draw_rectangle(.{0,18,0.2}, .{.{-5,0}, .{5, 1}}, .{30,30,30,255});

        ratio: = current_health.(float) / definition.max_health.(float);
        draw_rectangle(.{0,18,0.3}, .{.{-5,0}, .{-5 + ratio*10, 1}}, RED);

        end_render_texture();
    }
}

actor_hit :: (using actor: *Actor, source: *Actor)
{
    assert(actor != null);
    assert(definition != null);

    last_hit_time = xx get_time();
    actor_modify_health(actor, -1);

    if definition.on_hit != null
    {
        definition.on_hit(actor, source);
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
        // die
    }
    else if previous_health == 0 && current_health > 0
    {
        // revive
    }
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

#scope_file

delete_actor :: (using actor: *Actor)
{
    actor_set_definition(actor, null);
    array_free(actor.colliders);
    pool_remove(*actors, actor);
}