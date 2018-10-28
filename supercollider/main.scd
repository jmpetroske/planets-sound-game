(
a = (
	SynthDef('BasicSin', {
		arg freq = 220;
		Out.ar([0, 1], Saw.ar(freq) * 0.01)
	}).add;
);

b = a.play
)
  
n = NetAddr("127.0.0.1", nil);
o = OSCFunc({arg msg, time; b.set(\freq, 220 + (msg[1] / 5))}, '/planetUpdate', n, 57123)
o.free
b.free

b.set(\freq, 200)

planet_data

orbits: uid -> mappings[]
mapping: synth.parameter = mapping_func(orbit.parameter)

d = (hello: 9, whello: "world");
d.keys;
d.add(123 -> 1)
d.add(123 -> [])
d.free

(
var planetInitOSCFunc;
var planetUpdateOSCFunc;
var oscListenAddress = NetAddr("127.0.0.1", nil);
var oscListenPort = 57123;

planetInitOSCFunc = OSCFunc({arg msg, time; /* todo */}, '/planet/init', oscListenAddress, oscListenPort);
planetUpdateOSCFunc = OSCFunc({arg msg, time; /*todo*/ }, '/planet/update', oscListenAddress, oscListenPort);

planetInitOSCFunc.free;
planetUpdateOSCFunc.free
)