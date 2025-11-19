SpellDefinition :: struct
{
    type: SpellCastType;
    icon: AsepriteAnimation;
    range: float;
    cast_func: #type (params: SpellCastParams);
}

spell_cast :: (definition: *SpellDefinition, params: SpellCastParams)
{
    assert(definition != null);
    if definition.cast_func == null return;

    definition.cast_func(params);
}