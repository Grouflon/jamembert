SpellCastType :: enum
{
    PROJECTILE;
    TARGET;
    POSITION;
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
            origin: Vector2;
            direction: Vector2;
        };
        target: struct {
            target: *Actor;
        };
        position: struct {
            origin: Vector2;
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
            current_cast.projectile.origin = source.position.xy + source.definition.cast_position;
            current_cast.projectile.direction = normalize(target - current_cast.projectile.origin);
        }

        case .TARGET;
        {
            targets: = physics_cast(target, .{ type = .CIRCLE, circle = .{ .{}, 10 } }, .[PHYSIC_LAYER_BODY]);
            closest_squared_distance: float = FLOAT32_MAX;
            for collider: targets
            {
                squared_distance: = distance_squared(target, collider.parent.position.xy);
                if squared_distance < closest_squared_distance
                {
                    closest_squared_distance = squared_distance;
                    current_cast.target.target = collider.parent.(*Actor);
                }
            }
        }
        case .POSITION;
        {
            current_cast.position.origin = target;
        }
    } 
}

spellcaster_draw :: (using spellcaster: *SpellCaster)
{
    if definition == null return;
    if source == null return;

    cast_position: = source.position.xy + source.definition.cast_position;
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

                begin_render_texture(render_layers[RenderLayer.GROUND]);
                defer end_render_texture();
                draw_rectangle(target.position, .{.{-5,-2},.{5,2}}, .{255,255,255,150});
            }
            case .POSITION;
            {
                pos: = make_vector3(screen_to_world(get_mouse_position()), 0);
                draw_rectangle(pos, .{.{-5,-5},.{5,5}}, .{255,255,255,150});
            }
        } 
    }
}

spellcaster_cast :: (using spellcaster: *SpellCaster) -> bool
{
    if definition == null return false;
    return spell_cast(definition, current_cast);
}
