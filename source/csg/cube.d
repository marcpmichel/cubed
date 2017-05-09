
module csg.cube;
import gl3n.linalg;
import csg.polygon;
import csg.vertex;
import csg.csg;

// Construct an axis-aligned solid cuboid. Optional parameters are `center` and
// `radius`, which default to `[0, 0, 0]` and `[1, 1, 1]`. The radius can be
// specified using a single number or a list of three numbers, one for each axis.
// 
// Example code:
// 
//     var cube = CSG.cube({
//       center: [0, 0, 0],
//       radius: 1
//     });
class Cube {
	vec3 position;
	vec3 scale;

	this() {
		position = vec3(0,0,0);
		scale = vec3(1,1,1);
	}

	this(vec3 a_position) {
		position = a_position;
	}

	this(vec3 a_position, vec3 a_scale) {
		position = a_position;
		scale = a_scale;
	}

	CSG csg() {
		auto faces = [
		    [[0, 4, 6, 2], [-1, 0, 0]],
		    [[1, 3, 7, 5], [+1, 0, 0]],
		    [[0, 1, 5, 4], [0, -1, 0]],
		    [[2, 6, 7, 3], [0, +1, 0]],
		    [[0, 2, 3, 1], [0, 0, -1]],
		    [[4, 5, 7, 6], [0, 0, +1]]
		];

		Polygon buildPolygon(int[][] facedef) {
			Vertex[] vertices;
			foreach( i; facedef[0] ) {
				vec3 pos = vec3( 
					(!(!(i&1))) * scale.x + position.x, 
					(!(!(i&2))) * scale.y + position.y, 
					(!(!(i&4))) * scale.z + position.z );
				vec3 norm = vec3( facedef[1][0], facedef[1][1], facedef[1][2] );
				vertices ~= new Vertex( pos, norm );
			}
			PolygonProperties props;
			return new Polygon(vertices, props);
		}

		Polygon[] polys;
		foreach( facedef; faces ) { polys ~= buildPolygon(facedef); }

		return CSG.fromPolygons(polys);
	}


}
