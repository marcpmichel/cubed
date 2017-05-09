module csg.polygon;

import csg.vertex;
import csg.plane;
import gl3n.linalg;
import std.algorithm;

struct PolygonProperties {
	vec3 color;
}

// # class Polygon

// Represents a convex polygon. The vertices used to initialize a polygon must
// be coplanar and form a convex loop. They do not have to be `CSG.Vertex`
// instances but they must behave similarly (duck typing can be used for
// customization).
// 
// Each convex polygon has a `shared` property, which is shared between all
// polygons that are clones of each other or were split from the same polygon.
// This can be used to define per-polygon properties (such as surface color).
class Polygon {
	Vertex[] vertices;
	PolygonProperties properties;
	Plane plane;

	this(Vertex[] vertices, PolygonProperties properties) {
		this.vertices = vertices;
		this.properties = properties;
		plane = Plane.fromPoints(vertices[0].pos, vertices[1].pos, vertices[2].pos );
	}

	Polygon clone() {
		Vertex[] verts;
		foreach( v; vertices ) { verts ~= v.clone; }
		return new Polygon( verts, properties);
	}

	void flip() {
		foreach( ref v; vertices.reverse) { v.flip(); }
		plane.flip();
	}
}
