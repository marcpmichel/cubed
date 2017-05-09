import std.random;
import std.math;

__gshared Noise theNoise = new Noise();

class Noise {

	float[1024] randomPool;
	//auto gen = MinstdRand0(1);
	Random gen;

	this() {
		gen.seed(1);

		foreach( ref r; randomPool) {
			r = cast(float)uniform(-10_000,10_000, gen) / 10_000.0;
		}
	}

	float perlin(float x, float y) {
		float total = 0;
		float numberOfOctaves = 4;
		float persistence = 0.5f;

		for (int i = 0; i < numberOfOctaves; i++) {
			float frequency = pow(2, i);
			float amplitude = pow(persistence, i);
			float p = interpolated(x * frequency, y * frequency);
			total += p * amplitude;
		}
		return fmin(fmax(total, -1.0), 1.0);
	}

	private:
	float randxy(float x, float y) {
		return randomPool[cast(uint)(x+256*y) % 1024];
	}

	float InterpolateCSCurve(float leftSample, float rightSample, float position) {
		float f = position * position * (3 - 2 * position);
		return leftSample * (1 - f) + rightSample * f;
	}

	float interpolated(float x, float y) {
		int integer_X = cast(int)x;
		float fractional_X = x - integer_X;
		int integer_Y = cast(int)y;
		float fractional_Y = y - integer_Y;

		float v1 = randxy(integer_X, integer_Y);
		float v2 = randxy(integer_X + 1, integer_Y);
		float v3 = randxy(integer_X, integer_Y + 1);
		float v4 = randxy(integer_X + 1, integer_Y + 1);
		float i1 = InterpolateCSCurve(v1, v2, fractional_X);
		float i2 = InterpolateCSCurve(v3, v4, fractional_X);
		return InterpolateCSCurve(i1, i2, fractional_Y);
	}

}




