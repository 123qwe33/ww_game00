shader_type canvas_item;

uniform float time_scale = 1.0;
uniform float distortion_strength = 0.01;
uniform float wave_freq = 30.0;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform vec4 tint = vec4(0.2, 0.4, 0.8, 0.4);

// void fragment() {
//     vec2 uv = UV;

//     // Apply wave distortion
//     vec2 wave = vec2(
//         sin(uv.y * wave_freq + TIME * time_scale),
//         cos(uv.x * wave_freq + TIME * time_scale)
//     ) * distortion_strength;

//     // Apply distortion to screen UV
//     vec4 screen_tex = textureLod(SCREEN_TEXTURE, SCREEN_UV + wave, 0.0);

//     COLOR = mix(screen_tex, tint, 0.3);
// }
