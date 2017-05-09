
module mesh;
import geometry;
import derelict.opengl3.gl3;
import std.math;
import std.stdio;
import gl3n.linalg;
import std.random;
import material;
import gl3n.aabb;


class Mesh {

	Geometry _geom;
	vec3 _color = vec3(1,0,0);
	mat4 _mat = mat4.identity;
	vec3 _position;
	Material _material;
	AABB _aabb;

	this() {
		this.material = null;
		_aabb = AABB(vec3(-1,-1,-1), vec3(1,1,1));
	}

	this( Geometry geom, Material material = null ) {
		setGeometry(geom);
		this.material = material;
	}

	@property material(Material mat) {
		if(mat is null) 
			_material = new Material();
		else
			_material = mat;
	}

	void setGeometry(Geometry a_geom) {
		_geom = a_geom;
		_aabb = a_geom.aabb;
	}

	@property geom() {
		return _geom;
	}

	@property aabb() {
		return _aabb;
	}

	@property mat4 matrix() {
		return _mat;
	}

	@property vec3 color() {
		return _material.color();
	}

	@property position() {
		return _position;
	}

	void setPosition(vec3 position) {
		setPosition( position.x, position.y, position.z );
	}

	void setPosition(float x, float y, float z) {
		_position.x = x;
		_position.y = y;
		_position.z = z;
		_mat.matrix[0][3] = x;
        _mat.matrix[1][3] = y;
        _mat.matrix[2][3] = z;
	
		vec3 half_size = _aabb.half_extent;
		_aabb = AABB(_position - half_size, _position + half_size );
	}

	void render() {
		_geom.render();
	}

}

