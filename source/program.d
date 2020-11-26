module program;

// import derelict.opengl3.gl3;
import derelict.opengl;
import std.stdio;
import shader;

class Program {
	private bool _linked = false;
	private uint _id;

	this(Shader vertexShader, Shader fragmentShader) {
		init();
		addShader(vertexShader);
		addShader(fragmentShader);
		link();
	}

	this() {
		init();
	}

	void init() {
		_id = glCreateProgram();
	}

	~this() {
		destroy();
	}

	void destroy() {
		if(!linked()) return;
		_linked = false;
		glDeleteProgram(_id);
	}

	bool addShader(Shader shader) {
		if(!shader.compiled()) return false;
		glAttachShader(_id, shader.id);
		return true;
	}

	void link() {
		glLinkProgram(_id);
		int status;
		glGetProgramiv(_id, GL_LINK_STATUS, &status);
		_linked = ( status == GL_TRUE );
		debugOutput();
	}

	uint getUniformId( string name ) {
		return glGetUniformLocation( _id, name.ptr );
	}


	void debugOutput() {
		writeln( "Program linked : ", _linked );
	}

	void use() {
		if(linked()) 
			glUseProgram(_id);
	}

	bool linked() {
		return _linked;
	}

	uint id() {
		return _id;
	}
}
