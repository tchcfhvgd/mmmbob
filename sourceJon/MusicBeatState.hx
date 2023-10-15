package;

import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import openfl.Lib;
import Conductor.BPMChangeEvent;
import flixel.FlxG;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.ui.FlxUIState;
import flixel.math.FlxRect;
import flixel.util.FlxTimer;
#if mobile
import flixel.input.actions.FlxActionInput;
import flixel.mobile.FlxHitbox;
import flixel.mobile.FlxVirtualPad;
import flixel.util.FlxDestroyUtil;
import flixel.FlxCamera;
#end

class MusicBeatState extends FlxUIState
{
	private var lastBeat:Float = 0;
	private var lastStep:Float = 0;

	private var curStep:Int = 0;
	private var curBeat:Int = 0;
	private var controls(get, never):Controls;

	inline function get_controls():Controls
		return PlayerSettings.player1.controls;

	#if mobile
	var hitbox:FlxHitbox;
	var vPad:FlxVirtualPad;

	var trackedInputsHitbox:Array<FlxActionInput> = [];
	var trackedInputsVirtualPad:Array<FlxActionInput> = [];

	public function addVPad(dPad:FlxDPadMode, action:FlxActionMode, ?visible:Bool = true):Void
	{
		if (vPad != null)
			removeVPad();

		vPad = new FlxVirtualPad(dPad, action);
		vPad.visible = visible;
		add(vPad);

		controls.setVPad(vPad, dPad, action);
		trackedInputsVirtualPad = controls.trackedInputs;
		controls.trackedInputs = [];
	}

	public function addVPadCamera(defaultDrawTarget:Bool = true):Void
	{
		if (vPad != null)
		{
			var camControls:FlxCamera = new FlxCamera();
			FlxG.cameras.add(camControls, defaultDrawTarget);
			camControls.bgColor.alpha = 0;
			vPad.cameras = [camControls];
		}
	}

	public function removeVPad():Void
	{
		if (trackedInputsVirtualPad.length > 0)
			controls.removeVControlsInput(trackedInputsVirtualPad);

		if (vPad != null)
			remove(vPad);
	}

	public function addHitbox(?visible:Bool = true):Void
	{
		if (hitbox != null)
			removeHitbox();

		hitbox = new FlxHitbox(4, Std.int(FlxG.width / 4), FlxG.height, [0xC34B9A, 0x00FFFF, 0x12FB06, 0xF9393F]);
		hitbox.visible = visible;
		add(hitbox);

		controls.setHitbox(hitbox);
		trackedInputsHitbox = controls.trackedInputs;
		controls.trackedInputs = [];
	}

	public function addHitboxCamera(DefaultDrawTarget:Bool = true):Void
	{
		if (hitbox != null)
		{
			var camControls:FlxCamera = new FlxCamera();
			FlxG.cameras.add(camControls, DefaultDrawTarget);
			camControls.bgColor.alpha = 0;
			hitbox.cameras = [camControls];
		}
	}

	public function removeHitbox():Void
	{
		if (trackedInputsHitbox.length > 0)
			controls.removeVControlsInput(trackedInputsHitbox);

		if (hitbox != null)
			remove(hitbox);
	}
	#end

	override function create():Void
	{
		cast(Lib.current.getChildAt(0), Main).setFPSCap(FlxG.save.data.fpsCap);

		if (transIn != null)
			trace('reg ' + transIn.region);

		super.create();
	}

	final colors:Array<FlxColor> = [
		FlxColor.fromRGB(148, 0, 211),
		FlxColor.fromRGB(75, 0, 130),
		FlxColor.fromRGB(0, 0, 255),
		FlxColor.fromRGB(0, 255, 0),
		FlxColor.fromRGB(255, 255, 0),
		FlxColor.fromRGB(255, 127, 0),
		FlxColor.fromRGB(255, 0 , 0)
	];

	var skippedFrames:Int = 0;

	override function update(elapsed:Float):Void
	{
		final oldStep:Int = curStep;

		updateCurStep();
		updateBeat();

		if (oldStep != curStep && curStep > 0)
			stepHit();

		if (FlxG.save.data.fpsRain && skippedFrames >= 6)
			{
				if (currentColor >= colors.length)
					currentColor = 0;

				cast(Lib.current.getChildAt(0), Main).changeFPSColor(colors[currentColor]);
				currentColor++;
				skippedFrames = 0;
			}
			else
				skippedFrames++;

		if (cast(Lib.current.getChildAt(0), Main).getFPSCap != FlxG.save.data.fpsCap)
			cast(Lib.current.getChildAt(0), Main).setFPSCap(FlxG.save.data.fpsCap);

		super.update(elapsed);
	}

	override function destroy():Void
	{
		#if mobile
		if (trackedInputsHitbox.length > 0)
			controls.removeVControlsInput(trackedInputsHitbox);

		if (trackedInputsVirtualPad.length > 0)
			controls.removeVControlsInput(trackedInputsVirtualPad);
		#end

		super.destroy();

		#if mobile
		if (vPad != null)
			vPad = FlxDestroyUtil.destroy(vPad);

		if (hitbox != null)
			hitbox = FlxDestroyUtil.destroy(hitbox);
		#end
	}

	private function updateBeat():Void
	{
		lastBeat = curStep;
		curBeat = Math.floor(curStep / 4);
	}

	var currentColor:Int = 0;

	private function updateCurStep():Void
	{
		var lastChange:BPMChangeEvent = {
			stepTime: 0,
			songTime: 0,
			bpm: 0
		}

		for (i in 0...Conductor.bpmChangeMap.length)
		{
			if (Conductor.songPosition >= Conductor.bpmChangeMap[i].songTime)
				lastChange = Conductor.bpmChangeMap[i];
		}

		curStep = lastChange.stepTime + Math.floor((Conductor.songPosition - lastChange.songTime) / Conductor.stepCrochet);
	}

	public function stepHit():Void
	{
		if (curStep % 4 == 0)
			beatHit();
	}

	public function beatHit():Void
	{
		// do literally nothing dumbass
	}
}
