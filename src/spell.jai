#load "spells/bouledefeu.jai";
#load "spells/lobotomie.jai";
#load "spells/sentification.jai";

spellbook: []*SpellDefinition = .[
    *bouledefeu_spell_definition,
    *sentification_spell_definition,
    *lobotomie_spell_definition,
];

// ---
SpellCastType :: enum
{
    PROJECTILE;
    TARGET;
}

SpellDefinition :: struct
{
    type: SpellCastType;
    icon: AsepriteAnimation;
    range: float;
    cast_func: #type (params: SpellCastParams);
}

SpellCaster :: struct
{
    definition: *SpellDefinition;
    source: *Actor;
    current_cast: SpellCastParams;
}

SpellCastParams :: struct
{
    source: *Actor;
    union {
        projectile: struct {
            direction: Vector2;
        };
        target: struct {
            target: *Actor;
        };
    }
}

spellcaster_update :: (using spellcaster: *SpellCaster, dt: float, target: Vector2)
{
    if definition == null return;
    if source == null return;

    current_cast.source = source;
    if definition.type ==
    {
        case .PROJECTILE;
        {
            current_cast.projectile.direction = normalize(target - source.position.xy);
        }

        case .TARGET;
        {
            
        }
    } 
}

spellcaster_draw :: (using spellcaster: *SpellCaster)
{
    if definition == null return;
    if source == null return;
    {
        if definition.type ==
        {
            case .PROJECTILE;
            {
                direction: = Vector3.{current_cast.projectile.direction.x, current_cast.projectile.direction.y, 0};
                draw_line(source.position + direction * 7, source.position + direction * 20, 3, .{255,255,255,100});
            }
        } 
    }
}

spellcaster_cast :: (using spellcaster: *SpellCaster)
{
    if definition == null return;
    if definition.cast_func == null return;

    definition.cast_func(current_cast);
}
