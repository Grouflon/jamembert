// Spell
sentification_spell_definition : = SpellDefinition.{
    type = .TARGET,
    icon = .{ "icons_aseprite", "sentification" },
    range = 200,
    cast_func = (params: SpellCastParams) -> bool
    {
        target: = params.target.target;
        if target == null return false;
        if actor_is_sentient(target) return false;

        pos: = actor_get_icon_position(params.target.target);
        effect: = create_simple_animation_actor(pos, .{*resources.sentification_aseprite, string_hash("idle")} , .OVERLAY);

        actor_set_sentient(target, true);
        return true;
    },
};
