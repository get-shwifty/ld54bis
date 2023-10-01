shader_type canvas_item;
render_mode blend_mix;

varying vec2 world_position;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

uniform sampler2D gradient_inside;
uniform sampler2D gradient_outside;

const int ELASTIC_MAX_POINTS = 10;

void vertex(){
    world_position = (MODEL_MATRIX * vec4(VERTEX,0.0,1.0)).xy;
}

//This functions is adapted from Inigo Quilez work that can be found here https://iquilezles.org/articles/distfunctions/
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


void fragment() {
    vec3 c = textureLod(screen_texture, SCREEN_UV, 0.0).rgb;
	
	vec2 pA = vec2(-0.8,  0.7);
    vec2 pB = vec2( 4.0, 4.0);
    vec2 pC = vec2( 1.0, -0.4);
    vec2 pD = vec2( 0.0, -1.2);
    vec2 pE = vec2(-1.0, -0.6);
	
	vec2 edges[ELASTIC_MAX_POINTS];
	edges[0] = pA;
	edges[1] = pB;
	edges[2] = pC;
	float d = sdPolygon(edges,3,world_position);
	
	
	
	    //Inigo's pretty colors:
    vec3 col = vec3(1.0) - sign(d)*vec3(0.1,0.4,0.7);
    col *= 1.0 - exp(-3.0*abs(d));
    col *= 0.8 + 0.2*cos(120.0*d);
    col = mix( col, vec3(1.0), 1.0-smoothstep(0.0,0.015,abs(d)) );
	
    COLOR.rgb = col;
}

   