package
{
	import com.bit101.components.FPSMeter;
	import com.bit101.components.Label;
	import com.bit101.components.Panel;
	import com.bit101.components.Style;
	
	import flash.display.Sprite;
	import flash.display.Stage3D;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.display3D.Context3D;
	import flash.events.Event;
	
	import caurina.transitions.Tweener;
	
	import game.input.GameInput;
	import game.model.GameDispatcher;
	import game.model.GameEvent;
	import game.scenes.GameScene;
	import game.scenes.Scene3D;
	import game.scenes.StartScene;

	
	[SWF(width="1280", height="800", frameRate="60", backgroundColor="#333333")]
	public class space_defander extends Sprite
	{
		
		private var _scene:Scene3D;
		
		private var context3d:Context3D;
	
		
		private var title:Label;
		
		private var fpsPanel:Panel;
		private var fpsMeter:FPSMeter;
		
		private var scoreLabel:Label;
		private var pauseLabel:Label;
		private var gameoverLabel:Label;
		
		
		public function space_defander()
		{
			if (stage != null) 
				init();
			else 
				addEventListener(Event.ADDED_TO_STAGE, init);
			
		}
		
		private function init(e:Event = null):void 
		{
			if (hasEventListener(Event.ADDED_TO_STAGE))
				removeEventListener(Event.ADDED_TO_STAGE, init);
			
			Facade.gi().stage = stage;
			
			
			// set up the stage
			stage.frameRate = 60;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			
			// and request a context3D from Stage3d
			stage.stage3Ds[0].addEventListener(
				Event.CONTEXT3D_CREATE, onContext3DCreate);
			stage.stage3Ds[0].requestContext3D();
			
			
			if(Facade.debugMode)
			{
				fpsPanel = new Panel(this, 20, 20);
				fpsPanel.setSize(40, 20);
			
				fpsMeter = new FPSMeter(this, 22, 21, "FPS:");
			}
			
			Style.fontSize = 25;
			Style.setStyle(Style.DARK);
			
			Facade.gi().scoreLabel = new Label(this, stage.stageWidth - 300, 10);
			scoreLabel = Facade.gi().scoreLabel;
			scoreLabel.text = "Score: 0";
			scoreLabel.x = stage.stageWidth - 150;
			scoreLabel.alpha = 0;
			
			
			Style.fontSize = 100;
			Facade.gi().title = new Label(this, 120, 300, "SPACE DEFENDER");
			title = Facade.gi().title;
			
			Facade.gi().gameOverLabel = new Label(this, 300, 300, "GAME OVER");
			gameoverLabel = Facade.gi().gameOverLabel;
			gameoverLabel.alpha = 0;
			
			Facade.gi().pauseLabel = new Label(this, 450, 0, "PAUSE");
			pauseLabel = Facade.gi().pauseLabel;
			pauseLabel.alpha = 0;
			
			
		}
		
		protected function onContext3DCreate(event:Event):void
		{
			if (hasEventListener(Event.ENTER_FRAME))
				removeEventListener(Event.ENTER_FRAME,enterFrame);
			
			// Obtain the current context
			var t:Stage3D = event.target as Stage3D;					
			context3d = t.context3D; 
			
			if(!(_scene is StartScene))
			{
				_scene = new StartScene(context3d);
			}
			
			if (context3d == null) 
			{
				// Currently no 3d context is available (error!)
				trace('ERROR: no context3D - video driver problem?');
				return;
			}
			
			Facade.gi().gameInput = new GameInput(stage);
			
			// Disabling error checking will drastically improve performance.
			// If set to true, Flash sends helpful error messages regarding
			// AGAL compilation errors, uninitialized program constants, etc.
			context3d.enableErrorChecking = true;
			
			// The 3d back buffer size is in pixels (2=antialiased)
			context3d.configureBackBuffer(stage.stageWidth, stage.stageHeight, 2, true);
		
			
			// start the render loop!
			addEventListener(Event.ENTER_FRAME,enterFrame);
			
			GameDispatcher.gi().addEventListener(GameEvent.START_LEVEL, onLevelStart);
			GameDispatcher.gi().addEventListener(GameEvent.DIE, onDie);
		}
		
		protected function onDie(event:Event):void
		{
			_scene = new StartScene(context3d);
		}
		
		protected function onLevelStart(event:Event):void
		{
			
			_scene = new GameScene(context3d);
			Tweener.addTween(scoreLabel, {alpha:1, time:3});
			
		}		
		
		
		private function enterFrame(e:Event):void
		{
			// clear scene before rendering is mandatory
			context3d.clear(0,0,0); 
			
			// count frames, measure elapsed time
			//gametimer.tick();
			
			// update all entities positions, etc
			//gameStep(gametimer.frameMs);
			if(_scene)
			{
				_scene.render();
			}
			
			context3d.present();
			
			
		}
		
		private function gameStep(frameMs:Number):void
		{
			
		}
	}
}