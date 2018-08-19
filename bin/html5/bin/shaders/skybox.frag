varying vec3 TexCoords;

uniform samplerCube skybox;

void main()
{    
	vec4 color = textureCube(skybox, TexCoords);
    gl_FragColor = color.bgra;
}
 