s = Server.local.boot;
MIDIIn.connectAll;
~clipsLocation = "clips";
"buffLoader.scd".loadRelative;

(
~main_rountine.stop;

~main_routine = Routine.new({
	var planetUpdateOSCListener;
	var oscListenAddress = NetAddr("127.0.0.1", nil);
	var oscListenPort = 57123;

	var midiListener;

	var updateTask;

	"util.scd".loadRelative;
	"synths.scd".loadRelative;
	"synthinstances.scd".loadRelative;

	~planetData = Dictionary.new(); // uid -> PlanetData
	~sliderData = Dictionary.new(); // slidernum -> value (0-127)
	~synthControllers = List.new();

	// midiListener = MIDIFunc.new({arg val, ctrlNum, chan, src;
	// 	~sliderData[ctrlNum] = val;
	// }, msgType: 'control');

	midiListener = MIDIFunc.new({arg val, ctrlNum, chan, src;
		~sliderData[ctrlNum + 12] = val;
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

	~synthControllers.add(Routine.new(~fm1RoutineFunc.value(1, 12, 1, 2)));
	~synthControllers.add(Routine.new(~fm1RoutineFunc.value(2, 12, 2, 3)));
	~synthControllers.add(Routine.new(~additiveRoutineFunc.value([], [13, 14])));
	~synthControllers.add(Routine.new(~rhythmicNoiseRoutineFunc.value([3, 4], [15])));
	~synthControllers.add(Routine.new(~fireRoutineFunc.value([], [16])));
	~synthControllers.add(Routine.new(~asteroidRoutineFunc.value([7, 8, 9, 10], [17])));
	~synthControllers.add(Routine.new(~landingRoutineFunc.value([6], [18])));
	~synthControllers.add(Routine.new(~beepRoutineFunc.value([11], [19])));

	~synthControllers.do({arg item, index;
		item.next(True);
	});
	0.3.wait;

	updateTask = Task.new({
		loop({
			~synthControllers.do({arg item, index;
				item.next(True);
			});
			(1/60).wait;
		});
	}).play;

	"waiting for exit".yield;

	midiListener.free;
	planetUpdateOSCListener.free;

	"exiting routine".postln;
	updateTask.stop;
	~synthControllers.do({arg item, index;
		item.next(nil);
		item.stop;
	});
});
)
~main_routine.play;
~main_routine.next;