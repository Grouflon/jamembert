AIComponent :: struct
{
    owner: *Actor;

    is_agressive: bool;

    detection_zone_radius: float;
    wandering_zone_radius: float;
    zone_center: Vector2;
    wait_time: float;
    target: *Actor;
    attack_cooldown: float;
}

ai_component_init :: (using ai: *AIComponent, actor: *Actor)
{
    owner = actor;

    ai.zone_center = owner.position.xy;
    ai.wandering_zone_radius = 30.0;
    ai.detection_zone_radius = 35.0;
}

ai_component_update :: (using ai: *AIComponent, dt: float)
{
    if actor_is_dead(owner) return;
    if !actor_is_sentient(owner) return;
    if owner.user_controlled return;

    MIN_WAIT_TIME :: 0.5;
    MAX_WAIT_TIME :: 2.0;

    if attack_cooldown > 0
    {
        attack_cooldown -= dt;
    }

    if target != null
    {
        if !actor_is_sentient(target) || actor_is_dead(target)
        {
            target = null;
        }
        else
        {
            ATTACK_RANGE :: 13;
            ATTACK_COOLDOWN :: 1;
            target_to_self: = (owner.position - target.position).xy;
            distance: = length(target_to_self);
            movement_component_go_to(*owner.movement, target.position.xy + normalize(target_to_self) * ATTACK_RANGE);

            if attack_cooldown <= 0 && distance <= ATTACK_RANGE + 1
            {
                actor_attack(owner, target.position.xy);
                attack_cooldown = ATTACK_COOLDOWN;
            }
        }
    }

    if target == null
    {
        if !owner.movement.is_moving
        {
            if wait_time <= 0
            {
                angle: = random_get_zero_to_one() * PI * 2;
                distance: = random_get_zero_to_one() * wandering_zone_radius;
                wait_time = MIN_WAIT_TIME + random_get_zero_to_one() * (MAX_WAIT_TIME-MIN_WAIT_TIME);

                target_position: = zone_center + rotate(.{distance, 0}, angle);
                movement_component_go_to(*owner.movement, target_position);
            }
            else
            {
                wait_time -= dt;
            }
        }
    }

    if is_agressive && target == null
    {
        potential_targets: = physics_cast(zone_center, .{ type = .CIRCLE, circle = .{.{}, detection_zone_radius}}, .[PHYSIC_LAYER_BODY]);
        closest_target: *Actor;
        closest_target_squared_distance: float = FLOAT32_MAX;
        for collider: potential_targets
        {
            if collider.parent == owner continue;

            d: = distance_squared(owner.position, collider.parent.position);
            if d < closest_target_squared_distance
            {
                closest_target_squared_distance = d;
                closest_target = collider.parent.(*Actor);
            }
        }

        if closest_target != null
        {
            target = closest_target;
        }
    }
}