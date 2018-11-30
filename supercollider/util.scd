~midiToGain = {arg midiVal, lowerVal = -75.6, upperVal = 0;
	// change in 10 results in a change of 6 dB
	
	var returnVal = -inf;
	if(midiVal != 0,
		// see https://docs.cycling74.com/max7/maxobject/gain~
		{returnVal = midiVal.linlin(0, 127, lowerVal, upperVal);});
	returnVal;
};
