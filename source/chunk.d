
import geometry;
import std.stdio: write, writeln, writefln;
import core.exception;
import gl3n.linalg;
import gl3n.aabb;
import noise;
import mesh;

alias Vector!(int, 2) ChunkCoord;
alias Vector!(int, 3) VoxelCoord;
alias Vector!(float, 3) WorldCoord;

VoxelCoord toVoxelCoord(WorldCoord pos) {
	return VoxelCoord( cast(int)(pos.x+.5), cast(int)(pos.y+.5), cast(int)(pos.z+.5) );
}

VoxelCoord toLocalVoxelCoord(WorldCoord pos) {
	return VoxelCoord( 
		cast(int)pos.x % (Chunk.Width - 1),
		cast(int)pos.y,
		cast(int)pos.z % (Chunk.Length - 1));
}

VoxelCoord toLocal( VoxelCoord pos ) {
	return VoxelCoord( pos.x % ( Chunk.Width - 1 ),
		pos.y,
		pos.z % ( Chunk.Length - 1 ));
}

struct Voxel {
	Chunk.VoxelType type;
	AABB aabb;
}

class Chunk: Mesh {

	//enum Type { Empty, Full, Flat, Noise }
	enum Width = 32, Height = 32, Length = 32;
	enum VoxelType:byte { Invalid=-1, Air, Stone }

	VoxelType[Width][Height][Length] voxels;
	float[] vertices;
	uint[] elements;
	uint voxelsCount;
	ChunkCoord position;
	ulong trianglesCount;
	ulong verticesCount;
	ulong facesCount;

	this(ChunkCoord a_position) { //, Type type = Type.Noise, bool doBuildGeometry = true ) {
		super();
		position = a_position;

		/*
		switch(type) {
			case Type.Empty: break;
			case Type.Full: initVoxelsFlat(Height); break;
			case Type.Flat: initVoxelsFlat(1); break;
			case Type.Noise: initVoxelsNoise(); break;
			default: initVoxelsFlat(1);
		}

		if( doBuildGeometry )
			buildGeometry();
		*/
		
	}

	void buildGeometry() {
		buildVertices();

		verticesCount = vertices.length;
		facesCount = elements.length / 6;
		trianglesCount = elements.length /3;

		setGeometry(new Geometry(vertices, elements));
	}

	/*
	bool voxelPresent( WorldCoord wc ) {
		auto vc = wc.toVoxelCoord - VoxelCoord(position.x,0, position.y);
		return voxelPresent(vc.x, vc.y, vc.z);
	}
	*/
	
	bool voxelPresent(VoxelCoord vc) {
		return voxelPresent(vc.x, vc.y, vc.z );
	}

	bool voxelPresent(uint x, uint y, uint z) {
		if( x < 0 || y < 0 || z < 0 ) return false;
		if( x >= Width || y >= Height || z >= Length ) return false;

		if(voxels[x][y][z] > 0) return true;
		return false;
	}

	void buildVertices() {
		for(int i=0; i<Width; i++) {
			for(int j=0; j<Height; j++) {
				for(int k=0; k<Length; k++) {
					if( voxelPresent(i,j,k)) {
						if( !isSurrounded(i,j,k) )
							buildVerticesForOneCube(i,j,k);
					}
				}
			}
		}
	}

	bool isSurrounded(int i, int j, int k) {

		if( j == 0 ) {
			if(voxelPresent(i-1,j,k) &&
					voxelPresent(i+1, j, k) &&
					voxelPresent(i, j+1, k) &&
					voxelPresent(i, j, k-1) &&
					voxelPresent(i, j, k+1))
				return true;
			else
				return false;
		}

		if(voxelPresent(i-1,j,k) &&
			voxelPresent(i+1, j, k) &&
			voxelPresent(i, j+1, k) &&
			voxelPresent(i, j-1, k) &&
			voxelPresent(i, j, k-1) &&
			voxelPresent(i, j, k+1))
			return true;
		return false;
	}

	Voxel voxelAt( /* world */ VoxelCoord vc ) {
		if( vc.y > (Chunk.Height-1) || vc.y < 0 ) return Voxel(Chunk.VoxelType.Invalid);
		return Voxel(
			voxels[vc.x % (Width-1)][vc.y % (Height-1)][vc.z % (Length-1)], 
			AABB( vec3(vc.x-0.5,vc.y-0.5,vc.z-0.5), vec3(vc.x+0.5,vc.y+0.5,vc.z+0.5) )
		);
	}

	AABB voxelAABB( /* world */ VoxelCoord vc ) {
		return AABB( vec3(vc.x-0.5,vc.y-0.5,vc.z-0.5), vec3(vc.x+0.5,vc.y+0.5,vc.z+0.5) );
	}

	VoxelType voxelType( /*local*/ VoxelCoord vc ) {
		return voxels[vc.x][vc.y][vc.z];
	}

/*
	AABB voxelAABB( vec3 world_coords ) {
		return voxelAABB( worldToVoxelAbs(world_coords)); 
	}
*/

	vec3 voxelToWorld(int i, int j, int k) {
		return vec3( i + Width * position.x, j, k + Length * position.y );
	}

/*
	VoxelCoord worldToVoxelAbs( vec3 worldPos ) {
		return VoxelCoord(
			cast(int)worldPos.x, //  % (Width-1),
			cast(int)worldPos.y, // % (Height-1),
			cast(int)worldPos.z // % (Length-1)
		);
	}

	VoxelCoord worldToVoxelRel( vec3 worldPos ) {
		return VoxelCoord(
			cast(int)worldPos.x % (Width-1),
			cast(int)worldPos.y % (Height-1),
			cast(int)worldPos.z % (Length-1)
		);
	}
*/

