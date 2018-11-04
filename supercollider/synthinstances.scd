~synthinstances = Dictionary.new();

Routine.new({arg inval;
	// initialization here
	
	var update_data;
	while(update_data = routine.yield).isNil.not, {
		// update here

	});

	// cleanup here
});

// symbol -> [routine]
~synthinstances.add(\FM1 -> );
