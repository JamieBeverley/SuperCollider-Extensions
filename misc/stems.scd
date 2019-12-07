false

Jam.boot(true);

~out

SuperDirt.start()

(
Pdef(\a,
	Pbind(
		\instrument, Pseq([
			// Pseq([\kick_5, \tamb_m,\snare_2,\tamb_2],4),
			Pseq([\kick_m, \tamb_2,\snare_2],3),
		],inf),
		\dur, 0.25,
		\midinote,67,
		\sustain,1
	)
).play;
)

TempoClock.default.tempo = 2

TempoClock.tempo =2.11

Pdef(\a).stop

(
Pdef(\b,
	Pbind(
		\instrument, Pseq([
			// Pseq([\drumLoop_0,\drumLoop_1,\drumLoop_4,\drumLoop_3],4),
			Pseq([\drumLoop_2],16)
		],inf),
		\dur, Pseq([0.25],inf),
		\legato,1,
		\pitch,Pseq([0,0,0,0,-12],inf),
		\pos, Pseq([0, 0.25,0.5,0.75],inf)*0.125 + Pseq([0,0,0.125],inf),
		\db,-25
	)
).play;
)

Pdef(\b).stop
(
Pdef(\c,
	Pbind(
		\instrument, Pseq([
			\synth_0
		],inf),
		\dur, 0.125,
		\pitch,Pseq([0,7,19],inf)+Pseq([0,0,-12,12],inf)+[0,7],
		\sustain,Pseq((0.01,0.05..0.25).mirror,inf),
		\pan,Pwhite(-1,1),
		\strum,0.01,
		\db,-28
	)
).play;
)

Pdef(\c).stop

Pdef(\c).fadeTime = 15

(
Pdef(\d,
	Pmono(
		\saw6,
		\dur, 8,
		\midinote,Pseq([
			86+[0,3,7],
			91+[0,3,7]
		],inf),
		\panScatter,2,
		\db,-35,
		\rt,0
	)
).play;
)
Pdef(\d).stop
(
Pdef(\e,
	Pbind(
		\instrument, Pseq([
			\rest,\fut2
		],inf),
		\dur, Pseq([1/5,1/5,1/5,1/5,1/5],inf),
		\midinote,48+Pseq([
			Pseq([0],40)
		],inf)-12,
		\at,Pseq([
			Pseq([0.01],10),
			0.1,
		],inf),
		\mod,Pseq([2,1,1,1,1],inf)*[8],
		\rt,0.5,
		\sustain,0.25,
		\db, Pseq([-20,-20,-24,-24,-28,-28,-32,-32,-36,-36],inf)-15
	)
).play;
);
Pdef(\e).stop

Pdef(\a).stop

TempoClock.tempo = 1.1


(
Pdef(\a,
	Pbind(
		\instrument, Pseq([
			\fut2
		],inf),
		\dur, Pseq([0.07,0.08,0.1],inf)*2,
		\midinote,Pseq([
			Pstutter(1,Pseq([
				Pseq([0],4),
				// Pseq([-2],3),
				// Pseq([-6],1),
			],inf)+12)+36
		],inf)-12,
		\at,0.001,
		\rt,0.3,  // start at 0.01, change to 0.3
		\mod, Pseq([2,4,16, 2,4,16, 8,4,16],inf),
		\sustain,Pseq([0.1,0.01,0.4],inf),
		\db, Pseq([-25,-30,-25],inf)-1
	)
).play;
);

(
Pdef(\p,
	Pbind(\instrument, Pseq([\kick_2,\tamb_0,\snare_3,\tamb_0],inf),\db,-15,\dur,Pseq([0.25],inf))
).play
)

(
Pdef(\a,
	Pbind(
		\instrument, Pseq([
			\rest,\fmBass
		],inf),
		\dur, 1/5,
		\midinote,48+Pseq([
			Pseq([[0,22]],20),
			Pseq([[0,24]],20)
		],inf)-12,
		\at,0.1,
		\modPartial,Pseq([2,2,2,2,8],inf)*[2,0.25],
		\dt,0.1,
		\db, Pseq([-20,-20,-24,-24,-28,-28,-32,-32,-36,-36],inf),
	)
).play;
)



(
Pdef(\c,
	Pbind(
		\instrument, \fut2,
		\dur, 0.25,
		\at,0.01,
		\rt,0.3,
		\midinote, Pseq([
			Pseq([[0,3,7]],3),
			Pseq([[0,3,8]],4),
			Pseq([[0,3,12]],3),
			Pseq([[0,7,10]],4),
			Pseq([[-2,3,10]],3),
			Pseq([[0,-4,5]],3),
			Pseq([[0,-4,-12]],10)+Pseq([0,0,12],inf)
		],inf)+60,
		\strum, 0.025+Pwhite(0,0.005),
		\mod, Pseq([1,8],inf),
		\pan, Pseq([0,-1,1,0,1],inf)
	)
).play
)

MIDIClient.init
MIDIIn.connectAll

MIDIClient.destinations


s.options.sampleRate

Server.default.options.sampleRate

{SampleRate.ir.poll}.play