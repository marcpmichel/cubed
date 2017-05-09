#version 120

varying vec3 pos;
uniform vec3 in_color;
uniform vec3 sundir = normalize(vec3(1,1,1));
uniform vec3 suncolor = vec3(1.0,1.0,1.0);
uniform float ambient = 0.2;
// out vec4 out_color; // 130 only

void main(void) {
	vec3 norm = normalize(cross(dFdx(pos), dFdy(pos)));
	float diffuse = max( 0.0, dot(norm, sundir ));
	//out_color = vec4(in_color,1.0) * vec4( suncolor * ( diffuse + ambient), 1.0 );
	gl_FragColor = vec4(in_color,1.0) * vec4( suncolor * ( diffuse + ambient), 1.0 );
}
