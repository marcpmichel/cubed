module csg.vertex;
import gl3n.linalg;

class Vertex {
	vec3 pos, normal;
	this( vec3 a_pos, vec3 a_normal = vec3(0,1,0) ) {
		pos = vec3(a_pos);
		normal = vec3(a_normal);
	}

	Vertex clone() {
		return new Vertex( vec3(pos), vec3(normal));
	}

	void flip() {
		normal = -normal;
	}

	Vertex interpolate(Vertex other, float t) {
		return new Vertex( vector_lerp(pos, other.pos, t), vector_lerp(normal, other.normal, t).normalized);
	}

	vec3 vector_lerp(vec3 v1, vec3 v2, float t) {
		return v1 + ((v2 - v1) * t);
	}
}
