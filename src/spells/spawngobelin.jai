// Spell
spawngobelin_spell_definition : = SpellDefinition.{
    type = .POSITION,
    icon = .{ "icons_aseprite", "spawn_gobelin" },
    cast_func = (params: SpellCastParams) -> bool
    {

        create_actor(*goblin_definition, params.position.origin);
        return true;
    },
};
