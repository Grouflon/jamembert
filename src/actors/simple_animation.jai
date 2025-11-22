simple_animation_definition : = ActorDefinition.{
    update = simple_animation_update,
    render_layer = .OBJECTS,
};

simple_animation_update :: (using actor: *Actor, dt: float)
{
    if !animation.is_playing
    {
        request_delete_actor(actor);
    }
}

create_simple_animation_actor :: (position: Vector2, animation: AsepriteAnimationHandle, layer: RenderLayer = .OBJECTS)
{
    actor: = create_actor(*simple_animation_definition, position);
    actor.definition.render_layer = layer;
    animation_player_play(*actor.animation, animation, false);
}