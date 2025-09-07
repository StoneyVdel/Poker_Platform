shader_type canvas_item;

uniform sampler2D colorTexture;
uniform sampler2D noise : repeat_enable;
uniform sampler2D noise2 : repeat_enable;
uniform vec2 scroll = vec2(-0.2, -0.2);
uniform vec2 scroll2 = vec2(1, 1);

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	float noise_col = texture(TEXTURE, UV + scroll * tan(TIME/(2.0))).r;
	float noise_col2 = texture(noise2, UV + scroll2 * tan(TIME/(2.0))).r;
	float noise_cross = noise_col * noise_col2;
	vec4 color = texture(colorTexture, vec2(noise_cross));
	COLOR = color;

}
//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
