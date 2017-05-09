module csg.csg;

import csg.polygon;
import csg.node;
import csg.plane;
debug import std.stdio: writeln;

class CSG {
	
	Polygon[] polygons;

	static CSG fromPolygons( Polygon[] polygons ) {
		auto csg = new CSG();
		csg.polygons = polygons;
		return csg;
	}

	CSG clone() {
		auto csg = new CSG();
		foreach( p; polygons) { csg.polygons ~= p.clone; }
		return csg;
	}

	Polygon[] toPolygons() {
		return polygons;
	}

  // Return a new CSG solid representing space in either this solid or in the
  // solid `csg`. Neither this solid nor the solid `csg` are modified.
  // 
  //     A.union(B)
  // 
  //     +-------+            +-------+
  //     |       |            |       |
  //     |   A   |            |       |
  //     |    +--+----+   =   |       +----+
  //     +----+--+    |       +----+       |
  //          |   B   |            |       |
  //          |       |            |       |
  //          +-------+            +-------+
  // 
	// was renamed from union ( reserved is D )
	CSG merge(CSG csg) {
		auto a = new Node( this.clone().polygons );
		auto b = new Node( csg.clone().polygons );
		a.clipTo(b);
		b.clipTo(a);
		b.invert();
		b.clipTo(a);
		b.invert();
		a.build(b.allPolygons());
		return CSG.fromPolygons(a.allPolygons());
	}

  // Return a new CSG solid representing space in this solid but not in the
  // solid `csg`. Neither this solid nor the solid `csg` are modified.
  // 
  //     A.subtract(B)
  // 
  //     +-------+            +-------+
  //     |       |            |       |
  //     |   A   |            |       |
  //     |    +--+----+   =   |    +--+
  //     +----+--+    |       +----+
  //          |   B   |
  //          |       |
  //          +-------+
  // 
	CSG substract(CSG csg) {
		auto a = new Node( this.clone().polygons );
		auto b = new Node( csg.clone().polygons );
		a.invert();
		a.clipTo(b);
		b.clipTo(a);
		b.invert();
		b.clipTo(a);
		b.invert();
		a.build(b.allPolygons());
		a.invert();
		return CSG.fromPolygons(a.allPolygons());
	}

  // Return a new CSG solid representing space both this solid and in the
  // solid `csg`. Neither this solid nor the solid `csg` are modified.
  // 
  //     A.intersect(B)
  // 
  //     +-------+
  //     |       |
  //     |   A   |
  //     |    +--+----+   =   +--+
  //     +----+--+    |       +--+
  //          |   B   |
  //          |       |
  //          +-------+
  // 
	CSG intersect(CSG csg) {
		auto a = new Node( this.clone().polygons );
		auto b = new Node( csg.clone().polygons );
		a.invert();
		b.clipTo(a);
		b.invert();
		a.clipTo(b);
		b.clipTo(a);
		a.build(b.allPolygons());
		a.invert();
		return CSG.fromPolygons(a.allPolygons());
	}

  // Return a new CSG solid with solid and empty space switched. This solid is
  // not modified.
	CSG inverse() {
		auto csg = this.clone();
		foreach( ref p; csg.polygons ) { p.flip(); }
		return csg;
	}

	CSG[] truncate(Plane plane) {
		auto a = new Node( this.clone().polygons );

		Polygon[] f,b;
		Polygon[] cf,cb;

		foreach(ref p; a.allPolygons) {
			writeln( "f.len = ", f.length, " : b.len = ", b.length );
			plane.splitPolygon(p, cf, cb, f, b);
		}
		//if( a.front !is null ) f = a.front.clipPolygons(f);
		//if( a.back !is null ) b = a.back.clipPolygons(b);

		return [ CSG.fromPolygons(f), CSG.fromPolygons(b) ];
	}
}
