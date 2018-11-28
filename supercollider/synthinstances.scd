~fm1RoutineFunc = {arg planetUID, gainSliderIndex;
	{arg initData;
		// initialization here
		var synth, panner;
		var panBus;
		
		var updateFunc;

		// updatable data
		var sliderGain = -inf;
		var mainPlanet = PlanetPosition.zero.value;

		panBus = Bus.audio(s, 1);
		
		// arg inbus, outbus = 0, pos = 0;
		panner = Synth("panner", [\inbus, panBus, \pos, 0]);
		// arg outbus = 0, freq = 220, cratio = 1, mratio = 1, modulationindex = 1, gain = -12
		synth = Synth("fm_synth", [\outbus, panBus, \freq, 137, \cratio, 2, \mratio, 3, \gain, -inf]);

		updateFunc = {
			synth.set(\modulationindex, mainPlanet.globalPos.y.linlin(-300, 1, 5, 0));
			synth.set(\gain, sliderGain + mainPlanet.globalPos.y.linlin(-250, 100, -24, -50, \min));
			panner.set(\pos, mainPlanet.globalPos.x.linlin(-400, 400, -0.8, 0.8));
		};

		updateFunc.value;

		initData = "Started synth controller".yield;
		"started synth controller".postln;
		while({initData.isNil.not}, {
			sliderGain = ~midiToGain.value(~sliderData[gainSliderIndex] ? 0);
			mainPlanet = ~planetData[planetUID] ? PlanetPosition.zero.value;

			updateFunc.value();
			initData = "Updated synth controller".yield;
		});

		// cleanup here
		"Stopping synth controller".postln;
		panBus.free;
		synth.free;
	};
};

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
	var synths = Dictionary.new();
	
	// [partialNum, partialAmp]
	var partialData = Dictionary.newFrom(List[
		1, 1/2,
		2, 1/3,
		3, 1/4,
		4, 1/5,
		5, 1/6,
		6, 1/7,
		7, 1/8,
	]);

	var extraGain = -12;
	var freq = 137;
	var richness = 0;
	var dbPerPartial = 12;
	
	uid = updateData;

	partialData.keysValuesDo({arg key, value;
		var partialNum = key;
		var partialMaxAmp = value;
		var partialGain;

		partialGain = (partialMaxAmp.ampdb - ((partialNum - richness) * dbPerPartial)).min(partialMaxAmp.ampdb);
		// outbus = 0, cFreq, mFreq, mIndexGain = 0, gain = -12
		synths.add(partialNum -> [
			Synth("simple_am_synth",
				[
					\outbus, 0,
					\cFreq, partialNum * (137/2),
					\mFreq, 137/2,
					\mIndexGain, -6,
					\gain, partialGain + extraGain;
				]),
			// arg outbus = 0, freq = 440.0, formFreq = 1760.0, q = 1.0, gain = -12;
			Synth("ags_noise_synth",
				[
					\outbus, 0,
					\freq, 137/2, 
					\formFreq, partialNum * (137/2),
					\q, 25,
					\gain, partialGain + extraGain - 9;
				])
		]);
	});

	updateData = "starting".yield;
	while({updateData.isNil.not}, {
		richness = updateData.globalPos.x.linlin(-400, 400, 7, 1.5);
		
		synths.keysValuesDo({arg partialNum, partialSynths;
			var partialMaxAmp = partialData[partialNum];
			var partialGain = (partialMaxAmp.ampdb - ((partialNum - richness) * dbPerPartial)).min(partialMaxAmp.ampdb);
			partialSynths[0].set(\gain, partialGain + extraGain);
			partialSynths[1].set(\gain, partialGain + extraGain - 6);
		});
		
		updateData = True.yield;
	});

	// cleanup here
	"cleanup".postln;
	synths.keysValuesDo({arg key, value;
		value[0].free;
		value[1].free;
	});
});