get_closest_actor :: (position: Vector2, actors: []*Actor, user_data: *void = null, filter: #type(*Actor, *void)->bool = null) -> *Actor
{
    closest_squared_distance: float = FLOAT32_MAX;
    closest_actor: *Actor;
    for actor: actors
    {
        if filter != null && !filter(actor, user_data) continue;

        squared_distance: = distance_squared(position, actor.position.xy);
        if squared_distance < closest_squared_distance
        {
            closest_squared_distance = squared_distance;
            closest_actor = actor;
        }
    }
    return closest_actor;
}

get_closest_actor :: (position: Vector2, colliders: []*Collider, user_data: *void = null, filter: #type(*Actor, *void)->bool = null) -> *Actor, Vector2
{
    closest_squared_distance: float = FLOAT32_MAX;
    closest_actor: *Actor;
    closest_collider_bounds: Bounds;
    for collider: colliders
    {
        actor: = collider.parent.(*Actor);
        if filter != null && !filter(collider.parent.(*Actor), user_data) continue;

        bounds: = collider_get_bounds(collider);
        squared_distance: = distance_squared_point_bounds(position, bounds);
        if squared_distance < closest_squared_distance
        {
            closest_squared_distance = squared_distance;
            closest_collider_bounds = bounds;
            closest_actor = actor;
        }
    }
    return closest_actor, closest_point_on_bounds(position, closest_collider_bounds);
}
