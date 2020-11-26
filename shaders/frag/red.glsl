#version 150
out vec4 oColor;
#define gl_FragColor oColor

void main(void) {
	gl_FragColor = vec4(1.0, 0.0, 0.0, 1.0);
}
