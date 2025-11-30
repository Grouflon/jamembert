AIComponent :: struct
{
    owner: *Actor;

    state: AIState;

    is_agressive: bool;
    is_panicking: bool;

    detection_zone_radius: float = 50;
    wandering_zone_radius: float;
    zone_center: Vector2;
    wait_time: float;
    target: *Actor;
    disabled: bool;
}

AIState :: enum
{
    NONE;
    WANDERING;
    AGRESSIVE;
    PANICKING;
    CHASING;
}

WanderingParams :: struct
{
    zone_radius: float;
    wait_time_min: float;
    wait_time_max: float;
    speed_modifier: float;
}
default_wandering_params : WanderingParams = .{
    zone_radius = 30,
    wait_time_min = 0.5,
    wait_time_max = 2.0,
    speed_modifier = 0.7,
};

agressive_wandering_params : WanderingParams = .{
    zone_radius = 30,
    wait_time_min = 0.5,
    wait_time_max = 1.0,
    speed_modifier = 1.0,
};

panicked_wandering_params : WanderingParams = .{
    zone_radius = 40,
    wait_time_min = 0,
    wait_time_max = 0,
    speed_modifier = 1.7,
};

SPEED_MODIFIER_NAME :: "ai";

ai_component_init :: (using ai: *AIComponent, actor: *Actor)
{
    owner = actor;
}

ai_component_shutdown :: (using ai: *AIComponent)
{
    set_state(ai, .NONE);
}

ai_component_update :: (using ai: *AIComponent, dt: float)
{
    // Check target is still valid
    if !actor_is_chasable(ai, target)
    {
        target = null;
    }

    // Transitions
    if disabled || actor_is_dead(owner) || !actor_is_sentient(owner)
    {
        set_state(ai, .NONE);
    }
    else
    {
        if is_panicking
        {
            set_state(ai, .PANICKING);
        }
        else if owner.controlling_player == null
        {
            if target != null
            {
                set_state(ai, .CHASING);
            }
            else if is_agressive
            {
                set_state(ai, .AGRESSIVE);
            }
            else
            {
                set_state(ai, .WANDERING);
            }
        }
        else
        {
            set_state(ai, .NONE);
        }
        
    }

    // State update
    if state ==
    {
        case .WANDERING;
        {
            update_wandering(ai, dt, default_wandering_params);
        }

        case .AGRESSIVE;
        {
            update_wandering(ai, dt, agressive_wandering_params);

            assert(target == null);

            potential_targets: = physics_cast(owner.position.xy, .{ type = .CIRCLE, circle = .{.{}, detection_zone_radius}}, .[PHYSIC_LAYER_HURTBOX]);
            closest_target: = get_closest_actor(owner.position.xy, potential_targets, ai, (actor: *Actor, user_data: *void) -> bool
            {
                ai: = user_data.(*AIComponent);
                if actor == ai.owner return false;
                if !actor_is_chasable(ai, actor) return false;
                return true;
            });

            if closest_target != null
            {
                target = closest_target;
            }
        }

        case .PANICKING;
        {
            update_wandering(ai, dt, panicked_wandering_params);
        }

        case .CHASING;
        {
            assert(target != null);
            target_attack_range: = owner.definition.attack_range - 2;
            can_attack_range: = owner.definition.attack_range + 2;

            attack_position: Vector2 = target.position.xy;
            closest_distance_squared: = distance_squared(attack_position, owner.position.xy);

            for hurtbox: target.hurtboxes
            {
                if !hurtbox.enabled continue;

                p: = closest_point_on_bounds(owner.position.xy, collider_get_bounds(hurtbox));
                d: = distance_squared(owner.position.xy, p);
                if d < closest_distance_squared
                {
                    attack_position = p;
                    closest_distance_squared = d;
                }
            }

            target_to_self: = owner.position.xy - attack_position;
            distance: = length(target_to_self);
            movement_component_go_to(*owner.movement, attack_position + normalize(target_to_self) * target_attack_range);

            if distance <= can_attack_range
            {
                actor_attack(owner, signed_angle_between(-target_to_self, .{1,0}));
            }
        }
    }
}

#scope_file

set_state :: (using ai: *AIComponent, _state: AIState)
{
    if state == _state return;

    if state ==
    {
        case .WANDERING;
        {
            movement_component_stop(*owner.movement);
            movement_component_remove_speed_modifer(*owner.movement, SPEED_MODIFIER_NAME);
            wait_time = 0;
        }

        case .AGRESSIVE;
        {
            movement_component_stop(*owner.movement);
            movement_component_remove_speed_modifer(*owner.movement, SPEED_MODIFIER_NAME);
            wait_time = 0;
        }

        case .PANICKING;
        {
            movement_component_stop(*owner.movement);
            movement_component_remove_speed_modifer(*owner.movement, SPEED_MODIFIER_NAME);
            wait_time = 0;
        }

        case .CHASING;
        {
            movement_component_stop(*owner.movement);
            target = null;
        }

        case;
    }
    state = _state;
    if state ==
    {
        case .WANDERING;
        {
            zone_center = owner.position.xy;
        }

        case .AGRESSIVE;
        {
            zone_center = owner.position.xy;
        }

        case .PANICKING;
        {
            zone_center = owner.position.xy;
        }
        case;
    }
}

update_wandering :: (using ai: *AIComponent, dt: float, params: WanderingParams)
{
    has_collision: = false;
    if owner.body.frame_collisions.count > 0
    {
        has_collision = true;
    }

    if !owner.movement.is_moving_to || has_collision
    {
        if wait_time <= 0
        {
            angle: = random_get_zero_to_one() * PI * 2;
            distance: = random_get_zero_to_one() * params.zone_radius;
            wait_time = params.wait_time_min + random_get_zero_to_one() * (params.wait_time_max-params.wait_time_min);

            target_position: = zone_center + rotate(.{distance, 0}, angle);
            movement_component_go_to(*owner.movement, target_position);
            movement_component_set_speed_modifer(*owner.movement, SPEED_MODIFIER_NAME, params.speed_modifier);


        }
        else
        {
            wait_time -= dt;
        }
    }
}

actor_is_chasable :: (using ai: *AIComponent, actor: *Actor) -> bool
{
    if actor == null return false;
    if actor == owner return false;
    if !actor_is_sentient(actor) return false;
    if actor_is_dead(actor) return false;
    return true;
}