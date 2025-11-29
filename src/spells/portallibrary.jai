// Spell
portallibrary_spell_definition : = SpellDefinition.{
    type = .POSITION,
    icon = .{ "icons_aseprite", "portal_library" },
    range = 200,
    cast_func = (params: SpellCastParams) -> bool
    {
        portalactor: = create_actor(*portal_definition, params.position.origin);
        portaldata: = portalactor.data.(*PortalData);

        portaldata.caster = params.source.id;
        portaldata.animation = resources.portallibrary_aseprite;
        portaldata.actors_to_spawn = portallibrary_spawn_actors;
        return true;
    },
};

#scope_file
portallibrary_spawn_actors :: (using actor: *Actor)
{
    portalpos:= actor.position.xy;

    //bookshelves
    create_actor(*bookshelf_definition, portalpos + .{-13, 8});
    create_actor(*bookshelf_definition, portalpos + .{-13+22+2, 8});

    //books
    create_actor(*book_definition, portalpos + .{3, -15});
    create_actor(*book_definition, portalpos + .{-16, -5});
    create_actor(*book_definition, portalpos + .{8, 1});
}