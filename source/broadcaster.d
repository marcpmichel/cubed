//module broadcaster;

import std.container;

interface Receiver(M) {
	void onMessage( M message );
}

static class Broadcaster(M) {
	private static Receiver!(M)[] mReceivers;

	public static void register( Receiver!(M) receiver ) {
		mReceivers ~= receiver;
	}

	public static void unregister( Receiver!(M) receiver ) {
		foreach( i, v; mReceivers ) {
			if( receiver is v ) {
				mReceivers = mReceivers[0 .. i] ~ mReceivers[i+1 .. $];
				break;
			}
		}
	}

	public static void broadcast( M message ) {
		foreach( ref receiver; mReceivers ) {
			receiver.onMessage( message );
		}
	}

}
	