	void buildVerticesForOneCube(int i, int j, int k) {
		vec3 vp = voxelToWorld(i,j,k);

		uint vcount = cast(uint)vertices.length/3;
		vertices ~= [ 
			-0.5 + vp.x, -0.5 + vp.y, -0.5 + vp.z,
			 0.5 + vp.x, -0.5 + vp.y, -0.5 + vp.z,
			 0.5 + vp.x,  0.5 + vp.y, -0.5 + vp.z,
			-0.5 + vp.x,  0.5 + vp.y, -0.5 + vp.z,
			-0.5 + vp.x, -0.5 + vp.y,  0.5 + vp.z,
			 0.5 + vp.x, -0.5 + vp.y,  0.5 + vp.z,
			 0.5 + vp.x,  0.5 + vp.y,  0.5 + vp.z,
			-0.5 + vp.x,  0.5 + vp.y,  0.5 + vp.z
				];
				/*
		elements ~= [
			vcount + 0, vcount + 1, vcount + 2,
				   vcount + 2, vcount + 3, vcount + 0,
				   vcount + 3, vcount + 2, vcount + 6,
				   vcount + 6, vcount + 7, vcount + 3,
				   vcount + 7, vcount + 6, vcount + 5,
				   vcount + 5, vcount + 4, vcount + 7,
				   vcount + 4, vcount + 5, vcount + 1,
				   vcount + 1, vcount + 0, vcount + 4,
				   vcount + 4, vcount + 0, vcount + 3,
				   vcount + 3, vcount + 7, vcount + 4,
				   vcount + 1, vcount + 5, vcount + 6,
				   vcount + 6, vcount + 2, vcount + 1
					   ];
					   */
			if( /* k > 0 && */ !voxelPresent(i,j,k-1)) 
				elements ~= [ vcount +0, vcount +1, vcount +2, vcount +2, vcount + 3, vcount + 0 ];
			if( /* k < Length - 1 && */ !voxelPresent(i,j,k+1)) 
				elements ~= [ vcount +7, vcount +6, vcount +5, vcount +5, vcount + 4, vcount + 7 ];
			if( /* i > 0 && */ !voxelPresent(i-1,j,k)) 
				elements ~= [ vcount +4, vcount +0, vcount +3, vcount +3, vcount + 7, vcount + 4 ];
			if( /* i < Width -1 &&  */ !voxelPresent(i+1,j,k)) 
				elements ~= [ vcount +1, vcount +5, vcount +6, vcount +6, vcount + 2, vcount + 1 ];
			if( /* j > 0 && */ !voxelPresent(i,j-1,k)) 
				elements ~= [ vcount +4, vcount +5, vcount +1, vcount +1, vcount + 0, vcount + 4 ];
			if( /* j < Height -1 && */ !voxelPresent(i,j+1,k)) 
				elements ~= [ vcount +3, vcount +2, vcount +6, vcount +6, vcount + 7, vcount + 3 ];
	}

}

class NoiseChunk: Chunk {
	this(ChunkCoord a_position, bool doBuildGeometry = true ) {
		super(a_position);

		initVoxels();
		
		if( doBuildGeometry ) buildGeometry();
	}

	override
	bool voxelPresent(uint x, uint y, uint z) {
		if( y < 0 || y >= Height - 1 ) return false;
		if( x < 0 || z < 0 || x >= Width || z >= Length ) {
			//if( noiseHeight(x,z) > cast(float)y/Height) return true;
			return isUnderNoise(x,y,z);
		}

		if(voxels[x][y][z] > 0) return true;
		return false;
	}

	bool isUnderNoise( uint x, uint y, uint z ) {
		if( noiseHeight(x,z) > cast(float)y/Height) return true;
		return false;
	}

	float noiseHeight(int x, int y) {
		float nx = position.x + cast(float)x/Width;
		float ny = position.y + cast(float)y/Length;
		return (theNoise.perlin(nx,ny) + 1.0)/2.0;
	}

	void initVoxels() {

		for( int i=0; i<Width; i++) {
			for(int k=0; k<Length; k++) {

				//float x = position.x + cast(float)i/Width;
				//float y = position.y + cast(float)k/Length;
				float noise = noiseHeight(i,k); // (theNoise.perlin(x,y) + 1.0)/2.0;

				for( int j=0; j<Height; j++ ) {
					if( isUnderNoise(i,j,k) ) {
					//float h = (cast(float)j)/Height;
					//if( h <= noise ) { 
						voxels[i][j][k] = VoxelType.Stone;
						voxelsCount++;
					}
				}
			}
		}
	}
}


class FilledChunk: Chunk {
	this(ChunkCoord a_position, uint height, bool doBuildGeometry = true ) {
		super(a_position);
		if(height > Chunk.Height-1) height = Chunk.Height - 1;
		initVoxels(height);
		if(doBuildGeometry) buildGeometry();
	}

	void initVoxels(uint height) {
		for( int i=0; i<Width; i++) {
			for( int j=0; j<height; j++ ) {
				for(int k=0; k<Length; k++) {
					voxels[i][j][k] = VoxelType.Stone;
					voxelsCount++;
				}
			}
		}
	}
}


