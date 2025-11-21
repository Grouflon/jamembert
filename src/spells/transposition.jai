// Spell
transposition_spell_definition : = SpellDefinition.{
    type = .TARGET,
    icon = .{ "icons_aseprite", "transposition" },
    range = 200,
    cast_func = (params: SpellCastParams) -> bool
    {
        target: = params.target.target;
        if target == null return false;


        pos_target: = params.target.target.position;
        pos_caster: = params.source.position;

        effect1: = create_simple_animation_actor(pos_target.xy, .{*resources.transposition_aseprite, string_hash("idle")} , .OVERLAY);
        effect2: = create_simple_animation_actor(pos_caster.xy, .{*resources.transposition_aseprite, string_hash("idle")} , .OVERLAY);

        params.source.position = pos_target;
        params.target.target.position = pos_caster;
        return true;
    },
};
