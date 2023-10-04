package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.util.FlxColor;
import hxvlc.flixel.FlxVideo;

class VideoState extends MusicBeatState
{
	var leSource:String;
	var transClass:FlxState;
	var video:FlxVideo;

	public function new(source:String, toTrans:FlxState):Void
	{
		super();

		FlxG.autoPause = false;

		leSource = source;
		transClass = toTrans;
	}
	
	override function create():Void
	{
		super.create();

		add(new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK));

		video = new FlxVideo();
		video.onEndReached.add(function()
		{
			video.dispose();

			FlxG.autoPause = true;

			FlxG.switchState(transClass);
		});
		video.play(leSource);
	}
	
	override function update(elapsed:Float):Void
	{
		super.update(elapsed);
		
		if (controls.ACCEPT && video.isPlaying)
			onEndReached.dispatch();
	}
}
