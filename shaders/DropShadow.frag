// Automatically converted with https://github.com/TheLeerName/ShadertoyToFlixel

#pragma header

#define round(a) floor(a + 0.5)
#define iResolution vec3(openfl_TextureSize, 0.)
uniform float iTime;
#define iChannel0 bitmap
uniform sampler2D iChannel1;
uniform sampler2D iChannel2;
uniform sampler2D iChannel3;
#define texture flixel_texture2D

// third argument fix
vec4 flixel_texture2D(sampler2D bitmap, vec2 coord, float bias) {
	vec4 color = texture2D(bitmap, coord, bias);
	if (!hasTransform)
	{
		return color;
	}
	if (color.a == 0.0)
	{
		return vec4(0.0, 0.0, 0.0, 0.0);
	}
	if (!hasColorTransform)
	{
		return color * openfl_Alphav;
	}
	color = vec4(color.rgb / color.a, color.a);
	mat4 colorMultiplier = mat4(0);
	colorMultiplier[0][0] = openfl_ColorMultiplierv.x;
	colorMultiplier[1][1] = openfl_ColorMultiplierv.y;
	colorMultiplier[2][2] = openfl_ColorMultiplierv.z;
	colorMultiplier[3][3] = openfl_ColorMultiplierv.w;
	color = clamp(openfl_ColorOffsetv + (color * colorMultiplier), 0.0, 1.0);
	if (color.a > 0.0)
	{
		return vec4(color.rgb * color.a * openfl_Alphav, color.a * openfl_Alphav);
	}
	return vec4(0.0, 0.0, 0.0, 0.0);
}

// variables which is empty, they need just to avoid crashing shader
uniform float iTimeDelta;
uniform float iFrameRate;
uniform int iFrame;
#define iChannelTime float[4](iTime, 0., 0., 0.)
#define iChannelResolution vec3[4](iResolution, vec3(0.), vec3(0.), vec3(0.))
uniform vec4 iMouse;
uniform vec4 iDate;

uniform float uQuality = 5.0;
uniform float uSize = 8.0;
uniform float uStrength = 1;
uniform float uDivisions = 15;


float normpdf(in float x, in float sigma)
{
	return 0.39894*exp(-0.5*x*x/(sigma*sigma))/sigma;
}

vec4 getBlur(in sampler2D tex, in vec2 uv, in vec2 resolution) {
    const float Pi = 3.14159265359;
    const float Pi2 = Pi * 2.0;
    //const float directions = 15.0;
    //const float quality = 5.0;
    //const float size = 8.0;
    vec2 radius = uSize / iResolution.xy;

    vec4 color = texture(tex, uv);
    float total = 1.0;
    for(float d = 0.0; d < Pi2; d += Pi2 / uDivisions) {
        for(float i = 1.0 / uQuality; i <= 1.0; i += 1.0 / uQuality) {
            float w = i;
            total += w;
            color += texture(tex, uv + vec2(cos(d), sin(d)) * radius * i) * w; 
        }
    }
    color = color / total;
    
    return color;
}


vec4 blend(in vec4 src, in vec4 dst) {
    return src * src.a + dst * (1.0 - src.a);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = fragCoord/iResolution.xy;

    vec4 shadow = getBlur(iChannel0, uv, iResolution.xy);

    shadow *= vec4(0.0, 0.0, 0.0, 1.0);

    shadow *= uStrength;



    if(fragCoord.x < iMouse.x) {
        shadow *= 0.0;
    }

    vec4 background = vec4(0.0);
    vec4 original = texture(iChannel0, uv);

    vec4 result = shadow;
    result = blend(original, result);

    fragColor = result;
}

void main() {
	mainImage(gl_FragColor, openfl_TextureCoordv*openfl_TextureSize);
}