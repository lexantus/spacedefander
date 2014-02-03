package game.shaders
{
	import flash.display.Shader;
	import flash.display3D.Context3D;
	import flash.display3D.Program3D;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;

	
	public class Shaders
	{
		public static var shaders:Dictionary = new Dictionary;
	
		public static var Shader1:Program3D;
		
		public static var context:Context3D;
		
		private static var vertexProgram:ByteArray;
		private static var fragmentProgram:ByteArray;
		
	
		public static function getShader(name:String):Program3D
		{
			if(shaders[name] == undefined)
			{
				shaders[name] = context.createProgram();
				vertexProgram = ShaderProgramTexts.getProgramFor(name)[0];
				fragmentProgram = ShaderProgramTexts.getProgramFor(name)[1];
				(shaders[name] as Program3D).upload(vertexProgram, fragmentProgram);		
			}	
			
			return shaders[name];
		}
	}
	
}