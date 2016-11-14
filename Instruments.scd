var techno = Buffer.read(s, "/Users/JamieBeverley/Desktop/samples/techno/000_0.wav");
var bd = Buffer.read(s, "/Users/JamieBeverley/Desktop/samples/bd/BTAA0DA.wav");
var sn2 = Buffer.read(s, "/Users/JamieBeverley/Desktop/samples/sn/ST0T0S3.wav");
var clak= Buffer.read(s, "/Users/JamieBeverley/Desktop/samples/clak/000_clak1.wav");
var cp = Buffer.read(s, "/Users/JamieBeverley/Desktop/samples/cp/HANDCLP0.wav");
var hh = Buffer.read(s,"/Users/JamieBeverley/Desktop/samples/hh/000_hh3closedhh.wav");
var toys = Buffer.read(s, "/Users/JamieBeverley/Desktop/samples/toys/ClassicalMusic.wav");
var tone = Buffer.read(s,"/Users/JamieBeverley/Desktop/samples/newnotes/000_0.wav" );
var gunShot = Buffer.read(s, "/Users/JamieBeverley/Desktop/samples/ZZ Made/gunshot.wav");
var wobble = Buffer.read(s,"/Users/JamieBeverley/Desktop/samples/bleep/laser-reverse-wobble.wav");
var jvbass = Buffer.read(s,"/Users/JamieBeverley/Desktop/samples/jvbass/000_01.wav");
var metal = Buffer.read(s ,"/Users/JamieBeverley/Desktop/samples/metal/000_0.wav");

var drop = Buffer.read(s,"/Users/JamieBeverley/Desktop/samples/ZZ Made/Single Water Droplet-SoundBible.com-425249738.wav");
var fred = Buffer.read(s,"/Users/JamieBeverley/Desktop/samples/ZZ Made/Fred.wav");
var snap = Buffer.read(s,"/Users/JamieBeverley/Desktop/samples/snap.wav");


var hho = Buffer.read(s,"/Users/JamieBeverley/Desktop/samples/hh/007_hh3openhh.wav");
var sna = Buffer.read(s,"/Users/JamieBeverley/Desktop/samples/hh/012_hh3snare2.wav");


SynthDef(\rest,{
	arg dur;
	var audio =SinOsc.ar(mul:-300.dbamp);
	audio =audio*EnvGen.ar(envelope:Env.pairs([[0,0],[dur,0]]),doneAction:2);
		Out.ar(0,[audio,audio]);
 }).add;

// Crash
SynthDef(\crash,{
/*	arg dur;
	var audio=SinOsc.ar();
		Out.ar(0,[audio,audio]);*/
 }).add;

SynthDef(\pad,{
	arg out, freq, amp, gate=1,sus=8,vib=4;
	var audio,env;
	env = EnvGen.ar(Env.asr(2,sustainLevel:0.9,releaseTime:3),gate:gate,doneAction:2);


	audio = SinOsc.ar((freq+SinOsc.ar(freq,mul:freq)), mul:amp*SinOsc.ar(vib,mul:0.8))+BPF.ar(BrownNoise.ar(amp),freq,rq:0.25);

	audio = audio*env;

	Out.ar(0,[audio,audio]);

}
).add;
//Dr 0 fm
SynthDef(\fm29,
	{
		arg freq=440,amp=0.1,gate=1,out=0,lpf=20000;
		var f,mod,car,env,aud;
		f = Clip.kr(freq,12.midicps,108.midicps)/2;
		mod = EnvGen.ar(Env.pairs([[0,14],[0.4,0.5]],-8));
		mod = SinOsc.ar(f*2,mul:f*mod); // modulating oscillator
		car = SinOsc.ar(f+mod); // carrier oscillator
		env = Env.adsr(0.001,0.008,-10.dbamp,0.2,curve:-4); // envelope
		aud = car*EnvGen.ar(env,gate:gate,doneAction:2)*3.dbamp;
		aud = Compander.ar(aud,aud,-10.dbamp,clampTime:0.001,relaxTime:0.001,slopeAbove:1/10); // compression
		aud = aud * (3).dbamp; // makeup gain
		aud = LPF.ar(aud,freq:Clip.kr(lpf,20,20000)); // lowpass filter
		aud = aud * Clip.kr(amp,0,12.dbamp); // overall gain

		Out.ar(out,aud!2);
	}
).add;

//808  _________________________________________________________________________________

SynthDef(\808,{
	|amp=0.1, freq=30, sustain, pan=0|
	var audio = SinOsc.ar(freq,mul:amp)*EnvGen.ar(Env(levels:[0,1,0.8,0],times:[0.0001,1,0.5],curve:'lin'),doneAction:2);

	Out.ar(0,Pan2.ar(audio,pan));

}).add;

//String  Karplus-Strong synth
SynthDef(\string, { arg freq,lpf=1000, pan=0,sustain=2,gate=1, rand=0.2,out=0, amp,delayTime=3, noiseType=1;
	var x, y, env;
	//env = Env.new(#[1, 1, 0],#[2, 0.001]);
	env = EnvGen.ar(Env.adsr(attackTime:0.03,decayTime:0.9,sustainLevel:0.3,releaseTime:1),gate:gate,doneAction:2);


	// A simple exciter x, with some randomness.
	x = Decay.ar(Impulse.ar(0,0,0.2 ), 0.01, BrownNoise.ar());
 	x = CombL.ar(x, 0.05, freq.reciprocal, delayTime, env,mul:amp*4);
	x = LPF.ar(x,freq:lpf);
	//x = Pan2.ar(x, pan);

	Out.ar(0, [x,x]);
}).add;






