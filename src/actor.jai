ActorID :: PoolID(Actor);

Actor :: struct
{
    #as using e:Entity;
    angle: float;

    id: ActorID;

    definition: *ActorDefinition;

    movement: MovementComponent;
    animation: AsepriteAnimationPlayer;
    active: bool = true;

    idle_animation: AsepriteAnimationHandle;
    move_animation: AsepriteAnimationHandle;

    colliders: [..]PoolID(Collider);
}
actors: Pool(Actor);
to_delete_actors: [..]ActorID;

ActorDefinition :: struct
{
    init: #type (actor: *Actor);
    shutdown: #type (actor: *Actor);
    update: #type (actor: *Actor, dt: float);
    draw: #type (actor: *Actor);

    draw_offset: Vector2 = .{-8, -8};
    idle_animation: AsepriteAnimation;
    move_animation: AsepriteAnimation;
}

create_actor :: (definition: *ActorDefinition = null, position: Vector2 = .{}) -> ActorID
{
    pos: = position; // Prevent argument given by ref invalidated by the growing array crash
    id, actor: = pool_add(*actors);

    actor.id = id;
    actor.position = .{pos.x, pos.y, 0};
    actor.movement.owner_id = id;

    actor_set_definition(actor, definition);

    return id;
}

request_delete_actor :: (_id: ActorID)
{
    for id: to_delete_actors
    {
        if id == _id return;
    }
    array_add(*to_delete_actors, _id);
}

request_delete_actor :: (actor: *Actor)
{
    assert(actor != null);
    request_delete_actor(actor.id);
}

delete_all_actors :: ()
{
    for *actor: actors
    {
        log("%", << actor);
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
}

actors_update :: (dt: float)
{
    for *actor: actors
    {
        if !actor.active continue;
        if actor.definition == null continue;

        actor_update(actor, dt);
    }

    for id: to_delete_actors
    {
        actor: = get(id);
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
    if movement.is_moving && move_animation.aseprite != null
    {
        animation_player_play(*animation, move_animation);
    }
    else
    {
        animation_player_play(*animation, idle_animation);
    }

    movement_component_update(*movement, dt);
    animation_player_update(*animation, dt);

    if definition.update
    {
        definition.update(actor, dt);
    }
}

actor_draw :: (using actor: *Actor)
{
    begin_transform();
    defer end_transform();

    transform_translate(position);
    r: Quaternion;
    set_from_axis_and_angle(*r, .{0,0,1}, angle);
    transform_rotate(r);

    animation_player_draw(*animation, .{definition.draw_offset.x, definition.draw_offset.y, 0});

    if definition.draw
    {
        definition.draw(actor);
    }
}

actor_add_collider :: (using actor: *Actor, rect: Rect, layer: u8, static: bool = false) -> PoolID(Collider)
{
    collider_id: = physics_add_collider(actor, layer);
    collider: *Collider = get(collider_id);
    collider.rect = rect;
    collider.static = static;
    array_add(*colliders, collider_id);
    return collider_id;
}

actor_remove_collider :: (using actor: *Actor, _id: PoolID(Collider))
{
    for id : colliders
    {
        if id == _id
        {
            remove id;
            break;
        }
    }
    physics_remove_collider(_id);
}

actor_remove_all_colliders :: (using actor: *Actor)
{
    for id : colliders
    {
        physics_remove_collider(id);
    }
    colliders.count = 0;
}

#scope_file

delete_actor :: (using actor: *Actor)
{
    actor_set_definition(actor, null);
    array_free(actor.colliders);
    pool_remove(*actors, id);
}