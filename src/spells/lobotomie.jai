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

        //remove sentience
        actor_set_sentient(target, false);

        //spawn brain
        brainpos: Vector2 = .{random_get_within_range(-10,10),random_get_within_range(-10,10)};
        brain: = create_actor(*brain_definition, target.position.xy + brainpos);
        braindata: = brain.data.(*BrainData);
        braindata.previously_possessed_actor = target;

        //set the control to the brain if the target was controlled
        //I don't know how the mindstate work so maybe we should change that
        if target.controlling_player
        {
            set_controlled_actor(target.controlling_player,brain);
        }


        return true;
    },
};
