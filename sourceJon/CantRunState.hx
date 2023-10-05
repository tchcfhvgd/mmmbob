package;

import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.FlxG;
import flixel.FlxSprite;

/**
 * ...
 * i took this code from pompom im sorry
 */
class CantRunState extends FlxState
{
	override function create():Void
	{
		super.create();

		FlxG.sound.playMusic(Paths.music('youcantrun'), 1, false);

		add(new FlxSprite(0, 0, Paths.image('bob/cantruncantrunfartpiss', 'shared')));

		FlxG.camera.fade(FlxColor.BLACK, 0.8, true);

		new FlxTimer().start(24, function(e:FlxTimer)
		{
			trace("ENDING");

			FlxG.switchState(new PlayState());
		});
	}
}
