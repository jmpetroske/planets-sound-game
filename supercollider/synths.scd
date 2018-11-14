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

// ~instance = ~fm_synth.play;
// ~instance.set(\freq, 98, \cratio, 3, \mratio, 4, \modulationindex, 1.2, \amp, -20);
// ~instance.free;
// s.freeAll;	