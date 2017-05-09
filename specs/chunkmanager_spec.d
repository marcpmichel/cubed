
import specd.specd;
import chunkmanager;
import chunk;
import gl3n.linalg;
import gl3n.aabb;

version(specrunner) unittest {

	// create a chunkManager with a flat chunk with 1 layer of voxels at (2,2) :
	ChunkManager chunkManager = new ChunkManager();
	auto coord = ChunkCoord(2,2);
	chunkManager.chunks[chunkManager.chunkName(coord)] = new FilledChunk(coord, 1, false);
	auto voxel_present_coords = vec3( Chunk.Width * 2, 0, Chunk.Length * 2 );
	auto voxel_absent_coords = vec3( Chunk.Width * 2, 1, Chunk.Length * 2 );
	auto above_any_voxel_coords = vec3( Chunk.Width * 2, Chunk.Height + 1, Chunk.Length * 2 );
	auto no_chunk_there_coords = vec3( 0, 0, 0 );
	auto aabb_2_0_2 = AABB(
		voxel_present_coords - vec3(.5,.5,.5),
		voxel_present_coords + vec3(.5,.5,.5) );

	describe("chunkmanager").as( (it) {
		it.should("have a chunk at (2,2)",
			chunkManager.chunkAt(voxel_present_coords).must.not.be.Null
		);
		it.should("not have a chunk at (1,1)",
			chunkManager.chunkAt(no_chunk_there_coords).must.be.Null
		);
		it.should("have a voxel present at (2,0,2)",
			chunkManager.voxelPresent(voxel_present_coords).must.be.True
		);
		it.should("not have a voxel present when there's not chunk",
			chunkManager.voxelPresent(no_chunk_there_coords).must.be.False
		);
		it.should("reply false for a voxel above the maximum voxel height",
			chunkManager.voxelPresent(above_any_voxel_coords).must.be.False
		);
		it.should("not have a voxel present at (2,1,2)",
			chunkManager.voxelPresent(voxel_absent_coords).must.be.False
		);
		it.should("return an AABB for a present Voxel",
			chunkManager.voxelAABB(voxel_present_coords).must.equal(aabb_2_0_2)
		);
//		it.should("fetch above/below/right/left voxels given a world position", 
//			(chunkmanager.voxelsAround(vec3(1,1,1)).must.equal() ) );
	});

}
