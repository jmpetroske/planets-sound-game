~synthinstances = Dictionary.new();

~fm1Routine = Routine.new({arg updateData;
	// initialization here
	var uid;
	var synth;

	uid = updateData;
	
	// arg outbus = 0, freq = 220, cratio = 1, mratio = 1, modulationindex = 1, gain = -12
	synth = Synth("fm_synth", [\freq, 98, \cratio, 2, \mratio, 3, \gain, -20]);

	updateData = "starting".yield;
	while({updateData.isNil.not}, {
		// update here
		// updateData.postln;
		synth.set(\modulationindex, updateData.globalPos.y.linlin(-300, 0, 3, 0));
		updateData = True.yield;
	});

	// cleanup here
	"cleanup".postln;
	synth.free;
});

~fm2Routine = Routine.new({arg updateData;
	// initialization here
	var uid;
	var synth;

	uid = updateData;
	
	// arg outbus = 0, freq = 220, cratio = 1, mratio = 1, modulationindex = 1, gain = -12
	synth = Synth("fm_synth", [\freq, 98, \cratio, 3, \mratio, 4, \gain, -26]);

	updateData = "starting".yield;
	while({updateData.isNil.not}, {
		// update here
		// updateData.postln;
		synth.set(\modulationindex, updateData.globalPos.x.linlin(-300, 300, 1, 3));
		updateData = True.yield;
	});

	// cleanup here
	"cleanup".postln;
	synth.free;
});

// ~fm1_routine.next([1, 2]);
// ~fm1_routine.next(Plane);

// symbol -> [routine]
~synthinstances.add(\FM1 -> ~fm1Routine);
~synthinstances.add(\FM2 -> ~fm2Routine);