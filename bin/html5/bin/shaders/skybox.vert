attribute vec3 position;

uniform mat4 view;
uniform mat4 proj;
uniform mat4 model;

varying vec3 TexCoords;

void main()
{
    gl_Position = proj * mat4(mat3(view)) * model * vec4(position, 1.0);  
    TexCoords = position;
}  