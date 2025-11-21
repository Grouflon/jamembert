// Cheese
cheese_definition : = ActorDefinition.{
    init = cheese_init,
    update = cheese_update,

    sprite_origin = .{8,1},
    face_position = .{0,5},
    face_dead_position = .{0,2},
    idle_hollow_animation = .{ "cheese_aseprite", "idle_hollow" },
    idle_animation = .{ "cheese_aseprite", "idle" },
    move_animation = .{ "cheese_aseprite", "walk" },
    dead_animation = .{ "cheese_aseprite", "dead" },
    max_health = 2,
    speed = 10,
};


CheeseData :: struct
{
    body: *Collider;
    pickup_trigger: *Collider;
    enabled_collisions: bool;
}

cheese_init :: (using actor: *Actor)
{
    cheese: = New(CheeseData);
    data = cheese;

    cheese.body = actor_add_collider(actor, .{ type = .BOX, box = .{.{-8,0}, .{4,8}} }, PHYSIC_LAYER_BODY, true);
    cheese.pickup_trigger = actor_add_collider(actor, .{ type = .BOX, box = dilate(cheese.body.shape.box, .{1,1}) }, PHYSIC_LAYER_SPELL);
    cheese.body.enabled = false;
    cheese.pickup_trigger.enabled = false;

    actor.alterations.burning_collider.shape = .{ type = .BOX, box = .{.{-8,0}, .{8,8}} };
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

    for collider: cheese.pickup_trigger.frame_overlaps
    {
        picking_actor: = collider.parent.(*Actor);
        if !picking_actor.user_controlled continue;

        //heal
        if picking_actor.current_health < picking_actor.definition.max_health
        {
            actor_hit(picking_actor, -3, actor);
            create_simple_animation_actor(picking_actor.position.xy, .{*resources.healing_aseprite, string_hash("idle")} , .OVERLAY);

            request_delete_actor(actor);
        }

    }

    cheese.body.enabled = cheese.enabled_collisions;
    cheese.pickup_trigger.enabled = cheese.enabled_collisions && !actor_is_sentient(actor) && !actor_is_dead(actor);
}