Alteration :: enum_flags u64
{
    BURNING :: 1 << 0;
    SENTIENT :: 1 << 1;
}

AlterationComponent :: struct
{
    owner: *Actor;

    burning: bool;
    remaining_burning_time: float;
    consecutive_burning_time: float;

    sentient: bool;

    rng: Random_State;

    particle_seeds: [..]u64;
}

BURNING_TICK_COUNT :: 2;
BURNING_TICK_TIME :: 2.5;
BURNING_TICK_DAMAGE :: 1;

PARTICLE_SEEDS :: 100;

alteration_component_init :: (using component: *AlterationComponent, actor: *Actor)
{
    owner = actor;

    array_resize(*particle_seeds, PARTICLE_SEEDS);
    for i: 0..PARTICLE_SEEDS-1
    {
        particle_seeds[i] = random_get();
    }
}

alteration_component_shutdown :: (using component: *AlterationComponent)
{
    array_reset(*particle_seeds);
}

alteration_component_update :: (using component: *AlterationComponent, dt: float)
{
    if burning
    {
        // Damage
        previous_consecutive_burning_time: = consecutive_burning_time;
        consecutive_burning_time += dt;
        remaining_burning_time -= dt;

        previous_consecutive_ticks: = floor_to_s32(previous_consecutive_burning_time / BURNING_TICK_TIME);
        consecutive_ticks: = floor_to_s32(consecutive_burning_time / BURNING_TICK_TIME);

        if previous_consecutive_ticks != consecutive_ticks
        {
            actor_hit(owner, BURNING_TICK_DAMAGE, null);
        }

        if remaining_burning_time <= 0
        {
            actor_set_burning(owner, false);
        }
    }

    for burnbox: owner.burnboxes
    {
        for collider: burnbox.frame_overlaps
        {
            actor_set_burning(collider.parent.(*Actor), true);
        }
    }
}

alteration_component_draw :: (using component: *AlterationComponent)
{
    time: = get_time();

    if burning
    {
        // Particles
        PARTICLE_PER_SQUARE_UNIT_COUNT :: 0.04;
        TRAVEL_LENGTH :: 6;
        TRAVEL_TIME :: 0.7;

        for burnbox, j: owner.burnboxes
        {
            if !burnbox.enabled continue;
            collider_size: = size(collider_get_bounds(burnbox));
            particle_count: = ceil_to_s32(collider_size.x * collider_size.y * PARTICLE_PER_SQUARE_UNIT_COUNT);

            for i: 0..particle_count-1
            {
                p_time: = time + ((j*particle_count + i).(float) * TRAVEL_TIME / particle_count);
                t: = positive_mod(p_time, TRAVEL_TIME) / TRAVEL_TIME;
                cycle_count: u64 = xx (p_time / TRAVEL_TIME);
                seed: = particle_seeds[i%PARTICLE_SEEDS] + cycle_count*9472;
                random_seed(*rng, seed);
                r1: = random_get_zero_to_one(*rng);
                // random_seed(*rng, seed + 124414);
                r2: = random_get_zero_to_one(*rng);

                origin: = Vector3.{
                    burnbox.shape.box.min.x + r1 * width(burnbox.shape.box),
                    burnbox.shape.box.min.y + r2 * height(burnbox.shape.box),
                    0.1,
                };

                draw_sprite(origin + .{0, TRAVEL_LENGTH, 0} * t + .{-8,-8, 0}, resources.flame_texture.texture);
            }
        }

    }
}

actor_set_burning :: (actor: *Actor, value: bool)
{
    assert(actor != null);
    if actor.alterations.burning == value return;

    actor.alterations.burning = value;
    actor.ai.is_panicking = value;

    if value
    {
        actor.alterations.remaining_burning_time = BURNING_TICK_TIME * BURNING_TICK_COUNT;
    }
    else
    {
        actor.alterations.consecutive_burning_time = 0;
        actor.alterations.remaining_burning_time = 0;
    }
}

actor_is_burning :: (actor: *Actor) -> bool
{
    assert(actor != null);
    return actor.alterations.burning;
}

actor_set_sentient :: (actor: *Actor, value: bool)
{
    assert(actor != null);
    previous_sentient: = actor.alterations.sentient;
    actor.alterations.sentient = value;

    // This is bit of a hack, everything should be centralized in a state machine
    if previous_sentient && !value
    {
        movement_component_stop(*actor.movement);
    }
}

actor_is_sentient :: (actor: *Actor) -> bool
{
    assert(actor != null);
    return actor.alterations.sentient;
}

#import "Random";