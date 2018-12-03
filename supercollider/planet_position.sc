PlanetPosition {
	var <globalPos;
	var <relativePos;
	var <relativeVel;

	*zero {
		^super.newCopyArgs(
			Point.new(0, 0),
			Point.new(0, 0),
			Point.new(0, 0));
	}

	*new {|globalPos, relativePos, relativeVel|
		^super.newCopyArgs(globalPos, relativePos, relativeVel);
	}

}