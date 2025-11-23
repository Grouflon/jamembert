// Spell
mindswap_spell_definition : = SpellDefinition.{
    type = .TARGET,
    icon = .{ "icons_aseprite", "mindswap" },
    range = 200,
    cast_func = (params: SpellCastParams) -> bool
    {
        target: = params.target.target;
        if target == null return false;

        effect: = create_actor(*mindswap_definition, params.source.position.xy);
        mindswap: = effect.data.(*MindswapData);
        mindswap.caster = params.source.id;
        mindswap.target = target.id;
        mindswap.mind_state = get_mind_state(params.source);
        set_mind_state(params.source, .{});
        movement_component_go_to(*effect.movement, target.position.xy);

        return true;
    },
};

mindswap_definition : = ActorDefinition.{
    init = mindswap_init,
    update = mindswap_update,

    render_layer = .OVERLAY,
    sprite_origin = .{8,8},
    speed = 300,
    idle_animation = .{ "lobotomie_aseprite", "idle" },
};

MindswapData :: struct
{
    caster: ID(Actor);
    target: ID(Actor);
    mind_state: MindState;
    swap_back: bool;
}

MindState :: struct
{
    is_sentient: bool;
    is_agressive: bool;
    is_user_controlled: bool;
}

get_mind_state :: (actor: *Actor) -> MindState
{
    if actor == null return .{};
    return .{
        is_sentient = actor.alterations.sentient,
        is_agressive = actor.ai.is_agressive,
        is_user_controlled = actor.user_controlled,
    };
}

set_mind_state :: (actor: *Actor, state: MindState)
{
    if actor == null return;

    actor_set_sentient(actor, state.is_sentient);
    actor.ai.is_agressive = state.is_agressive;
    if state.is_user_controlled
    {
        set_controlled_actor(actor);
    }
    else if controlled_actor == actor
    {
        set_controlled_actor(null);
    }
}

mindswap_init :: (using actor: *Actor)
{
    position.z = 1;
    mindswap: = New(MindswapData);
    data = mindswap;
}

mindswap_update :: (using actor: *Actor, dt: float)
{
    mindswap: = data.(*MindswapData);
    target: = get(mindswap.target);
    if target == null
    {
        request_delete_actor(actor);
        return;
    }
    
    if !movement.is_moving_to
    {
        target_mind_state: = get_mind_state(target);
        set_mind_state(target, mindswap.mind_state);

        caster: = get(mindswap.caster);
        if caster != null && !mindswap.swap_back && target_mind_state.is_sentient
        {
            effect: = create_actor(*mindswap_definition, target.position.xy);
            new_mindswap: = effect.data.(*MindswapData);
            new_mindswap.caster = mindswap.target;
            new_mindswap.target = mindswap.caster;
            new_mindswap.mind_state = target_mind_state;
            new_mindswap.swap_back = true;
            movement_component_go_to(*effect.movement, caster.position.xy);
        }

        request_delete_actor(actor);
        return;
    }

    movement_component_go_to(*movement, target.position.xy);
}