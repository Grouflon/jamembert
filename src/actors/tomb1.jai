// Tree
tomb1_definition : = ActorDefinition.{
    init = tomb1_init,
    update = tomb1_update,
    shutdown = tomb1_shutdown,

    idle_hollow_animation = .{ "tomb1_aseprite", "idle_hollow" },
    idle_animation = .{ "tomb1_aseprite", "idle" },
    move_animation = .{ "tomb1_aseprite", "walk" },
    dead_animation = .{ "tomb1_aseprite", "dead" },
    max_health = 5,
    speed = 10,
    is_static = true,
};

Tomb1Data :: struct
{
    current_ghost: *Actor;
    spawn_delay_min:= 5.0;
    spawn_delay_max:= 40.0;
    spawn_cd:= 0.0;
}

tomb1_init :: (using actor: *Actor)
{    
    tomb1: = New(Tomb1Data);
    data = tomb1;

    tomb1.spawn_cd = random_get_within_range(tomb1.spawn_delay_min,tomb1.spawn_delay_max);
}

tomb1_update :: (using actor: *Actor, dt: float)
{
    tomb1: = data.(*Tomb1Data);

    if !actor_is_sentient(actor) && !actor_is_dead(actor)
    {    
        //log("%",dt);
        //log("%",tomb1.spawn_cd);
        if tomb1.spawn_cd <= 0
        {
            if tomb1.current_ghost == null
            {
                //log("SPAWN");
                tomb1.current_ghost = create_actor(*ghost_definition, actor.position.xy + .{0, -5});
                //doesn't work
                //tomb1.current_ghost.definition.on_hit = tomb1_ghost_on_hit;
            }
            tomb1.spawn_cd = random_get_within_range(tomb1.spawn_delay_min,tomb1.spawn_delay_max);
        }
        tomb1.spawn_cd -= dt;
    }
}

/*
I tried to assign the function for when the ghost die but it crashes :(

tomb1_ghost_on_hit :: (using actor: *Actor, source: *Actor)
{
    log("ghost hit");
    tomb1: = data.(*Tomb1Data);
    if actor_is_dead(actor)
    {
        tomb1.current_ghost = null;
    }
}*/

tomb1_shutdown :: (using actor: *Actor)
{
    
}