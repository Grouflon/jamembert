Alteration :: enum_flags u64
{
    BURNING :: 1 << 0;
    SENTIENT :: 1 << 1;
}

AlterationComponent :: struct
{
    owner: *Actor;

    burning: bool;
    sentient: bool;

    burning_collider: *Collider;
}

alteration_component_init :: (using component: *AlterationComponent, actor: *Actor)
{
    owner = actor;

    burning_collider = actor_add_collider(owner, .{}, PHYSIC_LAYER_SPELL);
    burning_collider.enabled = false;
}

alteration_component_shutdown :: (using component: *AlterationComponent)
{
    actor_remove_collider(owner, burning_collider);
    burning_collider = null;
}

alteration_component_update :: (using component: *AlterationComponent, dt: float)
{
    for collider: burning_collider.frame_overlaps
    {
        set_burning(collider.parent.(*Actor), true);
    }
}

alteration_component_draw :: (using component: *AlterationComponent)
{
    time: = get_time();

    if burning
    {
        PARTICLE_COUNT :: 5;
        TRAVEL_LENGTH :: 6;
        TRAVEL_TIME :: 0.7;


        for i: 0..PARTICLE_COUNT-1
        {
            p_time: = time + (i.(float) * TRAVEL_TIME / PARTICLE_COUNT);
            t: = positive_mod(p_time, TRAVEL_TIME) / TRAVEL_TIME;
            cycle_count: u64 = xx (p_time / TRAVEL_TIME);
            seed: = component.(u64) + (xx i + cycle_count) * 1000;
            random_seed(seed);
            r1: = random_get_zero_to_one();
            random_seed(seed + 124414);
            r2: = random_get_zero_to_one();

            origin: = Vector3.{
                burning_collider.rect.x + r1 * burning_collider.rect.w,
                burning_collider.rect.y + r2 * burning_collider.rect.h,
                0.1,
            };

            draw_sprite(origin + .{0, TRAVEL_LENGTH, 0} * t + .{-8,-8, 0}, resources.flame_texture.texture);
        }
    }
}

set_burning :: (actor: *Actor, value: bool)
{
    assert(actor != null);

    actor.alterations.burning = value;
    actor.alterations.burning_collider.enabled = value;
}

is_burning :: (actor: *Actor) -> bool
{
    assert(actor != null);
    return actor.alterations.burning;
}

set_sentient :: (actor: *Actor, value: bool)
{
    assert(actor != null);
    actor.alterations.sentient = value;
}

is_sentient :: (actor: *Actor) -> bool
{
    assert(actor != null);
    return actor.alterations.sentient;
}

#import "Random";