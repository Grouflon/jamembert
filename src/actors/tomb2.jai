// Tree
tomb2_definition : = ActorDefinition.{
    init = tomb2_init,
    update = tomb2_update,
    shutdown = tomb2_shutdown,

    sprite_origin = .{8,1},
    face_position = .{0,3},
    idle_hollow_animation = .{ "tomb2_aseprite", "idle_hollow" },
    idle_animation = .{ "tomb2_aseprite", "idle" },
    move_animation = .{ "tomb2_aseprite", "walk" },
    dead_animation = .{ "tomb2_aseprite", "dead" },
    max_health = 3,
    speed = 20,
};

Tomb2Data :: struct
{
    current_skeleton: *Actor; //this one should spawn skeletons but it doesn't exist yet
    spawn_delay_min:= 5.0;
    spawn_delay_max:= 40.0;
    spawn_cd:= 0.0;
}

tomb2_init :: (using actor: *Actor)
{    
    tomb2: = New(Tomb1Data);
    data = tomb2;

    body: = actor_add_collider(actor, .{ type = .BOX, box = .{.{-3,0}, .{3,5}} }, PHYSIC_LAYER_BODY, true);
    actor.alterations.burning_collider.shape = .{ type = .BOX, box = .{.{-4,0}, .{4,6}} };

    tomb2.spawn_cd = random_get_within_range(tomb2.spawn_delay_min,tomb2.spawn_delay_max);
}

tomb2_update :: (using actor: *Actor, dt: float)
{
    tomb2: = data.(*Tomb2Data);

    if !actor_is_sentient(actor) && !actor_is_dead(actor)
    {    
        if tomb2.spawn_cd <= 0
        {
            if tomb2.current_skeleton == null
            {
                //log("SPAWN");
                tomb2.current_skeleton = create_actor(*ghost_definition, actor.position.xy + .{0, -5});
                //doesn't work
                //tomb2.current_skeleton.definition.on_hit = tomb2_skeleton_on_hit;
            }
            tomb2.spawn_cd = random_get_within_range(tomb2.spawn_delay_min,tomb2.spawn_delay_max);
        }
        tomb2.spawn_cd -= dt;
    }
}

/*
I tried to assign the function for when the skeleton die but it crashes :(

tomb2_skeleton_on_hit :: (using actor: *Actor, source: *Actor)
{
    log("skeleton hit");
    tomb2: = data.(*Tomb2Data);
    if actor_is_dead(actor)
    {
        tomb2.current_skeleton = null;
    }
}*/

tomb2_shutdown :: (using actor: *Actor)
{
    
}
