~fm_synth = SynthDef('FM', {
	arg outbus = 0, freq = 220, cratio = 1, mratio = 1, modulationindex = 1, amp = 0.01;
	var carrierfreq, modulatorfreq, modulatoramp;
	var modulatorNoise;
	var modulator, carrier, outsig;

	modulationindex = SinOsc.ar(0.1, 0, 1, 2);
	
	carrierfreq = freq * cratio;
	modulatorfreq = freq * mratio;
	modulatoramp = modulationindex * freq;
	modulatorfreq = modulatorfreq + LFNoise2.ar(1/5, 5);

	modulator = LPF.ar(Saw.ar(modulatorfreq, modulatoramp), modulatorfreq * 4);
	// modulator = Saw.ar(modulatorfreq, modulatoramp);
	carrier = SinOsc.ar(carrierfreq + modulator);
	outsig = carrier;
	
	Out.ar(outbus, [1, 1] * outsig * amp);
}).add;

// instance = fm_synth.play;
// instance.set(\freq, 69 * 3, \cratio, 1, \mratio, 1.0, \modulationindex, 1.2, \amp, 1);
// b.free;
// s.freeAll;
