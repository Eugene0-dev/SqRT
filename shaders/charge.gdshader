shader_type canvas_item;

uniform float charge : hint_range(0.0, 1.0) = 0.0;
uniform vec4 glow_color : source_color = vec4(0.0, 0.9, 1.0, 1.0);
uniform vec2 glow_origin = vec2(0.5, 0.5);

void fragment() {
    float dist = distance(UV, glow_origin);

    float radius = mix(0.02, 0.8, charge);
    float glow = 1.0 - smoothstep(0.0, radius, dist);

    glow *= charge;

    COLOR = vec4(glow_color.rgb * glow * 3.0, glow);
}