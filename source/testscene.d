
import scene;
import geometry;
import geometries.cube;
import geometries.quad;
import geometries.triangle;
import geometries.tetra;
import geometries.ground;
import mesh;
import material;
import gl3n.linalg;
import camera;
import sun;

class TestScene: Scene {

	Geometry triangleGeom, quadGeom, cubeGeom, tetraGeom, groundGeom;
	//RotateAroundCamera _cam;
	FPCamera _cam;
	Sun _sun;
	Mesh[] _meshes;

	this() {
		//_cam = new RotateAroundCamera( vec3(0,0,0), 6, 2);
		_cam = new FPCamera( vec3(0,0,-5));
		_sun = new Sun(vec3(1,0.8,0.8).normalized);

		triangleGeom = new Triangle();
		quadGeom = new Quad();
		cubeGeom = new Cube();
		tetraGeom = new Tetra();
		groundGeom = new Ground();

		initMeshes();
	}

	@property Camera cam() { return _cam; }
	@property Sun sun() { return _sun; }
	@property Mesh[] meshes() { return _meshes; }

	override void update() {
		_cam.update(0.001);
		//sun.update(0.002);
	}

	void initMeshes() {
		_meshes ~= new Mesh( cubeGeom );
		_meshes ~= new Mesh( cubeGeom );
		_meshes ~= new Mesh( cubeGeom );
		_meshes ~= new Mesh( cubeGeom );
		_meshes ~= new Mesh( tetraGeom );
		_meshes ~= new Mesh( groundGeom, new Material(vec3(0.6,0.6,0.6)) );

		_meshes[0].setPosition(1,1,-1);
		_meshes[1].setPosition(-1,3,-1);
		_meshes[2].setPosition(1,3,-1);
		_meshes[3].setPosition(-1,1,-1);
		_meshes[4].setPosition(0,1,0);
		_meshes[5].setPosition(0,-1,0);
	}

}
