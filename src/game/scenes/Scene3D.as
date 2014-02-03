package game.scenes
{
	import com.adobe.utils.PerspectiveMatrix3D;
	
	import flash.display.Sprite;
	import flash.display3D.Context3D;
	import flash.geom.Matrix3D;
	
	import game.assets.Assets;
	import game.input.GameInput;
	import game.shaders.Shaders;
	import game.utils.GameTimer;

	public class Scene3D extends Sprite
	{
		protected var _context3D:Context3D;
		
		protected var projectionmatrix:PerspectiveMatrix3D = new PerspectiveMatrix3D;
		protected var viewmatrix:Matrix3D = new Matrix3D;
		
		protected var gameinput:GameInput;
		protected var gametimer:GameTimer;
		
		public function Scene3D(context3D:Context3D)
		{
			_context3D = context3D;
			Assets.context = context3D;
			Shaders.context = context3D;
			
			projectionmatrix.identity();
			
			// TODO do better
			
			var aspectRatio:Number = Facade.gi().stage.stageWidth / Facade.gi().stage.stageHeight;
			
			projectionmatrix.perspectiveFieldOfViewRH(
				45, aspectRatio, 0.01, 150000.0);
		}
		
		final public function initResources():void
		{
			initTextures();
			initShaders();
			initMeshes();
		}
		
		protected function initMeshes():void
		{
		
		}
		
		protected function initTextures():void
		{
		
		}
		
		protected function initShaders():void
		{
		
		}
		
		public function heartbeat(frameMs:Number = 0):void
		{
			// для тяжёлых вычислений или чтобы не зависеть от fps
		}
		
		public function render():void
		{
			
		}
		
		public function dispose():void
		{
		
		}
	}
}