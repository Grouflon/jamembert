MovementComponent :: struct
{
    owner: *Actor;

    target: Vector2;
    is_moving: = false;
    speed_modifiers: Table(StringHash, float);
}

movement_component_init :: (using c: *MovementComponent, actor: *Actor)
{
    owner = actor;
}

movement_component_shutdown :: (using c: *MovementComponent)
{
    table_reset_and_free(*speed_modifiers);
}

movement_component_update :: (using c: *MovementComponent, dt: float)
{
    if !is_moving return;

    last_position: = owner.position.xy;
    current_position: = last_position;
    direction: = normalize(target - current_position);

    speed_modifier: = 1.0;
    for s: speed_modifiers
    {
        speed_modifier *= s;
    }
    current_position += direction * owner.definition.speed * speed_modifier * dt;

    if dot(target - current_position, direction) <= 0
    {
        current_position = target;
        is_moving = false;
    }
    owner.position = .{current_position.x, current_position.y, owner.position.z};
}

movement_component_go_to :: (using c: *MovementComponent, _target: Vector2)
{
    target = _target;
    is_moving = true;
}

movement_component_stop :: (using c: *MovementComponent)
{
    is_moving = false;
}

movement_component_set_speed_modifer :: (using c: *MovementComponent, name: string, value: float)
{
    table_set(*speed_modifiers, string_hash(name), value);
}

movement_component_remove_speed_modifer :: (using c: *MovementComponent, name: string)
{
    table_remove(*speed_modifiers, string_hash(name));
}

#scope_file

#import "Hash_Table";