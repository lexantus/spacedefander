package game.shaders
{
	import com.adobe.utils.AGALMiniAssembler;
	
	import flash.display3D.Context3DProgramType;
	import flash.utils.ByteArray;

	public class ShaderProgramTexts
	{
		public function ShaderProgramTexts()
		{
		}
		
		public static const SHADER1_VERTEX:String = // 4x4 matrix multiply to get camera angle	
													"m44 op, va0, vc0\n" +
													// tell fragment shader about XYZ
													"mov v0, va0\n" +
													// tell fragment shader about UV
													"mov v1, va1\n" +
													// tell fragment shader about RGBA
													"mov v2, va2";
		
		public static const SHADER1_FRAGMENT:String = // grab the texture color from texture 0 
													 // and uv coordinates from varying register 1
													// and store the interpolated value in ft0
													"tex ft0, v1, fs0 <2d,linear,repeat,nomip>\n"+
													// move this value to the output color
													"mov oc, ft0\n";
		
		public static const SHADER2_VERTEX:String = // 4x4 matrix multiply to get camera angle	
			"m44 op, va0, vc0\n" +
			// tell fragment shader about XYZ
			"mov v0, va0\n" +
			// tell fragment shader about UV
			"mov v1, va1\n" +
			// tell fragment shader about RGBA
			"mov v2, va2";
		
		public static const SHADER2_FRAGMENT:String = // grab the texture color from texture 0
													 // and uv coordinates from varying register 1
													// and store the interpolated value in ft0
													"tex ft0, v1, fs0 <2d,linear,repeat,nomip>\n" +
													"sub ft1, ft0, fc5\n" +
													"mov oc, ft1\n"; 
		
		private static var assembler:AGALMiniAssembler = new AGALMiniAssembler();
		private static var programs:Vector.<ByteArray>  = new Vector.<ByteArray>(2);
		
		
		public static function getProgramFor(name:String):Vector.<ByteArray>
		{
			
			programs[0] = assembler.assemble(Context3DProgramType.VERTEX, 
						       ShaderProgramTexts[name.toUpperCase() + "_VERTEX"]);
			
			programs[1] = assembler.assemble(Context3DProgramType.FRAGMENT, 
							   ShaderProgramTexts[name.toUpperCase() + "_FRAGMENT"]);
			
			return programs;
		}
		
		
	}
}