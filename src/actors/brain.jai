brain_definition : = ActorDefinition.{
    init = brain_init,
    update = brain_update,
    //draw = brain_draw,

    idle_hollow_animation = .{ "brain_aseprite", "idle_hollow" },
    idle_animation = .{ "brain_aseprite", "idle" },
    move_animation = .{ "brain_aseprite", "walk" },
    dead_animation = .{ "brain_aseprite", "dead" },

    sprite_origin = .{8,1},
    face_dead_position = .{0,7},

    max_health = 1,
    speed = 40,

    attack_damage = 0,
};

BrainData :: struct
{
    body: *Collider;
    possess_col: *Collider;
    previously_possessed_actor: *Actor;
    current_target: *Actor;
}


brain_init :: (using actor: *Actor)
{
    brain: = New(BrainData);
    data = brain;

    brain.body = actor_add_collider(actor, .{ type = .BOX, box = .{.{-2, 1}, .{2,4}} }, PHYSIC_LAYER_BODY);
    brain.possess_col = actor_add_collider(actor, .{ type = .BOX, box = .{.{-4, -1}, .{4,6}} }, PHYSIC_LAYER_SPELL);
    actor.alterations.burning_collider.shape = .{ type = .BOX, box = dilate(brain.body.shape.box, .{2,1}) };

    actor_set_sentient(actor, true);
}

//used for debug
/*brain_draw :: (using actor: *Actor)
{
    brain: = data.(*BrainData);
    draw_line(actor.position, brain.current_target.position, 3);
}*/

brain_update :: (using actor: *Actor, dt: float)
{
    brain: = data.(*BrainData);
    
    if !actor.controlling_player
    {    
        //when controlled by AI
        if brain.current_target
        {
            //reset chase for target if it becomes not valid
            if !check_if_braintarget_is_valid(actor, brain.current_target, false) brain.current_target = null;

            //chase target
            movement_component_go_to(*actor.movement, brain.current_target.position.xy);

            for col: brain.possess_col.frame_overlaps
            {
                actorcollide: = col.parent.(*Actor);

                //trigger the "possess" even if it's not the current target because there is no pathfinding so it get stuck
                //nor there's a way to sort an array by closest + it wouldn't work for the player
                if check_if_braintarget_is_valid(actor, actorcollide, false)
                {
                    actor_set_sentient(actorcollide, true);
                    array_unordered_remove_by_value(*brains_targets, brain.current_target);
                    request_delete_actor(actor);
                    return;
                }
            }
        }
        else 
        {    
            //sweep for targets
            triggers: = physics_cast(actor.position.xy, .{ type = .CIRCLE, circle = .{ .{}, 128 } }, .[PHYSIC_LAYER_BODY]);
            for trigger: triggers
            {
                target: = trigger.parent.(*Actor);

                //check if the target fits the conditions
                if !check_if_braintarget_is_valid(actor, target) continue;

                //add the target
                brain.current_target = target;
                array_add_if_unique(*brains_targets, target);
            }
        }
    }
    else
    {
        //When controlled by the player
        for col: brain.possess_col.frame_overlaps
        {
            actorcollide: = col.parent.(*Actor);

            //trigger the "possess" when any actor valid is collided
            //for the player maybe it should be triggered on the attack ?
            if check_if_braintarget_is_valid(actor, actorcollide, false)
            {
                actor_set_sentient(actorcollide, true);

                //I don't know how the mindstate work so maybe we should change that
                set_controlled_actor(actor.controlling_player,actorcollide);

                request_delete_actor(actor);
                return;
            }
        }
    }
}

check_if_braintarget_is_valid :: (using actor: *Actor, target:*Actor, check_in_array:bool=true) -> bool 
{
    brain: = data.(*BrainData);
    valid: = true;

    if target==null valid = false;
    if target.definition == *brain_definition valid = false;
    if actor_is_sentient(target) valid = false;
    if actor_is_dead(target) valid = false;
    if target==brain.previously_possessed_actor valid = false;
    if check_in_array 
    {
        if array_find(brains_targets, target) valid = false;
    }

    return valid;
}

//global array to avoid the brains targeting the same actor
brains_targets: [..] *Actor;