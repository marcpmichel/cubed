module inputmanager;

import derelict.glfw3.glfw3;
import derelict.opengl;
import broadcaster;
import std.stdio: writeln;

enum InputAction {
	NONE, 
	QUIT, 
	MOVE_FORWARD, 
	MOVE_BACKWARD, 
	MOVE_LEFT, 
	MOVE_RIGHT, 
	MOVE_UP, 
	MOVE_DOWN,
	YAW,
	PITCH,
	MOVE_FORWARD_QUICK,
	MOVE_BACKWARD_QUICK,
	MOVE_LEFT_QUICK,
	MOVE_RIGHT_QUICK,
	MOVE_UP_QUICK,
	MOVE_DOWN_QUICK
}

struct InputMessage {
	InputAction action;
	float delta;
}


class InputManager: Broadcaster!(InputMessage) {

	GLFWwindow* window;
    double mouseX, mouseY;

	this( GLFWwindow* a_window ) {
		window = a_window;

		glfwSetInputMode( window, GLFW_STICKY_KEYS, GL_FALSE );
		// glfwSetKeyCallback(window, &KeyEventManager.key_callback);
		// glfwSetCursorPosCallback( window, &MouseEventManager.mouse_moved );
		//glfwSetMouseButtonCallback( window, &InputManager.mouse_button_event );
		//glfwSetScrollCallback( window, &InputManager.mouse_scroll_event );
		// glfwSetInputMode(window, GLFW_CURSOR, GLFW_CURSOR_HIDDEN);
		glfwSetInputMode(window, GLFW_CURSOR, GLFW_CURSOR_DISABLED);
		// glfwSetCursorPos(window, 400/*Viewport.WIDTH/2*/, 300/*Viewport.HEIGHT/2*/);

		glfwGetCursorPos(window, &mouseX, &mouseY);
	}

	bool pressed(int key) {
		return glfwGetKey( window, key ) == GLFW_PRESS;
	}

	//bool released(int key) {
	//	return glfwGetKey( window, key ) == GLFW_RELEASE;
	//}

	void update() {
		double mx, my;
		glfwGetCursorPos(window, &mx, &my);
    
    	double dx = (mouseX - mx) / 1.0;
    	double dy = (mouseY - my) / 1.0;

    	mouseX = mx;
    	mouseY = my;

		if( dx != 0 ) broadcast( InputMessage(InputAction.YAW, dx ));
		if( dy != 0 ) broadcast( InputMessage(InputAction.PITCH, dy ));

		if( pressed(GLFW_KEY_LEFT_SHIFT) ) {
			if( pressed(GLFW_KEY_W)) broadcast( InputMessage(InputAction.MOVE_FORWARD_QUICK) );
			if( pressed(GLFW_KEY_S)) broadcast( InputMessage(InputAction.MOVE_BACKWARD_QUICK) );
			if( pressed(GLFW_KEY_A)) broadcast( InputMessage(InputAction.MOVE_LEFT_QUICK) );
			if( pressed(GLFW_KEY_D)) broadcast( InputMessage(InputAction.MOVE_RIGHT_QUICK) );
			if( pressed(GLFW_KEY_Q)) broadcast( InputMessage(InputAction.MOVE_UP_QUICK) );
			if( pressed(GLFW_KEY_Z)) broadcast( InputMessage(InputAction.MOVE_DOWN_QUICK) );
		}
		else {
			if( pressed(GLFW_KEY_W)) broadcast( InputMessage(InputAction.MOVE_FORWARD) );
			if( pressed(GLFW_KEY_S)) broadcast( InputMessage(InputAction.MOVE_BACKWARD) );
			if( pressed(GLFW_KEY_A)) broadcast( InputMessage(InputAction.MOVE_LEFT) );
			if( pressed(GLFW_KEY_D)) broadcast( InputMessage(InputAction.MOVE_RIGHT) );
			if( pressed(GLFW_KEY_Q)) broadcast( InputMessage(InputAction.MOVE_UP) );
			if( pressed(GLFW_KEY_Z)) broadcast( InputMessage(InputAction.MOVE_DOWN) );
		}

		if( pressed(GLFW_KEY_ESCAPE) )
			glfwSetWindowShouldClose(window, GL_TRUE);

	}

}



