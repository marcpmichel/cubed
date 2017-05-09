
import derelict.glfw3.glfw3;

class Delay {

	double delay;
	double prevTime; 

	this(double a_delay) {
		delay = a_delay;
		prevTime = glfwGetTime();
	}

	bool over() {
		if( (prevTime + delay ) < glfwGetTime() ) return true;
		return false;
	}

	void reset() {
		prevTime = glfwGetTime();
	}
}