// __________________________________________________________________________________
/*// FM Synth suited to longer duration
(
SynthDef(\space,{
arg sustain, freq, amp,chop=2*sustain,linb=0.04,line=1, out=0;

	var hfo = SinOsc.ar(freq,mul:freq*XLine.ar(linb,line,sustain/2)*SinOsc.ar(chop/sustain,mul:0.2,add:1));
	var audio = SinOsc.ar(freq+hfo,phase:hfo, mul:amp);

	var env = EnvGen.ar(Env.linen(attackTime:0.1*sustain,sustainTime: sustain, releaseTime:0.2*sustain),doneAction:2);

	audio = audio*LFTri.ar(freq:freq,mul:amp);
	audio = audio*env;

	audio=Compander.ar(audio,audio,-10.dbamp,slopeAbove:1/20,clampTime:0.001,relaxTime:0.5);

	Out.ar(out, audio);


}).add;
(\instrument:\space,\dur:1,\db:-20).play

)*/
//
// FM Synth suited to longer duration




SynthDef(\laser,{
arg dur, freq, amp,chop=2*dur,linb=0.04,line=1, gate=1;

	var hfo = SinOsc.ar(freq,mul:freq*XLine.ar(linb,line,dur/2)*SinOsc.ar(chop,mul:0.2,add:1));
	var audio = SinOsc.ar(freq+hfo,phase:hfo, mul:amp);

	var env = EnvGen.ar(Env.adsr(dur/4,releaseTime:dur/4),gate:gate,doneAction:2);

	audio = audio*LFTri.ar(freq:freq,mul:amp);
	audio = audio*env;

	audio=Compander.ar(audio,audio,-10.dbamp,slopeAbove:1/20,clampTime:0.001,relaxTime:0.5);

	Out.ar(0, [audio,audio]);


}).add;

// Ring Modulated. Decrement bwr for clearer sound
SynthDef(\bz,
	{
		arg mod=1,freq=440,amp=0.1,dur,gate=1,out=[0,1],sustain=1,lpf=5000,bwr=0.001;
		var audio,env,rfreq;
		rfreq = freq/mod;
		amp = amp * (20.dbamp) * (1/bwr);
		audio = Saw.ar(freq,amp) * Resonz.ar(PinkNoise.ar(),freq:freq/mod,mul:0.dbamp,bwr:bwr);
		env = EnvGen.ar(Env.linen(attackTime:0.01,sustainTime:dur,releaseTime:0.5),doneAction:2);
		audio = audio*env;
		audio = LPF.ar(audio,freq:lpf)*0.2;
		audio = Compander.ar(audio,audio,thresh:-3.dbamp,slopeAbove:0.05,clampTime:0.001);
		Out.ar(out,[audio,audio]);
	}
).add;

//Scratchy FM Synth

SynthDef(\fmf,
	{
		arg out=0, freq,amp,gate=1,modPartial=4;

		var mod1 = SinOsc.ar(freq,phase:SinOsc.ar(freq),mul:freq);

		var audio;

		var env = EnvGen.ar(Env.adsr(attackTime:0.01,decayTime:0.2,sustainLevel:0.9,releaseTime:0.3),gate:gate,doneAction:2);

		var modenv = EnvGen.ar(Env.pairs([[0,0.1],[0.1,0.2]],\exp));

//		mod1= SinOsc.ar(2*freq*mod1,mul:2)*env;
		mod1=mod1*modenv;

		audio = SinOsc.ar(freq*mod1*modPartial,mul:amp);

		audio=audio*env;

		Clip.ar(audio,-200.dbamp,30.dbamp);
		Out.ar(0,[audio,audio]);
	}
).add;

//high kick_______________________________________________________________________________________

SynthDef(\kh, {
	arg out = 0,curve= -4, amp;
	var audio = SinOsc.ar(36,mul:amp);

	var env = EnvGen.ar(Env.perc(attackTime:0.01,releaseTime:0.05),doneAction:2);

	audio=HPF.ar(audio,600,mul:300);

	audio = audio*env;

	audio=Compander.ar(audio,audio,-10.dbamp,slopeAbove:1/20,clampTime:0.001,relaxTime:0.5);

	Out.ar( 0,[audio,audio]);
}).add;

//Simple Closed Highat__________________________________________________________________________________

SynthDef(\chh,
	{
		arg out,amp= -20.dbamp,dur,curve= -20,gate=1,rt=1,hpf=2000;
		var audio = HPF.ar(WhiteNoise.ar(amp*0.1),hpf);

		var env = EnvGen.ar(Env.perc(attackTime:0.01,releaseTime:rt,curve:curve),gate:gate,doneAction:2);

		audio = audio*env;

		//audio=Compander.ar(audio,audio,0.1,slopeBelow:1,slopeAbove:0.1,clampTime:0.01,);
		Out.ar(0, [audio,audio]);
	}
).add;



SynthDef(\chp,
	{
		arg amp= -20.dbamp,dur,curve= -20,gate=1,sustaine;
		//var audio = GVerb.ar(HPF.ar(WhiteNoise.ar(amp*0.1),2000));
		var audio = WhiteNoise.ar(amp);

		var env = EnvGen.ar(Env.perc(attackTime:0.001,releaseTime:1,curve:curve),gate:gate,doneAction:2);

		audio=BPF.ar(audio,96.midicps,rq:0.1,mul:2);

		audio= FreeVerb.ar(audio,0.3);
		audio = audio*env;

		audio=Compander.ar(audio,audio,0.1,slopeBelow:1,slopeAbove:0.1,clampTime:0.01,);
		Out.ar(0, [audio,audio]);
	}
).add;
//Rcch


