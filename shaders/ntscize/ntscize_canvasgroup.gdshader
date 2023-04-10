shader_type canvas_item;
render_mode unshaded,blend_mix;
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

uniform float scale = 1.0;

uniform float flashtime = 20;
uniform float flashpower = 0.25;
uniform float flashlines = 0.25;
uniform vec2 flashchange = vec2(0.3, 0.05);
uniform float flashlinescount = 20.0;

uniform float aberrationAmount;
uniform vec2 aberrationDistancePower;
uniform vec3 color_mult = vec3(1.0);

uniform float SAT = 1.0;      //  Saturation / "Color" (normally 1.0)
uniform float HUE = 0.0;      //  Hue / "Tint" (normally 0.0)
uniform float BRI = 1.0;      //  Brightness (normally 1.0)

uniform int   filter_width   = 15;       //  Filter Width

const float FC  = 0.25;     //  Frequency Cutoff
const float SCF = 0.25;     //  Subcarrier Frequency

const mat3 YIQ2RGB = mat3(vec3(1.000, 1.000, 1.000),
                          vec3(0.956,-0.272,-1.106),
                          vec3(0.621,-0.647, 1.703));
						
vec3 adjust(vec3 YIQ, float H, float S, float B) {
	mat3 mat = mat3(vec3(B,      0.0,      0.0),
                  vec3(0.0, S*cos(H),  -sin(H)), 
                  vec3(0.0,   sin(H), S*cos(H)));
    return mat * YIQ;
}
//	Hann windowing function
float hann(float n, float n2) {
    return 0.5 * (1.0 - cos((TAU*n)/(n2-1.0)));
}
//	Sinc function
float sinc(float x) {
    if (x == 0.0) return 1.0;
	return sin(PI*x) / (PI*x);
}

vec3 ntsc(vec2 uv, vec2 tex_size, sampler2D maintex){
	//  Compute sampling weights
	int N = clamp(filter_width, 0, 50);
	int M = N/2;
	
    float weights[50];
    float sum = 0.0;
    for (int n=0; n<N; n++) {
        weights[n] = hann(float(n), float(N)) * sinc(FC * float(n-M));
        sum += weights[n];
    }
    
    //  Normalize sampling weights
    for (int n=0; n<N; n++) {
        weights[n] /= sum;
    }
    
    //  Sample composite signal and decode to YIQ
    vec3 YIQ = vec3(0.0);
    for (int n=0; n<N; n++) {
        vec2 pos = uv + vec2(float(n-M) / float(tex_size.x), 0.0);
        float phase = TAU * (SCF * float(tex_size.x) * pos.x);
        YIQ += vec3(1.0, cos(phase), sin(phase)) * texture(maintex, pos).rgb * weights[n];
    }
    
    //  Apply TV adjustments to YIQ signal and convert to RGB
    vec3 color = vec3(YIQ2RGB * adjust(YIQ, HUE, SAT, BRI));
	
	return color;
}

void fragment() {
	vec2 tex_size = vec2(textureSize(screen_texture, 0));
	//vec2 pixel_size = vec2(1.0)/vec2(tex_size);
	vec2 uv = SCREEN_UV;
	
	//Chromatic Aberration
	vec2 distFromCenter = uv - 0.5;
	vec2 aberration = aberrationAmount * pow(abs(distFromCenter), aberrationDistancePower);
	
	vec3 color = vec3(
		ntsc(uv - aberration, tex_size, screen_texture).r,
    	ntsc(uv, tex_size, screen_texture).g,
    	ntsc(uv + aberration, tex_size, screen_texture).b
	);
	vec4 tex = textureLod(screen_texture, SCREEN_UV, 0.0);
	if (tex.a > 0.0001) tex.rgb /= tex.a;
	vec3 col = color * tex.rgb;
	float flash = mod(TIME*flashtime, 1.0) * (flashpower);
	col = col * mix(flashchange.x, flashchange.y, mod(flash+(SCREEN_UV.y*flashlinescount), flashlines));
	col = (col*(vec3(1.0)+col*flash*1.0));
	
	float lum = (col.r * 0.299) + (col.g * 0.587) + (col.b * 0.114);
	col *= lum;
	col *= color_mult;
	
	col = mix(tex.rgb, col, scale);
	
	COLOR = vec4(col, tex.a);
}