shader_type canvas_item;

uniform float time;
uniform float sparkle_intensity = 1.0;
uniform float sparkle_density = 0.01;
uniform float twinkle_intensity = 0.1;
uniform float hue_shift_speed = 0.1;
uniform float hue_shift_strength = 0.2; // 0 = no hue shift, 1 = full hue shift

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);

    // --- Twinkle ---
    float noise = fract(sin(dot(UV * 100.0, vec2(12.9898, 78.233))) * 43758.5453);
    float twinkle = sin(time * 2.0 + noise * 20.0) * twinkle_intensity;
    tex_color.rgb += twinkle;

    // --- Hue Shift (subtle tint style) ---
    float angle = time * hue_shift_speed;
    mat3 hue_shift = mat3(
        vec3(0.299 + 0.701 * cos(angle) + 0.168 * sin(angle),
             0.587 - 0.587 * cos(angle) + 0.330 * sin(angle),
             0.114 - 0.114 * cos(angle) - 0.497 * sin(angle)),
        vec3(0.299 - 0.299 * cos(angle) - 0.328 * sin(angle),
             0.587 + 0.413 * cos(angle) + 0.035 * sin(angle),
             0.114 - 0.114 * cos(angle) + 0.292 * sin(angle)),
        vec3(0.299 - 0.3 * cos(angle) + 1.25 * sin(angle),
             0.587 - 0.588 * cos(angle) - 1.05 * sin(angle),
             0.114 + 0.886 * cos(angle) - 0.203 * sin(angle))
    );
    vec3 hue_color = clamp(hue_shift * tex_color.rgb, 0.0, 1.0);
    tex_color.rgb = mix(tex_color.rgb, hue_color, hue_shift_strength);

    
    COLOR = tex_color;
}