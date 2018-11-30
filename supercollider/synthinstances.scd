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
			synth.set(\gain, sliderGain + mainPlanet.globalPos.y.linlin(-200, 200, -50, -24, \min));
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
		panner.free;
		synth.free;
	};
};

~additiveRoutineFunc = {arg planetUIDs, gainSliderIndices;
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
		var sliderVals;

		partialData.keysValuesDo({arg key, value;
			var partialNum = key;

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
			var richness = sliderVals[0].linlin(0, 127, 1.5, 7);
			var masterGain = ~midiToGain.value(sliderVals[1]);
			
			synths.keysValuesDo({arg partialNum, partialSynths;
				var partialMaxAmp = partialData[partialNum];
				var partialGain = (partialMaxAmp.ampdb - ((partialNum - richness) * dbPerPartial)).min(partialMaxAmp.ampdb);
				partialSynths[0].set(\gain, masterGain + partialGain + extraGain);
				partialSynths[1].set(\gain, masterGain + partialGain + extraGain - 6);
			});
		};

		initData = "Started synth controller".yield;
		"started synth controller".postln;
		while({initData.isNil.not}, {
			sliderVals = Array.newClear(gainSliderIndices.size);
			gainSliderIndices.do({arg item, index;
				sliderVals[index] = ~sliderData[item] ? 0;
			});

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

~rhythmicNoiseRoutineFunc = {arg planetUIDs, gainSliderIndices;
	{arg initData;
		var updateFunc;

		var synths = Dictionary.new();

		// updatable data
		var planetVals;
		var sliderVals;

		// init Synths here
		var reverbBus = Bus.audio(s, 1);

		var noise;
		var reverb;
		
		// arg outbus = 0, buffer, gain = -12, q = 1, position = 0, wavRatio = 1.0, refFreq = 137;
		reverb = {
			Out.ar(0, FreeVerb.ar(InBus.ar(reverbBus), 0.5, 0.7));
		}.play;

		noise = Synth("ags_buf_noise_synth",
			[
				\outbus, reverbBus,
				\buffer, ~ahhooBuf,
				\gain, -inf,
				\q, 3,
				\position, 0,
				\wavRatio, 1,
				\refFreq, 137
			]
		);
				
		
		// end init synths
		
		updateFunc = {
			// update synths here
			var planet = planetVals[0];
			var moon = planetVals[1];
			var masterGain = ~midiToGain.value(sliderVals[0]);

			// var planetAngle = planet.relativePos.angle;
			var distance = planet.relativePos.dist(Point(0, 0));
			// var position = planetAngle.abs.linlin(0, pi/8, 0, 1);
			// distance.postln;

			// 38 -> 300
			var position = distance.linlin(38, 60, 0, 1);
			
			// a: (random: 0.2, 0) o: (random: 0.08, 1)
			noise.set(\gain, -15 + masterGain + moon.relativePos.y.linlin(-30, 5, -15, 0));
			noise.set(\position, position);
			noise.set(\randomness, position.linlin(0, 1, 0.2, 0.08));			
			// noise.set(\position, position);
			// noise.set(\randomness, position.linlin(0, 1, 0.2, 0.08));

						// noise.set(\position, 
			
			// end update synths
		};

		initData = "Started synth controller".yield;
		"started synth controller".postln;
		while({initData.isNil.not}, {
			sliderVals = Array.newClear(gainSliderIndices.size);
			gainSliderIndices.do({arg item, index;
				sliderVals[index] = ~sliderData[item] ? 0;
			});

			planetVals = Array.newClear(planetUIDs.size);
			planetUIDs.do({arg item, index;
				planetVals[index] = ~planetData[item] ? PlanetPosition.zero.value;
			});

			updateFunc.value();
			initData = "Updated synth controller".yield;
		});

		"Stopping synth controller".postln;
		// cleanup here
		noise.free;
		reverb.free;
		reverbBus.free;
	};
};

~templeteRoutineFunc = {arg planetUIDs, gainSliderIndices;
	{arg initData;
		var updateFunc;

		var synths = Dictionary.new();

		// updatable data
		var planetVals;
		var sliderVals;

		// init Synths here

		// end init synths

		updateFunc = {
			// update synths here

			// end update synths
		};

		initData = "Started synth controller".yield;
		"started synth controller".postln;
		while({initData.isNil.not}, {
			sliderVals = Array.newClear(gainSliderIndices.size);
			gainSliderIndices.do({arg item, index;
				sliderVals[index] = ~sliderData[item] ? 0;
			});

			planetVals = Array.newClear(planetUIDs.size);
			planetUIDs.do({arg item, index;
				planetVals[index] = ~planetData[item] ? PlanetPosition.zero.value;
			});

			updateFunc.value();
			initData = "Updated synth controller".yield;
		});

		"Stopping synth controller".postln;
		// cleanup here

		// end cleanup
	};
};