SynthDef(\chhr,
	{
		arg amp= -20.dbamp,dur,curve= -8;
		var audio = GVerb.ar(LPF.ar(WhiteNoise.ar(amp*0.2),2400));
		var env = EnvGen.ar(Env.perc(attackTime:0.1,releaseTime:0.02,curve:curve),doneAction:2);

		audio = audio*env;

		audio=Clip.ar(audio,-100.dbamp,30.dbamp);


		Out.ar(0, [audio,audio]);
	}
).add;



// Space __________________________________________________________________________________
// FM Synth suited to longer duration

/*SynthDef(\space,{
arg sustain, freq, amp,chop=2*sustain,linb=0.04,line=1,out=0;

	var hfo = SinOsc.ar(freq,mul:freq*XLine.ar(linb,line,sustain/2)*SinOsc.ar(chop/sustain,mul:0.2,add:1));
	var audio = SinOsc.ar(freq+hfo,phase:hfo, mul:amp);

	var env = EnvGen.ar(Env.linen(attackTime:0.1*sustain,sustainTime: sustain, releaseTime:0.2*sustain),doneAction:2);

	audio = audio*env;

	audio=Clip.ar(audio,-100.dbamp,30.dbamp);

	audio=Compander.ar(audio,audio,-10.dbamp,slopeAbove:1/20,clampTime:0.001,relaxTime:0.5);

	Out.ar(0, [audio,audio]);


}).add;*/

SynthDef(\space,{
arg sustain, freq,at=2, amp,chop=2*sustain,linb=0.04,line=1,out=0,gate=1;

	var hfo = SinOsc.ar(freq,mul:freq*XLine.ar(linb,line,sustain/2)*SinOsc.ar(chop/sustain,mul:0.2,add:1));
	var audio = SinOsc.ar(freq+hfo,phase:hfo, mul:amp);

	var env = EnvGen.ar(Env.asr(attackTime:at,sustainLevel:0.9, releaseTime:1),gate:gate,doneAction:2);

	audio = audio*env;

	audio=Clip.ar(audio,-100.dbamp,30.dbamp);

	audio=Compander.ar(audio,audio,-10.dbamp,slopeAbove:1/20,clampTime:0.001,relaxTime:0.5);

	Out.ar(0, [audio,audio]);


}).add;


//HFO FM Synth (Triangular HFO Oscillator)_____________________________________________________________________________________
// Multiuse

SynthDef(\fmt, { arg bus = 0, freq = 440, gate=1,modPartial = 1, index = 3, amp, dur, hfoMod=3;



	var hfo = LFTri.ar(freq:freq * modPartial,mul: freq*index*SinOsc.ar(hfoMod/dur,mul:0.5,add:0.5),add:0);
	var audio = SinOsc.ar(freq:freq + hfo,mul: amp).max;
	var env = EnvGen.ar(Env.adsr(attackTime:0.01,decayTime:0.03,sustainLevel:0.2,curve:-4),gate:gate,doneAction:2);


	audio = audio*env;

	audio=Clip.ar(audio,-100.dbamp,30.dbamp);


	Out.ar( bus,[audio,audio])
}).add;


//HFO FM Synth 3 - linear envelope_______________________________________________________________________________
// Multiuse

SynthDef(\fm3, { arg bus = 0, freq = 440, carPartial = 1, modPartial = 1, index = 3, amp, dur, hfoMod=3;

	// index values usually are between 0 and 24
	// carPartial :: modPartial => car/mod ratio

	var hfo;
	var audio;

	var env = EnvGen.ar(Env.linen(attackTime:0.8*dur,sustainTime:0.1*dur,releaseTime:0.4*dur),doneAction:2);

	hfo = SinOsc.ar(freq:freq * modPartial,phase:0,mul: freq*index*SinOsc.ar(hfoMod/dur,mul:0.5,add:0.5));
	audio = SinOsc.ar(freq:(freq * 1) + hfo,mul: amp).squared*env;

	audio=Clip.ar(audio,-100.dbamp,30.dbamp);

	Out.ar(	bus,[audio,audio])
}).add;

SynthDef(\ting,
	{
		arg amp= -20.dbamp,dur,curve= -8, freq = 800,modPartial=16,delayTime=0.25;


		var audio = SinOsc.ar(freq+SinOsc.ar(freq:modPartial*freq,mul:modPartial*freq),mul:amp);

		var env = EnvGen.ar(Env.perc(attackTime:0.01,releaseTime:1,curve:curve),doneAction:0);
		var env1 = EnvGen.ar(Env.pairs([[0,1],[3,1]],\lin),doneAction:2);
		audio = audio*env;

		audio = Decay.ar(audio,decayTime: 0.2,mul:0.1);

		audio = audio+CombC.ar(audio,maxdelaytime: delayTime+0.1,delaytime: delayTime,decaytime:3);

//		audio = audio*env1;

		Out.ar(0, [audio,audio]);
	}
).add;

SynthDef(\noise,
	{
		arg freq = 440, out = 0, amp = 0.1, lpf = 2500, sustain=6.001, fnoise = 0.003,hm=1;
		var audio = LFTri.ar(freq*Rand(1-fnoise,1+fnoise)+PinkNoise.ar(mul:freq*hm),mul:amp*SinOsc.ar(freq:1,mul:0.5,add:1));
//		audio = LPF.ar(audio,freq:lpf);
		audio = audio*EnvGen.ar(Env.linen((sustain-0.001)*0.33,0.001,(sustain-0.001)*0.67),doneAction:2);
		Out.ar(out,audio);
}).add;

