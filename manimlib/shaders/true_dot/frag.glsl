#version 330

uniform float anti_alias_width;
uniform float glow_factor;

in vec4 color;
in float radius;
in vec2 center;
in vec2 point;
in float scaled_aaw;

out vec4 frag_color;

#INSERT finalize_color.glsl

void main() {
    vec2 diff = point - center;
    float dist = length(diff);
    float signed_dist = dist - radius;
    if (signed_dist > 0.5 * scaled_aaw){
        discard;
    }
    frag_color = color;
    if(gloss > 0 || shadow > 0){
        vec3 normal = vec3(diff / radius, sqrt(1 - (dist * dist) / (radius * radius)));
        frag_color = finalize_color(
            frag_color,
            vec3(point.xy, 0.0),
            normal,
            light_source_position,
            camera_position,
            reflectiveness,
            gloss,
            shadow
        );
    }
    if(glow_factor > 0){
        frag_color.a *= pow(1 - dist / radius, glow_factor);
    }

    frag_color.a *= smoothstep(0.5, -0.5, signed_dist / scaled_aaw);
}