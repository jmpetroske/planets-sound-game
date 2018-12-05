~panner = SynthDef('panner', {arg inbus, outbus = 0, pos = 0;
	Out.ar(outbus, Pan2.ar(In.ar(inbus, 1), pos, 1));
}).add;

~fm_synth = SynthDef('fm_synth', {
	arg outbus = 0, freq = 20, cratio = 1, mratio = 1, modulationindex = 1, gain = -12;
	var carrierfreq, modulatorfreq, modulatoramp;
	var modulatorNoise;
	var modulator, carrier, outsig;

	// modulationindex = SinOsc.ar(0.1, 0, 1, 2);
	
	carrierfreq = freq * cratio;
	modulatorfreq = freq * mratio;
	modulatoramp = modulationindex * freq;
	modulatorfreq = modulatorfreq;// + LFNoise2.ar(1/5, 5);

	modulator = LPF.ar(Saw.ar(modulatorfreq, modulatoramp), modulatorfreq * 3);
	// modulator = Saw.ar(modulatorfreq, modulatoramp);
	carrier = SinOsc.ar(carrierfreq + modulator);
	outsig = carrier;
	
	Out.ar(outbus, outsig * gain.dbamp);
}).add;

~formant_synth = SynthDef('formant_synth', {//arg vowel = 0;
	var vowel = MouseY.kr(0.0, 1.0, \linear);
	var bw = MouseX.kr(0.0, 1.0, \linear);
	var noise = BLowShelf.ar(LFNoise2.ar(2000) + LFNoise2.ar(1500), 1000, 0.7, -16);
	// 280, 2620, 3390: i
	// 600, 2060, 2840: e
	var freq1, freq2, freq3;
	var f1, f2, f3;

	freq1 = LinLin.ar(vowel, 0, 1, 280, 600);
	freq2 = LinLin.ar(vowel, 0, 1, 2620, 2060);
	freq3 = LinLin.ar(vowel, 0, 1, 3390, 2840);
	
	// f1 = BPF.ar(noise, freq1, 0.002);
	// f2 = BPF.ar(noise, freq2, 0.001);
	// f3 = BPF.ar(noise, freq3, 0.001);
	
	f1 = BPF.ar(noise, freq1, bw * 0.8);
	f2 = BPF.ar(noise, freq2, bw);
	f3 = BPF.ar(noise, freq3, bw);

	bw.poll;
	noise.poll;
	
	// var f1 = BPF.ar(noise, 600, 0.001);
	// var f2 = BPF.ar(noise, 2060, 0.002);
	// var f3 = BPF.ar(noise, 2840, 0.002);	
	Out.ar([0, 1], LPF.ar(10 * ((0.1 * f1) + (2 * f2) + (1 * f3)), 4000));
	// Out.ar([0, 1], BHiShelf.ar(0.3 * (SinOsc.ar(220) + Formant.ar(220, 2620, 440, 0.3) + Formant.ar(220, 3390, 440, 0.1)), 800, 0.1, -8));
}).add;

~simpleAMSynth = SynthDef.new('simple_am_synth', {
	arg outbus = 0, cFreq, mFreq, mIndexGain = 0, gain = -12;

	
	var mIndex, amp, carrier, normFac;

	mIndex = mIndexGain.dbamp;
	amp = gain.dbamp;

	normFac = (1 + (2*mIndex)).reciprocal;

	carrier = SinOsc.ar(cFreq, 0, (2*SinOsc.ar(mFreq, 0, mIndex)) + 1);
	carrier = amp * normFac * carrier;

	Out.ar(0, carrier);
}).add;

~agsNoiseSynth = CtkSynthDef.new('ags_noise_synth', {arg outbus = 0, freq = 440.0, formFreq = 1760.0, q = 1.0, gain = -12;
    var bus = 0;
    var trigger;
    var granSig;
    var out;
    var amp;
    var grainDur, grainFreq, envFreq, wavFreq;

    amp = gain.dbamp;
    grainFreq = freq;
    envFreq = q.reciprocal * (formFreq/2);
    wavFreq = formFreq;
    grainDur = envFreq.reciprocal;

    trigger = Dust.ar(grainFreq); // asynchronous trigger
    granSig = GrainSin.ar(trigger: trigger, dur: grainDur, freq: wavFreq);

    Out.ar(bus, granSig * amp)
});


// Not to be used but with anything but ahhoo.wav (too many hardcoded values)
~agsBufSynth = SynthDef.new('ags_buf_noise_synth', {
	arg outbus = 0, buffer, gain = -12, q = 1, position = 0, wavRatio = 1.0, refFreq = 137, randomness = 0.15;
    var trigger;
    var granSig;
    var out;
    var grainDur, grainFreq, envFreq;
	var index;
	var bufferPeriods;

    envFreq = wavRatio * refFreq / (2 * q);
    grainDur = envFreq.reciprocal;
	bufferPeriods = (refFreq * BufDur.kr(buffer)) - 20;

	// position = MouseY.kr(0, 1);
	position = LinLin.ar(position, 0.43, 0.76);

	// 0.15 randomness is good
	position = position + (LFNoise0.ar(refFreq * 60) * randomness);
	
	// position = LinLin.kr(position, 0, 1, 0.76, 0.43);
	index = (position * bufferPeriods).floor / bufferPeriods;
	// index = position;

    trigger = Dust.ar(refFreq * 30); // asynchronous trigger
	granSig = GrainBuf.ar(
		numChannels: 1,
		trigger: trigger,
		dur: grainDur,
		sndbuf: buffer,
		rate: wavRatio,
		pos: index,
	);

	granSig = HPF.ar(granSig, 500);

    Out.ar(outbus, FreeVerb.ar(granSig * gain.dbamp, 0.5, 0.7));
}).add;

