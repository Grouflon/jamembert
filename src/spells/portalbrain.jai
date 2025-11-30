// Spell
portalbrain_spell_definition : = SpellDefinition.{
    type = .POSITION,
    icon = .{ "icons_aseprite", "portal_brain" },
    range = 200,
    cast_func = (params: SpellCastParams) -> bool
    {
        create_portal(params.position.origin, *resources.portalbrain_aseprite, portalbrain_spawn_actors);
        return true;
    },
};

#scope_file
portalbrain_spawn_actors :: (using actor: *Actor)
{
    portalpos:= actor.position.xy;
    braincount: = cast(u32) random_get_within_range(4,8);
    for brain : 0..braincount
    {
        pos: Vector2 = .{random_get_within_range(-28,28), random_get_within_range(-28,28)};
        create_actor(*brain_definition, portalpos + pos);
    }
    create_actor(*brain_definition, portalpos);

}