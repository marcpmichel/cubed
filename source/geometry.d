
module geometry;
import derelict.opengl3.gl3;
import std.math;
import std.stdio;
import gl3n.linalg;
import gl3n.aabb;

class Geometry {

	enum PositionAttrib = 0;
	uint vao, vbo, ebo;
	uint elements_count;
	AABB aabb;

	void load( string filename ) {
		// parses a file
		// into vertex and elements data
		setup([], []);
	}

	this() {};

	this( float[] vertices, uint[] elements ) {
		setup(vertices, elements);
	}

	void setup( float[] vertices, uint[] elements ) {

		glGenVertexArrays(1, &vao);
		glBindVertexArray(vao);

		glGenBuffers(1, &vbo);
		glBindBuffer(GL_ARRAY_BUFFER, vbo);
		glBufferData(GL_ARRAY_BUFFER, vertices.length * float.sizeof, vertices.ptr, GL_STATIC_DRAW); 

		glVertexAttribPointer(PositionAttrib, 3, GL_FLOAT, GL_FALSE, 3*float.sizeof, cast(void*)0);
		glEnableVertexAttribArray(PositionAttrib); 

		glGenBuffers(1, &ebo);
		glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, ebo);
		glBufferData(GL_ELEMENT_ARRAY_BUFFER, elements.length * uint.sizeof, elements.ptr, GL_STATIC_DRAW);

		elements_count = cast(uint)elements.length;

		computeAABB(vertices);
	}

	~this() {
		//write("deleting geom#", vbo, "..." );
		glDeleteVertexArrays(1, &vao);
	    glDeleteBuffers(1, &vbo);
	    glDeleteBuffers(1, &ebo);
		//writeln("k.");
	}

	void computeAABB(float[] vertices) {
		for(int i=0; i<vertices.length; i += 3 ) {
			aabb.expand( vec3(vertices[i], vertices[i+1], vertices[i+2] ));
		}
	}

	void render() {
		glBindVertexArray(vao);
		//glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
		// glBindBuffer(GL_ARRAY_BUFFER, vbo);
		// glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, ebo);
		glDrawElements(GL_TRIANGLES, elements_count, GL_UNSIGNED_INT, null);
		// glDrawElements(GL_LINES, elements_count, GL_UNSIGNED_INT, null);
	}

}

