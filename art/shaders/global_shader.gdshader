shader_type canvas_item;
render_mode blend_mix;

varying vec2 world_position;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

uniform sampler2D gradient_inside;
uniform sampler2D gradient_outside;

const float MAX_CORE_DISTANCE = 600.0;
uniform vec2 core_position = vec2(400.0);

const int ELASTIC_MAX_POINTS = 30;
uniform vec2 elastic_points[ELASTIC_MAX_POINTS];
uniform int elastic_current_points_number;
uniform float elastic_thickness = 10;

uniform float common_elastic_sdf_offset = 45.0;

void vertex(){
    world_position = (MODEL_MATRIX * vec4(VERTEX,0.0,1.0)).xy;
}

float steper(float val, int step_nb)
{
	return floor(val*float(step_nb)) / float(step_nb);
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




float get_distance_from_position(vec2 position)
{
	return opRound(sdPolygon(elastic_points, elastic_current_points_number, world_position), common_elastic_sdf_offset);
}

vec3 get_base_color_from_distance(float d)
{
	float distance_to_core = distance(world_position,core_position);
	float core_distance_ratio = distance_to_core/MAX_CORE_DISTANCE;
	float gradient_sample_ratio = steper(mix(1.0, 0.5, core_distance_ratio), 20);
	
	vec3 base_inside_color = texture(gradient_inside, vec2(0.50)).rgb;
	vec3 base_outside_color = texture(gradient_outside, vec2(0.25)).rgb;
	vec3 base_elastic_color = vec3(1.0);
	
	vec3 col = base_elastic_color;
	if (d < - elastic_thickness)
	{
		col = texture(gradient_inside, vec2(gradient_sample_ratio)).rgb;
	}
	else if (d > elastic_thickness)
	{
		col = texture(gradient_outside, vec2(0.25)).rgb;
	}
	return col;
}

vec3 get_base_color_from_position(vec2 position)
{
	return get_base_color_from_distance(get_distance_from_position(position));
}

//code inspired by https://gist.github.com/uheartbeast/312a7ea761b8712c448b31c30c0d8f1f
vec3 chroma_distortion(float distance_to_elastic, float distort_potency)
{
	float distortion_ratio = 1.0;
	float adjusted_amount = distortion_ratio * distort_potency * sin(TIME * 5.0)* 2.0 * sin(TIME * sin(TIME * 4.0) * 15.0);
	vec3 color = vec3(1.0);
	
	color.r = get_base_color_from_distance(distance_to_elastic - adjusted_amount).r;
	color.g = get_base_color_from_distance(distance_to_elastic).g;
	color.b = get_base_color_from_distance(distance_to_elastic + adjusted_amount).b;

	return color;
}


void fragment() {
    vec3 c = textureLod(screen_texture, SCREEN_UV, 0.0).rgb;
	
	float distance_elastic = get_distance_from_position(world_position);
	vec3 col = chroma_distortion(distance_elastic, 5.0);
	
    COLOR.rgb = mix(col, c, 0.1);
}

   
