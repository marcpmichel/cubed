
import derelict.opengl;
import program;
import shader;
import gl3n.linalg;
import scene;
import gl3n.frustum;
import gl3n.aabb;

class Renderer {

	Program mainProgram;
	ShaderLibrary theShaderLibrary;

	mat4 projectionMatrix = mat4.perspective(800,600,70,0.1,200);
	mat4 viewMatrix = mat4.look_at( vec3(0,0,-5), vec3(0,0,0), vec3(0,1,0) );
	mat4 modelMatrix = mat4.identity;

	int viewMatrixId, projectionMatrixId, modelMatrixId;
	int meshColorId;
	int sunDirId, sunColorId;

	this() {
		loadShaders();
		buildProgram();
		setup();
	}

	void setup() {
		glEnable(GL_CULL_FACE);
		glFrontFace(GL_CW);
		glEnable(GL_DEPTH_TEST);
		glClearDepth(1.0);

		glClearColor(0.1f, 0.2f, 0.3f, 1.0f);
	}

	void loadShaders() {
		theShaderLibrary = new ShaderLibrary();
	}

	void buildProgram() {
		mainProgram = new Program( theShaderLibrary.get("cam"), theShaderLibrary.get("flat"));

		meshColorId = mainProgram.getUniformId("in_color");
		viewMatrixId = mainProgram.getUniformId("viewMatrix");
		projectionMatrixId = mainProgram.getUniformId("projectionMatrix");
		modelMatrixId = mainProgram.getUniformId("modelMatrix");
		sunDirId = mainProgram.getUniformId("sundir");
		sunColorId = mainProgram.getUniformId("suncolor");
		//sunAmbientId = mainProgram.getUniformId("ambient");

		mainProgram.use();
	}
	
	void render(Scene theScene) {

		glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT );

		glUniformMatrix4fv(viewMatrixId, 1, GL_TRUE, theScene.cam.matrix.value_ptr);
		glUniformMatrix4fv(projectionMatrixId, 1, GL_TRUE, projectionMatrix.value_ptr);
		glUniform3fv(sunDirId, 1, theScene.sun.direction.value_ptr );
		glUniform3fv(sunColorId, 1, theScene.sun.color.value_ptr );

		mat4 viewProjectionMatrix = projectionMatrix * theScene.cam.matrix;
		auto frustum = Frustum(viewProjectionMatrix);

		foreach( mesh; theScene.meshes ) {
			//auto frustum = Frustum(viewProjectionMatrix * mesh.matrix);
			if( frustum.intersects(mesh.aabb)) {
				glUniform3fv( meshColorId, 1, mesh.color.value_ptr );
				glUniformMatrix4fv(modelMatrixId, 1, GL_TRUE, mesh.matrix.value_ptr);
				mesh.render();
			}
		}
	}

}
