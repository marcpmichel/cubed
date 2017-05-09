
import derelict.opengl3.gl3;

class GBuffer {

	uint fbo;
	uint diffuseTexture;
	uint positionTexture;
	uint depthTexture;

	enum WindowWidth = 800;
	enum WindowHeight = 600;

	this() {
		glGenFramebuffers(1, &fbo); 
		glBindFramebuffer(GL_DRAW_FRAMEBUFFER, fbo);

		// diffuse
		glGenTextures(1, &diffuseTexture);
		glBindTexture(GL_TEXTURE_2D, diffuseTexture);
		glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB32F, WindowWidth, WindowHeight, 0, GL_RGB, GL_FLOAT, null);
		glFramebufferTexture2D(GL_DRAW_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, diffuseTexture, 0);

		// position
		glGenTextures(1, &positionTexture);
		glBindTexture(GL_TEXTURE_2D, positionTexture);
		glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB32F, WindowWidth, WindowHeight, 0, GL_RGB, GL_FLOAT, null);
		glFramebufferTexture2D(GL_DRAW_FRAMEBUFFER, GL_COLOR_ATTACHMENT1, GL_TEXTURE_2D, positionTexture, 0);

		glDrawBuffers(2, [ GL_COLOR_ATTACHMENT0, GL_COLOR_ATTACHMENT1 ].ptr);


		// depth
		glGenTextures(1, &depthTexture);
	    glBindTexture(GL_TEXTURE_2D, depthTexture);
		glTexImage2D(GL_TEXTURE_2D, 0, GL_DEPTH_COMPONENT32F, WindowWidth, WindowHeight, 0, GL_DEPTH_COMPONENT, GL_FLOAT, null);
		glFramebufferTexture2D(GL_DRAW_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_TEXTURE_2D, depthTexture, 0);


		glBindFramebuffer(GL_DRAW_FRAMEBUFFER, 0);
	}

	~this() {
		glDeleteFramebuffers(1, &fbo);
		glDeleteTextures(1, &diffuseTexture);
		glDeleteTextures(1, &positionTexture);
		glDeleteTextures(1, &depthTexture);
	}

	void bindForWriting() {
		glBindFramebuffer(GL_DRAW_FRAMEBUFFER, fbo);
	}

	void bindForReading() {
		glBindFramebuffer(GL_READ_FRAMEBUFFER, fbo);
	}

	void setReadBuffer( uint bufferNum ) {
		glReadBuffer( GL_COLOR_ATTACHMENT0 + bufferNum );
	}


}
