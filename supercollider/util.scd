~midiToGain = {arg midiVal, lowerVal = -75.6, upperVal = 0;
	// change in 10 results in a change of 6 dB
	
	var returnVal = -inf;
	if(midiVal != 0,
		// see https://docs.cycling74.com/max7/maxobject/gain~
		{returnVal = midiVal.linlin(0, 127, lowerVal, upperVal);});
	returnVal;
};

~combDelayFunc = { arg freq;
    (2*freq).reciprocal;
};

~evenCombCoeffsFunc = { arg gain;

    var kFac, gFac, cFac;

    // convert gain to scalar
    kFac = gain.dbamp;

    // filter coefficients
    gFac = (1-kFac)/(1+kFac);
    cFac = 1-gFac.abs;

    // return
    Array.with(cFac, gFac);
};

~combT60Func = { arg delay, gFac;

    var t60;

    t60 = gFac.sign * (-3 * delay / log10(gFac.abs));

    // return
    t60;
};