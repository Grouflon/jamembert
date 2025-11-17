// Spell
lobotomie_spell_definition : = SpellDefinition.{
    type = .TARGET,
    icon = .{ "icons_aseprite", "lobotomie" },
    range = 200,
    cast_func = (params: SpellCastParams)
    {
        target: = params.target.target;
        if target == null return;
        set_sentient(target, false);
    },
};
