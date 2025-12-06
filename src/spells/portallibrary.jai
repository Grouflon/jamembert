// Spell
portallibrary_spell_definition : = SpellDefinition.{
    type = .POSITION,
    icon = .{ "icons_aseprite", "portal_library" },
    cast_func = (params: SpellCastParams) -> bool
    {
        create_portal(params.position.origin, *resources.portallibrary_aseprite, portallibrary_spawn_actors);
        return true;
    },
};

#scope_file
portallibrary_spawn_actors :: (using actor: *Actor)
{
    portalpos:= actor.position.xy;

    //bookshelves
    create_actor(*bookshelf_definition, portalpos + .{-13, 8});
    create_actor(*chest_definition, portalpos + .{-13+18, 8});
    create_actor(*chest_definition, portalpos + .{-13+31, 8});
    //create_actor(*bookshelf_definition, portalpos + .{-13+22+2, 8});

    //books
    create_actor(*book_definition, portalpos + .{3, -15});
    create_actor(*book_definition, portalpos + .{-16, -5});
    create_actor(*book_definition, portalpos + .{8, 1});
}