varying vec2 TexCoord;
varying vec3 FragPos;

uniform float alpha;
uniform vec3 tint;

uniform sampler2D tex1;

void main()
{
	vec4 color = texture2D(tex1, TexCoord).bgra;
	color.r *= tint.r;
	color.g *= tint.g;
	color.b *= tint.b;
	
	color.a *= alpha;
	
	if(color.a == 0.0)
	{
		discard;
	}
	
	gl_FragColor = vec4(color);
}