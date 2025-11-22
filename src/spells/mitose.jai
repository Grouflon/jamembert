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
        newactor.alterations = params.target.target.alterations;
        return true;
    },
};