SynthDef(\bell,
	{
		arg amp= -20.dbamp,dur,curve= -8, freq = 800,modPartial=16;
		//var audio = Resonz.ar(WhiteNoise.ar(mul:amp),freq:freq,bwr:0.00001,mul:2000);

		//var audio = SinOsc.ar(freq,mul:amp)+LPF.ar(WhiteNoise.ar(mul:amp),freq:freq*2);

		var audio = SinOsc.ar(freq+SinOsc.ar(freq:modPartial*freq,mul:modPartial*freq),mul:amp);

		//	var audio = Resonz.ar(WhiteNoise.ar(mul:amp),freq:freq,bwr:0.01,mul:1);
		var env = EnvGen.ar(Env.perc(attackTime:0.01,releaseTime:1,curve:curve),doneAction:2);
		audio = audio*env;



		Out.ar(0, [audio,audio]);
	}
).add;


SynthDef(\full,
	{
		arg gate=1,amp= -20.dbamp,dur,curve= -8, freq = 440,modPartial=4, sustain=0.5;
		//var audio = Resonz.ar(WhiteNoise.ar(mul:amp),freq:freq,bwr:0.00001,mul:2000);

		//var audio = SinOsc.ar(freq,mul:amp)+LPF.ar(WhiteNoise.ar(mul:amp),freq:freq*2);

		var freq2 = freq/2;
		var audio = SinOsc.ar(freq+SinOsc.ar(freq:modPartial*freq,mul:64*freq),mul:amp).max ;//+SinOsc.ar(freq*3/2+SinOsc.ar(freq:3*freq,mul:64*freq),mul:amp).max;
		var audio2 = Saw.ar(freq/4,mul:amp).abs + Saw.ar(freq/2,mul:amp).abs +Saw.ar(freq/8,mul:amp).abs;

		//	var audio = Resonz.ar(WhiteNoise.ar(mul:amp),freq:freq,bwr:0.01,mul:1);
		var env = EnvGen.ar(Env.adsr(attackTime:0.01,decayTime:0.3,sustainLevel:sustain,releaseTime:4,curve:curve),gate:gate,doneAction:2);
		audio = audio+audio2;
		audio = audio*env;
		Out.ar(0, [audio,audio]);
	}
).add;


//Future house fm synth_____________________________________________________________________________

/*SynthDef(\fut, { arg bus = 0, dt=0.4, at=0.01,freq = 440, gate=1,modPartial = 8, curve= -8,index = 3, amp, dur;



	var hfo = SinOsc.ar(freq:freq*modPartial,mul: freq*XLine.ar(12,4,dur:dur/5,doneAction:0),add:0);
//	var hfo = SinOsc.ar(freq:freq*modPartial,mul: freq*EnvGen.ar(Env.,add:0);
	var audio = SinOsc.ar(freq:freq+hfo,mul: amp).squared;
	var env = EnvGen.ar(Env.adsr(attackTime:at,decayTime:dt,sustainLevel:0.3,curve:curve),gate:gate,doneAction:2);

	//hfo=hfo*EnvGen.ar(Env.pairs([[0,1],[dur,1]]),gate:gate,doneAction:2);
	audio = audio*env;


	Out.ar( bus,[audio,audio]);
}).add;*/

/*
SynthDef(\fut, {
	arg out = 0, dt=0.2, at=0.01,freq = 220, gate=1,modPartial=4, curve= -4,index = 3, amp, sustain;



	var hfo = SinOsc.ar(freq:freq*modPartial/4,mul: freq*modPartial);

	var envhfo= EnvGen.ar(Env.adsr(attackTime:at,decayTime:dt,sustainLevel:0.1,releaseTime:0.1,curve:-3),doneAction:0)*hfo;
	var audio = SinOsc.ar(freq:freq+envhfo,mul: amp);
	var env = EnvGen.ar(Env.adsr(attackTime:at,decayTime:dt,sustainLevel:0.3,curve:curve),gate:gate,doneAction:2);

	audio = LPF.ar(audio,freq:XLine.ar(10000,end:10,dur:at+dt+sustain,doneAction:0));


	audio = audio*env;

	audio=Compander.ar(audio,audio,-10.dbamp,slopeAbove:1/20,clampTime:0.001,relaxTime:0.5);

	Out.ar( 0,[audio,audio]);
}).add;*/

SynthDef(\fm6, {
	arg out = 0, freq = 220, gate=1,modPartial=5, curve= -4,index = 3, amp, sustain;



	var hfo = SinOsc.ar(freq:freq*modPartial,mul: freq*modPartial);
	var envhfo= EnvGen.ar(Env.adsr(attackTime:0.02,decayTime:2,sustainLevel:0.1,releaseTime:0.01,curve:-16),doneAction:0)*hfo;

	var topOctave = SinOsc.ar(freq:(freq+envhfo),mul: amp/4)*EnvGen.ar(Env.linen(0.01,0.03,sustain));
	var audio = SinOsc.ar(freq:(freq+envhfo)/2,mul: amp/2) + SinOsc.ar(freq:freq+envhfo,mul: amp/2) + topOctave;
	var env = EnvGen.ar(Env.adsr(attackTime:0.01,decayTime:0.2,sustainLevel:0.4,curve:-2),gate:gate,doneAction:2);


	audio = audio*env;
	audio=Compander.ar(audio,audio,20.dbamp,slopeAbove:1/20,clampTime:0.001,relaxTime:0.5);

	Out.ar( 0,[audio,audio]);
}).add;

