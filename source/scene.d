
import mesh;
import camera;
import sun;

interface Scene {

	void update();

	@property Mesh[] meshes();
	@property Sun sun();
	@property Camera cam();
}
