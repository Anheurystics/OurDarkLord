attribute vec3 position;
attribute vec2 texCoord;
attribute vec3 normal;

uniform mat4 model;
uniform mat4 view;
uniform mat4 proj;

varying vec2 TexCoord;
varying vec3 FragPos;

void main() 
{
	gl_Position = proj * view * model * vec4(position, 1.0);
	TexCoord = texCoord;
	FragPos = vec3(model * vec4(position, 1.0));
}