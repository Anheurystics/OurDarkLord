varying vec2 TexCoord;
varying vec3 FragPos;

uniform vec2 tile;
uniform vec2 offset;
uniform vec3 cameraPos;

uniform vec4 fogColor;

uniform int useFog;
uniform float fogDistance;
uniform float fogRate;

uniform float flipX;

uniform sampler2D tex1;

void main()
{
	//If fog is turned on (useFog == 1.0), useFog a visibility value
	//to be applied to the final alpha
	float dist = length(cameraPos - FragPos);
	float visibility = 1.0;
	if(useFog == 1)
	{
		visibility = clamp(1.0 - ((dist - fogDistance) / fogRate), 0.0, 1.0);
	}

	//Flip texture if needed
	vec2 coord = TexCoord;
	if(flipX == -1.0)
	{
		coord.s = 1.0 - coord.s;
	}
	
	vec4 color = texture2D(tex1, offset + coord * tile).bgra;
	
	//Discard fragments that are completely invisible
	if(color.a == 0.0)
	{
		discard;
	}
	
	gl_FragColor = vec4(color * visibility) + vec4(fogColor * (1.0 - visibility));
}