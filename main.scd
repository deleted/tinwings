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
        shutterAdd: (symbol: \shutterAdd, note: 48, cc: 0),
        shutterClear: (symbol: \shutterClear, note: 49, cc: 1),
        tuiAdd: (symbol: \tuiAdd, note: 50, cc: 2), 
        tuiClear: (symbol: \tuiClear, note:51, cc: 3),
        spadefootAdd: (symbol: \spade, note: 53, cc: 4),
        spadefootClear: (symbol: \spadefootClear, note: 54, cc: 5)
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
    buffers.spadefoot = loadSample.("spadefoot.wav");
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

    {
        var createShaveTrack = { arg buffer, buttons, group={group.new}, amp=0.5;
            var loopGroup = group;
            var addKey = buttons.at(\create).symbol, clearKey = buttons.at(\clear).symbol;
            var addNote = buttons.at(\create).note, clearNote = buttons.at(\clear).note;
            var addCC = buttons.at(\create).cc, clearCC = buttons.at(\clear).cc;
            var startLoop = { |val, nn, chan|
                var pan;
                addKey.postln;   
                pan = rrand(-1.0, 1/0);
                pan.postln;

                x = Synth.new(\loopShave, [\buf, buffer, \length, rrand(0.5, 1.0), \pan, rrand(-1.0, 1.0), \amp: amp], target: loopGroup);

            };
            var clearLoops = {
                clearKey.postln;
                loopGroup.freeAll;
            };
            MIDIdef.noteOn(addKey, startLoop, noteNum: addNote).permanent_(true);
            MIDIdef.noteOn(clearKey, clearLoops, noteNum: clearNote).permanent_(true);
            MIDIdef.cc(addKey ++ \cc, startLoop, ccNum: addCC);
            MIDIdef.cc(clearKey ++ \cc, clearLoops, ccNum: clearCC);

        };

        createShaveTrack.(
                buffer: ~buffers.shutter,
                buttons: (
                    create: ~buttons.shutterAdd,
                    clear: ~buttons.shutterClear
                ),
                group: Group.new
        );
        createShaveTrack.(
                buffer: ~buffers.tui,
                buttons: (
                    create: ~buttons.tuiAdd,
                    clear: ~buttons.tuiClear
                ),
                group: Group.new
        );
        createShaveTrack.(
                buffer: ~buffers.spadefoot,
                buttons: (
                    create: ~buttons.spadefootAdd,
                    clear: ~buttons.spadefootClear
                ),
                group: Group.new
        );
    }.value;


}
