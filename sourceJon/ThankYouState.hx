package;

import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxSprite;

class ThankYouState extends MusicBeatState
{
	override function create():Void
	{
		super.create();

		add(new FlxSprite(0, 0, Paths.image('bob/thankers', 'shared')));

		FlxG.camera.fade(FlxColor.BLACK, 0.8, true);
	}

	override function update(elapsed:Float):Void
	{
		#if mobile
		for (touch in FlxG.touches.list)
			if (touch.justPressed)
				FlxG.switchState(new MainMenuState());
		#end

		if (controls.ACCEPT)
			FlxG.switchState(new MainMenuState());

		super.update(elapsed);
	}
}