SynthDef(\fut, {
	arg out = 0, dt=0.2, at=0.01,freq = 220, gate=1,modPartial=4, curve= -4,index = 3, amp=(-20.dbamp),doneAction=2;
	var hfo = SinOsc.ar(freq:freq*modPartial/4,mul: freq*modPartial);
	var envhfo= EnvGen.ar(Env.adsr(attackTime:at,decayTime:dt,sustainLevel:0.1,releaseTime:0.1,curve:-3),doneAction:0)*hfo;
	var audio = SinOsc.ar(freq:freq+envhfo,mul: amp);
	var env = EnvGen.ar(Env.adsr(attackTime:0.01,decayTime:dt,sustainLevel:0.3,curve:curve),gate:gate,doneAction:doneAction);

	audio = audio*env;

	audio=Compander.ar(audio,audio,20.dbamp,slopeAbove:1/20,clampTime:0.001,relaxTime:0.5);

	Out.ar( 0,[audio,audio]);
}).add;



//Fm simple_____________________________________________________________________________________
// Multiuse

SynthDef(\fms, { arg bus = 0, dt=0.02,at=0.02,freq = 440, gate=1,modPartial = 1, curve= -8,index = 3, amp, dur, hfoMod=3;



	var hfo = SinOsc.ar(freq:freq*modPartial,mul: freq*3,add:0);
	var audio = SinOsc.ar(freq:freq+hfo,mul: amp).squared;
	var env = EnvGen.ar(Env.adsr(attackTime:at,decayTime:dt,sustainLevel:0.3,curve:curve),gate:gate,doneAction:2);

	audio = audio*env;

	audio=Clip.ar(audio,-100.dbamp,30.dbamp);

	Out.ar( bus,[audio,audio])
}).add;


//HFO FM Synth ADSR Env._____________________________________________________________________________________
// Multiuse

SynthDef(\fma, { arg bus = 0, dt=0.02,at=0.02,freq = 440, gate=1,modPartial = 1, curve= -8,index = 3, amp, dur, hfoMod=3;



	var hfo = LFTri.ar(freq:freq * modPartial,mul: freq*index*SinOsc.ar(hfoMod/dur,mul:0.5,add:0.5),add:0);
	var audio = SinOsc.ar(freq:freq + hfo,mul: amp).max;
	var env = EnvGen.ar(Env.adsr(attackTime:at,decayTime:dt,sustainLevel:0.3,curve:curve),gate:gate,doneAction:2);

	audio = audio*env;

	audio=Clip.ar(audio,-100.dbamp,30.dbamp);

	Out.ar( bus,[audio,audio])
}).add;

//HFO FM Synth 2 Perc Env._____________________________________________________________________________________
// Multiuse


SynthDef(\fmp, { arg bus = 0, freq = 440, carPartial = 1, modPartial = 1, index = 3, amp, dur, hfoMod=3;
	var env = EnvGen.ar(Env.perc(0.05*dur,0.9*dur,curve:-2),doneAction:2);
	var hfo = SinOsc.ar(freq:freq * modPartial,phase:0,mul: freq*index*SinOsc.ar(hfoMod/dur,mul:0.5,add:0.5));
	var audio = SinOsc.ar(freq:(freq * 1) + hfo,mul: amp).squared*env;
	audio=Clip.ar(audio,-100.dbamp,30.dbamp);
	Out.ar(	bus,[audio,audio])
}).add;

//HFO FM Synth__________________________________________________________________________________________
// Multiuse

SynthDef(\fm1, { arg bus = 0, freq = 440, carPartial = 1, modPartial = 1, index = 3, amp, dur;
	var hfo;
	var audio;

	var envhfo = EnvGen.ar(Env.sine(dur),doneAction:2);
	var env = EnvGen.ar(Env.perc(0.05*dur,0.95*dur,curve:-4),doneAction:2);

	hfo = SinOsc.ar(freq:freq * modPartial,phase:0,mul: freq*index*env);
	audio = GVerb.ar(SinOsc.ar(freq:(freq * carPartial) + hfo,mul: amp),25)*env;

	audio=Clip.ar(audio,-100.dbamp,30.dbamp);

	Out.ar(	bus,[audio,audio])
}).add;

// Organ __________________________________________________________________________________
// FM Synth suited to longer duration

SynthDef(\org,{
arg dur, freq, amp,chop=2*dur,linb=0.04,line=1;
	var hfo = LFTri.ar(freq*3,mul:freq*XLine.ar(4,1,dur/2));
	var audio = SinOsc.ar(freq+hfo, mul:amp);
	var env = EnvGen.ar(Env.linen(attackTime:0.1*dur,sustainTime: 0.3*dur, releaseTime:0.6*dur),doneAction:2);
	audio = audio*env;
	audio=Clip.ar(audio,-100.dbamp,30.dbamp);

	Out.ar(0, [audio,audio]);
}).add;


//Hol_______________________________________________________________________
//Ambient

SynthDef(\hol,
	{
		arg freq, amp = 0.1,gate=1,dur,len=1,out=0;
		//var env = EnvGen.ar(Env.linen(attackTime:0.2*dur,sustainTime:0.4*dur, releaseTime:0.4*dur),doneAction:2);
		var env = EnvGen.ar(Env.linen(attackTime:0.5,sustainTime:dur*len, releaseTime:4),gate:gate,doneAction:2);

		var audio = PinkNoise.ar(freq,mul:amp);

		audio = BPF.ar(audio,freq:freq,rq:0.001)*16;

		audio=audio*env;
	//	audio1=Clip.ar(audio1,-100.dbamp,30.dbamp);

		Out.ar(0 ,[audio,audio]);
	}
).add;

