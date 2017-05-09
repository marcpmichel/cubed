
import specd.specd;
import mesh;
import gl3n.linalg;

version(specrunner) unittest {

	auto mesh = new Mesh();
	auto mesh2 = new Mesh();
	mesh2.setPosition(1,1,1);

	describe("mesh aabb").as( (it) {
		it.should("have an AABB",
			mesh.aabb.min.must.equal(vec3(-1,-1,-1))
		);

		it.should("move its AABB",
			mesh2.aabb.min.must.equal(vec3(0,0,0))
		);
	});

}
