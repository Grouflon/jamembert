// Spell
sentification_spell_definition : = SpellDefinition.{
    type = .TARGET,
    icon = .{ "icons_aseprite", "sentification" },
    range = 200,
    cast_func = (params: SpellCastParams)
    {
        target: = params.target.target;
        if target == null return;

        if !actor_is_sentient(target)
        {
            pos: = params.target.target.position.xy + .{0,10};
            effect: = create_simple_animation_actor(pos, .{*resources.sentification_aseprite, string_hash("idle")} , .OVERLAY);
        }

        actor_set_sentient(target, true);

    },
};
