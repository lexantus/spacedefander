package game.music
{
	import flash.events.Event;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	
	
	public class GameMusic
	{
		
		[Embed(source="../../../resources/sounds/soundtrack2.mp3")]
		public var SoundTrack1:Class;
	
		[Embed(source="../../../resources/sounds/soundtrack1.mp3")]
		public var SoundTrack2:Class;
	
		private var queue:Vector.<Sound>;
		private var stream:SoundChannel;
		
		private var trackNum:int = -1;
		
		private var isPlaying:Boolean = false;
		
		
		private static var _instance:GameMusic;
		
		
		public static function gi():GameMusic
		{
			if(!_instance)
			{
				_instance = new GameMusic(new ConstructorEnforcer);
			}
			
			return _instance;
		}
		
		public function GameMusic(inforcer:ConstructorEnforcer)
		{
			initQueue();
		}
		
		private function initQueue():void
		{
			queue = new Vector.<Sound>;
			
			var rand:Number = Math.random();
			
			if(rand > 0.5)
			{
				queue.push((new SoundTrack1) as Sound);
				queue.push((new SoundTrack2) as Sound);
			}else{
				queue.push((new SoundTrack2) as Sound);
				queue.push((new SoundTrack1) as Sound);
			
			}
			
			
			
		}
		
		public function start():void
		{
			if(!isPlaying)
			{
				trackNum = -1;
				onNext();
				isPlaying = true;
			}
		}
		
		private function playTrack(num:uint):void
		{		
			if(num < queue.length)
			{
				trackNum = num;
			
			}else{
			
				num = 0;
				trackNum = 0;
			}
			
			
			stream = queue[num].play();
			stream.soundTransform = new SoundTransform(0.08);
			stream.addEventListener(Event.SOUND_COMPLETE, onNext);
			
		}
		
		protected function onNext(event:Event = null):void
		{
			if(stream)
			{
				stream.removeEventListener(Event.SOUND_COMPLETE, onNext);
			}
			
			playTrack(++trackNum);
		}		
		
		
		public function keepSilent(b:Boolean):void
		{
			if(b){
				stream.soundTransform = new SoundTransform(0);
			
			}else{
				
				stream.soundTransform = new SoundTransform(0.08);
			}
		}
		
	}
}

class ConstructorEnforcer{}