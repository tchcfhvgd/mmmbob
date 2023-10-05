package;

import flixel.FlxG;
import flixel.FlxSprite;

class WarningState extends MusicBeatState
{
	override function create():Void
	{
		super.create();

		FlxG.sound.music.fadeIn(0.5, 0.7, 0.1);

		add(new FlxSprite(0, 0, Paths.image('WARNINGSCRENWARNINGSCREN', 'preload')));
	}

	override function update(elapsed:Float):Void
	{
		#if mobile
		for (touch in FlxG.touches.list)
		{
			if (touch.justPressed)
			{
				FlxG.sound.music.fadeIn(0.5, 0.1, 0.7);

				FlxG.switchState(new ThankYouState());
			}
		}
		#end

		if (controls.ACCEPT)
		{
			FlxG.sound.music.fadeIn(0.5, 0.1, 0.7);

			FlxG.switchState(new ThankYouState());
		}

		super.update(elapsed);
	}
}
