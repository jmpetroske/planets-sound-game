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