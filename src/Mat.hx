package;

import lime.utils.Float32Array;

interface Mat 
{
	public function array(): Float32Array;
	public function type(): Int;
}