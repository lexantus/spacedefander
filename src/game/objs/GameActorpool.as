// Game actor pool version 1.2
// creates a pool of actor entities on demand
// and reuses inactive ones them whenever possible

package game.objs
{
	import flash.geom.Matrix3D;
	import flash.utils.Dictionary;

	public class GameActorpool
	{
		// list of string names of each known kind
		private var allNames:Vector.<String>;
		
		//contains one source actor for each kind
		private var allKinds:Dictionary;
		
		// contains many cloned actors of various kinds
		private var allActors:Dictionary;
		
		// temporary variables - used often
		private var actor:GameActor;
		private var actorList:Vector.<GameActor>;
		
		// used only for stats
		public var actorsCreated:uint = 0;
		public var actorsActive:uint = 0;
		public var totalpolycount:uint = 0;
		public var totalrendered:uint = 0;
		
		// so we can "pause" any stepping for actors
		// as a group for efficiency
		public var active:Boolean = true;
		
		// so we can hide parts of the map if required
		// perfect for rooms/portals/pvs/lod
		public var visible:Boolean = true;
	
		
		public function GameActorpool()
		{
			trace("Actor pool created.");
			allKinds = new Dictionary;
			allActors = new Dictionary;
			allNames = new Vector.<String>;
		}
		
		// names a particular|kind of actor
		public function defineActor(name:String,
									cloneSource:GameActor):void
		{
			trace("New actor type defined: " + name);
			allKinds[name] = cloneSource;
			allNames.push(name);
		}
		
		public function step(ms:uint, 
							 collistionDetection:Function = null,
							 collistionReaction:Function = null):void
		{
			// do nothing if entire pool is inactive (paused)
			if(!active) return;
			
			actorsActive = 0;
			for each(actorList in allActors)
			{
				actorsActive ++;
				actor.step(ms);
				
				if(actor.collides &&
					(collistionDetection != null))
				{
					actor.touching = collistionDetection(actor);
					
					if(actor.touching &&
						(collistionReaction != null))
					{
						collistionReaction(actor, actor.touching);
					}
				}
			}
		}
		
		// renders all active actors
		public function render(view:Matrix3D,projection:Matrix3D):void
		{
			// do nothing if entire pool is invisible
			if (!visible) return;
			totalpolycount = 0;
			totalrendered = 0;
			var stateChange:Boolean = true;
			for each (actorList in allActors)
			{
				stateChange = true; // v2
				for each (actor in actorList)
				{
					if (actor.active && actor.visible)
					{
						totalpolycount += actor.polycount;
						totalrendered++;
						actor.render(view, projection, stateChange);
					}
				}
			}
		}
		
		// either reuse an inactive actor or create a new one
		// returns the actor that was spawned for further use
		public function spawn(
			name:String, pos:Matrix3D = null):GameActor
		{
			var spawned:GameActor = null;
			var reused:Boolean = false;
			if (allKinds[name])
			{
				if (allActors[name])
				{
					for each (actor in allActors[name])
					{
						if (!actor.active)
						{
							//trace("A " + name + " was reused.");
							actor.respawn(pos);
							spawned = actor;
							reused = true;
							return spawned;
						}
					}
				}
				else
				{
					//trace("This is the first " + name + " actor.");
					allActors[name] = new Vector.<GameActor>();
				}
				if (!reused) // no inactive ones were found
				{
					actorsCreated++;
					//trace("Creating a new " + name);
					//trace("Total actors: " + actorsCreated);
					spawned = allKinds[name].cloneactor();
					spawned.classname = name;
					spawned.name = name + actorsCreated;
					spawned.respawn(pos);
					allActors[name].push(spawned);
					//trace("Total " + name + "s: "
					//+ allActors[name].length);
					return spawned;
				}
			}
			else
			{
				trace("ERROR: unknown actor type: " + name);
			}
			return spawned;
		}
		
		public function colliding(checkthis:GameActor):GameActor
		{
			if (!checkthis.visible) return null;
			if (!checkthis.active) return null;
			var hit:GameActor;
			var str:String;
			for each (str in allNames)
			for each (hit in allActors[str])
			{
				if (hit.visible &&
					hit.active &&
					checkthis.colliding(hit))
				{
					//trace(checkthis.name +
					// " is colliding with " + hit.name);
					return hit;
				}
				else
				{
					//trace(checkthis.name + " is NOT colliding with " +
					//hit.name);
				}
			}
			return null;
		}
		
		// to "clear" the scene, "kill" all known entities
		// good for in between new levels ar after a gameover
		public function destroyAll():void
		{
			for each (actorList in allActors)
			{
				for each (actor in actorList)
				{
					// ready to be respawned
					actor.active = false;
					actor.visible = false;
				}
			}
		}
	}
}