module geometries.quad;

import geometry;

class Quad: Geometry {

	float[12] vertices = [
		-0.5, -1.0, 0, 
		 0.5, -1.0, 0, 
		 0.5,  0.0, 0,  
		-0.5,  0.0, 0
	];
	uint[6] elements = [ 0,1,2, 0,2,3 ];

	this() {
		setup( vertices, elements );
	}

}

