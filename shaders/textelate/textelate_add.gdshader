shader_type canvas_item;
render_mode blend_add;

uniform float pixel_size = 64.0; // dots size | using int is ok
uniform vec4 tint : source_color;
uniform sampler2D characters_tex;
uniform float char_count = 10.0;
uniform float background_color_contribution = 0.25;
uniform float pixelated_color_mix = 0.5;

vec2 get_character_uv(vec2 uv, vec2 ratio, float i){
	uv /= 1.0/(pixel_size/char_count) / ratio;
	uv.x += i * (1.0/char_count);
	uv.x = clamp(uv.x, i * (1.0/char_count), (i+1.0) * (1.0/char_count));
	uv *= char_count;
	return vec2(uv.x/char_count, uv.y);
}
float calculate_brightness(vec4 col){
	return (col.r * 0.3 + col.g * 0.59 + col.b * 0.11) * col.a;
}

void vertex(){
	
}

void fragment() {
	vec2 ratio = vec2(1.0, TEXTURE_PIXEL_SIZE.x / TEXTURE_PIXEL_SIZE.y); // make sure the dots are going to be 1:1
	vec2 pixelated_uv = floor(UV * pixel_size * ratio) / (pixel_size * ratio); // pixelates the UV, first multiply with size so it can be rounded to integer then divide it with the same value so your computer can see it and multiply with ratio to fix stretching
	vec4 pixelated_col = texture(TEXTURE, pixelated_uv);
	vec4 col = mix(texture(TEXTURE, UV), pixelated_col, pixelated_color_mix) * COLOR;	
	float id = floor(calculate_brightness(pixelated_col) * char_count);
	vec2 character_uv = get_character_uv(UV - pixelated_uv, ratio, id);
	vec4 character_col = texture(characters_tex, character_uv);
	character_col.a = calculate_brightness(character_col);
	COLOR = clamp((col *background_color_contribution) + character_col * col, 0.0, 1.0);
	COLOR *= tint;
}