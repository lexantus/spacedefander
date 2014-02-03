package game.gui
{

	import com.bit101.components.PushButton;
	import com.bit101.components.Style;
	
	import flash.display.Sprite;
	import flash.events.Event;
	
	import caurina.transitions.Tweener;
	
	import game.model.GameDispatcher;
	

	public class StartMenu extends Sprite
	{
		
		private var _btnStart:PushButton;
		private var _btnRules:PushButton;
		
		private var _container:Sprite;
		
		public function StartMenu()
		{
			initButtons();	
		}
		
		private function initButtons():void
		{
			_container = new Sprite;
			addChild(_container);
			
			Style.setStyle(Style.LIGHT);
			Style.fontSize = 12;
			
			_btnStart = new PushButton(_container, 0, 0, "START", onStart);
			_btnStart.setSize(200, 60);
			
			//_btnRules = new PushButton(_container, 0, 80, "RULES", onRules);
			//_btnRules.setSize(200, 60);
		
		}
		
		
		private function onRules(e:Event):void
		{
			
		}
		
		private function onStart(e:Event):void
		{
			
			GameDispatcher.gi().level_start();
			
			Tweener.addTween(Facade.gi().title, {alpha:0, time:1});
			
			
			Tweener.addTween(this, {x:-200, time:2, onComplete:function():void{
			

				removeFromStage();
			
			}});
			
			
		}
		
		private function removeFromStage():void
		{
			Facade.gi().stage.removeChild(this);
		}
		
	}
}