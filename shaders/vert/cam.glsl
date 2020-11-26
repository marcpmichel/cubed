#version 150

uniform mat4 projectionMatrix; 
uniform mat4 viewMatrix;
uniform mat4 modelMatrix; 
in vec4 coord;
out vec3 pos;

void main(void) {
	gl_Position = projectionMatrix * viewMatrix * modelMatrix * coord;
	pos = ( modelMatrix * coord).xyz;
}
