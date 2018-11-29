~fm1RoutineFunc = {arg planetUID, gainSliderIndex, cratio = 2, mratio = 3;
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
		synth = Synth("fm_synth", [\outbus, panBus, \freq, 137, \cratio, cratio, \mratio, mratio, \gain, -inf]);

		updateFunc = {
			synth.set(\modulationindex, mainPlanet.globalPos.y.linlin(0, 300, 0, 5));
			synth.set(\gain, sliderGain + mainPlanet.globalPos.y.linlin(-100, 250, -50, -24, \min));
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

~additiveRoutineFunc = {arg planetUID, gainSliderIndices;
	{arg initData;
		var updateFunc;

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

		// updatable data
		var sliderGains = [-inf, -inf];
		var mainPlanet = PlanetPosition.zero.value;

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
						\gain, -inf;
					]),
				Synth("simple_am_synth",
					[
						\outbus, 0,
						\cFreq, partialNum * (137/2) * (3/2),
						\mFreq, 137/2  * (3/2),
						\mIndexGain, -6,
						\gain, -inf;
					]),
				// arg outbus = 0, freq = 440.0, formFreq = 1760.0, q = 1.0, gain = -12;
				Synth("ags_noise_synth",
					[
						\outbus, 0,
						\freq, 137/2, 
						\formFreq, partialNum * (137/2),
						\q, 25,
						\gain, -inf;
					])
			]);
		});

		updateFunc = {
			richness = mainPlanet.globalPos.x.linlin(-400, 400, 7, 1.5);
			
			synths.keysValuesDo({arg partialNum, partialSynths;
				var partialMaxAmp = partialData[partialNum];
				var partialGain = (partialMaxAmp.ampdb - ((partialNum - richness) * dbPerPartial)).min(partialMaxAmp.ampdb);
				partialSynths[0].set(\gain, sliderGains[0] + partialGain + extraGain);
				partialSynths[1].set(\gain, sliderGains[0] + sliderGains[1] + partialGain + extraGain - 3);
				partialSynths[2].set(\gain, sliderGains[0] + partialGain + extraGain - 6);
			});
		};

		updateFunc.value;

		initData = "Started synth controller".yield;
		"started synth controller".postln;
		while({initData.isNil.not}, {
			sliderGains[0] = ~midiToGain.value(~sliderData[gainSliderIndices[0]] ? 0);
			sliderGains[1] = ~midiToGain.value(~sliderData[gainSliderIndices[1]] ? 0);
			mainPlanet = ~planetData[planetUID] ? PlanetPosition.zero.value;

			updateFunc.value();
			initData = "Updated synth controller".yield;
		});

		// cleanup here
		"Stopping synth controller".postln;
		synths.keysValuesDo({arg key, value;
			value[0].free;
			value[1].free;
		});
	};
};

// Point.new(0, 1).asPolar.angle