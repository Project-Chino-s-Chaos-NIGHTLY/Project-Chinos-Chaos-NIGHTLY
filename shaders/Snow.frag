//SHADERTOY PORT FIX
#pragma header
vec2 uv = openfl_TextureCoordv.xy;
vec2 fragCoord = openfl_TextureCoordv*openfl_TextureSize;
vec2 iResolution = openfl_TextureSize;
uniform float iTime = 0.0;
#define iChannel0 bitmap
#define texture flixel_texture2D
#define fragColor gl_FragColor
#define mainImage main
//****MAKE SURE TO remove the parameters from mainImage.
//SHADERTOY PORT FIX
const vec3 nord6 = vec3(236, 239, 244)/255.0;

const float SPEED = 0.5;
uniform float WIND = 0.0;
const float MAX_DEPTH = 0.0;
const float DEPTH_STEP = 0.2;
const float TIME_OFFSET = 100.0;

float hash(vec2 co) {
	return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

float noise( in vec2 p )
{
    vec2 i = floor( p );
    vec2 f = fract( p );
    
    vec2 u = f*f*f*(f*(f*6.0-15.0)+10.0);
    
    float va = hash( i + vec2(0.0,0.0) );
    float vb = hash( i + vec2(1.0,0.0) );
    float vc = hash( i + vec2(0.0,1.0) );
    float vd = hash( i + vec2(1.0,1.0) );
    
    float k0 = va;
    float k1 = vb - va;
    float k2 = vc - va;
    float k4 = va - vb - vc + vd;

    return va+(vb-va)*u.x+(vc-va)*u.y+(va-vb-vc+vd)*u.x*u.y;
}

/////////////////////////////////////////////////////////////////////////////////
// credit: Emil https://www.shadertoy.com/view/Mdt3Df                          //
float snow(vec2 coord, float depth, float time, float speed) {
    float snow = 0.0;
    float random = fract(sin(dot(coord.xy,vec2(12.9898,78.233)))* 43758.5453);
    for(int k=0;k<6;k++){
        for(int i=0;i<20 && i<int(depth*4.0);i++){
            float cellSize = 2.0 + (float(i)*3.0);
			float downSpeed = 0.3+(sin(time*0.4+float(k+i*20))+1.0)*0.00008;
            vec2 uv = (coord.xy / iResolution.x)+vec2(0.01*sin((time+float(k*6185))*0.6+float(i))*(5.0/float(i))+time*speed*0.3,downSpeed*(time+float(k*1352))*(1.0/float(i)));
            vec2 uvStep = (ceil((uv)*cellSize-vec2(0.5,0.5))/cellSize);
            float x = fract(sin(dot(uvStep.xy,vec2(12.9898+float(k)*12.0,78.233+float(k)*315.156)))* 43758.5453+float(k)*12.0)-0.5;
            float y = fract(sin(dot(uvStep.xy,vec2(62.2364+float(k)*23.0,94.674+float(k)*95.0)))* 62159.8432+float(k)*12.0)-0.5;
            float randomMagnitude1 = sin(time*2.5)*0.7/cellSize;
            float randomMagnitude2 = cos(time*2.5)*0.7/cellSize;
            float d = 5.0*distance((uvStep.xy + vec2(x*sin(y),y)*randomMagnitude1 + vec2(y,x)*randomMagnitude2),uv.xy);
            float omiVal = fract(sin(dot(uvStep.xy,vec2(32.4691,94.615)))* 31572.1684);
            if(omiVal<0.08?true:false){
                float newd = (x+1.0)*0.4*clamp(1.2-d*(15.0+(x*6.3))*(cellSize/1.4),0.0,1.0);
                snow += newd / float(i)*4.0;
            }
        }
    }
    
    return snow*noise(coord/iResolution.y*10.0 + iTime);
}                                                                              //
/////////////////////////////////////////////////////////////////////////////////


void mainImage() {
	vec2 pos = (fragCoord.xy - iResolution.xy/2.0) / (iResolution.y/2.0);
    pos.y -= 0.5;
    vec2 uv = fragCoord.xy / iResolution.xy;

    float depth = 1000.0;
    float time = (iTime+TIME_OFFSET)*SPEED;

    //vec3 col = mix(nord6, nord6, smoothstep(-0.5, 1.0, pos.y));
    vec4 col = texture(iChannel0, uv);
    col.rgb = mix(col.rgb, nord6, noise(pos+vec2(time*SPEED*WIND, 0))*0.4);

    float snow = snow(gl_FragCoord.xy, depth, time/SPEED, SPEED*WIND)*10.0;
    col.rgb = mix(col.rgb, nord6, min(1.0, snow));
    col.rgb += snow*(pos.y+1.0)*0.1;

    fragColor = col;
}
