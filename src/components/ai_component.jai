AIMode :: enum
{
    NONE :: 0;
    PANIC;
    WANDERING;
    AGRESSIVE;
}

AIComponent :: struct
{
    owner: *Actor;

    mode: AIMode;

    zone_radius: float;
    zone_center: Vector2;

    wait_time: float;
}

ai_component_init :: (using ai: *AIComponent, actor: *Actor)
{
    owner = actor;
}

ai_component_update :: (using ai: *AIComponent, dt: float)
{
    if actor_is_dead(owner) return;
    if !actor_is_sentient(owner) return;

    if mode ==
    {
        case .WANDERING;
        {
            if !owner.movement.is_moving
            {
                if wait_time <= 0
                {
                    MIN_WAIT_TIME :: 0.5;
                    MAX_WAIT_TIME :: 2.0;

                    angle: = random_get_zero_to_one() * PI * 2;
                    distance: = random_get_zero_to_one() * zone_radius;
                    wait_time = MIN_WAIT_TIME + random_get_zero_to_one() * (MAX_WAIT_TIME-MIN_WAIT_TIME);

                    target: = zone_center + rotate(.{distance, 0}, angle);
                    movement_component_go_to(*owner.movement, target);
                }
                else
                {
                    wait_time -= dt;
                }
            }
        }
    }
}