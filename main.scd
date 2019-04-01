// Start server and MIDI
s.quit;
s.boot;
MIDIClient.init;
MIDIIn.connectAll;


s.waitForBoot{

    // A map of MIDI note values to event names.
    var buttons = (
        shutterAdd: 48,
        shutterClear: 49
    );

    // Load Samples
    var basePath = "/home/ted/tinwings/samples";
    var getPath = { |fileName|
        basePath ++ "/" ++ fileName;
    };
    var loadSample = { |name| Buffer.read(s, getPath.value(name)) };

    var buffers = ();
    buffers.shutter = loadSample.("shutter_manual.wav");
    ~buffers = buffers;

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
    fork {
        var startLoop, loops, clearLoops;
        loops = List.new();
        startLoop = { |val, nn, chan|
            var pan;
            "startLoop".postln;
            pan = rrand(-1.0, 1/0);
            pan.postln;

            x = Synth.new(\loopShave, [\buf, ~buffers.shutter, \length, rrand(0.5, 1.0), \pan, rrand(-1.0, 1.0)]);
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
        MIDIdef.noteOn(\startShutter, startLoop, noteNum: buttons.shutterAdd);
        MIDIdef.noteOn(\clearShutters, clearLoops, noteNum: buttons.shutterClear);
    }

}
