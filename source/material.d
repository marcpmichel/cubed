
import gl3n.linalg;
import std.random;

class Material {
	
	vec3 _color;

	this() {
		_color.r = uniform(0.1f,1.0f);
		_color.g = uniform(0.1f,1.0f);
		_color.b = uniform(0.1f,1.0f);
	}

	this(vec3 color) {
		_color = color;
	}

	@property vec3 color() {
		return _color;
	}
}

