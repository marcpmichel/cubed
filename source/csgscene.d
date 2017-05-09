
import scene;
import mesh;
import geometry;
import csg.polygon, csg.vertex, csg.plane, csg.cube;
import geometries.csgconverter;
import camera;
import sun;
import gl3n.linalg;
import csg.csg;
import material;

class CSGScene : Scene {

	Mesh[] _meshes;
	Geometry csgGeom, triangleGeom;
	Material mat1, mat2;
	Camera _cam;
	Sun _sun;

	this() {
		// _cam = new ZoomAroundCamera( vec3(0,0,0), 5, 1);
		_cam = new FPCamera( vec3(1,1.8,1));
		_sun = new Sun( vec3(0.2,0.6,0.8).normalized );

		mat1 = new Material(vec3(.8,.6,.2));
		mat2 = new Material(vec3(0,0,1));

		// initTruncateTest();
		// initSubtractTest();
		// initIntersectTest();
		// initMergeTest();
		initCorridor2Test();

		_cam.update(0.80);
	}

	@property Camera cam() { return _cam; }
	@property Sun sun() { return _sun; }
	@property Mesh[] meshes() { return _meshes; }

	float y=0, dy=0.01;

	override void update() {
		_cam.update(0.01);
		// _sun.update(0.01);
		
		foreach( ref m; _meshes ) {
			// m._mat.rotatey(0.01);
			//m._mat.rotatez(0.005);
		}
	}


	void addMesh( CSGConverter geom, Material mat = null, vec3 pos = vec3(0,0,0)) {

		Mesh mesh;
		if( mat is null ) mesh = new Mesh(geom);
		else mesh = new Mesh(geom, mat );

		mesh.setPosition( pos );
		_meshes ~= mesh;
	}


	CSG csg1, csg2;

	void initSubtractTest() {
		CSG csg1 = new csg.cube.Cube().csg;
		CSG csg2 = new csg.cube.Cube(vec3(0.5,0.5,0.5), vec3(1,1,1)).csg;
		CSG sub = csg1.substract(csg2);

		addMesh( new CSGConverter(sub));
	}

	void initIntersectTest() {
		CSG csg1 = new csg.cube.Cube().csg;
		CSG csg2 = new csg.cube.Cube(vec3(0.5,0.5,0.5), vec3(1,1,1)).csg;
		CSG inter = csg1.intersect(csg2);

		addMesh( new CSGConverter(inter));
	}

	void initMergeTest() {
		CSG csg1 = new csg.cube.Cube(vec3(0,0,0), vec3(2,2,2)).csg;
		CSG csg2 = new csg.cube.Cube(vec3(0.0,1.0,0.0), vec3(1,1,1)).csg;
		CSG merged = csg1.merge(csg2);

		addMesh( new CSGConverter(merged));
	}

	void initTruncateTest() {

		CSG csg1 = new csg.cube.Cube().csg;
		//CSG merge = csg1.merge(csg2);
		//CSG inter = csg1.intersect(csg2);
		CSG[] fb1 = csg1.truncate(new Plane( vec3(0,1,0), 0.25 ) );
		_meshes ~= new Mesh(new CSGConverter(fb1[0]), mat1);
		_meshes[$-1].setPosition(0.0,0.2,0.0);
		_meshes ~= new Mesh(new CSGConverter(fb1[1]), mat2);


		CSG[] fb2 = csg1.truncate(new Plane( vec3(0,0,1), 0.25 ) );
		_meshes ~= new Mesh(new CSGConverter(fb2[0]), mat1);
		_meshes[$-1].setPosition(2,0,0.2);
		_meshes ~= new Mesh(new CSGConverter(fb2[1]), mat2);
		_meshes[$-1].setPosition(2,0,0);

		CSG[] fb3 = csg1.truncate(new Plane( vec3(1,0,1), 0.25 ) );
		_meshes ~= new Mesh(new CSGConverter(fb3[0]), mat1);
		_meshes[$-1].setPosition(-1.8,0.0,0.2);
		_meshes ~= new Mesh(new CSGConverter(fb3[1]), mat2);
		_meshes[$-1].setPosition(-2,0,0);

		/*
		_meshes ~= new Mesh(new CSGConverter(merge));
		_meshes[1].setPosition( vec3( 0,0,-2));
		_meshes ~= new Mesh(new CSGConverter(inter));
		_meshes[2].setPosition( vec3( 1,1,0));
		*/
	}

	void initCorridorTest() {
		CSG csg1 = new csg.cube.Cube(vec3(0,0,0), vec3(2,2,2)).csg;
		CSG csg2 = new csg.cube.Cube(vec3(1,-.5,0), vec3(2,1,.5)).csg;
		auto csg3 = new csg.cube.Cube(vec3(3,0,1), vec3(3,2,3)).csg;
		auto col = new csg.cube.Cube(vec3(3,0,1), vec3(.5,2,.5)).csg;
		CSG sub = csg1.merge(csg2).merge(csg3).substract(col);
		addMesh( new CSGConverter(sub.inverse));
	}

	void initCorridor2Test() {
		CSG chunk = new csg.cube.Cube(vec3(-1,-1,-1), vec3(16,16,16)).csg;
		CSG room1 = new csg.cube.Cube(vec3(0,0,0), vec3(6,5,8)).csg;
		CSG doorway = new csg.cube.Cube(vec3(6,0,1), vec3(1,2.5,2)).csg;
		CSG room2 = new csg.cube.Cube(vec3(7,0,0), vec3(4,5,4)).csg;
		CSG room3 = new csg.cube.Cube(vec3(12,0,0), vec3(2,5,12)).csg;
		CSG doorway2 = new csg.cube.Cube(vec3(11,0,1), vec3(1,2.5,2)).csg;
		CSG doorway3 = new csg.cube.Cube(vec3(14,0,1), vec3(1,2.5,2)).csg;
		CSG corridor = room1.merge(room2).merge(room3).merge(doorway).merge(doorway2).merge(doorway3);
		addMesh( new CSGConverter(chunk.substract(corridor)), mat1 );
	}

}
