#pragma header

uniform float uMix;
uniform vec4 color;

void main()
{
    vec4 sample = flixel_texture2D(bitmap, openfl_TextureCoordv);
    gl_FragColor = mix(sample, color, uMix * sample.a);
}