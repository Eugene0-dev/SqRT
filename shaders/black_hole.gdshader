
shader_type canvas_item;
render_mode unshaded, blend_mix;

uniform sampler2D screen_texture : hint_screen_texture,
	repeat_disable, filter_linear;

uniform float hole_radius = 0.065;
uniform float lens_strength = 0.008;

uniform float disk_angle = -0.18;
uniform float disk_flatten = 0.22;
uniform float rotation_speed = 0.12;
uniform float brightness = 1.0;
uniform float time_scale = 1.0;

uniform vec4 disk_inner : source_color = vec4(1.0, 0.24, 0.035, 1.0);
uniform vec4 disk_outer : source_color = vec4(0.9, 0.055, 0.015, 1.0);
uniform vec4 disk_hot : source_color = vec4(1.0, 0.82, 0.48, 1.0);

float hash21(vec2 p) {
	p = fract(p * vec2(123.34, 456.21));
	p += dot(p, p + 45.32);
	return fract(p.x * p.y);
}

float noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);

	float a = hash21(i);
	float b = hash21(i + vec2(1.0, 0.0));
	float c = hash21(i + vec2(0.0, 1.0));
	float d = hash21(i + vec2(1.0, 1.0));

	return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

float fbm(vec2 p) {
	float v = 0.0;
	float a = 0.5;

	for (int i = 0; i < 4; i++) {
		v += noise(p) * a;
		p *= 2.03;
		a *= 0.5;
	}

	return v;
}

void fragment() {
	// Local coordinates: the black hole is always centered.
	vec2 uv = SCREEN_UV;
	float aspect = SCREEN_PIXEL_SIZE.y / SCREEN_PIXEL_SIZE.x;

	vec2 p = (UV - vec2(0.5)) * vec2(aspect, 1.0);
	float r = length(p);

	// Gravitational lensing.
	vec2 radial = p / max(r, 0.0001);

	float lens = lens_strength / max(r, hole_radius * 0.8);
	float lens_mask = 1.0 - smoothstep(
		hole_radius * 3.8,
		hole_radius * 5.0,
		r
	);

	vec2 screen_offset = radial * lens * lens_mask / vec2(aspect, 1.0);
	vec2 warped_uv = clamp(
		uv + screen_offset,
		vec2(0.0),
		vec2(1.0)
	);

	vec3 background = texture(screen_texture, warped_uv).rgb;

	// Rotating accretion disk.
	float t = TIME * rotation_speed * time_scale;
	float a = disk_angle + t;

	mat2 rot = mat2(
		vec2(cos(a), sin(a)),
		vec2(-sin(a), cos(a))
	);

	vec2 disk_p = rot * p;

	float disk_r = length(
		vec2(disk_p.x, disk_p.y / disk_flatten)
	);

	float turbulence = fbm(
		vec2(
			atan(disk_p.y, disk_p.x) * 3.0,
			disk_r * 32.0 - TIME * 0.8
		)
	);

	float inner_edge = hole_radius * 1.45;
	float outer_edge = hole_radius * 4.5;

	float disk_mask =
		smoothstep(inner_edge, inner_edge * 1.25, disk_r) *
		(1.0 - smoothstep(outer_edge * 0.75, outer_edge, disk_r));

	float radial_profile = exp(
		-pow(
			(disk_r - hole_radius * 2.5) /
			(hole_radius * 1.15),
			2.0
		)
	);

	// Doppler brightening.
	float doppler = mix(
		0.35,
		1.6,
		smoothstep(-outer_edge, outer_edge, disk_p.x)
	);

	float energy = radial_profile *
		(0.55 + turbulence * 0.9) *
		disk_mask * doppler;

	vec3 disk_color = mix(
		disk_outer.rgb,
		disk_inner.rgb,
		clamp(turbulence * 1.5, 0.0, 1.0)
	);

	disk_color = mix(
		disk_color,
		disk_hot.rgb,
		pow(clamp(energy, 0.0, 1.0), 2.0)
	);

	float disk_alpha = clamp(
		disk_mask * (0.35 + energy * 0.65),
		0.0,
		1.0
	);

	// Photon ring.
	float photon_r = hole_radius * 1.13;

	float photon = exp(
		-pow(
			(r - photon_r) / (hole_radius * 0.055),
			2.0
		)
	);

	float photon_alpha = clamp(photon * 1.4 * brightness, 0.0, 1.0);
	vec3 photon_color = vec3(1.0, 0.63, 0.28);

	// Event horizon.
	float horizon = 1.0 - smoothstep(
		hole_radius * 0.94,
		hole_radius * 0.99,
		r
	);

	// Gravitational glow.
	float glow = exp(-r / (hole_radius * 3.5));
	float glow_alpha = glow * (1.0 - horizon) * 0.12;

	vec3 glow_color = vec3(0.035, 0.045, 0.11);

	// Alpha compositing.
	float alpha = lens_mask;
	vec3 premul = background * alpha;

	premul = disk_color * disk_alpha +
		premul * (1.0 - disk_alpha);
	alpha = disk_alpha + alpha * (1.0 - disk_alpha);

	premul = photon_color * photon_alpha +
		premul * (1.0 - photon_alpha);
	alpha = photon_alpha + alpha * (1.0 - photon_alpha);

	premul = glow_color * glow_alpha +
		premul * (1.0 - glow_alpha);
	alpha = glow_alpha + alpha * (1.0 - glow_alpha);

	premul *= 1.0 - horizon;
	alpha = horizon + alpha * (1.0 - horizon);

	vec3 final_color = premul / max(alpha, 0.00001);

	COLOR = vec4(final_color, alpha);
}
