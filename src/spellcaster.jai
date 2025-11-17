SpellCastType :: enum
{
    PROJECTILE;
    TARGET;
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

    current_cast = .{};
    current_cast.source = source;
    if definition.type ==
    {
        case .PROJECTILE;
        {
            current_cast.projectile.direction = normalize(target - source.position.xy);
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
    {
        if definition.type ==
        {
            case .PROJECTILE;
            {
                direction: = Vector3.{current_cast.projectile.direction.x, current_cast.projectile.direction.y, 0};
                draw_line(source.position + direction * 7, source.position + direction * 20, 3, .{255,255,255,100});
            }

            case .TARGET;
            {
                target: = current_cast.target.target;
                if target == null return;

                begin_render_texture(rt_ground);
                defer end_render_texture();
                draw_rectangle(target.position, .{.{-4,-4},.{4,4}}, .{255,255,255,150});
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
