shader_type canvas_item;

uniform float speed = 5.0; // How fast the colors strobe
uniform float brightness = 1.0; // How bright the colors are
uniform float alpha = 0.5;
void fragment() {
    // Create a flashing effect based on TIME
    float t = TIME * speed;

    // Generate 3 different color channels using sin functions
    float r = sin(t * 2.0) * 0.5 + 0.5;
    float g = sin(t * 1.3 + 1.0) * 0.5 + 0.5;
    float b = sin(t * 1.7 + 2.0) * 0.5 + 0.5;

    // Output the color
    COLOR = vec4(r, g, b, alpha) * brightness;
}