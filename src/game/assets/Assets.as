package game.assets
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.textures.Texture;
	import flash.utils.Dictionary;

	public class Assets
	{
		[Embed(source="../../../resources/imgs/textures/craters.jpg")]
		public static const CratersBitmap:Class;
		
		[Embed(source="../../../resources/imgs/textures/engine.jpg")]
		public static const EngineBitmap:Class;
		
		[Embed(source="../../../resources/imgs/textures/earth.jpg")]
		public static const EarthBitmap:Class;
		
		[Embed(source="../../../resources/imgs/textures/sky.jpg")]
		public static const SkyBitmap:Class;
		
		[Embed(source="../../../resources/imgs/textures/spaceship_texture.jpg")]
		public static const ShipBitmap:Class;
		
		[Embed(source="../../../resources/imgs/textures/titlescreen.png")]
		public static const TitleBitmap:Class;
		
		[Embed(source="../../../resources/imgs/textures/particle1.jpg")]
		public static const Particle1Bitmap:Class;
		
		[Embed(source="../../../resources/imgs/textures/particle2.jpg")]
		public static const Particle2Bitmap:Class;
		
		[Embed(source="../../../resources/imgs/textures/particle3.jpg")]
		public static const Particle3Bitmap:Class;
		
		
		[Embed(source="../../../resources/imgs/textures/particle4.jpg")]
		public static const Particle4Bitmap:Class;
		
		
		[Embed(source="../../../resources/3dmodels/spaceship.obj", mimeType="application/octet-stream")]
		public static const ShipOBJ:Class;
		
		[Embed(source="../../../resources/3dmodels/sphere3d.obj", mimeType="application/octet-stream")]
		public static const SphereOBJ:Class;
		
		[Embed(source="../../../resources/3dmodels/asteroid.obj", mimeType="application/octet-stream")]
		public static const AsteroidOBJ:Class;
		
		[Embed(source="../../../resources/3dmodels/explosion1.obj", mimeType="application/octet-stream")]
		public static const Explosion1OBJ:Class;
		
		[Embed(source="../../../resources/3dmodels/explosion2.obj", mimeType="application/octet-stream")]
		public static const Explosion2OBJ:Class;
		
		[Embed (source = "../../../resources/3dmodels/bullet.obj", mimeType = "application/octet-stream")] 
		public static const BulletOBJ:Class;
		
		
		private static var gameTextures:Dictionary = new Dictionary;
		private static var gameMeshes:Dictionary = new Dictionary;
		
		// reusable pointers
		private var texture:Texture;
		
		public static var context:Context3D;
		
		
		public static function getTexture(name:String):Texture
		{
			if(gameTextures[name] == undefined)
			{
				var bitmap:Bitmap = new Assets[name]();
				var bmpData:BitmapData = new BitmapData(bitmap.width, bitmap.height, true, 0x0);
					bmpData.draw(bitmap);
				
				
				if(isContextDefined())
				{
					gameTextures[name] = context.createTexture(bmpData.width, 
														   bmpData.height,
														   Context3DTextureFormat.BGRA,
														   false);
					
					uploadTexture(gameTextures[name], bitmap.bitmapData);
						
				}
				
			}
			
			return gameTextures[name];
		}
		
		
		public static function getMeshClass(name:String):Class
		{
			if(!Assets[name])
			{
				throw new Error("No asset mesh class with this name: " + name);
				return null;
				
			}
			
			return Assets[name];
			
		}
		
		private static function isContextDefined():Boolean
		{
			if(context)
			{
				return true;
			
			}else{
			
				throw new Error
				("Please, pass define context for static property of Assets.as");
				
			}
			
			return false;
		}
		
		private static function uploadTexture(atexture:Texture, 
											  bmpData:BitmapData):void
		{
			// TODO implement mipmapping
			atexture.uploadFromBitmapData(bmpData, 0);
		}
	}
}