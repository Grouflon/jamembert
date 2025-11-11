MovementComponent :: struct
{
    owner: *Actor;

    speed: float = 10.0;
    target: Vector2;
    is_moving: = false;
}

movement_component_update :: (using c: *MovementComponent, dt: float)
{
    if !is_moving return;

    last_position: = owner.position.xy;
    current_position: = last_position;
    direction: = normalize(target - current_position);
    current_position += direction * speed * dt;

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
