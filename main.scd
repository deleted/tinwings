// Start server and MIDI
s.quit;
s.boot;

s.waitForBoot{
	MIDIClient.init;
	MIDIIn.connectAll;
};

s.waitForBoot{
    // A map of MIDI note values to event names.
    var buttons = (
        shutterAdd: 48,
        shutterClear: 49,
		tuiAdd: 50,
		tuiClear: 51
    );
	var setupShave;

    // Load Samples
    var basePath = "/home/ted/tinwings/samples";
    var getPath = { |fileName|
        basePath ++ "/" ++ fileName;
    };
    var loadSample = { |name| Buffer.read(s, getPath.value(name)) };
    var buffers = ();
    buffers.shutter = loadSample.("shutter_manual.wav");
	buffers.tui = loadSample.("tui.wav");
    ~buffers = buffers;
	~buttons = buttons;

    /*
    * SYNTH DEFS
    */

    // Offset looper
    SynthDef.new(\loopShave, {
        arg buf, amp=0.5, rate=1.0, length=1.0, pan=0.0;
        var ptr, sig;
        ptr = Phasor.ar(0, BufRateScale.kr(buf)*rate, start: 0, end: BufFrames.kr(buf)*length);

        sig = amp * BufRd.ar(1, buf, ptr, loop: 1);
        sig = Pan2.ar(sig, pan);
        Out.ar(0, sig);
    }).add;


    // Shutter track
    {
        var loopGroup = Group.new();
        var startLoop = { |val, nn, chan|
            var pan;
            "startLoop".postln;
            pan = rrand(-1.0, 1/0);
            pan.postln;

            x = Synth.new(\loopShave, [\buf, ~buffers.shutter, \length, rrand(0.5, 1.0), \pan, rrand(-1.0, 1.0)], target: loopGroup);

        };
        var clearLoops = {
            loopGroup.freeAll;
        };
        MIDIdef.noteOn(\addShutter, startLoop, noteNum: ~buttons.shutterAdd);
        MIDIdef.noteOn(\clearShutter, clearLoops, noteNum: ~buttons.shutterClear);
    }.value;

    // Tui Track
    {
        var loopGroup = Group.new();
        var startLoop = { |val, nn, chan|
            var pan;
            "startLoop".postln;
            pan = rrand(-1.0, 1/0);
            pan.postln;

            x = Synth.new(\loopShave, [\buf, ~buffers.tui, \length, rrand(0.5, 1.0), \pan, rrand(-1.0, 1.0), \amp], target: loopGroup);

        };
        var clearLoops = {
			"tui clear".postln;
            loopGroup.freeAll;
        };
        MIDIdef.noteOn(\addTui, startLoop, noteNum: ~buttons.tuiAdd);
        MIDIdef.noteOn(\clearTui, clearLoops, noteNum: ~buttons.tuiClear);
    }.value;

}
