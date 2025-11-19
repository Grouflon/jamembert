#version 300 es
precision highp float;

in vec2 fragTexCoord;
in vec4 fragColor;

out vec4 outColor;

uniform sampler2D uTexture;
uniform float uTime;
uniform float uLastHitTime;

const float hitEffectTime = 0.2;

void main()
{

    float t = clamp((uTime - uLastHitTime) / hitEffectTime, 0, 1);
    vec4 spriteColor = fragColor * texture(uTexture, fragTexCoord);
    outColor = mix(vec4(1,1,1,1), spriteColor, t);
    if (spriteColor.w == 0.0)
    {
        discard;
    }
}