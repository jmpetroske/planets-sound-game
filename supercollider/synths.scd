~spatializer = CtkSynthDef('spatializer', {
    arg inbus, masterX, masterY, masterZ, outbus, width, gain = -12, maxMeters = 1000, reverbGain = -18;
    var cartesian, src, amplitude, freq, radialDistance, amp;
    var phi, theta,  chain, hiFreqAttenCoeff, minAttenDist, lpfDB, speedOfSound;
    var reverb;

    // lets set a few variables first
    // our high frequency absorption constant
    hiFreqAttenCoeff = 100000;

    // at 15 meters our LPF freq would be 20,000, there's no point in having a LPF higher than that
    minAttenDist = 15;

    // our LPF's cutoff freq is always at -3dB, so this is what freq we need to calculate
    lpfDB = 3.0;

    // the speed of sound at sea level under normal conditions
    speedOfSound = 344;

    //convert gain to amplitude scalar
    amp = gain.dbamp;

    // B Format input
	src = FoaEncode.ar(In.ar(inbus, 4), ~encoder);

    // calculate theta, phi and rho
    cartesian = Cartesian(masterX, masterY, masterZ);
    theta = cartesian.theta;
    phi = cartesian.phi;
    radialDistance = cartesian.rho;

    // calculate the attenuation of high frequencies based on radial distance
    // dB/m = freq/100000
    freq = lpfDB/radialDistance.clip(minAttenDist, maxMeters) * hiFreqAttenCoeff;

    // radialDistance = VarLag.kr(radialDistance);

    // the amplitude based on a starting amplitude, amp
    amplitude = amp / radialDistance.clip(1, maxMeters);

    // lowpass the src and apply envelope and amplitude
    chain = LPF.ar(src, freq);

    // use a delay line based on the distance to simulate a doppler shift
    //chain = DelayC.ar(chain, maxMeters/speedOfSound, radialDistance/speedOfSound);

    // create the reverb
    reverb = FoaReverb.ar(chain * reverbGain.dbamp, predelay: 0.0, t60low: 0.6, t60high: 0.2, diffusion: 0.5, mod: 0.2);

    // zoom in on the center of the sound-field based on the arctangent of the distance and a user-defined width
	// chain = FoaZoom.ar(chain * amplitude, radialDistance.atan2(width));

    // use proximity filters based on the distance
    // note: proximity boots low frequencies so we need to condition our signal by using a highpass
	// chain = FoaProximity.ar(HPF.ar(HPF.ar(chain, 20.0), 20.0), radialDistance + 0.1);

    // tumble and then rotate
    chain = FoaTumble.ar(chain, phi);
    chain = FoaRotate.ar(chain, theta);

    // send out signal
	Out.ar(outbus, FoaDecode.ar(chain + reverb, ~decoder));
});

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

~simpleAMSynth = SynthDef.new('simple_am_synth', {
	arg outbus = 0, cFreq, mFreq, mIndexGain = 0, gain = -12;


	var mIndex, amp, carrier, normFac;

	mIndex = mIndexGain.dbamp;
	amp = gain.dbamp;

	normFac = (1 + (2*mIndex)).reciprocal;

	carrier = SinOsc.ar(cFreq, 0, (2*SinOsc.ar(mFreq, 0, mIndex)) + 1);
	carrier = amp * normFac * carrier;

	Out.ar(outbus, carrier);
}).add;

~agsNoiseSynth = CtkSynthDef.new('ags_noise_synth', {arg outbus = 0, freq = 440.0, formFreq = 1760.0, q = 1.0, gain = -12;
    var trigger;
    var granSig;
    var amp;
    var grainDur, grainFreq, envFreq, wavFreq;

    amp = gain.dbamp;
    grainFreq = freq;
    envFreq = q.reciprocal * (formFreq/2);
    wavFreq = formFreq;
    grainDur = envFreq.reciprocal;

    trigger = Dust.ar(grainFreq); // asynchronous trigger
    granSig = GrainSin.ar(trigger: trigger, dur: grainDur, freq: wavFreq);

    Out.ar(outbus, granSig * amp)
});


// Not to be used but with anything but ahhoo.wav (too many hardcoded values)
~agsBufSynth = SynthDef.new('ags_buf_noise_synth', {
	arg outbus = 0, buffer, gain = -12, q = 1, position = 0, wavRatio = 1.0, refFreq = 137, randomness = 0.15;
    var trigger;
    var granSig;
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