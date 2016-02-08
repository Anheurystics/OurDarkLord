package;

class Geometry
{
	public static var quadVertices: Array<Float> = [
		-0.5,  0.5, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0,
		 0.5,  0.5, 0.0, 1.0, 0.0, 0.0, 0.0, 1.0,
		 0.5, -0.5, 0.0, 1.0, 1.0, 0.0, 0.0, 1.0,
		-0.5, -0.5, 0.0, 0.0, 1.0, 0.0, 0.0, 1.0
	];
	
	public static var quadIndices: Array<Int> = [
		0, 1, 2, 0, 2, 3
	];
	
	public static var skyboxVertices: Array<Float> = [         
		-1.0,  1.0, -1.0,
		-1.0, -1.0, -1.0,
		 1.0, -1.0, -1.0,
		 1.0, -1.0, -1.0,
		 1.0,  1.0, -1.0,
		-1.0,  1.0, -1.0,
		
		-1.0, -1.0,  1.0,
		-1.0, -1.0, -1.0,
		-1.0,  1.0, -1.0,
		-1.0,  1.0, -1.0,
		-1.0,  1.0,  1.0,
		-1.0, -1.0,  1.0,
		
		 1.0, -1.0, -1.0,
		 1.0, -1.0,  1.0,
		 1.0,  1.0,  1.0,
		 1.0,  1.0,  1.0,
		 1.0,  1.0, -1.0,
		 1.0, -1.0, -1.0,

		-1.0, -1.0,  1.0,
		-1.0,  1.0,  1.0,
		 1.0,  1.0,  1.0,
		 1.0,  1.0,  1.0,
		 1.0, -1.0,  1.0,
		-1.0, -1.0,  1.0,

		-1.0,  1.0, -1.0,
		 1.0,  1.0, -1.0,
		 1.0,  1.0,  1.0,
		 1.0,  1.0,  1.0,
		-1.0,  1.0,  1.0,
		-1.0,  1.0, -1.0,

		-1.0, -1.0, -1.0,
		-1.0, -1.0,  1.0,
		 1.0, -1.0, -1.0,
		 1.0, -1.0, -1.0,
		-1.0, -1.0,  1.0,
		 1.0, -1.0,  1.0
	];	
}