//Whiss (developing)
SynthDef(\whis,
	{
		arg freq, amp = 0.1,gate=1,dur,len=1,sustain;
		//var env = EnvGen.ar(Env.linen(attackTime:0.2*dur,sustainTime:0.4*dur, releaseTime:0.4*dur),doneAction:2);
		var env = EnvGen.ar(Env.perc(attackTime:0.01*dur,releaseTime:dur),gate:gate,doneAction:2);

		var audio = WhiteNoise.ar(mul:amp);

		audio = BPF.ar(audio,freq:freq*2,rq:0.001*XLine.ar(1,100,dur:dur))*16;//*XLine.ar(0.2,2,dur:dur))*64;

	//	audio = HPF.ar(WhiteNoise.ar(amp/6),freq:XLine.ar(freq,freq/8,dur:1));

		audio=audio*env;
	//	audio1=Clip.ar(audio1,-100.dbamp,30.dbamp);

		Out.ar(0 ,[audio,audio]);
	}
).add;

//Berm______________________________________________________________________
//Driver

SynthDef(\berm,
	{
		arg freq = 65,out=0 , amp = 0.1,dur, pulser=3,gate=1;
		//var env = EnvGen.ar(Env.linen(attackTime:0.2*dur,sustainTime:0.4*dur, releaseTime:0.4*dur),doneAction:2);
		var env = EnvGen.ar(Env.linen(attackTime:0.01*dur,sustainTime:0.95*dur, releaseTime:0.2*dur),gate=1,doneAction:2);
		var wob = Saw.ar(pulser,mul:12.midicps);
		var audio1 = SinOsc.ar(freq+wob,mul:amp);
		audio1=audio1*env;

		Out.ar(0 ,[audio1,audio1]);
	}
).add;


//Verb_________________________________________________________________________________
SynthDef(\verb,
	{
		arg freq, gate=1, amp, out=0,div=2;

		var mod = SinOsc.ar(freq*div,mul:freq*(1/div),add:freq);

		var car = SinOsc.ar(mod,mul:amp)+SinOsc.ar(mod*2,mul:amp);

		var env = EnvGen.ar(Env.adsr(attackTime:0.3,decayTime:0.3,sustainLevel:0.3,releaseTime:0.2),gate:gate,doneAction:2);

		car =car*env;

		Out.ar(out,[car,car]);
	}




).add;

//Womp2____________________________________________________________________________________

SynthDef(\womp2,
	{
	arg freq, amp, sustain,chopr=3, numharm,sustainlvl=0.4,gate=1;
		var nh = SinOsc.ar(freq:1/4,mul:1,add:1);
		var audio = LPF.ar(Blip.ar(freq,mul:amp,numharm:numharm*nh),freq:6000*LFPar.ar(freq:sustain*chopr,add:0.5,mul:0.5));
		var env = EnvGen.ar(Env.adsr(attackTime:0.05,decayTime:0.3,sustainLevel:sustainlvl,releaseTime:0.5),gate:gate,doneAction:2);
		audio = audio*env;

		Out.ar(0, [audio,audio]);
	}
).add;
//Womp____________________________________________________________________________________

SynthDef(\womp,
	{
	arg freq, out=0, amp, chopr, dur, numharm,sustainlvl=0.4,gate=1,at=0.03,dt=0.3,rt=0.5;
		var nh = SinOsc.ar(freq:chopr,phase:SinOsc.ar(freq:1/2,mul:3.14/2,add:3.14/2),mul:1,add:1);
		var audio = LPF.ar(Blip.ar(freq,mul:amp,numharm:numharm*nh),freq:6000*LFPar.ar(freq:dur*chopr,add:0.5,mul:0.5));
		var env = EnvGen.ar(Env.adsr(attackTime:at,decayTime:dt,sustainLevel:sustainlvl,releaseTime:rt),gate:gate,doneAction:2);
		audio = audio*env;

		audio=Compander.ar(audio,audio,-10.dbamp,slopeAbove:1/20,clampTime:0.001,relaxTime:0.5);

		Out.ar(0,[audio,audio]);
	}
).add;

//Bubble___________________________________________________________________________________


SynthDef(\bb,
	{
		arg  freq,amp = 0.1;

		var hfo = SinOsc.kr(100,mul:24.midicps);
		var nh = 5;
		var hfo2 = SinOsc.kr(10,nh,nh);
		var audio1 = HPF.ar(Blip.ar(freq+hfo,mul:amp,numharm:hfo2),32.midicps);

		var env = EnvGen.ar(Env.perc(attackTime:0.01,releaseTime:1,curve:-4),doneAction:2);


		audio1=audio1*env;

		Out.ar(0 ,[audio1,audio1]);


	}
).add;


//baw______________________________________________________________________
//Driver

SynthDef(\baw,
	{
		arg freq = 65 , amp = 0.1,dur, pulser=3;
		var env = EnvGen.ar(Env.linen(attackTime:0.01,sustainTime:dur*1.2, releaseTime:0.1),doneAction:2);
		var wob = SinOsc.ar(100,mul:12.midicps);
		var audio1 = LFTri.ar(freq+wob,mul:amp);
		audio1=audio1*env;
		Out.ar(0 ,[audio1,audio1]);
	}
).add;

// Build Release_______________________________________________________________________________________
// Situational
SynthDef(\release,
	{
		arg amp= -20.dbamp, lpf=4000, dur;

		var bpfl = EnvGen.ar(Env.linen(attackTime:0.01*dur,sustainTime:0.06*dur,releaseTime:0.89*dur,curve:\lin),doneAction:2);
		var a = BPF.ar(WhiteNoise.ar(amp*SinOsc.ar(2,mul:0.2,add:1)),1600*bpfl);

		var env = EnvGen.ar(Env.linen(attackTime:0,sustainTime:dur),doneAction:2);
		//var clip = BPF.ar(WhiteNoise.ar(amp+5.dbamp),500);
		var env2 = EnvGen.ar(Env.perc(attackTime:0.01,releaseTime:0.1,curve:-8,level:1.5),doneAction:0);

		var clip=a*env2;

		a = a*env;
		Out.ar(0, [[clip,a],[a,clip]]);
	}
).add;

