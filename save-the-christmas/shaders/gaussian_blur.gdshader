shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
uniform float blur_amount : hint_range(0.0, 5.0) = 2.5;

void fragment() {
	vec2 uv = SCREEN_UV;
	vec4 color = vec4(0.0);

	// 9-tap box blur for performance
	float offset = blur_amount / 1000.0;
	for (float x = -1.0; x <= 1.0; x += 1.0) {
		for (float y = -1.0; y <= 1.0; y += 1.0) {
			color += texture(screen_texture, uv + vec2(x, y) * offset);
		}
	}

	COLOR = color / 9.0;
	COLOR.a = 0.95;  // Slight transparency
}
