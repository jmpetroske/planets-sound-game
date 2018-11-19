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

(
~formant_synth = SynthDef('formant_synth', {
	var noise = LFNoise2.ar(500);
	// 280, 2620, 3390: i
	// 600, 2060, 2840: e
	var f1 = BPF.ar(noise, 280, 0.001);
	var f2 = BPF.ar(noise, 2620, 0.001);
	var f3 = BPF.ar(noise, 2840, 0.001);

	// var f1 = BPF.ar(noise, 600, 0.001);
	// var f2 = BPF.ar(noise, 2060, 0.002);
	// var f3 = BPF.ar(noise, 2840, 0.002);	
	Out.ar([0, 1], 100 * (f2 + (f3 * 0.7)));
	// Out.ar([0, 1], BHiShelf.ar(0.3 * (SinOsc.ar(220) + Formant.ar(220, 2620, 440, 0.3) + Formant.ar(220, 3390, 440, 0.1)), 800, 0.1, -8));
}).add;
)

// ~instance = ~formant_synth.play;
// ~instance.set(\freq, 98, \cratio, 3, \mratio, 4, \modulationindex, 1.2, \amp, -20);
// ~instance.free;