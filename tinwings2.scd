// Start server and MIDI
(
s.quit;
s.boot;
MIDIClient.init;
MIDIIn.connectAll;
)

// Load Samples
(
~basePath = "/home/ted/tinwings/samples";
~getPath = {
	arg fileName;
	// (PathName(~basePath) +/+ PathName(fileName)).asAbsolutePath;
	~basePath ++ "/" ++ fileName;
	// format("%s/%s", ~basePath, fileName);
};

~shutterBuf = Buffer.read(s, ~getPath.value("shutter_manual.wav"));
)


// Offset looper
(
SynthDef.new(\loopShave, {
	arg buf, amp=0.5, rate=1.0, length=1.0, pan=0.0;
	var ptr, sig;
	ptr = Phasor.ar(0, BufRateScale.kr(buf)*rate, start: 0, end: BufFrames.kr(buf)*length);

	sig = amp * BufRd.ar(1, buf, ptr, loop: 1);
	sig = Pan2.ar(sig, pan);
	Out.ar(0, sig);
}).add;

)

// Shutter track
(
var startLoop, loops, clearLoops;
loops = List.new();
startLoop = {
	arg val, nn, chan;
	var pan;
	"startLoop".postln;
	pan = rrand(-1.0, 1/0);
	pan.postln;

	x = Synth.new(\loopShave, [\buf, ~shutterBuf, \length, rrand(0.5, 1.0), \pan, rrand(-1.0, 1.0)]);
	loops.add(x);
	loops.size.postln;
};
clearLoops = {
	"clear".postln;
	loops.do{
		arg loop;
		loop.free;
	};
	loops.clear;
	loops.size.postln;
};
MIDIdef.noteOn(\startShutter, startLoop, noteNum: 48);
MIDIdef.noteOn(\clearShutters, clearLoops, noteNum: 49);
startLoop.value;
)

startLoop.value
