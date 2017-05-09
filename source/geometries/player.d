module geometries.player;
import geometry;

class PlayerGeom: Geometry {

	float[] vertices = [
		0, 0.8, 0,
		-0.3, -0.8, -0.3,
		0.3, -0.8, -0.3,
		0.3, -0.8, 0.3,
		-0.3, -0.8, 0.3
	];

	uint[] faces = [
		0,1,2,
		0,2,3,
		0,3,4,
		0,4,1,
		4,3,2,
		2,1,4
	];

	this() {
		setup( vertices, faces );
	}
}
