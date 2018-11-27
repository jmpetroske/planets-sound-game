s = Server.local.boot;
s.quit;

// (0,0) is the top left of the screen
// Most planet data in form global_position.x, global_position.y, relative_postiion.x, relative_position.y, velocity.x, velocity.y

(
~main_routine = Routine.new({
	var planetUpdateOSCListener;
	var oscListenAddress = NetAddr("127.0.0.1", nil);
	var oscListenPort = 57123;

	// These are now globals
	// var planet_data;
	// var slider_data;
	// var synth_controller;

	var midiListener;

	"util.scd".loadRelative;
	"synths.scd".loadRelative;
	"synthinstances.scd".loadRelative;
	
	MIDIIn.connectAll;

	~planetCata = Dictionary.new(); // uid -> PlanetData
	~sliderData = Dictionary.new(); // slidernum -> value (0-127)
	~synthController = List.new();

	midiListener = MIDIFunc.new({arg val, ctrlNum, chan, src;
		~sliderData[ctrlNum] = val;
	}, msgType: 'control');
	
	planetUpdateOSCListener = OSCFunc({arg msg, time;
		var path, uid, data, planetPosition;
		#path, uid ... data = msg;

		planetPosition = PlanetPosition.new(
			Point.new(data[0], data[1]),
			Point.new(data[2], data[3]),
			Point.new(data[4], data[5]));
		
		~planetData[uid] = planetPosition;
	}, '/planet/update', oscListenAddress, oscListenPort);

	"waiting for exit".yield;
	
	planetUpdateOSCListener.free;
	
	"exiting routine".postln;
});
)

~main_routine.next;