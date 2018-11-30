// ~ahhooBuf = CtkBuffer.playbuf((~clipsLocation ++ "/ahhoo.wav").resolveRelative, 0, -1, s, 1);
~ahhooBuf = Buffer.read(s, (~clipsLocation ++ "/ahhoo.wav").resolveRelative);
~fireBuf = Buffer.read(s, (~clipsLocation ++ "/fire.aiff").resolveRelative);