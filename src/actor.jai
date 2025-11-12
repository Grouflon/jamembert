Actor :: struct
{
    #as using e:Entity;
    angle: float;

    id: ID(Actor);

    definition: *ActorDefinition;

    movement: MovementComponent;
    animation: AsepriteAnimationPlayer;
    alterations: AlterationComponent;
    active: bool = true;

    idle_animation: AsepriteAnimationHandle;
    move_animation: AsepriteAnimationHandle;

    colliders: [..]*Collider;
    data: *void;
}
actors: Pool(Actor);
to_delete_actors: [..]*Actor;

ActorDefinition :: struct
{
    init: #type (actor: *Actor);
    shutdown: #type (actor: *Actor);
    update: #type (actor: *Actor, dt: float);
    draw: #type (actor: *Actor);
    burn: #type (actor: *Actor);

    draw_offset: Vector2 = .{-8, -8};
    idle_animation: AsepriteAnimation;
    move_animation: AsepriteAnimation;
}

create_actor :: (definition: *ActorDefinition = null, position: Vector2 = .{}) -> *Actor
{
    pos: = position; // Prevent argument given by ref invalidated by the growing array crash
    actor, id: = pool_add(*actors);

    actor.id = id;
    actor.position = .{pos.x, pos.y, 0};
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

    alteration_component_update(*alterations, dt);
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
    alteration_component_draw(*alterations);
}

actor_burn :: (using actor: *Actor)
{
    assert(actor != null);
    assert(definition != null);

    if definition.burn != null
    {
        definition.burn(actor);
    }
}

actor_add_collider :: (using actor: *Actor, rect: Rect, layer: u8, static: bool = false) -> *Collider
{
    collider: = physics_add_collider(actor, layer);
    collider.rect = rect;
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