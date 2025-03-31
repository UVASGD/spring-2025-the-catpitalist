shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform sampler2D distortion_noise : repeat_enable;
uniform vec2 direction = vec2(3.0, 2.0);
uniform vec4 water_color : source_color = vec4(0.1, 0.4, 0.6, 0.3);
uniform float distortion_strength : hint_range(0.0, 1.0, 0.001) = 0.2;
uniform float water_opacity : hint_range(0.0, 1.0, 0.05) = 0.3;

void fragment() {
    // Sample noise texture for distortion
    vec2 noise_uv = UV + direction * TIME * 0.05;
    vec4 noise = texture(distortion_noise, noise_uv);

    // Apply distortion to screen texture coordinates
    vec2 distorted_uv = SCREEN_UV + (noise.rg * 2.0 - 1.0) * distortion_strength * 0.1;

    // Sample the screen with the distorted coordinates
    vec4 screen_color = texture(SCREEN_TEXTURE, distorted_uv);

    // Mix with water color
    vec4 final_color = mix(screen_color, water_color, water_opacity);

    COLOR = final_color;
}