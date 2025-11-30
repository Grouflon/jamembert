// Spell
lobotomie_spell_definition : = SpellDefinition.{
    type = .TARGET,
    icon = .{ "icons_aseprite", "lobotomie" },
    range = 200,
    cast_func = (params: SpellCastParams) -> bool
    {
        target: = params.target.target;
        if target == null return false;
        if !actor_is_sentient(target) return false;

        //spawn effect
        pos: = params.target.target.position.xy + params.target.target.definition.face_position + .{0,5};
        effect: = create_simple_animation_actor(pos, .{*resources.lobotomie_aseprite, string_hash("idle")} , .OVERLAY);

        //spawn brain
        brainpos: Vector2 = .{random_get_within_range(-10,10),random_get_within_range(-10,10)};
        brain: = create_actor(*brain_definition, target.position.xy + brainpos);
        braindata: = brain.data.(*BrainData);
        braindata.previously_possessed_actor = target.id;

        //swap minds
        swap_mind_states(target, brain);
        actor_set_sentient(target, false); // brains are sentient by default, but we don't want their base mind to linger in the target

        return true;
    },
};
