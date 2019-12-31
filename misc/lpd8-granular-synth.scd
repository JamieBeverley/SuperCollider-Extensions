(
b = Buffer.read(s,"C:/Users/jamie/AppData/Local/SuperCollider/downloaded-quarks/Dirt-Samples/asgmayl/9.wav");

// b = Buffer.read(s,"C:/Users/jamie/AppData/Local/SuperCollider/downloaded-quarks/Dirt-Samples/jamiexxss/16.wav");

// b = Buffer.read(s,"C:/Users/jamie/AppData/Local/SuperCollider/downloaded-quarks/Dirt-Samples/jamiexxss/19.wav");

// b = Buffer.read(s, "C:/Users/jamie/AppData/Local/SuperCollider/downloaded-quarks/Dirt-Samples/milesdavis/3flamencosketches.wav");

// b = Buffer.read(s,"C:/Users/jamie/AppData/Local/SuperCollider/downloaded-quarks/Dirt-Samples/drels/5.wav");
SynthDef(\grain,{
	arg rate=1,pos=0,amp=0.1,out=0,pan=0,sustain=1.0;
	var audio = Mix.ar(PlayBuf.ar(2,b.bufnum,rate:rate.clip(0,16)*BufRateScale.kr(b.bufnum),startPos:pos.clip(0,1)*BufFrames.kr(b.bufnum)));
	audio=audio*EnvGen.ar(Env([0,1,0],[sustain/2,sustain/2],curve:'welch'),doneAction:2);

	audio = Pan2.ar(audio,pan);
	Out.ar(~outBus,audio*(amp.clip(0,1)));
}).add;
~scale = Scale.major.degrees;
)
Jam.connectLPD8;


~k.size

Jam.boot

~k

~note



(
Pdef(\a,
	Pbind(
		\instrument,\grain,
		\db,-25,
		\rate,Pfunc({(~scale[(~note-24)%~scale.size]+[0,7]).midiratio}),
		\dur,0.005,
		\pos,Pfunc({~k[1]})+Pwhite(Pfunc({-1*~k[2]}),Pfunc({~k[2]})),
		\sustain,Pfunc({~k[5]*0.2})+ Pwhite(-0.01,0.01),
		\pan,Pfunc({~k[3].linlin(0,1,-1,1)})+Pwhite(Pfunc({(-1)*~k[4]}),Pfunc({~k[4]}))
	)
).play

)

~out.set(\reverb,0.4)

~out.set(\room,0.8)




~k[3]

"C:/Users/jamie/AppData/Local/SuperCollider/downloaded-quarks/Dirt-Samples/drebn"


"C:/Users/jamie/AppData/Local/SuperCollider/downloaded-quarks/Dirt-Samples/asgmayl/9.wav"

"C:/Users/jamie/AppData/Local/SuperCollider/downloaded-quarks/Dirt-Samples/asgmayl/6.wav"

"C:/Users/jamie/AppData/Local/SuperCollider/downloaded-quarks/Dirt-Samples/asgmayl/5.wav"

"C:/Users/jamie/AppData/Local/SuperCollider/downloaded-quarks/Dirt-Samples/asgmayl/4.wav"

"C:/Users/jamie/AppData/Local/SuperCollider/downloaded-quarks/Dirt-Samples/asgmayl/3.wav"