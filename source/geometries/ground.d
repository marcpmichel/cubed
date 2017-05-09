
module geometries.ground;

import geometry;

class Ground: Geometry {

	float[] vertices= [
		-10.0,  0.0, -10.0,
		 10.0,  0.0, -10.0,
		 10.0,  0.0,  10.0,
		-10.0,  0.0,  10.0
	];

	uint[] faces=[
		0,1,2,
		0,2,3
	];

	this() {
		setup( vertices, faces );
	}

	void update(float lapse) {
	}

}
