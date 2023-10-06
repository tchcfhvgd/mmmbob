package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.util.FlxColor;
#if FEATURE_VIDEOS
import hxvlc.flixel.FlxVideo;
#end

class VideoState extends MusicBeatState
{
	var leSource:String;
	var transClass:FlxState;
	var fuckingVolume:Float = 1;

	#if FEATURE_VIDEOS
	var video:FlxVideo;
	#end

	public function new(source:String, toTrans:FlxState):Void
	{
		super();

		FlxG.autoPause = false;

		fuckingVolume = FlxG.sound.music.volume;

		FlxG.sound.music.volume = 0;

		leSource = source;
		transClass = toTrans;
	}
	
	override function create():Void
	{
		add(new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK));

		super.create();

		#if FEATURE_VIDEOS
		video = new FlxVideo();
		video.onEndReached.add(function()
		{
			video.dispose();

			FlxG.autoPause = true;
			FlxG.sound.music.volume = fuckingVolume;
			FlxG.switchState(transClass);
		});
		video.play(leSource);
		#else
		FlxG.autoPause = true;
		FlxG.sound.music.volume = fuckingVolume;
		FlxG.switchState(transClass);
		#end
	}
	
	#if FEATURE_VIDEOS
	override function update(elapsed:Float):Void
	{
		super.update(elapsed);

		#if mobile
		for (touch in FlxG.touches.list)
			if (touch.justPressed && video.isPlaying)
				video.onEndReached.dispatch();
		#end

		if (controls.ACCEPT && video.isPlaying)
			video.onEndReached.dispatch();
	}
	#end
}
