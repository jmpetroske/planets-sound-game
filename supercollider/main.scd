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
a = {
	var planetInitOSCFunc;
	var planetUpdateOSCFunc;
	var oscListenAddress = NetAddr("127.0.0.1", nil);
	var oscListenPort = 57123;

	var createMapping;
	// uid -> func List[]
	var mappings = Dictionary.new(10);

	var planets;

	createMapping = {arg uid, func;
		if (mappings[uid].isNil,
			{mappings[uid] = List.new(2)}
		);
		mappings[uid].add(func);
	};

	planets = Dictionary.new(10);

	"aaa".postln;
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

	planetUpdateOSCFunc = OSCFunc({arg msg, time;
		var path, uid, data;
		#path, uid ... data = msg;
		path.postln;
		uid.postln;
		data.postln;
		
		mappings[msg[1]].do({arg item, i;

		});
	}, '/planet/update', oscListenAddress, oscListenPort);

	"waiting for exit".yield;
	
	planetInitOSCFunc.free;
	planetUpdateOSCFunc.free;
	"exiting routine".postln;
}
)

b = Routine.new(a);
b.next;