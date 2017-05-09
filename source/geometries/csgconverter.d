module geometries.csgconverter;

import csg.csg;
import csg.polygon;
import csg.vertex;
import geometry;
debug import std.stdio;

class CSGConverter: Geometry {

	class VerticesIndexer {
		Vertex[] vertices;
		uint add(Vertex v) {
			int found = find(v);
			if (found == - 1) {
				found = cast(int)vertices.length;
				vertices ~= v;
			}
			// writeln("adding vertex",v.pos.vector," => ", found );
			return found;
		}

		private int find(Vertex a) {
			foreach( int i, b; vertices) {
				if( a.pos == b.pos ) return i;
			}
			return -1;
		}
	}

	float[] vertices;
	uint[] elements;

	this( CSG csg ) {
		
		conv2(csg.inverse());

		setup( vertices, elements);

		//writeln( "vertices :", vertices.length);
		//writeln( "vertices :", vertices.length, " => ", vertices );
		//writeln( "triangles :", elements.length, " => ", elements );
	}

	void conv2(CSG csg) {
		auto indexer = new VerticesIndexer();
		foreach( p; csg.toPolygons) {
			uint[] indices;
			foreach( v; p.vertices ) { indices ~= indexer.add(v); }
			//writeln(" indices :", indices);
			for(int i=2; i < indices.length; i++)
				elements ~= [ indices[0], indices[i-1], indices[i] ];
		}

		foreach(v; indexer.vertices) {
			vertices ~= v.pos.vector;
		}
	}


	void conv1(CSG csg) {
		uint offset;
		foreach(polygon; csg.toPolygons) {
			foreach( v; polygon.vertices ) { vertices ~= v.pos.vector; }
			
			uint n = cast(uint)polygon.vertices.length;

			for(int i=1; i < n-1; i++ ) {
				elements ~= [ offset, offset+i, offset+i+1 ];
			}
			offset += n;
		}
	}

}
