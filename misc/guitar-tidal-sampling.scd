Server.default.options.devic


SuperDirt.start
MIDIClient.init;
MIDIIn.connectAll;
(
var buffers = [Buffer.alloc(s,s.sampleRate*8,1),Buffer.alloc(s,s.sampleRate*8,1),Buffer.alloc(s,s.sampleRate*8,1),Buffer.alloc(s,s.sampleRate*8,1),Buffer.alloc(s,s.sampleRate*8,1),Buffer.alloc(s,s.sampleRate*8,1),Buffer.alloc(s,s.sampleRate*8,1),Buffer.alloc(s,s.sampleRate*8,1)];
var synths = nil!8;


SynthDef(\record,
	{
		|buffer,gate=1|
		var in = SoundIn.ar(0);

		RecordBuf.ar(in,buffer);
		EnvGen.ar(Env.asr(0,0,0),gate:gate,doneAction:2);
		// Out.ar(b,in);
		Out.ar(0,in);
}).add;

MIDIdef.noteOn(\guitarOn,
	{
		|vel,note|
		// "really?".postln;
		note = note-60;
		// "anything?".postln;
		note.postln;
		synths[note] = Synth.new(\record,[\buffer,buffers[note]]);
		"created synth".postln;

	},(60..67)
);


MIDIdef.noteOff(\guitarOff,
	{
		|vel,note|

		note = note-60;
		note.postln;
		synths[note].set(\gate,0);
		~buffers=buffers;
		("r"++note).postln;
		SynthDef("r"++note, { |out, bufnum, sustain = 1, begin = 0, end = 1, speed = 1, endSpeed = 1, freq = 440, pan = 0|

			var sound, rate, phase, sawrate, numFrames;

			// playback speed
			rate = Line.kr(speed, endSpeed, sustain) * (freq / 60.midicps);

			numFrames = BufFrames.ir(buffers[note]);
			sawrate = rate * BufSampleRate.ir(buffers[note]) / (absdif(begin, end) * numFrames);
			phase = (speed.sign * LFSaw.ar(sawrate, 1)).range(begin,end) * numFrames;

			sound = BufRd.ar(
				numChannels: 1,
				bufnum: buffers[note],
				phase: phase,
				loop: 0,
				interpolation: 4 // cubic interpolation
			);

			sound = DirtPan.ar(sound, 2, pan);
			OffsetOut.ar(out, sound);
		}).add;
		"done".postln;
	},(60..67)
);


)

(instrument:\r5).play

~buffers[0].plot
~b = Buffer.alloc(s,s.sampleRate*4);

{PlayBuf.ar(1,bufnum:~b)}.play

~b.plot

~e= Synth.new(\record,[\b,~b])
~e.set(\gate,0);

(\instrument:\r0).play

(

)