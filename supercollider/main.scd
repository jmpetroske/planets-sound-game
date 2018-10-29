(
a = (
	SynthDef('BasicSin', {
		arg freq = 220;
		Out.ar([0, 1], Saw.ar(freq) * 0.01)
	}).add;
);

b = a.play
)
  
(
var planetInitOSCFunc;
var planetUpdateOSCFunc;
var oscListenAddress = NetAddr("127.0.0.1", nil);
var oscListenPort = 57123;

var planets;

planets = Dictionary.new(10);

planetInitOSCFunc = OSCFunc({arg msg, time;
	var newPlanet;
	var path, uid, keplerianData;
	# path, uid ... keplerianData = msg;
	// TODO: Set second argument to something valid (parent uid)
	newPlanet = PlanetData.new(uid, nil, keplerianData);
	if (planets[uid].isNil,
		{("Initializing new planet with uid: " + uid).postln;},
		{("Changing values for planet with uid: " + uid).postln}
	);
	planets[uid] = newPlanet;
}, '/planet/init', oscListenAddress, oscListenPort);

planetUpdateOSCFunc = OSCFunc({arg msg, time; /*todo*/ }, '/planet/update', oscListenAddress, oscListenPort);

// planetInitOSCFunc.free;
// planetUpdateOSCFunc.free
)