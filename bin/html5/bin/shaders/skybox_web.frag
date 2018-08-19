precision highp float;

varying vec3 TexCoords;

uniform samplerCube skybox;

void main()
{    
	vec4 color = textureCube(skybox, TexCoords);
	color.x = 0.0;
    gl_FragColor = color;
}
 