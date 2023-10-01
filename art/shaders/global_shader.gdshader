shader_type canvas_item;
render_mode blend_mix;

varying vec2 world_position;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

uniform sampler2D gradient_inside;
uniform sampler2D gradient_outside;

void vertex(){
    world_position = (MODEL_MATRIX * vec4(VERTEX,0.0,1.0)).xy;
}

//most part of the following code for SDF computation is based on work from Anders Riggelsen available here https://www.shadertoy.com/view/wdffWH
struct Result{
    float dist;     //Regular SDF distance
    float side;     //Which side of the line segment the point is (-1,0,1)
};

Result udSegment( in vec2 p, in vec2 a, in vec2 b )
{
    Result res;
    //All this is basically Inigo's regular line SDF function - but store it in 'dist' instead: 
    vec2 ba = b-a;
    vec2 pa = p-a;
    float h = clamp( dot(pa,ba)/dot(ba,ba), 0.0, 1.0 );
    res.dist = length(pa-h*ba);
    //Is the movement (a->b->p) a righthand turn? (cross product)
    res.side = sign( (b.x - a.x)*(p.y - a.y) - (b.y - a.y)*(p.x - a.x) ); 
    return res;
}

float computeSDF(vec2 pixel_pos)
{
	vec2 p = pixel_pos;
	
	vec2 pA = vec2(-0.8,  0.7);
    vec2 pB = vec2( 4.0, 4.0);
    vec2 pC = vec2( 1.0, -0.4);
    vec2 pD = vec2( 0.0, -1.2);
    vec2 pE = vec2(-1.0, -0.6);

    //Get the SDF distances for the line segments along with the 'side':
    Result rA = udSegment( p, pA, pB);
    Result rB = udSegment( p, pB, pC );
    Result rC = udSegment( p, pC, pD );
    Result rD = udSegment( p, pD, pE );
    Result rE = udSegment( p, pE, pA );
    
    //Union of all distances
    float d =  rA.dist;
    d = min(d, rB.dist);
    d = min(d, rC.dist);
    d = min(d, rD.dist);
    d = min(d, rE.dist);
	
	//At this point all we have is a SDF of an infinitely thin shape.
    //To make it "solid" we have to give all the points on the inside a negative distance.
    
    //But which side is the point on?
    //If the "side" is negative for *all* N segments the sum will be -N.
    //Adding N and subtracting a small value ]0-1[ before getting the sign
    //of this sum makes it either 1 (outside of shape) or -1 (inside of shape)
    d = d * sign(rA.side + rB.side + rC.side + rD.side + rE.side + 5.0 - 0.5);
	
	return d;
}


void fragment() {
    vec3 c = textureLod(screen_texture, SCREEN_UV, 0.0).rgb;
	
	float d = computeSDF(world_position);
	    //Inigo's pretty colors:
    vec3 col = vec3(1.0) - sign(d)*vec3(0.1,0.4,0.7);
    col *= 1.0 - exp(-3.0*abs(d));
    col *= 0.8 + 0.2*cos(120.0*d);
    col = mix( col, vec3(1.0), 1.0-smoothstep(0.0,0.015,abs(d)) );
	
    COLOR.rgb = col;
}

   
