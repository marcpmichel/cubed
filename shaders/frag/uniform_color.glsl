#version 120
uniform vec3 in_color;

void main(void) {
	gl_FragColor = vec4(in_color, 1.0);
}
