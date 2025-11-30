brain_definition : = ActorDefinition.{
    init = brain_init,
    shutdown = brain_shutdown,
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
    previously_possessed_actor: ID(Actor);
    current_target: ID(Actor);
}


brain_init :: (using actor: *Actor)
{
    brain: = New(BrainData);
    data = brain;

    brain.body = actor_add_collider(actor, .{ type = .BOX, box = .{.{-2, 1}, .{2,4}} }, PHYSIC_LAYER_BODY);
    brain.possess_col = actor_add_collider(actor, .{ type = .BOX, box = .{.{-4, -1}, .{4,6}} }, PHYSIC_LAYER_SPELL);
    actor.alterations.burning_collider.shape = .{ type = .BOX, box = dilate(brain.body.shape.box, .{2,1}) };
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

brain_update :: (using actor: *Actor, dt: float)
{
    brain: = data.(*BrainData);
    can_possess: = true;
    
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
            triggers: = physics_cast(actor.position.xy, .{ type = .CIRCLE, circle = .{ .{}, 128 } }, .[PHYSIC_LAYER_BODY]);
            for trigger: triggers
            {
                target: = trigger.parent.(*Actor);

                //check if the target fits the conditions
                if !check_if_braintarget_is_valid(actor, target) continue;

                //add the target
                brain.current_target = target.id;
                yae_array_add_if_unique(*brains_targets, target.id);
            }
        }
    }

    if can_possess
    {
        for col: brain.possess_col.frame_overlaps
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