// (0,0) is the top left of the screen
// Most planet data in form global_position.x, global_position.y, relative_postiion.x, relative_position.y, velocity.x, velocity.y
(

)

(
"synths.scd".loadRelative;

~main_routine = {
	var planetInitOSCFunc;
	var planetSynthOSCFunc;
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

	createMapping.value(1, {arg planetData;
		
	});

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

	planetSynthOSCFunc = OSCFunc({arg msg, time;
		var path, uid, length, data;
		path = msg[0];
		uid = msg[1];
		length = msg[2];
		data = List.new(length);
		for (3, 3 + length - 1, {arg index;
			data.add(msg[index]);
			("Adding synth for uid: " + uid + msg[index]).postln;
		});
	}, '/planet/addSynth', oscListenAddress, oscListenPort);	

	planetUpdateOSCFunc = OSCFunc({arg msg, time;
		var path, uid, data;
		#path, uid ... data = msg;
		
		mappings[msg[1]].do({arg item, i;
			item.value(data);
		});
	}, '/planet/update', oscListenAddress, oscListenPort);

	"waiting for exit".yield;
	
	planetInitOSCFunc.free;
	planetSynthOSCFunc.free;
	planetUpdateOSCFunc.free;
	"exiting routine".postln0;
}
)

~routine = Routine.new(~main_routine);
~routine.next;