
import chunk;
import specd.specd;
import gl3n.linalg;
import gl3n.aabb;

version(specrunner) unittest {

	auto chunk = new FilledChunk(ChunkCoord(2,2), 1, false);

	describe("chunk basic properties").as( (it) {
		it.should("have a position", 
			(chunk.position.must.equal(ChunkCoord(2,2)) ) );
	});


	describe("chunk detection").as( (it) {
		it.should("detect a solid voxel", 
			//chunk.voxels[0][0][0].must.equal(1)
			chunk.voxelPresent(VoxelCoord(0,0,0)).must.equal(true) 
		);
		it.should("not detect an air voxel", 
			//chunk.voxels[0][0][0].must.equal(1)
			chunk.voxelPresent(VoxelCoord(0,1,0)).must.equal(false) 
		);
	});

	describe("chunk coordinates").as( (it) {

		it.should("convert a world position to an absolute voxel coordinate", 
			vec3(32.5,64.2,96.7).toVoxelCoord.must.equal(VoxelCoord(32,64,96)) 
		);

		it.should("convert a voxel coordinate to a world position", 
			chunk.voxelToWorld(0,2,1).must.equal(vec3(64,2,65)) 
		);

		it.should("compute a voxel AABB", 
			chunk.voxelAABB(vec3(0,0,0).toVoxelCoord).must.equal(AABB(vec3(-.5,-.5,-.5), vec3(.5,.5,.5) ))
		);
		it.should("compute a voxel AABB", 
			chunk.voxelAABB(vec3(1,1,1).toVoxelCoord).must.equal(AABB(vec3(.5,.5,.5), vec3(1.5,1.5,1.5) ))
		);

	});

}
