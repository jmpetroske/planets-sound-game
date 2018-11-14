// (0,0) is the top left of the screen
// Most planet data in form global_position.x, global_position.y, relative_postiion.x, relative_position.y, velocity.x, velocity.y
(
~main_routine = {
	var planetInitOSCFunc;
	var planetSynthOSCFunc;
	var planetUpdateOSCFunc;
	var planetDestroyOSCFunc;
	var oscListenAddress = NetAddr("127.0.0.1", nil);
	var oscListenPort = 57123;

	var createMapping;
	// uid -> func List[]
	var mappings = Dictionary.new(10);

	var planets;

	"synths.scd".loadRelative;
	"synthinstances.scd".loadRelative;

	createMapping = {arg uid, func;
		if (mappings[uid].isNil,
			{mappings[uid] = List.new(2)}
		);
		mappings[uid].add(func);
	};

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
			if (~synthinstances[msg[index].asSymbol].isNil,
				{("Could not find synth mapping: " + msg[index]).postln;},
				{
					createMapping.value(uid, ~synthinstances[msg[index].asSymbol()]);
				});
		});
	}, '/planet/addSynth', oscListenAddress, oscListenPort);	

	planetUpdateOSCFunc = OSCFunc({arg msg, time;
		var path, uid, data, planetData;
		#path, uid ... data = msg;

		planetData = PlanetPosition.new(
			Point.new(data[0], data[1]),
			Point.new(data[2], data[3]),
			Point.new(data[4], data[5]));
		
		mappings[uid].do({arg item, i;
			item.value(planetData);
		});
	}, '/planet/update', oscListenAddress, oscListenPort);

	planetDestroyOSCFunc = OSCFunc({arg msg, time;
		var path, uid;
		#path, uid = msg;

		mappings[uid].do({arg mapping, i;
			mapping.do({|item, j|
				item.next(nil);
			});
		});
	}, '/planet/destory', oscListenAddress, oscListenPort);

	"waiting for exit".yield;
	
	planetInitOSCFunc.free;
	planetSynthOSCFunc.free;
	planetUpdateOSCFunc.free;
	planetDestroyOSCFunc.free;

	mappings.do({|mapping, i|
		mapping.do({|item, j|
			item.next(nil);
		});
	});
	
	"exiting routine".postln;
}
)

~routine = Routine.new(~main_routine);
~routine.next;