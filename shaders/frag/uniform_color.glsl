#version 150
uniform vec3 in_color;
out vec4 oColor;
#define gl_FragColor oColor

void main(void) {
	gl_FragColor = vec4(in_color, 1.0);
}
