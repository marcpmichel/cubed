#version 120

uniform mat4 projectionMatrix; 
uniform mat4 viewMatrix;
uniform mat4 modelMatrix; 
varying vec3 pos;

void main(void) {
	gl_Position = projectionMatrix * viewMatrix * modelMatrix * gl_Vertex;
	pos = ( modelMatrix * gl_Vertex).xyz;
}
