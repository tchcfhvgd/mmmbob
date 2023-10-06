package;

import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.FlxG;
import flixel.FlxSprite;

using StringTools;

typedef SongMetadata = {
	var name:String;
	var character:String;
	var week:Int;
}

class FreeplayState extends MusicBeatState
{
	var songs:Array<SongMetadata> = [];
	var curSelected:Int = 0;
	var curDifficulty:Int = 1;

	var scoreText:FlxText;
	var diffText:FlxText;
	var lerpScore:Int = 0;
	var intendedScore:Int = 0;

	var grpSongs:FlxTypedGroup<Alphabet>;
	var icons:Array<HealthIcon> = [];
	var waitTimer:FlxTimer;

	override function create():Void
	{
		final songList:Array<String> = CoolUtil.coolTextFile(Paths.txt('freeplaySonglist'));

		for (i in 0...songList.length)
		{
			songs.push({
				name: songList[i].split(':')[0],
				character: songList[i].split(':')[1],
				week: Std.parseInt(songList[i].split(':')[2])
			});
		}

		#if FEATURE_DISCORD
		// Updating Discord Rich Presence
		Discord.changePresence("In the Menus", null);
		#end

		add(new FlxSprite(0, 0, Paths.image('menuBGBlue')));

		grpSongs = new FlxTypedGroup<Alphabet>();
		add(grpSongs);

		for (i in 0...songs.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, songs[i].name, true, false);
			songText.isMenuItem = true;
			songText.targetY = i;
			grpSongs.add(songText);

			var icon:HealthIcon = new HealthIcon(songs[i].character);
			icon.sprTracker = songText;

			// using a FlxGroup is too much fuss!
			icons.push(icon);
			add(icon);
		}

		scoreText = new FlxText(FlxG.width * 0.7, 5, 0, "", 32);
		scoreText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT);

		var scoreBG:FlxSprite = new FlxSprite(scoreText.x - 6, 0).makeGraphic(Std.int(FlxG.width * 0.35), 66, 0xFF000000);
		scoreBG.alpha = 0.6;
		add(scoreBG);

		diffText = new FlxText(scoreText.x, scoreText.y + 36, 0, "", 24);
		diffText.font = scoreText.font;
		add(diffText);

		add(scoreText);

		waitTimer = new FlxTimer();

		changeSelection();
		changeDiff();

		#if mobile
		addVirtualPad(LEFT_FULL, A_B);
		#end

		super.create();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.sound.music.volume < 0.7)
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;

		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, 0.4));

		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;

		scoreText.text = 'PERSONAL BEST:$lerpScore';

		if (controls.UP_P)
			changeSelection(-1);
		else if (controls.DOWN_P)
			changeSelection(1);

		if (controls.LEFT_P)
			changeDiff(-1);
		else if (controls.RIGHT_P)
			changeDiff(1);

		if (controls.BACK)
			FlxG.switchState(new MainMenuState());
		else if (controls.ACCEPT)
		{
			final poop:String = Highscore.formatSong(songs[curSelected].name.toLowerCase(), curDifficulty);

			PlayState.SONG = Song.loadFromJson(poop, songs[curSelected].name.toLowerCase());
			PlayState.isStoryMode = false;
			PlayState.storyDifficulty = curDifficulty;
			PlayState.storyWeek = songs[curSelected].week;
			FlxG.switchState(new PlayState());
		}
	}

	function changeDiff(change:Int = 0)
	{
		curDifficulty = FlxMath.wrap(curDifficulty + change, 0, 2);

		intendedScore = Highscore.getScore(songs[curSelected].name, curDifficulty);

		switch (curDifficulty)
		{
			case 0:
				diffText.text = "EASY";
			case 1:
				diffText.text = 'NORMAL';
			case 2:
				diffText.text = "HARD";
		}
	}

	function changeSelection(change:Int = 0)
	{
		waitTimer.cancel();

		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected = FlxMath.wrap(curSelected + change, 0, songs.length - 1);

		intendedScore = Highscore.getScore(songs[curSelected].name, curDifficulty);

		waitTimer.start(1, (tmr:FlxTimer) -> FlxG.sound.playMusic(Paths.inst(songs[curSelected].name), 0));

		for (i in 0...grpSongs.members.length)
		{
			grpSongs.members[i].targetY = i - curSelected;
			grpSongs.members[i].alpha = grpSongs.members[i].targetY == 0 ? 1 : 0.6;

			icons[i].alpha = grpSongs.members[i].alpha;
		}
	}
}
