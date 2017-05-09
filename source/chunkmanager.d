
import chunk;
import std.conv;
import gl3n.linalg;
import mesh;
import std.array: empty, front, popFront;
import std.algorithm;
import delay;
import gl3n.aabb;


ChunkCoord toChunkCoord( vec3 pos ) {
	return ChunkCoord( 
			cast(int)(pos.x / Chunk.Width),
			cast(int)(pos.z / Chunk.Length) );
}

class ChunkManager {

	Chunk[string] chunks;
	ChunkCoord prevCoord = ChunkCoord(-1,-1);

	ChunkCoord[] chunksToCreate;
	ChunkCoord[] chunksToDestroy;

	static const int Radius = 4;
	Delay delay;

	this() {
		//delay = new Delay(.1);
	}

	void update( vec3 worldPos ) {
		
		//if(delay.over) {
			//writeln("one");
			createChunks(1);
			//writeln("two");
			//destroyChunks(1);
		//	delay.reset;
		//}

		//writeln("three");

		ChunkCoord coord = worldPos.toChunkCoord;
		if( coord == prevCoord ) return;
		//writeln("prev:", prevCoord, " current:", coord);
		prevCoord = ChunkCoord(coord);

		int xmin = coord.x - Radius;
		int xmax = coord.x + Radius;
		int ymin = coord.y - Radius;
		int ymax = coord.y + Radius;
		//writeln("xmin:", xmin, " ymin:",ymin,  " xmax:",xmax, " ymax:", ymax );

		for(int i=xmin; i<=xmax; i++ ) {
			for(int j=ymin; j<=ymax; j++ ) {
				createIfMissing( ChunkCoord(i,j));
			}
		}
		
		//writeln("four");

		foreach( k; chunks.keys ) {
			Chunk c = chunks[k];
			if( c.position.x < xmin || 
				c.position.x > xmax || 
				c.position.y < ymin || 
				c.position.y > ymax ) {
				
				//writeln("destroying ", k );
				destroyChunk(c.position);
				// chunksToDestroy ~= c.position;
			}
		}

		//writeln("five");
	}
	
	void destroyChunks(int n) {
		if(chunksToDestroy.empty) return;
		for(int i=0; i<n; i++) {
			ChunkCoord coord = chunksToDestroy.front;
			chunksToDestroy.popFront();
			destroyChunk(coord);
		}
	}

	void destroyChunk(ChunkCoord coord) {
		string name = chunkName(coord);
		if( !chunksToCreate.any!(a => a == coord)) {
			Chunk* c = (name in chunks); 
			if( *c !is null ) destroy(*c);
		}
		chunks.remove(name);
	}


	void createIfMissing( ChunkCoord coord ) {

		if( coord.x < 0 || coord.y < 0 ) return;

		Chunk* found = chunkName(coord) in chunks;
		if( found is null ) {
			//writeln("creating chunk at ", coord );
			//createChunkAt( coord );
			//if( !chunksToDestroy.any!(a => a == coord))
			if( !chunksToCreate.any!(a => a == coord)) // avoid duplicates
				chunksToCreate ~= coord;
		}
	}

	void createChunks(int n) {
		if(chunksToCreate.empty) return;
		for(int i=0; i<n; i++) {
			ChunkCoord coord = chunksToCreate.front;
			createChunkAt(coord);
			chunksToCreate.popFront();
		}
	}

	void createChunkAt( ChunkCoord coord ) {
		chunks[ chunkName(coord) ] = new NoiseChunk(coord);
	}

	string chunkName( ChunkCoord c ) {
		return text( c.x, "x", c.y);
	}


	Chunk chunkAt( vec3 pos ) {
		ChunkCoord coord = pos.toChunkCoord;
		Chunk* found = chunkName(coord) in chunks;
		if( found is null ) return null;
		return *found;
	}

	Chunk.VoxelType voxelTypeAt( VoxelCoord vc ) {
		Chunk chunk = chunkAt(vec3(vc.x,vc.y,vc.z));
		if( chunk is null ) return Chunk.VoxelType.Invalid;
		if( vc.y > Chunk.Height-1 ) return Chunk.VoxelType.Invalid;
		return chunk.voxelType( vc.toLocal );
	}

