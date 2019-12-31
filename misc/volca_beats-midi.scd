MIDIClient.init

MIDIClient.sources.at(0)

MIDIIn.connectAll

(
//NOTE: set lpd8 to 4th prog
var synth = Synth(\volca_beats);
var quant = 4;
var noteDowns = false!8;
var effects = [\amp,\lpf,\hpf,\pan,\reverb,\room,\pitch,\begin];
var defaultLastLoop=4;
var lastLoop=defaultLastLoop;
MIDIdef.noteOn(\volca_beats_lpd8_loopOn,
	{
		|vel,note|
		var dur =((((TempoClock.beats*quant).ceil)/quant)-TempoClock.beats);
		note.postln;

		note = note-60+1;
		lastLoop=note;
		noteDowns[note-1]=true;

		synth.set(\loop,note);
		/*"played".postln;
		Routine{
			// (dur*TempoClock.tempo).wait;
			synth.set(\loop,note);
			"played".postln;
		}.play;*/
	},(60..67)
);
MIDIdef.noteOff(\volca_beatss_lpd8_loopOff,
	{
		|vel, note|
		var dur = ((((TempoClock.beats*quant).ceil)/quant)-TempoClock.beats);
		note = note-60+1;



		noteDowns[note-1 ]=false;

		if( (noteDowns[0]||noteDowns[1]||noteDowns[2]||noteDowns[3]||noteDowns[4]||noteDowns[5]||noteDowns[6]||noteDowns[7]).not, {
				synth.set(\loop,0);
				lastLoop=defaultLastLoop;
		});

		// Routine{
		// 	// (dur*TempoClock.tempo).wait;
		// 	if( (noteDowns[0]||noteDowns[1]||noteDowns[2]||noteDowns[3]||noteDowns[4]||noteDowns[5]||noteDowns[6]||noteDowns[7]).not, {
		// 		synth.set(\loop,0);
		// 		lastLoop=defaultLastLoop;
		// 	});
	// }.play;
	},(60..67)
);


MIDIdef.cc(\volca_beats_lpd8_effects,{
	|val,k|
	k.postln;
	switch(k,
		1,{synth.set(\amp,val*4/127)},
		2,{synth.set(\lpf,((val*val/127/127)*24000).clip(20,24000))},
		3,{synth.set(\hpf,((val*val/127/127)*24000).clip(20,24000))},
		4,{synth.set(\pan, ((val/127)*2)-1 )},
		5,{synth.set(\reverb, (val/127))},
		6,{synth.set(\room, (val/127))},
		7,{synth.set(\pitch, ((val/127)*12).round/12)},
		8,{synth.set(\begin, val/127)}
	);

}
);
)

Pbindef(\a,\instrument,\fmBass,\db,-20,\midinote,Pseq([60,60,60,62],inf),\dur,0.5,\sustain,0.25,\release,0.01).play

TempoClock.default

Jam.loadSuperDirtSynths

TempoClock.tempo = 0.9
TempoClock.tempo = 1

TempoClock.tempo



true||false

TempoClock.tempo

((((TempoClock.beats*32).ceil)/32));