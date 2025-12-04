brain_definition : = ActorDefinition.{
    init = brain_init,
    shutdown = brain_shutdown,
    update = brain_update,
    //draw = brain_draw,

    idle_hollow_animation = .{ "brain_aseprite", "idle_hollow" },
    idle_animation = .{ "brain_aseprite", "idle" },
    move_animation = .{ "brain_aseprite", "walk" },
    dead_animation = .{ "brain_aseprite", "dead" },

    max_health = 1,
    speed = 40,

    attack_damage = 0,
    can_pick_objects = false,
};

BrainData :: struct
{
    previously_possessed_actor: ID(Actor);
    current_target: ID(Actor);
}


brain_init :: (using actor: *Actor)
{
    brain: = New(BrainData);
    data = brain;

    actor.ai.disabled = true; // brain has custom ai

    actor_set_sentient(actor, true);
}

brain_shutdown :: (using actor: *Actor)
{
    brain: = data.(*BrainData);
    yae_array_unordered_remove_by_value(*brains_targets, brain.current_target);
}

//used for debug
/*brain_draw :: (using actor: *Actor)
{
    brain: = data.(*BrainData);
    draw_line(actor.position, brain.current_target.position, 3);
}*/

sort_reference_position: Vector2;

brain_update :: (using actor: *Actor, dt: float)
{
    brain: = data.(*BrainData);
    can_possess: = true;

    if actor_is_dead(actor)
    {
        movement_component_stop(*movement);
        return;
    }
    
    //when controlled by AI
    if !actor.controlling_player
    {
        current_target: = get(brain.current_target);
        can_possess = false;

        //reset chase for target if it becomes not valid
        if !check_if_braintarget_is_valid(actor, current_target, false)
        {
            yae_array_unordered_remove_by_value(*brains_targets, brain.current_target);
            current_target = null;
            brain.current_target = .{};
        }

        if current_target
        {
            //chase target
            movement_component_go_to(*actor.movement, current_target.position.xy);
            can_possess = true;
        }
        else 
        {    
            //sweep for targets
            triggers: = physics_cast_circle(actor.position.xy, 512, .[PHYSIC_LAYER_HURTBOX]);

            sort_reference_position = actor.position.xy;
            bubble_sort(triggers, (a: *Collider, b: *Collider) -> s64
            {
                d1: = distance_squared_point_bounds(sort_reference_position, collider_get_bounds(a));
                d2: = distance_squared_point_bounds(sort_reference_position, collider_get_bounds(b));
                return (d1-d2).(s64);
            });

            for trigger: triggers
            {
                target: = trigger.parent.(*Actor);

                //check if the target fits the conditions
                if !check_if_braintarget_is_valid(actor, target) continue;

                //add the target
                brain.current_target = target.id;
                yae_array_add_if_unique(*brains_targets, target.id);
                break;
            }
        }
    }

    if can_possess
    {
        for hitbox: hitboxes
        {
            for col: hitbox.frame_overlaps
            {
                actorcollide: = col.parent.(*Actor);

                //trigger the "possess" when any actor valid is collided
                //for the player maybe it should be triggered on the attack ?
                if check_if_braintarget_is_valid(actor, actorcollide, false)
                {
                    swap_mind_states(actor, actorcollide);
                    request_delete_actor(actor);
                    return;
                }
            }
        }
    }
}

check_if_braintarget_is_valid :: (using actor: *Actor, target:*Actor, check_in_array:bool=true) -> bool 
{
    brain: = data.(*BrainData);

    if target==null return false;
    if target.definition == *brain_definition return false;
    if actor_is_sentient(target) return false;
    if actor_is_dead(target) return false;
    if target.id==brain.previously_possessed_actor.id return false;
    if check_in_array 
    {
        if yae_array_find(brains_targets, target.id) return false;
    }

    return true;
}

//global array to avoid the brains targeting the same actor
brains_targets: [..] ID(Actor);

#scope_file

#import "Sort";