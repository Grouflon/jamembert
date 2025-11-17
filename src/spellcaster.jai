SpellCastType :: enum
{
    PROJECTILE;
    TARGET;
}

SpellCaster :: struct
{
    definition: *SpellDefinition;
    source: *Actor;
    cast_offset: Vector2;
    current_cast: SpellCastParams;
}

SpellCastParams :: struct
{
    source: *Actor;
    union {
        projectile: struct {
            origin: Vector2;
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

    current_cast = .{};
    current_cast.source = source;
    if definition.type ==
    {
        case .PROJECTILE;
        {
            current_cast.projectile.origin = source.position.xy + cast_offset;
            current_cast.projectile.direction = normalize(target - current_cast.projectile.origin);
        }

        case .TARGET;
        {
            targets: = physics_cast(target, .{ type = .CIRCLE, circle = .{ .{}, 10 } }, .[PHYSIC_LAYER_BODY]);
            if targets.count != 0
            {
                current_cast.target.target = targets[0].parent.(*Actor);
            }
        }
    } 
}

spellcaster_draw :: (using spellcaster: *SpellCaster)
{
    if definition == null return;
    if source == null return;

    cast_position: = source.position.xy + cast_offset;
    {
        if definition.type ==
        {
            case .PROJECTILE;
            {
                origin: = xyz(current_cast.projectile.origin, 0);
                direction: = xyz(current_cast.projectile.direction, 0);
                draw_line(origin + direction * 7, origin + direction * 20, 3, .{255,255,255,100});
            }

            case .TARGET;
            {
                target: = current_cast.target.target;
                if target == null return;

                begin_render_texture(render_layers[RENDER_LAYER_GROUND]);
                defer end_render_texture();
                draw_rectangle(target.position, .{.{-5,-2},.{5,2}}, .{255,255,255,150});
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
