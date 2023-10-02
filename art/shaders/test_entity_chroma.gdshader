shader_type canvas_item;


void fragment() {
	vec4 texture_color = texture(TEXTURE, UV);
	float distortion_power = 1.0-UV.y;
	
	float distortion_offset = 0.05 * distortion_power * sin(TIME*25.0) * cos(TIME*2.0)*2.0;
	
	vec4 right_texture = texture(TEXTURE, UV-vec2(distortion_offset,(sin(TIME*35.0)+1.0)*0.01));
	vec4 left_texture = texture(TEXTURE, UV+vec2(distortion_offset,(sin(TIME*35.0)+1.0)*0.01));
	COLOR.r = right_texture.r;
	COLOR.b = left_texture.b;
	
	COLOR.a = max(texture_color.a, max(right_texture.a, left_texture.a));
}

