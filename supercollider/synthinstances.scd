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
			var masterGain = ~midiToGain.value(sliderVals[1], -35);
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
		var noise;

		// arg outbus = 0, buffer, gain = -12, q = 1, position = 0, wavRatio = 1.0, refFreq = 137;
		noise = Synth("ags_buf_noise_synth",
			[
				\outbus, 0,
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
			var masterGain = ~midiToGain.value(sliderVals[0], -30);

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
	};
};

~fireRoutineFunc = {arg planetUIDs, gainSliderIndices;
	{arg initData;
		var updateFunc;

		var synth;

		// updatable data
		var planetVals;
		var sliderVals;

		// init Synths here
		// arg outbus = 0, buffer, gain = -12, grainRate, grainDur, playRate = 1, posRand = 30, rateRand = 0.1;
		synth = {arg gain = -inf;
			Out.ar(0, PlayBuf.ar(
				numChannels: 1,
				bufnum: ~fireBuf,
				loop: 1) * gain.dbamp
			);
		}.play;
		0.1.wait;

		// end init synths

		updateFunc = {
			// update synths here
			synth.set(\gain, ~midiToGain.value(sliderVals[0], -45));
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
		synth.free;
		// end cleanup
	};
};

~asteroidRoutineFunc = {arg planetUIDs, gainSliderIndices;
	{arg initData;
		var updateFunc;

		// updatable data
		var planetVals;
		var sliderVals;

		// var speedMax = -inf;
		// var speedMin = inf;
		// var ampMax = -inf;
		// var ampMin = inf;

		// init Synths here
		var synths = Array.newClear(planetUIDs.size);
		var synthFreqs = Array.newClear(planetUIDs.size);
		planetUIDs.do({arg item, index;
			synthFreqs[index] = 137 * 1.7.rrand(2.4);
			synths[index] = Synth("bln_synth", [
				\carFreq, synthFreqs[index];
				\gain, -inf
			]);
		});
		0.1.wait;

		// end init synths

		updateFunc = {
			// update synths here
			synths.do({arg synth, index;
				var normalizedDirection;
				var speedTowardsSun;
				normalizedDirection = Point.new(planetVals[index].relativePos.x,
					planetVals[index].relativePos.x);
				normalizedDirection = normalizedDirection / normalizedDirection.dist(Point.new(0, 0));
				speedTowardsSun = 1 * (
					(planetVals[index].relativeVel.x * normalizedDirection.x) +
					(planetVals[index].relativeVel.y * normalizedDirection.y));

				// For asteroid:
				// [7, 0, [30, 0.9, PI, PI, 0, 15]],
				// [8, 0, [30, 0.91, PI, PI + 0.03, 0, 15 - 1]],
				// [9, 0, [30, 0.895, PI, PI - 0.02, 0, 15 - 1.4]],
				// [10, 0, [30, 0.905, PI, PI + 0.02, 0, 15 - 4]],
				//
				// speed:
				// 409.84768320776, -500.46975718179
				// amp: 10.51845461148, 3.8053333275709
				// amp: 0.00029690310797345 7.3453324582332e-07
				// speedMax = speedTowardsSun.max(speedMax);
				// speedMin = speedTowardsSun.min(speedMin);
				// ampMax = pow(planetVals[index].globalPos.dist(Point(0, 0)), 1/3).max(ampMax);
				// ampMin = pow(planetVals[index].globalPos.dist(Point(0, 0)), 1/3).min(ampMin);
				// ampMax = (1 / pow(planetVals[index].globalPos.dist(Point(0, 0)), 2)).max(ampMax);
				// ampMin = (1 / pow(planetVals[index].globalPos.dist(Point(0, 0)), 2)).min(ampMin);
				// speedMax.postln;
				// speedMin.postln;
				// ampMax.postln;
				// ampMin.postln;
				// \gain, ~midiToGain.value(sliderVals[0], -45) + (1 / pow(planetVals[index].globalPos.dist(Point(0, 0)), 2)).linlin(7.3453324582332e-07, 0.00029690310797345, -30, 0)
				// synth.set(
				// 	\carFreq, speedTowardsSun.linlin(-500, 409.9, 274, 274 * 2),
				// 	// \q,
				// 	\gain, ~midiToGain.value(sliderVals[0], -45) +
				// 	(1 / pow(planetVals[index].globalPos.dist(Point(0, 0)), 2)).linlin(7.3453324582332e-07, 0.00004, -90, 6)
				// );
				synth.set(
					\carFreq, synthFreqs[index] * speedTowardsSun.linlin(-500, 409.9, 1, 2),
					// \q,
					\gain, ~midiToGain.value(sliderVals[0], -45) +
					(1 / pow(planetVals[index].globalPos.dist(Point(0, 0)), 2)).linlin(7.3453324582332e-07, 0.00004, -90, 6)
				);
			});

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
		synths.do({arg synth, index;
			synth.free;
		});
		// end cleanup
	};
};

~landingRoutineFunc = {arg planetUIDs, gainSliderIndices;
	{arg initData;
		var updateFunc;

		var synth;

		// updatable data
		var planetVals;
		var sliderVals;

		// init Synths here
		// arg outbus = 0, buffer = ~landingBuf, gain = 0, grainRate = 5, grainDur = 2, playRate = 1, posStart = 7, posEnd = 15, posRand = 30, rateRand = 0.1, minFreq = 137, combFreq = 137, combGain = -8;
		synth = Synth("launch_granulator_synth", [
			\buffer, ~landingBuf,
			\gain, -inf,
			\combGain, -8,
			\combFreq, 137
		]);
		// end init synths

		updateFunc = {
			// update synths here
			synth.set(
				\gain, ~midiToGain.value(sliderVals[0], -45),
				\combFreq, planetVals[0].globalPos.y.abs.linlin(0, 600, 137, 137 * 2)
			);
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
		synth.free;
		// end cleanup
	};
};

~beepRoutineFunc = {arg planetUIDs, gainSliderIndices;
	{arg initData;
		var updateFunc;

		var noteGenTask;
		var ampController;
		var ampBus;

		// updatable data
		var planetVals;
		var sliderVals;

		var waitScalar = 1;
		var length = 0.1;

		// init Synths here
		ampBus = Bus.audio(s, 1);
		ampController = {arg gain = -inf;
			Out.ar(0, FreeVerb.ar(In.ar(ampBus) * gain.dbamp, 0.5, 0.5, 0.3));
		}.play;

		0.1.wait;

		noteGenTask = Task.new({
			var freqs = Prand([137 * 3, Pseq([137 * 3 * 3/2, 137 * 4]), 137 * 3, 137 * 3, 137 * 3], inf).asStream;
			loop({
				Synth("ambln_synth", [\outbus, ampBus, \gain, -6, \carFreq, freqs.next, \noiFreq, 50, \modIndexGain, -6.0, \dur, length]);
				(1.rrand(1.2) * waitScalar).wait;
			});
		});
		noteGenTask.play;
		// end init synths

		updateFunc = {
			// update synths here
			var planetDistance = planetVals[0].relativePos.dist(Point(0, 0));
			waitScalar = planetDistance.linlin(200, 500, 0.1, 1);
			ampController.set(
				\gain, ~midiToGain.value(sliderVals[0], -45),
			);
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
		noteGenTask.stop;
		ampBus.free;
		ampController.free;
		// end cleanup
	};
};