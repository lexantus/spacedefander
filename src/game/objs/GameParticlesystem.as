// Game particle system manager version 1.0
// creates a pool of particle entities on demand
// and reuses inactive ones them whenever possible
//
package game.objs
{
import flash.geom.Matrix3D;
import flash.utils.Dictionary;



public class GameParticlesystem
{
	// contains one source particle for each kind
	private var allKinds:Dictionary;
	// contains many cloned particles of various kinds
	private var allParticles:Dictionary;
	// temporary variables - used often
	private var particle:Stage3dParticle;
	private var particleList:Vector.<Stage3dParticle>;
	// used only for stats
	public var particlesCreated:uint = 0;
	public var particlesActive:uint = 0;
	public var totalpolycount:uint = 0;
	
	// class constructor
	public function GameParticlesystem()
	{
		trace("Particle system created.");
		allKinds = new Dictionary();
		allParticles = new Dictionary();
	}
	
	// names a particular kind of particle
	public function defineParticle(
		name:String, cloneSource:Stage3dParticle):void
	{
		trace("New particle type defined: " + name);
		allKinds[name] = cloneSource;
	}
	
	// updates the time step shader constants
	public function step(ms:uint):void
	{
		particlesActive = 0;
		for each (particleList in allParticles)
		{
			for each (particle in particleList) 
			{
				if (particle.active) 
				{
					particlesActive++;
					particle.step(ms);
				}
			}
		}
	}
	
	// renders all active particles
	public function render(view:Matrix3D,projection:Matrix3D):void
	{
		totalpolycount = 0;
		for each (particleList in allParticles)
		{
			for each (particle in particleList) 
			{
				if (particle.active)
				{
					totalpolycount += particle.polycount;
					particle.render(view, projection);
				}
			}
		}
	}

	// either reuse an inactive particle or create a new one
	public function spawn(
		name:String, pos:Matrix3D, maxage:Number = 1000, 
		scale1:Number = 1, scale2:Number = 50):void
	{
		var reused:Boolean = false;
		if (allKinds[name])
		{
			if (allParticles[name])
			{
				for each (particle in allParticles[name]) 
				{
					if (!particle.active)
					{
						//trace("A " + name + " was reused.");
						particle.respawn(pos, maxage, scale1, scale2);
						particle.updateValuesFromTransform();
						reused = true;
						return;
					}
				}
			}
			else
			{
				trace("This is the first " + name + " particle.");
				allParticles[name] = new Vector.<game.objs.Stage3dParticle>;
			}
			if (!reused) // no inactive ones were found
			{
				particlesCreated++;
				trace("Creating a new " + name);
				trace("Total particles: " + particlesCreated);
				var newParticle:Stage3dParticle = 
					allKinds[name].cloneparticle();
				newParticle.respawn(pos, maxage, scale1, scale2);
				newParticle.updateValuesFromTransform();				
				allParticles[name].push(newParticle);
			}
		}
		else
		{
			trace("ERROR: unknown particle type: " + name);
		}
	}

} // end class

} // end package