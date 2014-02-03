package game.model
{
	import flash.events.Event;
	import flash.events.EventDispatcher;

	public class GameDispatcher extends EventDispatcher
	{
		
		private static var _instance:GameDispatcher;
		
		public function GameDispatcher(ce:ConstructorEnforcer):void
		{
		
		}	
		
		public static function gi():GameDispatcher
		{
			if(!_instance)
			{
				_instance = new GameDispatcher(new ConstructorEnforcer);
			}
			
			return _instance;
		}
		
		public function player_die():void
		{
			dispatchGameEvent(GameEvent.DIE);
		}
		
		public function game_pause():void
		{
			dispatchGameEvent(GameEvent.PAUSE);
		}
		
		public function level_start():void
		{
			dispatchGameEvent(GameEvent.START_LEVEL);
		}
		
		public function level_complete():void
		{
			dispatchGameEvent(GameEvent.COMPLETE_LEVEL);
		}
		
		private function dispatchGameEvent(name:String):void
		{
			dispatchEvent(new Event(name));
		}
	}
}

class ConstructorEnforcer{};