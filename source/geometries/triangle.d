module geometries.triangle;

import geometry;

class Triangle: Geometry {

	this() {
		setup(cast(float[])[0,0,0,.5,1,0,-.5,1,0], cast(uint[])[0,1,2]);
	}

}