//Pitched Build ____________________________________________________________________________
//Pitched/Situ.

 SynthDef(\build,
	{
		arg  amp = 1, freq, numharm=0,curve= -8, dur;
		var env = EnvGen.ar(Env.linen(attackTime:0.4*dur,sustainTime:0.7*dur,releaseTime:dur/4),doneAction:2);
		var envfreq = EnvGen.ar(Env.linen(attackTime:dur,sustainTime:0,releaseTime:dur/4),doneAction:2);
		var envnh = EnvGen.ar(Env.linen(attackTime:dur,sustainTime:0,releaseTime:dur/4),doneAction:2);
		var nhosc = SinOsc.ar(freq:16,mul:0.1,add:1);
		var audio1 = Blip.ar(freq+24.midicps*envfreq,mul:amp,numharm:numharm+16*envnh*nhosc);
		audio1=audio1*env;
		Out.ar(0 ,[audio1,audio1]);
	}
).add;

//Long Fuzz______________________________________________________________________
//Ambient
SynthDef(\long,
	{
		arg freq = 65 , amp = 0.1,dur, pulser=3;
		var env = EnvGen.ar(Env.triangle(dur),doneAction:2);

		var wob = SinOsc.ar(100,mul:12.midicps);
		var pulse = SinOsc.ar(pulser,mul:0.5,add:1);
		var audio1 = LFTri.ar(freq+wob,mul:amp*pulse);
		audio1=audio1*env;

		Out.ar(0 ,[audio1,audio1]);


	}
).add;

//Echo Drip Drop______________________________________________________________________
//Ambient
SynthDef(\edd,
	{
		arg freq = 65 , amp = 0.1, dur,chopr=3;
		var env = EnvGen.ar(Env.linen(attackTime:0.01,sustainTime:0.02,releaseTime:2),doneAction:2);
		var chop = Saw.ar(chopr);
		var hfo = SinOsc.kr(100,mul:12.midicps);
		var audio1 = GVerb.ar(SinOsc.ar(freq+hfo,mul:amp*chop),roomsize:10,damping:0.5);
		audio1=audio1*env;

		Out.ar(0 ,[audio1,audio1]);

	}
).add;


//Dr O Dust ____________________________________________________________________

SynthDef(\dust,
	{
		arg freq=110,amp=0.1,sustain=0.061,gain = 2,density=5000,out=0;



		var audio = Dust.ar(density,mul:amp);
		var env = Env.perc();
		audio = MoogFF.ar(audio,freq,gain);
		audio = LPF.ar(audio,13500);
		audio = audio*EnvGen.ar(env,doneAction:2);
		Out.ar(out,audio);
}).add;


//Gloom______________________________________________________________________

SynthDef(\gloom,
	{
		arg freq = 65 , amp = 0.1, dur;
		var env = EnvGen.ar(Env.perc(attackTime:0.03*dur,releaseTime:0.7*dur),doneAction:2);
		var nh = SinOsc.ar(100,mul:0.5, add:4);
		var hfo = SinOsc.kr(500,mul:24.midicps);
		var audio1 = Blip.ar(freq+hfo,mul:amp,numharm:6);
		audio1=audio1*env;

		Out.ar(0 ,[audio1,audio1]);


	}
).add;


// x__________________________________________________
SynthDef(\x,
	{
		arg freq, amp, wobbler=3,gate=1, sustain,vibrato=10;
		var wobble = LFTri.ar(wobbler, mul:1.midicps);
		var a = LFTri.ar(freq+wobble,mul:amp*SinOsc.ar(vibrato,mul:0.2,add:0.8));
		var env = EnvGen.ar(Env.adsr(attackTime:0.01,decayTime:0.3,sustainLevel:0.9,releaseTime:1),gate, doneAction:2);
		a= a*env;
		Out.ar(0, [a,a]);
	}
).add;

//Kick drum
SynthDef(\k,
	{
		arg  amp = 0.1, freq= 12.midicps,dur,curve= -8;

	//	var env = EnvGen.ar(Env.perc(attackTime:0.01,releaseTime:0.5,curve:-8),doneAction:2);

		var env = EnvGen.ar(Env.perc(0.01,releaseTime:1,curve:-20),doneAction:2);
		var audio1 = SinOsc.ar(36.midicps,mul:amp*2);

		audio1=Compander.ar(audio1,thresh:0.5,slopeBelow:0.6,slopeAbove:0.7,clampTime:0.1,relaxTime:0.3,mul:0.5);
		//audio1=GVerb.ar(audio1,revtime:0.01,roomsize:20,revtime:1,drylevel:0.5,mul:1);
		//audio1=FreeVerb.ar(audio1,mix:0.33,mul:2);
//
		audio1=audio1*env;

		Out.ar(0,[audio1,audio1]);

	}
).add;
//BRUSH SNARE__________________________________________________________________________________

SynthDef(\brushsnare,
	{
		arg amp= -20.dbamp;
		var audio = WhiteNoise.ar(amp);
		var env = EnvGen.ar(Env.perc(attackTime:0.01,releaseTime:0.5,curve:-8),doneAction:2);
		audio = audio*env;
		Out.ar(0, [audio,audio]);
	}
).add;


