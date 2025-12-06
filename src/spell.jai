SpellDefinition :: struct
{
    type: SpellCastType;
    icon: AsepriteAnimation;
    range: float = 1000;
    cast_func: #type (params: SpellCastParams) -> bool;
}

spell_cast :: (definition: *SpellDefinition, params: SpellCastParams) -> bool
{
    assert(definition != null);
    if definition.cast_func == null return false;

    return definition.cast_func(params);
}