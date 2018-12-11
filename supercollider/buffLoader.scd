~ahhooBuf = Buffer.read(s, (~clipsLocation +/+ "ahhoo.wav").resolveRelative);
~fireBuf = Buffer.read(s, (~clipsLocation +/+ "fire.wav").resolveRelative);
~landingBuf = Buffer.readChannel(s, (~clipsLocation +/+ "landing.wav").resolveRelative, channels: [0]);
// ~landingBuf = Buffer.read(s, (~clipsLocation ++ "/landing.wav").resolveRelative);
~launchBuf = Buffer.readChannel(s, (~clipsLocation +/+ "launch.wav").resolveRelative, channels: [0]);
// ~launchBuf = Buffer.read(s, (~clipsLocation ++ "/launch.wav").resolveRelative);

~encoder = FoaEncoderKernel.newDiffuse;
~decoder = FoaDecoderKernel.newSpherical;
	