
module camera;

import gl3n.linalg;
import broadcaster;
import inputmanager;
import derelict.glfw3.glfw3;


interface Camera {
	@property mat4 matrix();
	void lookAt( vec3 target );
	void setPosition( vec3 pos );
	@property vec3 position();
	void update(float delta);
}

class BaseCamera : Camera {
	mat4 _matrix;
	vec3 _world_up = vec3(0,1,0);
	vec3 _pos = vec3(0,2,-20);
	vec3 _target = vec3(0,0,0);

	this() {
		update_matrix();
	}

	mat4 matrix() { return _matrix; }

	void update(float delta) {
	}

	void update_matrix() { 
		_matrix = mat4.look_at( _pos, _target, _world_up );
	}
	
	void lookAt( vec3 target ) { 
		_target = target;
		update_matrix();
	}

	void setPosition( vec3 pos ) {
		_pos = pos;
		update_matrix(); 
	}

	@property vec3 position() {
		return _pos;
	}

}

class RotateAroundCamera: BaseCamera {
	
	float _dist, _elevation, _alpha=0;

	this( vec3 target, float dist, float elevation ) {
		_target = target;
		_dist = dist;
		_elevation = elevation;
	}

	override void update(float lapsed) {
		_alpha += lapsed;
		_pos.x = cos(_alpha) * _dist;
		_pos.z = sin(_alpha) * _dist;
		_pos.y = _elevation;

		update_matrix();
	}

}

class ZoomAroundCamera: RotateAroundCamera, Receiver!(InputMessage) {

	this( vec3 target, float dist, float elevation ) {
		super( target, dist, elevation );
		Broadcaster!(InputMessage).register(this);
	}

	void onMessage(InputMessage evt) {

		switch( evt.action ) {
			case InputAction.MOVE_LEFT: _alpha += 0.1; break;
			case InputAction.MOVE_RIGHT: _alpha -= 0.1; break;
			case InputAction.MOVE_FORWARD: _dist -= 0.1; break;
			case InputAction.MOVE_BACKWARD: _dist += 0.1; break;
			case InputAction.MOVE_UP: _elevation += 0.1; break;
			case InputAction.MOVE_DOWN: _elevation -= 0.1; break;
			default: return;
		}
	}

	override void update(float delta) {
		_pos.x = sin(_alpha) * sin(_elevation) * _dist;
		_pos.y = cos(_elevation) * _dist;
		_pos.z = cos(_alpha) * sin(_elevation) * _dist;
		update_matrix();
	}
}


class FPCamera: BaseCamera, Receiver!(InputMessage) {
	
	float yaw, pitch;
	vec4 move;
	vec4 forward = vec4( 0,0,0.1,1 );
	vec4 up = vec4( 0,0.1,0,1 );
	vec4 strafe = vec4( 0.1,0,0,1 );

	vec4 forwardQuick = vec4( 0,0,0.5,1 );
	vec4 upQuick = vec4( 0,0.5,0,1 );
	vec4 strafeQuick = vec4( 0.5,0,0,1 );

	this(vec3 pos) {
		_pos = pos;
		_target = pos + forward.xyz;
		yaw = 0;
		pitch = 0;
		update_matrix();
		Broadcaster!(InputMessage).register(this);
	}


	void changePitch(float delta) {
		pitch += delta / 200.0;
		if(pitch < -PI/2 + 0.1) pitch = -PI/2 + 0.1;
		if(pitch > PI/2 - 0.1) pitch = PI/2 - 0.1;
	}

	void changeYaw(float delta) {
		yaw -= delta / 200.0;
		if(yaw > 2*PI) yaw = -2*PI + yaw;
		if(yaw < -2*PI) yaw = 2*PI + yaw;
	}

	void onMessage(InputMessage im) {

		move = vec4(0,0,0,1);
		float prev_yaw = yaw;
		float prev_pitch = pitch;

		switch( im.action ) {
			case InputAction.YAW: changeYaw(im.delta); break;
			case InputAction.PITCH: changePitch(im.delta); break;
			case InputAction.MOVE_FORWARD: move = forward; break;
			case InputAction.MOVE_BACKWARD: move = -forward; break;
			case InputAction.MOVE_LEFT: move = strafe; break;
			case InputAction.MOVE_RIGHT: move = -strafe; break;
			case InputAction.MOVE_UP: move = up; break;
			case InputAction.MOVE_DOWN: move = -up; break;
			case InputAction.MOVE_FORWARD_QUICK: move = forwardQuick; break;
			case InputAction.MOVE_BACKWARD_QUICK: move = -forwardQuick; break;
			case InputAction.MOVE_LEFT_QUICK: move = strafeQuick; break;
			case InputAction.MOVE_RIGHT_QUICK: move = -strafeQuick; break;
			case InputAction.MOVE_UP_QUICK: move = upQuick; break;
			case InputAction.MOVE_DOWN_QUICK: move = -upQuick; break;
			default: return;
		}

		if( move != vec4(0,0,0,1)) update_pos;
		//if( prev_yaw != yaw || prev_pitch != pitch ) update_target;
		update_target;

	}

	void update_target() {
		mat4 viewmat = mat4.identity.rotatex(pitch).rotatey(yaw);
		_target = _pos + (forward * viewmat).xyz;
		update_matrix();
	}

	void update_pos() {
		mat4 movemat = mat4.identity.rotatey(yaw);
		_pos += ( move * movemat ).xyz;
	}


	override void update(float delta) { };
}

class FlyCamera: FPCamera {
	
	this(vec3 pos) {
		super(pos);
	}

	override void update_pos() {
		mat4 movemat = mat4.identity.rotatex(pitch).rotatey(yaw);
		_pos += ( move * movemat ).xyz;
	}

}



