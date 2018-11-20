~synthinstances = Dictionary.new();

~fm1Routine = Routine.new({arg updateData;
	// initialization here
	var uid;
	var synth, panner;
	var panBus;

	uid = updateData;

	panBus = Bus.audio(s, 1);
	
	// arg inbus, outbus = 0, pos = 0;
	panner = Synth("panner", [\inbus, panBus, \pos, 0]);
	// arg outbus = 0, freq = 220, cratio = 1, mratio = 1, modulationindex = 1, gain = -12
	synth = Synth("fm_synth", [\outbus, panBus, \freq, 137, \cratio, 2, \mratio, 3, \gain, -20]);

	updateData = "starting".yield;
	while({updateData.isNil.not}, {
		// update here
		// updateData.postln;
		synth.set(\modulationindex, updateData.globalPos.y.linlin(-300, 1, 5, 0));
		// updateData.globalPos.y.linlin(50, -150, -60, -24).postln;
		synth.set(\gain, updateData.globalPos.y.linlin(-250, 100, -24, -50, \min));
		panner.set(\pos, updateData.globalPos.x.linlin(-400, 400, -0.8, 0.8));
		updateData = True.yield;
	});

	// cleanup here
	"cleanup".postln;
	panBus.free;
	synth.free;
});

~fm2Routine = Routine.new({arg updateData;
	// initialization here
	var uid;
	var synth, panner;
	var panBus;

	uid = updateData;

	panBus = Bus.audio(s, 1);
	
	// arg inbus, outbus = 0, pos = 0;
	panner = Synth("panner", [\inbus, panBus, \pos, 0]);
	// arg outbus = 0, freq = 220, cratio = 1, mratio = 1, modulationindex = 1, gain = -12
	synth = Synth("fm_synth", [\outbus, panBus, \freq, 137, \cratio, 1, \mratio, 1, \gain, -20]);

	updateData = "starting".yield;
	while({updateData.isNil.not}, {
		// update here
		// updateData.postln;
		synth.set(\modulationindex, updateData.globalPos.y.linlin(-300, 1, 5, 0));
		// updateData.globalPos.y.linlin(50, -150, -60, -24).postln;
		synth.set(\gain, updateData.globalPos.y.linlin(-250, 100, -24, -50, \min));
		panner.set(\pos, updateData.globalPos.x.linlin(-400, 400, -0.8, 0.8));
		updateData = True.yield;
	});

	// cleanup here
	"cleanup".postln;
	panBus.free;
	synth.free;
});

~fm3Routine = Routine.new({arg updateData;
	// initialization here
	var uid;
	var synth;

	uid = updateData;
	
	// arg outbus = 0, freq = 220, cratio = 1, mratio = 1, modulationindex = 1, gain = -12
	synth = Synth("fm_synth", [\outbus, [0, 1], \freq, 137, \cratio, 3, \mratio, 4, \gain, -20]);

	updateData = "starting".yield;
	while({updateData.isNil.not}, {
		// update here
		// updateData.postln;
		synth.set(\gain, updateData.globalPos.y.linlin(-150, 150, -22, -18));
		synth.set(\modulationindex, updateData.globalPos.x.linlin(-300, 300, 1, 3));
		updateData = True.yield;
	});

	// cleanup here
	"cleanup".postln;
	synth.free;
});

~additive1Routine = Routine.new({arg updateData;
	// initialization here
	var uid;
	var synths = List.new();
	
	// [partialNum, partialAmp]
	var partialData = [
		[1, 1/2],
		[2, 1/3],
		[3, 1/4],
		[4, 1/5],
		[5, 1/6],
		[6, 1/7],
		[7, 1/8],
	];

	var freq = 137;
	var richness = 0;
	
	uid = updateData;
	
	partialData.do({arg item, index;
		var partialNum = item[0];
		var partialAmp = item[1];
		// outbus = 0, cFreq, mFreq, mIndexGain = 0, gain = -12
		synths.put(partialNum -> Synth("simple_am_synth",
			[
				\outbus, 0,
				\cFreq, partialNum * (137/2),
				\mFreq, 137/2,
				\mIndexGain, 0,
				\gain, partialAmp.ampdb - 12
			]));
	});

	updateData = "starting".yield;
	while({updateData.isNil.not}, {

		updateData = True.yield;
	});

	// cleanup here
	"cleanup".postln;
	
	synths.keysValuesDo({arg key, value;
		value.free;
	});
});

// ~fm1_routine.next([1, 2]);
// ~fm1_routine.next(Plane);

~synthinstances.add(\FM1 -> ~fm1Routine);
~synthinstances.add(\FM2 -> ~fm2Routine);
~synthinstances.add(\FM3 -> ~fm3Routine);