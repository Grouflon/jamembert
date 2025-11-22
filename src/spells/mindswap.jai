// Spell
mindswap_spell_definition : = SpellDefinition.{
    type = .TARGET,
    icon = .{ "icons_aseprite", "mindswap" },
    range = 200,
    cast_func = (params: SpellCastParams) -> bool
    {
        target: = params.target.target;
        if target == null return false;

        effect: = create_actor(*mindswap_definition, params.source.position.xy);
        effect.data.(*MindswapData).caster = params.source.id;
        effect.data.(*MindswapData).target = target;

        movement_component_go_to(*effect.movement, target.position.xy);

        if !actor_is_sentient(target) actor_set_sentient(target,true);

        if (target.definition.speed < 30) target.definition.speed = 30;

        if target.ai.is_agressive
        {
            target.ai.target = null;
            target.ai.is_agressive = false;
        }

        set_controlled_actor(target);

        return true;
    },
};

mindswap_definition : = ActorDefinition.{
    init = mindswap_init,
    update = mindswap_update,

    render_layer = .OVERLAY,
    sprite_origin = .{8,8},
    speed = 200,
    idle_animation = .{ "lobotomie_aseprite", "idle" },
};

MindswapData :: struct
{
    caster: ID(Actor);
    target: Actor;
}

mindswap_init :: (using actor: *Actor)
{
    position.z = 1;
    mindswap: = New(MindswapData);
    data = mindswap;
}

mindswap_update :: (using actor: *Actor, dt: float)
{
    mindswap: = data.(*MindswapData);
    
    if !movement.is_moving_to
    {
        //this doesn't work if I put it here

        /*log("mindswap");
        if !actor_is_sentient(*mindswap.target) actor_set_sentient(*mindswap.target,true);

        if (mindswap.target.definition.speed < 30) mindswap.target.definition.speed = 30;

        if mindswap.target.ai.is_agressive
        {
            mindswap.target.ai.target = null;
            mindswap.target.ai.is_agressive = false;
        }

        set_controlled_actor(*mindswap.target);*/

        request_delete_actor(actor);
        return;
    }
}