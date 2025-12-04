// Spell
mitose_spell_definition : = SpellDefinition.{
    type = .TARGET,
    icon = .{ "icons_aseprite", "mitose" },
    range = 200,
    cast_func = (params: SpellCastParams) -> bool
    {
        target: = params.target.target;
        if target == null return false;
        //if !actor_is_sentient(target) return false;

        newactor: =create_actor(params.target.target.definition, params.target.target.position.xy);
        mind_state: = get_mind_state(params.target.target);
        mind_state.controlling_player = null; // player can't control several entities (for now);
        set_mind_state(newactor, mind_state);

        cast_position: = params.target.target.position.xy;
        offset: = Vector2.{5,0};
        params.target.target.position = xyz(cast_position - offset, 0);
        newactor.position = xyz(cast_position + offset, 0);

        return true;
    },
};
