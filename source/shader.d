module shader;

import derelict.opengl3.gl3;
import std.file;
import std.stdio;
import std.algorithm;
import std.path : baseName;
import std.conv : to;

class Shader {
	private bool _compiled;
	private uint _id;
	private string _filename;
	enum logBufLength = 1024;
	private char[logBufLength] _log;

	this(uint gl_type) {
		_id = glCreateShader(gl_type);
	}
	~this() {
		destroy();
	}

	void destroy() {
		if(!compiled()) return;
		_compiled = false;
		glDeleteShader(_id);
	}

	@property
	void source(string src) {
		upload(cast(char[])src);
	}

	void load(string filename) {
		_filename = filename;
		auto source = cast(char[])std.file.read(_filename);
		upload(source);
	}

	void upload(char[] source) {
		auto ss = &source[0];
		int slen = cast(int)source.length;
		glShaderSource(_id, 1, &ss, &slen);
		compile();
	}

	bool compile() {
		glCompileShader(_id);
		int gl_status;
		glGetShaderiv(_id, GL_COMPILE_STATUS, &gl_status);
		_compiled = ( gl_status == GL_TRUE );
		if(!_compiled) glGetShaderInfoLog(_id, logBufLength, null, _log.ptr );
		debugOutput();
		return _compiled;
	}

	void debugOutput() {
		if(_compiled)
			writeln( "shader '", _filename, "' compiled");
		else {
			writeln( "warning: shader '", _filename, "' NOT compiled !");
			writeln( "gl error:", to!string(_log) );
		}
	}

	uint id() {
		return _id;
	}

	bool compiled() {
		return _compiled;
	}

	string log() {
		return _log.dup;
	}

}

class VertexShader: Shader {
	this() {
		super(GL_VERTEX_SHADER);
	}
}

class FragmentShader: Shader {
	this() {
		super(GL_FRAGMENT_SHADER);
	}
}

class ShaderLibrary {
	Shader[string] shaders;

	this() {
		string basePath = "./shaders/";
		loadAll!FragmentShader(basePath ~ "frag" );
		loadAll!VertexShader(basePath ~ "vert" );

	}

	int loadAll(T)(string path) {
		int loaded_count;
		Shader shader;
		auto glslFiles = filter!`endsWith(a.name,".glsl")`(dirEntries(path,SpanMode.depth));
		foreach(file; glslFiles) {
			shader = new T();
			shader.load(file.name);
			if(shader.compiled()) {
				this.add( file.name, shader );
				loaded_count++;
			}
		}
		return loaded_count;
	}

	void add(string name, Shader shader) {
		name = baseName(name, ".glsl");
		shaders[name] = shader;
	}

	Shader get(string name) {
		Shader* p;
		if(	(name in shaders) is null ) {
			writeln(name, " not found in loaded shaders" );
			return shaders["default_vert"];
		}
		else {
			return shaders[name];
		}
	}
}

