Actor :: struct
{
    #as using e:Entity;
    angle: float;

    definition: *ActorDefinition;

    movement: MovementComponent;
    animation: AsepriteAnimationPlayer;
    active: bool = true;

    idle_animation: AsepriteAnimationHandle;
    move_animation: AsepriteAnimationHandle;

    should_delete: bool;
}
actors: [..]*Actor;

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

create_actor :: (definition: *ActorDefinition = null, position: Vector2 = .{}) -> *Actor
{
    actor: = New(Actor);
    array_add(*actors, actor);

    actor.position = .{position.x, position.y, 0};
    actor.movement.owner = actor;

    actor_set_definition(actor, definition);

    return actor;
}

delete_actor :: (actor: *Actor)
{
    assert(actor != null);
    actor.should_delete = true;
}

actor_set_definition :: (actor: *Actor, definition: *ActorDefinition)
{
    assert(actor != null);

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
}

actors_update :: (dt: float)
{
    for actor: actors
    {
        if !actor.active continue;
        if actor.definition == null continue;

        actor_update(actor, dt);
    }

    for actor: actors
    {
        if !actor.should_delete continue;

        actor_set_definition(actor, null);
        free(actor);
        remove actor;
    }
}

actors_draw :: ()
{
    for actor: actors
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