//WAVE  __________________________________________________________________________________
SynthDef(\wave,
	{
		arg out=0, amp= -20.dbamp, lpf,gate=1;

		var audio = LPF.ar(BrownNoise.ar(),lpf,mul:amp+0.dbamp);
		var env = EnvGen.ar(Env.adsr(attackTime:0.03,decayTime:0.03,sustainLevel:0.1,releaseTime:0.2),gate:gate,doneAction:2);

		audio = audio*env;

		Out.ar(out, [audio,audio]);
	}
).add;



//Bass Drum____________________________________________________________________________
 SynthDef(\bd,
	{
		arg  amp = 0.1, freq=36.midicps;
		var env = EnvGen.ar(Env.perc(attackTime:0.01,releaseTime:1,curve:-8),doneAction:2);
		var audio1 = SinOsc.ar(freq,mul:amp);
		audio1=audio1*env;
		Out.ar(0 ,[audio1,audio1]);
	}
).add;

//Verb whin____________________________________________________________________________
 SynthDef(\form,
	{
		arg  amp = 0.1, freq=36.midicps, numharm=0,curve= -8,gate=1;
		var env = EnvGen.ar(Env.adsr(attackTime:0.03,sustainLevel:0.3,releaseTime:0.2,curve:curve),gate:gate,doneAction:2);

		var audio1 = Formlet.ar(Impulse.ar(freq,mul:amp), 800, 0.01, 0.1);
		audio1=audio1*env;

		Out.ar(0 ,[audio1,audio1]);


	}
).add;

//Release___________________________________________________________________________
SynthDef(\release,
	{
		arg amp= -20.dbamp, lpf=4000, dur;

		var bpfl = EnvGen.ar(Env.linen(attackTime:0.01*dur,sustainTime:0.06*dur,releaseTime:0.89*dur,curve:\lin),doneAction:2);
		var a = BPF.ar(WhiteNoise.ar(amp*SinOsc.ar(2,mul:0.2,add:1)),1600*bpfl);

		var env = EnvGen.ar(Env.linen(attackTime:0,sustainTime:dur),doneAction:2);
		//var clip = BPF.ar(WhiteNoise.ar(amp+5.dbamp),500);
		var env2 = EnvGen.ar(Env.perc(attackTime:0.01,releaseTime:0.1,curve:-8,level:1.5),doneAction:0);

		var clip=a*env2;

		a = a*env;
		Out.ar(0, [[clip,a],[a,clip]]);
	}
).add;

//

SynthDef(\bassa, {
	arg out = 0, dt=0.3, at=0.01,freq = 220, gate=1,modPartial=4, curve= -4,index = 3, amp, sustain;



	var one = SinOsc.ar(freq,mul:amp);
	var two = SinOsc.ar(freq+SinOsc.ar(freq*3,mul:freq*3),mul:amp);
	var three = SinOsc.ar(freq+SinOsc.ar(freq*5,mul:freq*5),mul:amp);
	var four = SinOsc.ar(freq+SinOsc.ar(freq*7,mul:freq*7),mul:amp);

	var audio;

	var fourenv = Line.ar(1,0,4);



	var env = EnvGen.ar(Env.adsr(at,dt,1),doneAction:2,gate:gate);

//	audio = LPF.ar(audio,freq:XLine.ar(10000,end:10,dur:at+dt+sustain,doneAction:0));

	//four=four*fourenv;

	audio = one+two+three+four;

	audio = audio*env;

	audio=Compander.ar(audio,audio,-10.dbamp,slopeAbove:1/20,clampTime:0.001,relaxTime:0.5);

	Out.ar( 0,[audio,audio]);
}).add;
//Spec_____________________________________________________________________________________________________
SynthDef(\spec, {
	arg out = 0, dt=0.2, at=0.01,n=2,freq = 220,ad=100, gate=1,modPartial=4, curve= -4,index = 3, amp, sustain;

	var noise = WhiteNoise.ar(mul:amp);
	var one;
	var two;
	var audio;
	var three;
	var four;

	var env = EnvGen.ar(Env.adsr(attackTime:0.001,decayTime:0.01,sustainLevel:0.5,releaseTime:1),doneAction:2,gate:gate);

	one = BPF.ar(noise,freq:freq,rq:0.01,mul:10);
	two = BPF.ar(noise,freq:freq*2,rq:0.01,mul:10);
	three = BPF.ar(noise,freq:freq*4,rq:0.01,mul:10);
	four = BPF.ar(noise,freq:freq*8,rq:0.01,mul:10);

	audio =one+two+three+ four;


	audio = audio*env;

	audio=Compander.ar(audio,audio,-10.dbamp,slopeAbove:1/20,clampTime:0.001,relaxTime:0.5);

	Out.ar( 0,[audio,audio]);
}).add;
//Pitched Build ____________________________________________________________________________
//Pitched/Situ.

 SynthDef(\build,
	{
		arg  amp = 1, freq, numharm=0,curve= -8, dur;
		var env = EnvGen.ar(Env.linen(attackTime:0.4*dur,sustainTime:0.7*dur,releaseTime:dur/4),doneAction:2);
		var envfreq = EnvGen.ar(Env.linen(attackTime:dur,sustainTime:0,releaseTime:dur/4),doneAction:2);

		var envnh = EnvGen.ar(Env.linen(attackTime:dur,sustainTime:0,releaseTime:dur/4),doneAction:2);
		var nhosc = SinOsc.ar(freq:16,mul:0.1,add:1);

		var audio1 = Blip.ar(freq+24.midicps*envfreq,mul:amp,numharm:numharm+16*envnh*nhosc);

		audio1=audio1*env;

		Out.ar(0 ,[audio1,audio1]);


	}
).add;
