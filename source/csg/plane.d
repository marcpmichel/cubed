
module csg.plane;

import csg.polygon;
import gl3n.linalg;
import csg.vertex;

class Plane {
	vec3 normal;
	float w;
	enum Epsilon = 1e-5;

	this( vec3 a_normal, float a_w ) {
		normal = a_normal;
		w = a_w;
	}

	static Plane fromPoints(vec3 a, vec3 b, vec3 c) {
		vec3 n = ((b - a).cross(c - a)).normalized;
		return new Plane(n, n.dot(a));
	}

	Plane clone() {
		return new Plane(vec3(normal), w);
	}

	void flip() {
		normal = -normal;
		w = -w;
	}

  // Split `polygon` by this plane if needed, then put the polygon or polygon
  // fragments in the appropriate lists. Coplanar polygons go into either
  // `coplanarFront` or `coplanarBack` depending on their orientation with
  // respect to this plane. Polygons in front or in back of this plane go into
  // either `front` or `back`.
	void splitPolygon( Polygon polygon, 
		ref Polygon[] coplanarFront, ref Polygon[] coplanarBack, 
		ref Polygon[] front, ref Polygon[] back) {

		enum Type:uint { COPLANAR=0, FRONT=1, BACK=2, SPANNING=3 }
		uint polygonType;
		Type[] verticesTypes;
		foreach( vertice; polygon.vertices ) {
			auto t = normal.dot(vertice.pos) - w;
			auto type = (t < -Plane.Epsilon) ? Type.BACK : (t > Plane.Epsilon) ? Type.FRONT : Type.COPLANAR;
			polygonType |= type;
			verticesTypes ~= type;
		}

		switch(polygonType) {
			case Type.COPLANAR:
				if( normal.dot(polygon.plane.normal) > 0) coplanarFront ~= polygon;
				else coplanarBack ~= polygon;
				break;
			case Type.FRONT:
				front ~= polygon;
				break;
			case Type.BACK:
				back ~= polygon;
				break;
			case Type.SPANNING:
				Vertex[] f, b;
				//foreach(i, vertice; polygon.vertices) {
				for( ulong i = 0; i < polygon.vertices.length; i++ ) {
					ulong j = (i+1) % polygon.vertices.length; 
					Type ti = verticesTypes[i], tj = verticesTypes[j];
					Vertex vi = polygon.vertices[i], vj = polygon.vertices[j];
					if( ti != Type.BACK) f ~= vi;
					if( ti != Type.FRONT) b ~= (ti != Type.BACK) ? vi.clone() : vi;
					if((ti | tj) == Type.SPANNING) {
						float t = (w - normal.dot(vi.pos)) / normal.dot(vj.pos - vi.pos);
						Vertex v = vi.interpolate(vj, t);
						f ~= v;
						b ~= v.clone();
					}
				}
				if( f.length >= 3) front ~= new Polygon(f, polygon.properties);
				if( b.length >= 3) back ~= new Polygon(b, polygon.properties);
				break;
			default:
				throw new Error("this can't happen");
		}
	}
}

