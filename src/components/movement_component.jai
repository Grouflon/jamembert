MovementComponent :: struct
{
    owner: *Actor;

    input: Vector2;

    target: Vector2;
    is_moving_to: = false;
    speed_modifiers: Table(StringHash, float);

    last_position: Vector2;
    velocity: Vector2;
}

movement_component_init :: (using c: *MovementComponent, actor: *Actor)
{
    owner = actor;

    last_position = owner.position.xy;
}

movement_component_shutdown :: (using c: *MovementComponent)
{
    table_reset_and_free(*speed_modifiers);
}

movement_component_update :: (using c: *MovementComponent, dt: float)
{
    speed_modifier: = 1.0;
    for s: speed_modifiers
    {
        speed_modifier *= s;
    }

    if is_moving_to
    {
        current_position: = owner.position.xy;
        direction: = normalize(target - current_position);

        current_position += direction * owner.definition.speed * speed_modifier * dt;

        if dot(target - current_position, direction) <= 0
        {
            current_position = target;
            is_moving_to = false;
        }
        owner.position = .{current_position.x, current_position.y, owner.position.z};
    }
    else
    {
        owner.position += xyz(input * owner.definition.speed * speed_modifier * dt, 0);
        input = .{};
    }

    velocity = (owner.position.xy - last_position) / dt;
    last_position = owner.position.xy;
}

movement_component_go_to :: (using c: *MovementComponent, _target: Vector2)
{
    target = _target;
    is_moving_to = true;
}

movement_component_add_input :: (using c: *MovementComponent, _input: Vector2)
{
    input += _input;
}

movement_component_stop :: (using c: *MovementComponent)
{
    is_moving_to = false;
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