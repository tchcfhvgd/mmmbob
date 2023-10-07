package;

import flixel.graphics.frames.FlxAtlasFrames;
import flixel.FlxG;
import openfl.utils.AssetType;
import openfl.utils.Assets;

class Paths
{
	static function getPath(file:String, type:AssetType, library:Null<String>):String
	{
		if (library != null)
			return getLibraryPath(file, library);

		final levelPath:String = getLibraryPathForce(file, "shared");
		if (Assets.exists(levelPath, type))
			return levelPath;

		return getPreloadPath(file);
	}

	static public function getLibraryPath(file:String, library = "preload"):String
	{
		return if (library == "preload" || library == "default") getPreloadPath(file); else getLibraryPathForce(file, library);
	}

	inline static function getLibraryPathForce(file:String, library:String):String
	{
		return '$library:assets/$library/$file';
	}

	inline static function getPreloadPath(file:String):String
	{
		return 'assets/$file';
	}

	inline static public function file(file:String, type:AssetType = TEXT, ?library:String):String
	{
		return getPath(file, type, library);
	}

	inline static public function txt(key:String, ?library:String):String
	{
		return getPath('data/$key.txt', TEXT, library);
	}

	inline static public function xml(key:String, ?library:String):String
	{
		return getPath('data/$key.xml', TEXT, library);
	}

	inline static public function json(key:String, ?library:String):String
	{
		return getPath('data/$key.json', TEXT, library);
	}

	static public function sound(key:String, ?library:String):String
	{
		return getPath('sounds/$key.ogg', SOUND, library);
	}

	inline static public function soundRandom(key:String, min:Int, max:Int, ?library:String):String
	{
		return sound(key + FlxG.random.int(min, max), library);
	}

	inline static public function music(key:String, ?library:String):String
	{
		return getPath('music/$key.ogg', MUSIC, library);
	}

	inline static public function voices(song:String):String
	{
		return getPath('${song.toLowerCase()}/Voices.ogg', MUSIC, 'songs');
	}

	inline static public function inst(song:String):String
	{
		return getPath('${song.toLowerCase()}/Inst.ogg', MUSIC, 'songs');
	}

	inline static public function image(key:String, ?library:String):String
	{
		return getPath('images/$key.png', IMAGE, library);
	}

	inline static public function video(key:String):String
	{
		return getPreloadPath('videos/$key.webm');
	}

	inline static public function font(key:String):String
	{
		final path:String = getPreloadPath('fonts/$key');

		if (Assets.exists(path, FONT))
			return Assets.getFont(path).fontName;
			
		return null;
	}

	inline static public function getSparrowAtlas(key:String, ?library:String):FlxAtlasFrames
	{
		return FlxAtlasFrames.fromSparrow(image(key, library), file('images/$key.xml', library));
	}

	inline static public function getPackerAtlas(key:String, ?library:String):FlxAtlasFrames
	{
		return FlxAtlasFrames.fromSpriteSheetPacker(image(key, library), file('images/$key.txt', library));
	}
}
