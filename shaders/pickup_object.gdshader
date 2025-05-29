shader_type canvas_item;
uniform float speed : hint_range(0.1, 5.0) = 2.0;
uniform float brightness : hint_range(1.0, 3.0) = 2.0;
uniform float frequency : hint_range(0.1, 2.0) = 0.5;

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);
    
    // Create pulses with gaps
    float time_cycle = TIME * frequency;
    float pulse = max(0.0, sin(time_cycle * PI * 2.0));
    float highlight = sin(TIME * speed + UV.x * 10.0) * 0.5 + 0.5;
    highlight *= pulse; // Only show when pulse is active
    
    COLOR = tex_color * (1.0 + highlight * brightness * 0.3);
}
