
import std.stdio: writeln;
import derelict.glfw3.glfw3;
import derelict.opengl;
import inputmanager;
import renderer;
import scene;
import csgscene;
import testscene;
import voxelscene;

Scene theScene;
Renderer theRenderer;
InputManager theInputManager;

enum Viewport { WIDTH = 1280, HEIGHT = 720 };
GLFWwindow* window;

void init() {
	DerelictGL3.load();
	DerelictGLFW3.load();

	if (!glfwInit()) return;

  // force gl version to 3.2
  glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
  glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 2);
  glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);
  glfwWindowHint(GLFW_OPENGL_FORWARD_COMPAT, GL_TRUE);
  
	window = glfwCreateWindow(Viewport.WIDTH, Viewport.HEIGHT, "CubeD", null, null);

	if (!window) { glfwTerminate(); return; }
	
	glfwMakeContextCurrent(window); // Make the window's context current
	glfwSwapInterval(1);

	theInputManager = new InputManager(window);

	GLVersion glver = DerelictGL3.reload(); //	for gl context something
	writeln( "GLversion :", glver);

	theRenderer = new Renderer();
	// theScene = new CSGScene();
	// theScene = new TestScene();
	theScene = new VoxelScene();

}

void loop() {
	while (!glfwWindowShouldClose(window)) {
		theScene.update;
		theRenderer.render( theScene );
		checkGLError(__FILE__, __LINE__);
		glfwSwapBuffers(window);
		glfwPollEvents();
		theInputManager.update();
	}
	glfwTerminate();
}

void checkGLError(string filename, int line) {
	uint err = glGetError();
	if(err == GL_NO_ERROR) return;
	string errstr;
	switch(err) {
		case GL_INVALID_ENUM: errstr="GL_INVALID_ENUM"; break;
		case GL_INVALID_VALUE: errstr="GL_INVALID_VALUE"; break;
		case GL_INVALID_OPERATION: errstr="GL_INVALID_OPERATION"; break;
		case GL_OUT_OF_MEMORY: errstr="GL_OUT_OF_MEMORY"; break;
		default: errstr = "unknown error !";
	}
	writeln("GL Error : ", errstr, "(", filename, " : ", line, ")");
}
