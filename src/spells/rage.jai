// Spell
rage_spell_definition : = SpellDefinition.{
    type = .TARGET,
    icon = .{ "icons_aseprite", "rage" },
    cast_func = (params: SpellCastParams) -> bool
    {
        target: = params.target.target;
        if target == null return false;
        if !actor_is_sentient(target) return false;

        //pos: = params.target.target.position.xy + params.target.target.definition.face_position + .{0,5};
        //effect: = create_simple_animation_actor(pos, .{*resources.lobotomie_aseprite, string_hash("idle")} , .OVERLAY);

        target.ai.is_agressive = true;
        return true;
    },
};
