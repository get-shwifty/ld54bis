shader_type canvas_item;
//render_mode blend_mix;

varying vec2 world_position;

const int ELASTIC_MAX_POINTS = 30;
uniform vec2 elastic_points[ELASTIC_MAX_POINTS];
uniform int elastic_current_points_number;
uniform float current_elastic_tension = 1.0;
uniform float current_elastic_tension_boost = 0.0;

uniform float common_max_elastic_thickness = 20;
uniform float common_min_elastic_thickness = 1;
uniform float common_elastic_sdf_offset = 12.0;

uniform bool enable_chromatic_distortion = false;

uniform float waistline = 0.5;

void vertex(){
    world_position = (MODEL_MATRIX * vec4(VERTEX,0.0,1.0)).xy;
}

//The following two functions are adapted from Inigo Quilez work that can be found here https://iquilezles.org/articles/distfunctions/
float sdPolygon( in vec2[ELASTIC_MAX_POINTS] v, in int current_max_points, in vec2 p )
{
	int array_size = min(current_max_points,ELASTIC_MAX_POINTS);
	
    float d = dot(p-v[0],p-v[0]);
    float s = 1.0;
    for( int i=0, j=array_size-1; i<array_size; j=i, i++ )
    {
        vec2 e = v[j] - v[i];
        vec2 w =    p - v[i];
        vec2 b = w - e*clamp( dot(w,e)/dot(e,e), 0.0, 1.0 );
        d = min( d, dot(b,b) );
        bvec3 c = bvec3(p.y>=v[i].y,p.y<v[j].y,e.x*w.y>e.y*w.x);
        if( all(c) || all(not(c)) ) s*=-1.0;  
    }
    return s*sqrt(d);
}

float opRound(in float d, in float r)
{
  return d - r;
}

vec4 chromatic_distortion (sampler2D txture, vec2 uv)
{
	vec4 final_color;
	vec4 texture_color = texture(txture, uv);
	float distortion_power = 1.0-uv.y;
	
	float distortion_offset = 0.05 * distortion_power * sin(TIME*25.0) * cos(TIME*2.0)*2.0;
	
	vec4 right_texture = texture(txture, uv-vec2(distortion_offset,(sin(TIME*35.0)+1.0)*0.01));
	vec4 left_texture = texture(txture, uv+vec2(distortion_offset,(sin(TIME*35.0)+1.0)*0.01));
	final_color.r = right_texture.r;
	final_color.g = final_color.g;
	final_color.b = left_texture.b;
	
	final_color.a = max(texture_color.a, max(right_texture.a, left_texture.a));
	
	return final_color;
}

float get_current_elastic_thickness()
{
	float tension = clamp(current_elastic_tension, 0.0, 1.0);
	return mix(common_max_elastic_thickness, common_min_elastic_thickness, tension);
}

void fragment() {
	float elastic_distance = opRound(sdPolygon(elastic_points, elastic_current_points_number, world_position), common_elastic_sdf_offset);

	vec3 base_elastic_color = vec3(1.0);
	
	vec4 final_color = COLOR.rgba;
	
	if (elastic_distance > 0.0 && enable_chromatic_distortion)
	{
		final_color = chromatic_distortion(TEXTURE,UV);
	}
	
	if (UV.y > waistline)
	{
		if (elastic_distance > 0.0 && elastic_distance < get_current_elastic_thickness())
		{
			final_color.rgb = base_elastic_color;
		}
	}
	
    COLOR = final_color;
}

   
