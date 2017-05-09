
import sun;
import camera;
import scene;
import chunk;
import gl3n.linalg;
import gl3n.aabb;
import mesh;
import entity;
import geometries.player;
import chunkmanager;

class VoxelScene: Scene {

	Camera _cam;
	Sun _sun;
	Mesh[] _meshes;
	Entity _player;
	ChunkManager theChunkManager;

	this() {
		//_cam = new RotateAroundCamera(vec3(0,0,0), 60, 20 );
		_cam = new FlyCamera( vec3(2000,40,2000));
		_sun = new Sun(vec3(0.2,0.4,0.6).normalized);
		
		theChunkManager = new ChunkManager;

		_player = new Entity( new Mesh( new PlayerGeom() ), vec3(2000,31,2016)); 
		_player.velocity = vec3(-0.03,0,0.03);
		_meshes ~= _player.mesh;
	}

	@property Camera cam() { return _cam; }
	@property Sun sun() { return _sun; }
	@property Mesh[] meshes() { return theChunkManager.meshes ~ _meshes; }

	void update() {
		theChunkManager.update(_cam.position);
		update_physics();
	}

	/*
	bool entityCollideVoxel( Entity entity, VoxelCoord rvc, ref AABB vbb ) {
			auto pbb = entity.mesh.aabb;
			auto pvc = entity.position.toVoxelCoord;

			auto vc = pvc + rvc;
			auto vt = theChunkManager.voxelTypeAt(vc);
			vbb = theChunkManager.voxelAABB(vc);

			if(vt == Chunk.VoxelType.Stone && vbb.intersects(pbb)) 
				return true;

			return false;
	}
	*/

	void update_physics() {
		vec3 gravity = vec3( 0, -0.0981, 0 );
		_player.velocity.y = _player.velocity.y + gravity.y / 16.66;

		theChunkManager.collide( _player );
		
		/*

		if( theChunkManager.chunkAt(_player.position) !is null ) {
			_player.position = _player.position + _player.velocity;

			AABB vbb;

			while( entityCollideVoxel( _player, VoxelCoord(0,0,0), vbb)){
				_player.position = vec3( _player.position.x, vbb.max.y + _player.mesh.aabb.half_extent.y, _player.position.z);
			}

			if( entityCollideVoxel( _player, VoxelCoord(0,-1,0), vbb )) {
				_player.position = vec3( _player.position.x, vbb.max.y + _player.mesh.aabb.half_extent.y, _player.position.z);
				_player.velocity.y = -_player.velocity.y * 0.8;
			}

			if( entityCollideVoxel( _player, VoxelCoord(0,0,1), vbb )) {
				_player.position = vec3( _player.position.x, _player.position.y, vbb.min.z - _player.mesh.aabb.half_extent.z);
				_player.velocity.z = -_player.velocity.z; //  / 2.0;
			}

			if( entityCollideVoxel( _player, VoxelCoord(0,0,-1), vbb )) {
				_player.position = vec3( _player.position.x, _player.position.y, vbb.max.z + _player.mesh.aabb.half_extent.z);
				_player.velocity.z = -_player.velocity.z; // / 2.0;
			}

			if( entityCollideVoxel( _player, VoxelCoord(-1,0,0), vbb )) {
				_player.position = vec3( vbb.max.x + _player.mesh.aabb.half_extent.x, _player.position.y, _player.position.z );
				_player.velocity.x = -_player.velocity.x; // / 2.0;
			}

			if( entityCollideVoxel( _player, VoxelCoord(1,0,0), vbb )) {
				_player.position = vec3( vbb.min.x - _player.mesh.aabb.half_extent.x, _player.position.y, _player.position.z );
				_player.velocity.x = -_player.velocity.x; // / 2.0;
			}

		}
			*/
	}

}

