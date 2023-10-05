package;

import haxe.Exception;
import haxe.Json;
#if sys
import sys.io.File;
#end

typedef KeyPress = {
	time:Float,
	key:String
}

typedef KeyRelease = {
	time:Float,
	key:String
}

typedef ReplayData = {
	replayGameVer:String,
	timestamp:Date,
	songName:String,
	songDiff:Int,
	keyPresses:Array<KeyPress>,
	keyReleases:Array<KeyRelease>
}

class Replay
{
	public static final version:String = '1.0'; // replay file version

	public var path:String;
	public var replay:ReplayData;

	public function new(path:String):Void
	{
		this.path = path;

		replay = {
			songName: 'Tutorial',
			songDiff: 1,
			keyPresses: [],
			keyReleases: [],
			replayGameVer: version,
			timestamp: Date.now()
		};
	}

	public static function LoadReplay(path:String):Replay
	{
		var rep:Replay = new Replay(path);
		rep.LoadFromJSON();
		return rep;
	}

	public function SaveReplay():Void
	{
		final data:ReplayData = {
			songName: PlayState.SONG.song.toLowerCase(),
			songDiff: PlayState.storyDifficulty,
			keyPresses: replay.keyPresses,
			keyReleases: replay.keyReleases,
			timestamp: Date.now(),
			replayGameVer: version
		};

		#if sys
		try
		{
			File.saveContent('assets/replays/replay-${PlayState.SONG.song}-time${Date.now().getTime()}.kadeReplay', Json.stringify(data));
		}
		catch (e:Exception)
			trace(e.message);
		#end
	}

	public function LoadFromJSON():Void
	{
		#if sys
		try
		{
			replay = Json.parse(File.getContent('assets/replays/$path'));
		}
		catch (e:Exception)
			trace(e.message);
		#end
	}
}
