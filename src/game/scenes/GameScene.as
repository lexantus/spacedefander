package game.scenes
{

	import com.bit101.components.Label;
	import com.bit101.components.Style;
	
	import flash.display3D.Context3D;
	import flash.display3D.Context3DBlendFactor;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DTriangleFace;
	import flash.display3D.Program3D;
	import flash.events.TimerEvent;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.utils.Timer;
	import flash.utils.getTimer;
	
	import caurina.transitions.Tweener;
	
	import game.assets.Assets;
	import game.input.GameInput;
	import game.model.GameDispatcher;
	import game.music.GameMusic;
	import game.objs.GameActor;
	import game.objs.GameParticlesystem;
	import game.objs.Stage3dEntity;
	import game.objs.Stage3dParticle;
	import game.shaders.Shaders;
	import game.utils.GameTimer;
	import game.utils.MathUtils;

	
	
	public class GameScene extends Scene3D
	{
		
		// SOUNDS
		[Embed(source="../../../resources/sounds/sfxgun.mp3")]
		public var gunMp3:Class;

		public var gunSound:Sound = (new gunMp3) as Sound;
		
		[Embed(source="../../../resources/sounds/sfxexplode.mp3")]
		public var explosionMp3:Class;
		
		public var explosionSound:Sound = (new explosionMp3) as Sound;
		
		// GAME UTILS
		private var gameInput:GameInput;
		private var gameTimer:GameTimer;
		
		
		// 3D OBJECTS
		private var ship:Stage3dEntity;
		private var earth:Stage3dEntity;
		private var universe:Stage3dEntity;
		
		// ASTEROIDS
		private var asteroids:Vector.<Stage3dEntity>;
		private var asteroidsHealth:Vector.<Number>;
		private var asteroidsAngles:Vector.<Number>;
		private var asteroid:GameActor;
		private var asteroidTimer:Timer;
		
		// BULLETS
		private var bullets:Vector.<Stage3dEntity>;
		private var bullet:Stage3dEntity;
		
		private var deleteBulletsIndexes:Vector.<int> = new Vector.<int>;
		private var deleteAsteroidsIndexes:Vector.<int> = new Vector.<int>;
		
		private var nextShootTime:Number = 0;
		private var shootDelay:Number = 200;
		
		protected var shaderProgram:Program3D;
		
		private var movX:Number = 0;
		private var movY:Number = 0;
		
		private var tempX:Number = 0;
		private var tempY:Number = 0;
		
		private const speed:Number = 0.02;
		private var angle:Number = 0;
		
		private var t:Number = 0;
		
		private var particleSystem:GameParticlesystem;
		
		private var bShipDie:Boolean = false;
		  
		private var max_shiphealth:Number = 5;
		private var ship_health:Number = 5;
	
		// меняется с увеличением сложности уровня. чем меньше, тем быстрее будут создаваться новые астеройды
		private var asteroidCreationDelay:Number = 1000;
		
		private var firedAsteroidInstance:Stage3dEntity;
		
		private var dieMeteoriteInstance:Stage3dEntity;
		private var dieBulletInstance:Stage3dEntity;
		
		private var scoreValue:int;
		private var scoreLength:uint = 0;
		
		private var bulletPower:Number = 5;
		
		private var soundStream:SoundChannel;
		
		private var lives_label:Label;
		
		// SHAKE EFFECT
		private var oldViewMatrix:Matrix3D;
		private var shaderProgram1:Program3D;
		private var vect:Vector.<Number> = new <Number>[0, 1, 1, 1];
		private var winkIteration:Number = 0;
		private var winkIterationMax:Number = 2;
		private var bSmashShipEffect:Boolean = false;
		private var maxCameraSmashEffectAngle:Number = 1;
		private var cameraAngle:Number = 0;
		private var deg:Number = 1;
		private var bShake:Boolean = false;
		
		
		public function GameScene(context3D:Context3D)
		{
			super(context3D);
			
			Facade.gi().score = 0;
			Facade.gi().scoreLabel.text = "Score: 0";
			
			gameInput = Facade.gi().gameInput;
			
			initResources();
			
			viewmatrix.identity();
			viewmatrix.appendTranslation(0, 0, -3);
			
			oldViewMatrix = viewmatrix.clone();
			
			asteroids = new Vector.<Stage3dEntity>;
			asteroidsHealth = new Vector.<Number>;
			asteroidsAngles = new Vector.<Number>;
			
			bullets = new Vector.<Stage3dEntity>;
		
			
			gameTimer = new GameTimer(heartbeat, 1);
			
		
			asteroidTimer = new Timer(asteroidCreationDelay);
			asteroidTimer.addEventListener(TimerEvent.TIMER, createAsteroid);
			
			
			asteroidTimer.start();
			
			Style.fontSize = 25;
			Style.setStyle(Style.DARK);
			
			if(!Facade.gi().livesLabel)
			{
				Facade.gi().livesLabel = new Label(Facade.gi().stage, 1095, 48);
			}
			
			Facade.gi().scoreLabel.x = Facade.gi().stage.stageWidth - 150;
			lives_label = Facade.gi().livesLabel;
			lives_label.x = Facade.gi().scoreLabel.x;
			lives_label.text = "Health: " + String(Math.floor(ship_health/max_shiphealth * 100));
			lives_label.alpha = 0;
			
			Tweener.addTween(lives_label, {alpha:1, time:3});
			
			GameMusic.gi().start();
		}
		
		private function updateShipHealth():void
		{
			lives_label.text = "Health: " + String(Math.floor(ship_health/max_shiphealth * 100));
			lives_label.x = Facade.gi().scoreLabel.x;
		}
		
		protected function createAsteroid(event:TimerEvent):void
		{
			
			if(!gameInput.pressing.pause)
			{
				asteroids.push(asteroid.clone());
				
				var randomX:Number = Math.random();
				var randomY:Number = Math.random();
				var randomSide:Number = Math.random();
				var randomAbsX:Number = (Math.random() > 0.5) ? 1 : -1;
				var randomAbsY:Number = (Math.random() > 0.5) ? 1 : -1;
				

				var side:String = defineAsteroidSide(randomSide);
				
				if(side == "left"){
				
					asteroids[asteroids.length - 1].x = -4;
					asteroids[asteroids.length - 1].y = randomY*3 + randomAbsY * 3;
					
				}else if(side == "right"){
					
					asteroids[asteroids.length - 1].x = 4;
					asteroids[asteroids.length - 1].y = randomY*3 + randomAbsY * 3;
					
				}else if(side == "top"){
					
					asteroids[asteroids.length - 1].x = randomX*3 + randomAbsX * 3;
					asteroids[asteroids.length - 1].y = -4;
				
				}else if(side == "bottom"){
					
					asteroids[asteroids.length - 1].x = randomX*3 + randomAbsX * 3;
					asteroids[asteroids.length - 1].y = 4;
				
				}else if(side == "topleft"){
				
					asteroids[asteroids.length - 1].x = -4;
					asteroids[asteroids.length - 1].y = -4;
					
				}else if(side == "topright"){
					
					asteroids[asteroids.length - 1].x = 4;
					asteroids[asteroids.length - 1].y = -4;
				
				}else if(side == "bottomleft"){
					
					asteroids[asteroids.length - 1].x = -4;
					asteroids[asteroids.length - 1].y = 4;
				
				}else if(side == "bottomright"){
				
					asteroids[asteroids.length - 1].x = 4;
					asteroids[asteroids.length - 1].y = 4;
				}
				
				var asteroidAngle:Number = Math.atan((asteroids[asteroids.length - 1].y) /
													 asteroids[asteroids.length - 1].x);
				
				asteroidsAngles.push(asteroidAngle * MathUtils.RAD_TO_DEG);
				
				//asteroids[asteroids.length - 1].rotationDegreesZ = asteroidAngle * MathUtils.RAD_TO_DEG;
				
				if(randomAbsX == 1)
				{
					asteroids[asteroids.length - 1].rotationDegreesZ += 180;
				}
				
				asteroids[asteroids.length - 1].scaleXYZ = (Math.random()*0.08 + 0.08);
				
				asteroidsHealth.push(asteroids[asteroids.length - 1].scaleXYZ * 100);
			}
		}
		
		protected function defineAsteroidSide(randomSeed:Number):String
		{
			
				if(randomSeed >=0 && randomSeed < 0.125)
					return "left";
			
				if(randomSeed >=0.125 && randomSeed < 0.25)
					return "right";
			
				if(randomSeed >=0.25 && randomSeed < 0.375)
					return "top";
			
				if(randomSeed >=0.375 && randomSeed < 0.5)
					return "bottom";
				
				if(randomSeed >=0.5 && randomSeed < 0.625)
					return "topleft";
			
				if(randomSeed >=0.625 && randomSeed < 0.8)
					return "topright";
			
				if(randomSeed >=0.8 && randomSeed < 0.925)
					return "bottomleft";
			
				if(randomSeed >=0.925 && randomSeed <= 1)
					return "bottomright";
					
				
					return "";
			
	
		}
		
		override protected function initMeshes():void
		{
			ship = new Stage3dEntity(Assets.getMeshClass("ShipOBJ"), 
				_context3D,
				shaderProgram, 
				Assets.getTexture("ShipBitmap"), 1, true, true);
			
			universe = new Stage3dEntity(Assets.getMeshClass("SphereOBJ"), 
				_context3D,
				shaderProgram, 
				Assets.getTexture("SkyBitmap"), 1, true, false);
			
			earth = new Stage3dEntity(Assets.getMeshClass("SphereOBJ"), 
				_context3D,
				shaderProgram, 
				Assets.getTexture("EarthBitmap"), 1, true, true);
			
			asteroid = new GameActor(Assets.getMeshClass("AsteroidOBJ"),
										 _context3D,
										 shaderProgram, 
				                          Assets.getTexture("CratersBitmap"), 1, true, false);
			
			bullet = new Stage3dEntity(
				Assets.getMeshClass("BulletOBJ"), 
				_context3D, 
				shaderProgram, 
				Assets.getTexture("Particle1Bitmap"));
			
			bullet.rotationDegreesZ = 90;
			bullet.blendSrc = Context3DBlendFactor.ONE;
			bullet.blendDst = Context3DBlendFactor.ONE;
			
			// create a particle system
			particleSystem = new GameParticlesystem();
			
			// define the types of particles
			trace("Creating an explosion particle system...");
			
			particleSystem.defineParticle("explosion", 
				new Stage3dParticle(Assets.getMeshClass("Explosion1OBJ"), _context3D, 
					Assets.getTexture("Particle3Bitmap"), Assets.getMeshClass("Explosion2OBJ")));
			
			particleSystem.defineParticle("explosion1", 
				new Stage3dParticle(Assets.getMeshClass("Explosion1OBJ"),  _context3D, 
					Assets.getTexture("EngineBitmap"), Assets.getMeshClass("Explosion2OBJ")));
			
			particleSystem.defineParticle("blue",
				new Stage3dParticle(Assets.getMeshClass("Explosion1OBJ"),  _context3D, 
					Assets.getTexture("Particle1Bitmap"), Assets.getMeshClass("Explosion2OBJ")));
			
		}
		
		override protected function initTextures():void
		{	
			Assets.getTexture("SkyBitmap");
			Assets.getTexture("ShipBitmap");
		}
		
		override protected function initShaders():void
		{
			shaderProgram = Shaders.getShader("Shader1");
			shaderProgram = Shaders.getShader("Shader2");
		}
		
		private function checkYBound(num:Number):Boolean
		{
			if((num < 1.4) && (num > -1.4))
			{
				return true;
			}
			
			return false;
		
		}
		
		private function checkXBound(num:Number):Boolean
		{
			if((num < 2.35) && (num > -2.35))
			{
				return true;
			}
			
			return false;
			
		}
		
		override public function heartbeat(frameMs:Number = 0):void
		{
			
			particleSystem.step(frameMs);
			
			if(bShipDie) return;
			
			if(gameInput.pressing.pause)
			{
				return;
			}
			
			if(gameInput.pressing.up)
			{
				tempY = movY + Math.cos(-angle * MathUtils.DEG_TO_RAD) * speed;
				
				
				if(checkYBound(tempY))
				{
					movY = tempY;
				}
				
				particleSystem.particlesActive = 0;
				
				tempX = movX + Math.sin(-angle * MathUtils.DEG_TO_RAD) * speed;
				
				if(checkXBound(tempX))
				{
					movX = tempX;
				}
				
			}
			
			if(gameInput.pressing.down)
			{
				tempY = movY - Math.cos(-angle * MathUtils.DEG_TO_RAD) * speed;
				
				if(checkYBound(tempY))
				{
					movY = tempY;
				}
				
				
				
				tempX = movX - Math.sin(-angle * MathUtils.DEG_TO_RAD) * speed;
				
				if(checkXBound(tempX))
				{
					movX = tempX;
				}
				
			}
			
			
			if(gameInput.pressing.left)
			{
				
				angle += 1;
			
			}
			
			if(gameInput.pressing.right)
			{
				
				angle -= 1;
			}
			
			//ship.scaleXYZ = 0.3;
			ship.x = movX;
			ship.y = movY;
			ship.rotationDegreesZ = angle;
			
			ship.scaleXYZ = 0.3;
			
			if(gameInput.pressing.fire)
			{
				
				trace(getTimer() - gameTimer.gameElapsedTime);
			
				if (gameTimer.gameElapsedTime >= nextShootTime)
				{
					//trace("Fire!");
					nextShootTime = gameTimer.gameElapsedTime + shootDelay;
					createBullet();
				}
				
			}
			
			checkCollision(ship);
			
			var m:Matrix3D = ship.transform.clone();
			m.prependTranslation(0, -0.8, 0);
		
			if(gameInput.pressing.up)
			{
				particleSystem.spawn("explosion", m, 500, 0.01,  0.03);
			}
			
			if(bShipDie)
			{
				
					particleSystem.spawn("explosion1", m, 500, 0.2, 0.2);
					particleSystem.spawn("explosion1", m, 500, 0.2, 0.2);
					particleSystem.spawn("explosion1", m, 500, 0.2, 0.2);
					particleSystem.spawn("explosion1", m, 500, 0.2, 0.2);
					
					soundStream = explosionSound.play();
					soundStream.soundTransform = new SoundTransform(0.05);
					
					Tweener.addTween(Facade.gi().gameOverLabel, {alpha:1, time: 5, onComplete: function():void{
					
								Tweener.addTween(Facade.gi().gameOverLabel, {alpha:0, time:2, onComplete: function():void{
										
											GameDispatcher.gi().player_die();
			
							
									}
								});
								
								
								Tweener.addTween([Facade.gi().scoreLabel, Facade.gi().livesLabel], {alpha:0, time:2});
								
					}});
				
				
				
				
			}

		}
		
		private function createBullet():void
		{
			
			var m:Matrix3D = ship.transform.clone();
			m.prependTranslation(0, 1, 0);
			
			var bullet_temp:Stage3dEntity = bullet.clone();
				bullet_temp.x = m.position.x;
				bullet_temp.y = m.position.y;
				//bullet
				bullet_temp.z = ship.z - 0.2;
				bullet_temp.rotationDegreesZ = ship.rotationDegreesZ + 90;
				bullet_temp.blendSrc = Context3DBlendFactor.ONE;
				bullet_temp.blendDst = Context3DBlendFactor.ONE;
					
			
				bullets.push(bullet_temp);
				soundStream = gunSound.play();
				soundStream.soundTransform = new SoundTransform(0.08);
		}
		
		private function checkCollision(obj:Stage3dEntity, bBullet:Boolean = false):Boolean
		{
			const KOEF_RADIUS_SCALE:Number = 2.3;
			var radius1:Number = 0;
			var radius2:Number = 0;
			
			var deltaX:Number = 0;
			var deltaY:Number = 0;
			
			var dist:Number = 0;
			
		
			
			for(var i:int = 0; i < asteroids.length; i++)
			{
				if(asteroids[i] == obj)
				{
					continue;
				
				}else{
				
					radius1 = asteroids[i].scaleXYZ * KOEF_RADIUS_SCALE;
					
					if(ship == obj)
					{
						radius2 = 0.3;
						
					}else if(bBullet){
						
						radius2 = 0.02;
					
					}else{
						
						radius2 = obj.scaleXYZ * KOEF_RADIUS_SCALE;
					}
					
					deltaX = obj.x - asteroids[i].x;
					deltaY = obj.y - asteroids[i].y;
					
					dist = Math.sqrt(deltaX * deltaX + deltaY * deltaY);
					
					if(dist <= (radius1 + radius2))
					{	
						if(ship == obj)
						{
							ship_health --;
							lives_label.text = "Health: " + String(Math.floor(ship_health/max_shiphealth * 100));
							
							dieMeteoriteInstance = asteroids[i];
							
							if(ship_health <= 0)
							{
								bShipDie = true;
							
							}else{
								
								bSmashShipEffect = true;
							}
							
						}else if(bBullet)
						{
							asteroidsHealth[i] -= bulletPower;
							if(asteroidsHealth[i] <= 0)
							{
								dieMeteoriteInstance = asteroids[i];
							
							}else{
							
								firedAsteroidInstance = asteroids[i];
							}
							
							var collisionPointX:Number = 
								((asteroids[i].x * obj.scaleXYZ) + (obj.x * asteroids[i].scaleXYZ)) 
								/ (asteroids[i].scaleXYZ + obj.scaleXYZ);
							
							var collisionPointY:Number = 
								((asteroids[i].y * obj.scaleXYZ) + (obj.y * asteroids[i].scaleXYZ)) 
								/ (asteroids[i].scaleXYZ + obj.scaleXYZ);
							
							var m:Matrix3D = new Matrix3D;
								m.appendTranslation(collisionPointX, collisionPointY, 0);
							
							particleSystem.spawn("blue", m, 200, 0.02, 0.02);
							dieBulletInstance = obj;
						}
						else{
							
							trace(obj.rotationDegreesX);
							trace(obj.rotationDegreesY);
						
							asteroidsAngles[i] += 45;
							//obj.rotationDegreesZ += 45;
							//Tweener.addTween([obj], {time: 0.2, rotationDegreesZ: 45});
						}
						
						return true;
					}	
				}
			}
			
			return false;
		}
		
		private function smashShipEffect(frameMs:Number):void
		{
			
			bShake = true;
			
			if((vect[1] > 0) && (vect[2] > 0))
			{
				vect[1] -= 0.05;
				vect[2] -= 0.05;
				
			
			}else{
				
				winkIteration += 1;
				
				if(winkIteration >= winkIterationMax)
				{
					bSmashShipEffect = false;
					bShake = false;
					viewmatrix.identity();
					viewmatrix.appendTranslation(0, 0, -3);
					
					winkIteration = 0;
					vect[1] = 1;
					vect[2] = 1;
					return;
				}
				
				vect[1] = 1;
				vect[2] = 1;
			
			}
			
			
			_context3D.setProgram(shaderProgram1);
			_context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 5, vect, -1);
		}
		
		private function shakeCamera():void
		{
			
			if((cameraAngle < maxCameraSmashEffectAngle) && (cameraAngle > -maxCameraSmashEffectAngle))
			{
				viewmatrix.appendRotation(deg, Vector3D.Y_AXIS);
				cameraAngle += deg;
			
			}else
			{
				deg *= -1;
				viewmatrix.appendRotation(deg, Vector3D.Y_AXIS);
				cameraAngle += deg;
			}
	
		}
		
		
		private function shipDie():void
		{
			
		}
		
		override public function render():void
		{
			t++;
			
			gameTimer.tick();
			
			if(bShake)
			{
				shakeCamera();
			}
			
			if(bSmashShipEffect)
			{
				smashShipEffect(gameTimer.frameMs);
			
			}else{
			
				_context3D.setProgram(shaderProgram);
			}
			
			heartbeat(gameTimer.frameMs);
			
			if(!gameInput.pressing.pause)
			{
				earth.rotationDegreesX += 0.7;
				earth.rotationDegreesZ = 90;
			}
			
			earth.z = -4;
			
			earth.render(viewmatrix, projectionmatrix);
			
			if(!bShipDie)
			{
				ship.render(viewmatrix, projectionmatrix);
			}
			
			universe.scaleXYZ = 1.5;
			universe.cullingMode = Context3DTriangleFace.NONE;
			universe.render(viewmatrix, projectionmatrix);
			
			
			
				for(var i:int = 0; i < asteroids.length; i++)
				{
					if(!gameInput.pressing.pause)
					{
						//asteroids[i].x += Math.cos(asteroids[i].rotationDegreesZ * MathUtils.DEG_TO_RAD) * 0.01;
						//asteroids[i].y += Math.sin(asteroids[i].rotationDegreesZ * MathUtils.DEG_TO_RAD) * 0.01;
						asteroids[i].x += Math.cos(asteroidsAngles[i]) * 0.01;
						asteroids[i].y += Math.sin(asteroidsAngles[i]) * 0.01;
						
						checkCollision(asteroids[i]);
						
						asteroids[i].rotationDegreesX += 1;
						asteroids[i].rotationDegreesY += 1;
					}
					
					if((asteroids[i].x > 6)||(asteroids[i].x < -6)||
						(asteroids[i].y > 6)||(asteroids[i].y < -6))
					{
						deleteAsteroidsIndexes.push(i);	
					}
					
					if(asteroids[i] == dieMeteoriteInstance)
					{ 
						deleteAsteroidsIndexes.push(i);
						particleSystem.spawn("explosion1",	dieMeteoriteInstance.transform, 1000, 0.15, 0.15);
						
						soundStream = explosionSound.play();
						soundStream.soundTransform = new SoundTransform(0.05);
						
						
						
						scoreValue = int(asteroids[i].scaleXYZ * 1000);
						Facade.gi().score += scoreValue;
						
						if(scoreLength !=  (String(Facade.gi().score).length))
						{
							
							Facade.gi().scoreLabel.x -= (String(Facade.gi().score).length - 2) * 10;
							scoreLength = String(Facade.gi().score).length;
						}
						Facade.gi().scoreLabel.text = "Score:" + Facade.gi().score;
						updateShipHealth();
					
						dieMeteoriteInstance = null;
					}
				
					asteroids[i].render(viewmatrix, projectionmatrix);
				}
				
			for(var d:int = 0; d < deleteAsteroidsIndexes.length; d++)
			{
			
				asteroids.splice(deleteAsteroidsIndexes[d], 1);
				asteroidsAngles.splice(deleteAsteroidsIndexes[d], 1);
				asteroidsHealth.splice(deleteAsteroidsIndexes[d], 1);
			}
			
			if(!gameInput.pressing.pause)
			{
				particleSystem.render(viewmatrix, projectionmatrix);
			}
			
			bullet.scaleXYZ = 0.06;
			
		
			for(i = 0; i < bullets.length; i++)
			{
				
				if(!gameInput.pressing.pause)
				{
					bullets[i].x += Math.cos(bullets[i].rotationDegreesZ * MathUtils.DEG_TO_RAD) * (speed*2);
					bullets[i].y += Math.sin(bullets[i].rotationDegreesZ * MathUtils.DEG_TO_RAD) * (speed*2);
					
					checkCollision(bullets[i], true);
				}
				
				trace("bullets[i].x" + bullets[i].x);
				
				if((bullets[i].x > 4)||(bullets[i].x < -4)||
				    (bullets[i].y > 4)||(bullets[i].y < -4))
				{
					deleteBulletsIndexes.push(i);	
				}
				
				if(bullets[i] == dieBulletInstance)
				{
					deleteBulletsIndexes.push(i);
					
					//particleSystem.spawn("explosion1", firedAsteroidInstance.transform, 1000, 0.01, 0.01);
					
					dieBulletInstance = null;
				}

				
				bullets[i].render(viewmatrix, projectionmatrix);	
			}
			
			for(d = 0; d < deleteBulletsIndexes.length; d++)
			{
				bullets.splice(deleteBulletsIndexes[d], 1);
			}
			
			deleteBulletsIndexes = new Vector.<int>;
			deleteAsteroidsIndexes = new Vector.<int>;
			
			
		}
		
		override public function dispose():void
		{
			
		}
	}
}