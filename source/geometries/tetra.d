
module geometries.tetra;

import geometry;

class Tetra: Geometry {

	float[] vertices= [
		-0.0, -1.0,  0.0,
		-0.5,  0.0, -0.5,
		 0.5,  0.0, -0.5,
		 0.5,  0.0,  0.5,
		-0.5,  0.0,  0.5,
		 0.0,  1.0,  0.0
	];

	uint[] faces=[
		0,2,1,
		0,3,2,
		0,4,3,
		0,1,4,
		5,1,2,
		5,2,3,
		5,3,4,
		5,4,1
	];

	this() {
		setup( vertices, faces );
	}

}