	bool voxelPresent( vec3 world_position ) {
		Chunk chunk = chunkAt(world_position);
		if( chunk is null ) return false;
		return chunk.voxelPresent(world_position.toLocalVoxelCoord);
	}

	bool voxelPresent(VoxelCoord vc) {
		Chunk chunk = chunkAt(vec3(vc.x,vc.y,vc.z));
		if( chunk is null ) return false;
		return chunk.voxelPresent(vc.toLocal);
	}

	AABB voxelAABB( vec3 world_position ) {
		enum AABB invalidAABB = AABB(vec3(-1,-1,-1), vec3(0,0,0));
		Chunk chunk = chunkAt(world_position);
		if( chunk is null ) {
			return invalidAABB;
		}
		VoxelCoord vc = world_position.toVoxelCoord();
		return chunk.voxelAABB(vc);
	}

	AABB voxelAABB( VoxelCoord vc ) {
		enum AABB invalidAABB = AABB(vec3(float.nan,float.nan,float.nan), vec3(float.nan, float.nan, float.nan));
		Chunk chunk = chunkAt(vec3(vc.x,vc.y,vc.z));
		if( chunk is null ) { return invalidAABB; }
		return chunk.voxelAABB(vc);
	}

	@property Mesh[] meshes() {
		return cast(Mesh[])chunks.values;
	}


	Voxel voxelAt( VoxelCoord vc ) {
		auto chunk = chunkAt(vec3(vc.x,vc.y,vc.z));
		if(chunk is null) return Voxel(Chunk.VoxelType.Invalid);
		return chunk.voxelAt(vc);
	}


	import entity;
	void collide(ref Entity entity) {

		enum float Bouncyness = 0.8;
		enum float Friction = 0.9;

		if( chunkAt(entity.position) is null ) return;
		// entity.velocity *= Friction;
		entity.position = entity.position + entity.velocity;

		auto ebb = entity.mesh.aabb;
		auto ebbhe = ebb.half_extent;
		VoxelCoord evc = entity.position.toVoxelCoord;

		Voxel v;
		if( entity.velocity.y < 0 ) {
			v = voxelAt(evc + VoxelCoord(0,-1,0));
			if( v.type > Chunk.VoxelType.Air && v.aabb.max.y > ebb.min.y ) {
				entity.position = vec3( entity.position.x, v.aabb.max.y + ebbhe.y, entity.position.z );
				entity.velocity.y = -entity.velocity.y * 0.8;
			}
		}
		else {
			v = voxelAt(evc + VoxelCoord(0,1,0));
			if( v.type > Chunk.VoxelType.Air && v.aabb.intersects(ebb) ) {
				entity.position = vec3( entity.position.x, v.aabb.min.y - ebbhe.y, entity.position.z );
				entity.velocity.y = -entity.velocity.y * Bouncyness;
			}
		}
		
		if( entity.velocity.x < 0 ) {
			v = voxelAt(evc + VoxelCoord(-1,0,0));
			if( v.type > Chunk.VoxelType.Air && v.aabb.intersects(ebb) ) {
				entity.position = vec3( v.aabb.max.x + ebbhe.x, entity.position.y, entity.position.z );
				entity.velocity.x = -entity.velocity.x * Bouncyness;
			}
		}
		else {
			v = voxelAt(evc + VoxelCoord(1,0,0));
			if( v.type > Chunk.VoxelType.Air && v.aabb.intersects(ebb) ) {
				entity.position = vec3( v.aabb.min.x - ebbhe.x, entity.position.y, entity.position.z );
				entity.velocity.x = -entity.velocity.x * Bouncyness;
			}
		}

		if( entity.velocity.z < 0 ) {
			v = voxelAt(evc + VoxelCoord(0,0,-1));
			if( v.type > Chunk.VoxelType.Air && v.aabb.intersects(ebb) ) {
				entity.position = vec3( entity.position.x, entity.position.y, v.aabb.max.z + ebbhe.z);
				entity.velocity.z = -entity.velocity.z * Bouncyness;
			}
		}
		else {
			v = voxelAt(evc + VoxelCoord(0,0,+1));
			if( v.type > Chunk.VoxelType.Air && v.aabb.intersects(ebb) ) {
				entity.position = vec3( entity.position.x, entity.position.y, v.aabb.min.z - ebbhe.z);
				entity.velocity.z = -entity.velocity.z * Bouncyness;
			}
		}

	}

}
