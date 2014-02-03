package game.scenes
{
	import flash.display3D.Context3D;
	import flash.display3D.Context3DTriangleFace;
	import flash.display3D.Program3D;
	import flash.geom.Point;
	
	
	import game.assets.Assets;
	import game.gui.StartMenu;
	import game.input.GameInput;
	import game.objs.Stage3dEntity;
	import game.shaders.Shaders;
	import game.utils.MathUtils;
	
	public class StartScene extends Scene3D
	{

		// ENTITIES
		private var earth:Stage3dEntity;
		private var universe:Stage3dEntity;
		
		protected var shaderProgram:Program3D;
		
		private var menu:StartMenu;
		
		private const t:Number = 1;
		
		private var gameinput:GameInput;
		
		private var priviousZoom:Number = -1;
		
		// ELLIPSE vars
		private var t1:Number = 0; // from 0 to 2PI
		private var a:Number = 0.2;
		private var b:Number = 0.05;
		private var acceleration:Number = 1;
		private var max_acceleration:Number = 5;
		
		private var t2:Number = -3;
		
		public function StartScene(context3D:Context3D)
		{
			super(context3D);
			initResources();
			
			viewmatrix.identity();
			viewmatrix.appendTranslation(0, 0, -3);
			
			
			menu = new StartMenu;
			menu.x = 535;
			menu.y = 30;
			Facade.gi().stage.addChild(menu);
			
			gameinput = new GameInput(Facade.gi().stage);
			
			Facade.gi().title.alpha = 1;
		}
		
		override protected function initMeshes():void
		{
			
			earth = new Stage3dEntity(Assets.getMeshClass("SphereOBJ"), 
									_context3D,
								    shaderProgram, 
				                     Assets.getTexture("EarthBitmap"), 1, true, true);
			
	
			universe = new Stage3dEntity(Assets.getMeshClass("SphereOBJ"), 
										_context3D,
										shaderProgram, 
										Assets.getTexture("SkyBitmap"), 1, true, false);
									
		}
		
		
		
		
		override protected function initTextures():void
		{
			Assets.getTexture("SkyBitmap");
		}
		
		override protected function initShaders():void
		{
			shaderProgram = Shaders.getShader("Shader1");
		}
		
		override public function heartbeat(frameMs:Number = 0):void
		{
		
		}
		
		private function ellipse(param:Number):Point
		{
			return new Point(a*Math.cos(param), b*Math.sin(param));	
		}
		
		override public function render():void
		{
			
			earth.rotationDegreesX += 0.7;
			earth.rotationDegreesZ = 90;
			
			earth.scaleXYZ = 0.3;
			
			if(viewmatrix.position.z < - 2)
			{
				viewmatrix.appendTranslation(0, 0, t/70);
			}
		
			//viewmatrix.appendRotation(gameinput.cameraAngleX/100, Vector3D.X_AXIS);
			//viewmatrix.appendRotation(gameinput.cameraAngleY/100, Vector3D.Y_AXIS);
			//viewmatrix.appendRotation(gameinput.cameraAngleZ/100, Vector3D.Z_AXIS);
			
			t1+= acceleration;
			
			if(t2 < -2)
			{
				t2+= 0.1;
			}
			
			acceleration += (Math.random() - 0.5)/100;
			
			if(acceleration > max_acceleration)
			{
				acceleration = 0;
			}
			
			var paramInRadians:Number = MathUtils.DEG_TO_RAD * t1;
			
			
			var pt:Point = ellipse(paramInRadians);
			viewmatrix.identity();
			viewmatrix.appendTranslation(pt.x, pt.y, t2);
	
			if(gameinput.zoom!= priviousZoom)
			{
				viewmatrix.appendTranslation(0, 0, (gameinput.zoom - priviousZoom)/100);
				priviousZoom = gameinput.zoom;
			}
			
			earth.render(viewmatrix, projectionmatrix);
			
			
			universe.scaleXYZ = 1.5;
			universe.cullingMode = Context3DTriangleFace.NONE;
			universe.render(viewmatrix, projectionmatrix);
			
		}
		
		override public function dispose():void
		{
			
		}
	}
}