package;

import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxSprite;
#if sys
import sys.FileSystem;
import sys.io.File;
#end

class LoadReplayState extends MusicBeatState
{
	var curSelected:Int = 0;
	var songs:Array<FreeplayState.SongMetadata> = [];
	var controlsStrings:Array<String> = [];
	var actualNames:Array<String> = [];
	var grpControls:FlxTypedGroup<Alphabet>;
	var versionShit:FlxText;
	var poggerDetails:FlxText;

	override function create():Void
	{
		#if sys
		controlsStrings = FileSystem.readDirectory('assets/replays');
		#end

		controlsStrings.sort(Reflect.compare);

		final songList:Array<String> = CoolUtil.coolTextFile(Paths.txt('freeplaySonglist'));

		for (i in 0...songList.length)
		{
			songs.push({
				name: songList[i].split(':')[0],
				character: songList[i].split(':')[1],
				week: Std.parseInt(songList[i].split(':')[2])
			});
		}

		for (i in 0...controlsStrings.length)
		{
			actualNames[i] = controlsStrings[i];

			final rep:Replay = Replay.LoadReplay(controlsStrings[i]);

			controlsStrings[i] = controlsStrings[i].split("time")[0] + " " + (rep.replay.songDiff == 2 ? "HARD" : rep.replay.songDiff == 1 ? "EASY" : "NORMAL");
		}

		if (controlsStrings.length <= 0)
			controlsStrings.push("No Replays...");

		var menuBG:FlxSprite = new FlxSprite(0, 0, Paths.image('menuDesat'));
		menuBG.color = 0xFFea71fd;
		menuBG.setGraphicSize(Std.int(menuBG.width * 1.1));
		menuBG.updateHitbox();
		menuBG.screenCenter();
		menuBG.antialiasing = true;
		add(menuBG);

		grpControls = new FlxTypedGroup<Alphabet>();
		add(grpControls);

		for (i in 0...controlsStrings.length)
		{
			var controlLabel:Alphabet = new Alphabet(0, (70 * i) + 30, controlsStrings[i], true, false);
			controlLabel.isMenuItem = true;
			controlLabel.targetY = i;
			grpControls.add(controlLabel);
		}

		versionShit = new FlxText(5, FlxG.height - 34, 0,
			"Replay Loader (ESCAPE TO GO BACK)\nNOTICE!!!! Replays are in a beta stage, and they are probably not 100% correct. expect misses and other stuff that isn't there!",
			12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);

		poggerDetails = new FlxText(5, 34, 0, "Replay Details - \nnone", 12);
		poggerDetails.scrollFactor.set();
		poggerDetails.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(poggerDetails);

		changeSelection();

		super.create();
	}

	public function getWeekNumbFromSong(name:String):Int
	{
		var week:Int = 0;

		for (song in songs)
		{
			if (song.name.toLowerCase() == name)
			{
				week = song.week;
				break;
			}
		}

		return week;
	}

	override function update(elapsed:Float):Void
	{
		super.update(elapsed);

		if (controls.UP_P)
			changeSelection(-1);
		else if (controls.DOWN_P)
			changeSelection(1);

		if (controls.BACK)
			FlxG.switchState(new OptionsMenu());
		else if (controls.ACCEPT && grpControls.members[curSelected].text != "No Replays...")
		{
			final poop:String = Highscore.formatSong(PlayState.rep.replay.songName.toLowerCase(), PlayState.rep.replay.songDiff);

			PlayState.SONG = Song.loadFromJson(poop, PlayState.rep.replay.songName.toLowerCase());
			PlayState.rep = Replay.LoadReplay(actualNames[curSelected]);
			PlayState.loadRep = true;
			PlayState.isStoryMode = false;
			PlayState.storyDifficulty = PlayState.rep.replay.songDiff;
			PlayState.storyWeek = getWeekNumbFromSong(PlayState.rep.replay.songName);

			FlxG.switchState(new PlayState());
		}
	}

	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected = FlxMath.wrap(curSelected + change, 0, grpControls.length - 1);

		var rep:Replay = Replay.LoadReplay(actualNames[curSelected]);

		poggerDetails.text = "Replay Details - \nDate Created: "
			+ rep.replay.timestamp
			+ "\nSong: "
			+ rep.replay.songName
			+ "\nReplay Version: "
			+ (rep.replay.replayGameVer != Replay.version ? "OUTDATED" : "Latest");

		var bullShit:Int = 0;

		for (i in 0...grpControls.members.length)
		{
			grpControls.members[i].targetY = i - curSelected;
			grpControls.members[i].alpha = grpControls.members[i].targetY == 0 ? 1 : 0.6;
		}
	}
}
