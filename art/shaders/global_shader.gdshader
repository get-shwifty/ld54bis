shader_type canvas_item;
render_mode blend_mix;

varying vec2 world_position;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

uniform sampler2D gradient_inside;
uniform sampler2D gradient_outside;

const int ELASTIC_MAX_POINTS = 30;
uniform vec2 elastic_points[ELASTIC_MAX_POINTS];
uniform int elastic_current_points_number;
uniform float elastic_thickness = 10;

uniform float common_elastic_sdf_offset = 45.0;

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

////code adapted from https://gist.github.com/uheartbeast/312a7ea761b8712c448b31c30c0d8f1f
//float chroma_distortion(vec3 color)
//{
//	float adjusted_amount = amount * texture(offset_texture, UV).r / 100.0;
//	color.r = texture(TEXTURE, vec2(UV.x + adjusted_amount, UV.y)).r;
//	color.g = texture(TEXTURE, UV).g;
//	color.b = texture(TEXTURE, vec2(UV.x - adjusted_amount, UV.y)).b;
//}

void fragment() {
    vec3 c = textureLod(screen_texture, SCREEN_UV, 0.0).rgb;
	
	vec3 base_inside_color = texture(gradient_inside, vec2(0.50)).rgb;
	vec3 base_outside_color = texture(gradient_outside, vec2(0.25)).rgb;
	
	float d = opRound(sdPolygon(elastic_points, elastic_current_points_number, world_position), common_elastic_sdf_offset);
	
	vec3 col = vec3(1.0);
	if (d < - elastic_thickness)
	{
		col = base_inside_color;
	}
	else if (d > elastic_thickness)
	{
		col = base_outside_color;
	}
	
    COLOR.rgb = mix(col, c, 0.1);
}

   
