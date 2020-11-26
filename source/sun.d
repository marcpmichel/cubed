
import gl3n.linalg;
import std.math: fmod, PI, cos, sin;

class Sun {

	vec3 _direction, _color;
	float alpha=0;

	this(vec3 direction, vec3 color = vec3(1,1,1) ) {
		_direction = direction;
		_color = color;
	}

	void update(float delta) {
		alpha = fmod( alpha + delta, 2 * PI );
		_direction = vec3(-cos(alpha), -sin(alpha), 0);
		//_color = vec3( cos(alpha), cos(alpha), cos(alpha + PI) );
	}

	@property direction() { return _direction; }
	@property color() { return _color; }

}
