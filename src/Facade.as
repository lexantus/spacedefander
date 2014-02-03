package
{
	import com.bit101.components.Label;
	
	import flash.display.Stage;
	
	import game.input.GameInput;


	public class Facade
	{
		
		public var stage:Stage;
		public var gameInput:GameInput;
		public var scoreLabel:Label;
		public var title:Label;
		public var pauseLabel:Label;
		public var gameOverLabel:Label;
		public var livesLabel:Label;
		
		public var score:int;
		public var silent:Boolean = false;
		
		public static var debugMode:Boolean = false;
		
		private static var _facade:Facade;
		
		
		
		public static function gi():Facade
		{
			if(!_facade)
			{
				_facade = new Facade(new ConstructorEnforces);
			}
			
			return _facade;
		
		}
		
		
		public function Facade(noconstructor:ConstructorEnforces)
		{
		}
		
		
	}
}

class ConstructorEnforces{};