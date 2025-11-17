SpellDefinition :: struct
{
    type: SpellCastType;
    icon: AsepriteAnimation;
    range: float;
    cast_func: #type (params: SpellCastParams);
}
