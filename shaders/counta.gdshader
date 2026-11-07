
shader_type canvas_item;

uniform float aberration = 1.0;
uniform float ghost_offset = 2.0;
uniform float ghost_alpha = 0.2;
uniform float flicker = 0.08;

void fragment() {
	vec2 px = TEXTURE_PIXEL_SIZE;

	vec4 base = texture(TEXTURE, UV);

	float r = texture(
		TEXTURE, UV + vec2(px.x * aberration, 0.0)
	).r;

	float b = texture(
		TEXTURE, UV - vec2(px.x * aberration, 0.0)
	).b;

	float ghost = texture(
		TEXTURE, UV - vec2(px.x * ghost_offset, 0.0)
	).a;

	float alpha = max(base.a, ghost * ghost_alpha);

	float pulse = 1.0 - flicker * (
		0.5 + 0.5 * sin(TIME * 3.0)
	);

	COLOR = vec4(r, base.g, b, alpha * pulse) * COLOR;
}
