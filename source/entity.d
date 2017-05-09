
import gl3n.linalg;
import mesh;

class Entity {

	vec3 velocity;
	Mesh _mesh;

	this(Mesh mesh, vec3 pos) {
		_mesh = mesh;
		_mesh.setPosition(pos);
	}

	@property mesh() { return _mesh; }

	@property position(vec3 pos) {
		_mesh.setPosition(pos);
	}

	@property position() {
		return _mesh.position;
	}

	void update() {
	}

}
