// Cheese
cheese_definition : = ActorDefinition.{
    init = cheese_init,
    update = cheese_update,

    sprite_origin = .{8,1},
    
    idle_hollow_animation = .{ "cheese_aseprite", "idle_hollow" },
    idle_animation = .{ "cheese_aseprite", "idle" },
    move_animation = .{ "cheese_aseprite", "walk" },
    dead_animation = .{ "cheese_aseprite", "dead" },
    max_health = 2,
    speed = 10,
};


CheeseData :: struct
{
    enabled_collisions: bool;
}

cheese_init :: (using actor: *Actor)
{
    cheese: = New(CheeseData);
    data = cheese;
}

cheese_update :: (using actor: *Actor, dt: float)
{
    cheese: = data.(*CheeseData);

    if !cheese.enabled_collisions
    {
        if length(movement.velocity) < 0.001
        {
            cheese.enabled_collisions = true;
        }
    }
    if !cheese.enabled_collisions return;

    for hitbox: hitboxes
    {
        for collider: hitbox.frame_overlaps
        {
            picking_actor: = collider.parent.(*Actor);
            if !picking_actor.definition.can_pick_objects continue;
            if picking_actor.current_health >= picking_actor.definition.max_health continue;

            //heal
            actor_modify_health(picking_actor, 3);
            create_simple_animation_actor(picking_actor.position.xy, .{*resources.healing_aseprite, string_hash("idle")} , .OVERLAY);

            request_delete_actor(actor);
            break;
        }
    }
    
}