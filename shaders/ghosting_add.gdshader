
shader_type canvas_item;

uniform sampler2D previous_frame;
uniform sampler2D current_frame;
uniform float decay : hint_range(0.0, 1.0) = 0.92;

void fragment() {
	vec4 previous = texture(previous_frame, UV);
	vec4 current = texture(current_frame, UV);

	previous *= decay;

	COLOR = current + previous * (1.0 - current.a);
}