~fireSynth = SynthDef.new('buf_granulator', {
	arg outbus = 0, buffer, gain = -12, grainRate, grainDur, playRate = 1, posRand = 30, rateRand = 0.1;
    var trigger;
    var granSig;
	var position;
	var noise;

	noise = LFNoise0.ar(500);
	position = ((noise + 1) * posRand) / BufDur.kr(buffer);
	position = 0;

    trigger = Impulse.ar(grainRate);
	granSig = GrainBuf.ar(
		numChannels: 1,
		trigger: trigger,
		dur: grainDur,
		sndbuf: buffer,
		rate: playRate * ((noise * rateRand) + 1),
		pos: position,
	);

    Out.ar(outbus, granSig * gain.dbamp);
}).add;

~blnSynth = SynthDef.new('bln_synth', {arg outbus = 0, carFreq, q = 1, gain = -12;
	var noise, carrier;
	var car;
	var outsig;

	car = LPF.ar(K2A.ar(carFreq), 15);
	
	noise = LFDNoise3.ar(car / (2*q));
	carrier = SinOsc.ar(car);

	outsig = FreeVerb.ar(carrier * noise * gain.dbamp, 0.5, 0.5, 0.5);
	
    Out.ar(outbus, outsig);
}).add;

~launchGranulator = SynthDef.new('launch_granulator_synth', {
	arg outbus = 0, buffer = ~landingBuf, gain = 0, grainRate = 5, grainDur = 2, playRate = 1, posStart = 7, posEnd = 15, posRand = 30, rateRand = 0.1, minFreq = 137, combFreq = 137, combGain = -8;
    var trigger;
    var granSig;
	var position;
	var noise;
	var dur = BufDur.kr(buffer);
	var outsig;

	var maxDelayTime, delayTime, decayTime;
	var cFac, gFac;

	noise = LFNoise0.ar(500);
	position = LinLin.ar(noise, -1, 1, posStart/dur, posEnd/dur);

    trigger = Impulse.ar(grainRate);
	granSig = GrainBuf.ar(
		numChannels: 1,
		trigger: trigger,
		dur: grainDur,
		sndbuf: buffer,
		rate: playRate * ((noise * rateRand) + 1),
		pos: position,
	);

	combFreq = LinLin.ar(SinOsc.ar(1/9), -1, 1, 137, 137 * 2);

	maxDelayTime = ~combDelayFunc.value(minFreq);
	delayTime = ~combDelayFunc.value(combFreq);
	#cFac, gFac = ~evenCombCoeffsFunc.value(combGain);
	decayTime = ~combT60Func.value(delayTime, gFac);

	outsig = CombC.ar(granSig, maxDelayTime, delayTime, decayTime, cFac * gFac, cFac * granSig);

    Out.ar(outbus, outsig * gain.dbamp);
}).add;

// ~instance = Synth("ags_buf_noise_synth", [\buffer, ~ahhooBuf, \gain, -30, \q, 2]);
// ~instance.set(\wavRatio, 1);
// ~instance.set(\q, 3);
// ~instance.free;

// // randomness = -0.15

// ~instance2 = Synth("ags_buf_noise_synth", [\buffer, ~ahhooBuf, \gain, -30, \q, 2]);
// ~instance2.set(\wavRatio, 0.5);
// ~instance2.set(\gain, -20);
// ~instance2.set(\q, 4);
// ~instance2.free;

// ~instance.set(\freq, 98, \cratio, 3, \mratio, 4, \modulationindex, 1.2, \amp, -20);
// ~instance = Synth("formant_synth", [\vowel, 0]);
// ~instance.set(\vowel, 1.0);
// ~instance.set(\vowel, 0.9);
// ~instance.set(\vowel, 0.8);
// ~instance.set(\vowel, 0.7);
// ~instance.set(\vowel, 0.6);
// ~instance.set(\vowel, 0.5);
// ~instance.set(\vowel, 0.4);
// ~instance.set(\vowel, 0.3);
// ~instance.set(\vowel, 0.2);
// ~instance.set(\vowel, 0.1);
// ~instance.set(\vowel, 0.0);

	// ~instance.free;
	

// (
// a.free;
~ambln_synth = SynthDef.new('ambln_synth', {
	arg outbus = 0, gain, carFreq = 440.0, noiFreq = 440.0, modIndexGain = 0.0, dur = 0.2;

    var noise, carOsc;
	
    var amp;
    var modIndex;
    var normFac;

	var ampEnv = EnvGen.kr(Env.linen(0.02, dur, 0.02), doneAction: Done.freeSelf);

    amp = gain.dbamp;
    modIndex = modIndexGain.dbamp;
    normFac = (1 + (2*modIndex)).reciprocal; // amplitude normalization factor

    noise = LFNoise1.ar(noiFreq, amp * (2*modIndex));
    carOsc = SinOsc.ar(carFreq, 0, amp + noise);
	carOsc = normFac * carOsc;
	// carOsc = LPF.ar(carOsc, 400);
    // carOsc = LPF.ar(carOsc, 300);

	carOsc = carOsc * ampEnv;

    Out.ar(outbus, carOsc)
}).add;
// a = Synth('ambln_synth', [\gain, 0, \carFreq, 137 / 2, \noiFreq, 5000, \modIndexGain, -12.0]);
// a = Synth('ambln_synth', [\gain, -3, \carFreq, 137 * 3, \noiFreq, 50, \modIndexGain, -6.0, \dur, 0.02]);