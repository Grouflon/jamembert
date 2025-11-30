MindState :: struct
{
    is_sentient: bool;
    is_agressive: bool;
    controlling_player: *Player;
}

get_mind_state :: (actor: *Actor) -> MindState
{
    if actor == null return .{};
    return .{
        is_sentient = actor.alterations.sentient,
        is_agressive = actor.ai.is_agressive,
        controlling_player = actor.controlling_player,
    };
}

set_mind_state :: (actor: *Actor, state: MindState)
{
    if actor == null return;

    actor_set_sentient(actor, state.is_sentient);
    actor.ai.is_agressive = state.is_agressive;
    if state.controlling_player != null
    {
        set_controlled_actor(state.controlling_player, actor);
    }
    else if actor.controlling_player != null
    {
        set_controlled_actor(actor.controlling_player, null);
    }
}

swap_mind_states :: (a: *Actor, b: *Actor)
{
    if a == null return;
    if b == null return;
    a_state: = get_mind_state(a);
    b_state: = get_mind_state(b);
    set_mind_state(a, b_state);
    set_mind_state(b, a_state);
}
