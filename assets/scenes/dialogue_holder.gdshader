shader_type canvas_item;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec2 uv = FRAGCOORD.xy / SCREEN_PIXEL_SIZE;
    vec4 sum = vec4(0.0);
    vec2 tex_size = vec2(textureSize(SCREEN_TEXTURE, 0));
    vec2 one_pixel = vec2(1.0) / tex_size;

    for (int x = -1; x <= 1; x++) {
        for (int y = -1; y <= 1; y++) {
            vec2 offset = vec2(float(x), float(y)) * one_pixel;
            sum += texture(SCREEN_TEXTURE, uv + offset);
        }
    }

    COLOR = sum / 22.0;
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
