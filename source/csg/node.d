
module csg.node;

import csg.plane;
import csg.polygon;
import std.algorithm: swap;
debug import std.stdio:writeln;

// # class Node

// Holds a node in a BSP tree. A BSP tree is built from a collection of polygons
// by picking a polygon to split along. That polygon (and all other coplanar
// polygons) are added directly to that node and the other polygons are added to
// the front and/or back subtrees. This is not a leafy BSP tree since there is
// no distinction between internal and leaf nodes.
class Node {
	
	Plane plane;
	Polygon[] polygons;
	Node front;
	Node back;

	this() { /* noop */ }

	this(Polygon[] polygons) {
		build(polygons);
	}

	@property Node clone() {
		auto node = new Node();
		node.plane = plane is null ? null : plane.clone;
		node.front = front is null ? null : front.clone;
		node.back = back is null ? null : back.clone;
		foreach( ref p; polygons ) { node.polygons ~= p.clone; }
		return node;
	}

  // Convert solid space to empty space and empty space to solid space.
	void invert() {
		foreach( ref p; polygons) { p.flip(); }
		assert(plane !is null);
		plane.flip();

		if( front !is null ) front.invert();
		if( back !is null ) back.invert();
		
		swap(front, back);
	}

  // Recursively remove all polygons in `polygons` that are inside this BSP
  // tree.
	Polygon[] clipPolygons(Polygon[] polys) {
		if( plane is null ) return polys.dup;
		Polygon[] f, b;
		foreach( ref p; polys) {
			plane.splitPolygon(p, f, b, f, b );
		}
		if( front !is null ) f = front.clipPolygons(f);
		if( back !is null ) b = back.clipPolygons(b);
		else b.length = 0;  // this is the "remove" part !!
		return f ~ b;
	}

  // Remove all polygons in this BSP tree that are inside the other BSP tree
  // `bsp`.
	void clipTo(ref Node bsp) {
		polygons = bsp.clipPolygons(polygons);
		if( front !is null ) front.clipTo(bsp);
		if( back !is null ) back.clipTo(bsp);
	}

	Polygon[] allPolygons() {
		auto polys = polygons.dup;
		if( front !is null ) polys ~= front.allPolygons();
		if( back !is null ) polys ~= back.allPolygons();
		return polys;
	}

  // Build a BSP tree out of `polygons`. When called on an existing tree, the
  // new polygons are filtered down to the bottom of the tree and become new
  // nodes there. Each set of polygons is partitioned using the first polygon
  // (no heuristic is used to pick a good split).
	void build(Polygon[] polys) {
		if(polys.length == 0) return;
		if( plane is null ) plane = polys[0].plane.clone();
		Polygon[] f, b;
		foreach(ref p; polys) {
			plane.splitPolygon(p, polygons, polygons, f, b );
		}
		if( f.length ) {
			if( front is null ) front = new Node();
			front.build(f);
		}
		if( b.length ) {
			if( back is null ) back = new Node();
			back.build(b);
		}
	}

}
