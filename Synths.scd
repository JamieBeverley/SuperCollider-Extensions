var shaker = Buffer.read(s,"C:/Users/jamie/AppData/Local/SuperCollider/downloaded-quarks/Personal-Samples/shaker/HIE_Shaker_1.wav");
var chevBuf = Buffer.alloc(s, 512, 1, {arg buf; buf.chebyMsg(amplitudes:[1,1,0.7,0.5,0.4,0.3])});

var timp = Buffer.read(s,"C:/Users/jamie/AppData/Local/SuperCollider/downloaded-quarks/Personal-Samples/timp/HIE_Timpani_1.wav");

var pai = Buffer.read(s,"C:/Users/jamie/AppData/Local/SuperCollider/downloaded-quarks/Personal-Samples/recordings/pai-swamp.wav");
//2,10,17,24
var kick17 = Buffer.read(s,"C:/Users/jamie/AppData/Local/SuperCollider/downloaded-quarks/Personal-Samples/kick/HIE_Kick_17.wav");

var tamb = Buffer.read(s,"C:/Users/jamie/AppData/Local/SuperCollider/downloaded-quarks/Personal-Samples/tamb/HIE_Tambourine_2.wav");



var kick = Buffer.read(s,"C:/Users/jamie/AppData/Local/SuperCollider/downloaded-quarks/Dirt-Samples/808bd/BD0075.WAV");

~outBus = Bus.audio(Server.default,2).index;

SynthDef(\sine,
	{
		|out,pan=0,freq,amp,sustain,at=0.01,rt=0.5|
		var audio = SinOsc.ar(freq,mul:amp);
		var env = EnvGen.ar(Env.perc(attackTime:at,releaseTime:rt),timeScale:sustain,doneAction:2);
		audio = audio*env;
		Out.ar(~outBus,Pan2.ar(audio,pan));
	}
).add;

// Load sample-based synths from personal-samples folder
(
"-- Loading samle-based synths:".postln;
(PathName(Platform.userAppSupportDir++"\\downloaded-quarks\\personal-samples").entries).do{
	|i|
	var counter = 0;
	i.files.do{
		|j|
		var buffer = Buffer.read(s,j.fullPath);
		SynthDef((i.folderName.asString++"_"++counter),{
			|amp, pitch=1, pos=0, sustain,pan=0|
			var audio,env;

			audio = PlayBuf.ar(2,buffer,pitch.midiratio,startPos:pos*BufFrames.kr(buffer.bufnum));

			env = EnvGen.ar(Env.new([1,1,0],[sustain,0.01]),doneAction:2);
			audio = Mix.ar(audio*env)*amp;

			Out.ar(~outBus,Pan2.ar(audio,pan));

		}).add;
		counter=counter+1;
	};
	i.folderName.postln;
	// PathName(i.asString);
};
);


(
SynthDef(\out,{
	|lpf=22000, hpf=10, reverb=0,db=0,hrq=1,lrq=1,room=0.3|
	var audio = In.ar(~outBus,2)*(db.dbamp);
	audio = FreeVerb.ar(audio,mix:Clip.kr(reverb,0,1),room:Clip.kr(room,0,1),damp:0.9);
	audio = LPF.ar(audio, Clip.kr(lpf,10,22000));//,1/(resonance.clip(0.0001,1)));
	audio = HPF.ar(audio,Clip.kr(hpf,10,22000));
	audio = Compander.ar(audio,audio,-30.dbamp,slopeAbove:1/2.5,mul:3.dbamp);
	audio = Compander.ar(audio,audio,thresh:-1.dbamp,slopeAbove:1/20); // limiter...
	Out.ar(0,audio);
}).add;
);


(
SynthDef(\fut2, {
	arg out = 0, rt=0.2, at=0.01,freq = 220,mod=4, curve= -4,index = 3, amp=0.1;
	var hfo = SinOsc.ar(freq:freq*4,mul: freq*mod*2);
	var envhfo= EnvGen.ar(Env.perc(attackTime:at,releaseTime:rt,curve:-3),doneAction:0)*hfo;
	var audio = SinOsc.ar(freq:freq+envhfo,mul: amp);
	var env = EnvGen.ar(Env.perc(at,releaseTime:rt,curve:-6),doneAction:2);

	audio = Clip.ar(audio,lo:-0.2,hi:0.2);

	audio = BPF.ar(audio,freq,rq:0.6);

	audio = audio*env*(24.dbamp);
	audio = audio +LPF.ar(audio,400,mul:(6.dbamp));

	Out.ar( ~outBus,[audio,audio]);
}).add;
);

SynthDef(\kick_m,
	{
	|freq,amp,sustain|

		var audio, arpegio,arpegioFreqEnv,arpegioEnv,arpegDur,noise3, soft,softEnv,noise,noise2;
		softEnv = EnvGen.ar(Env.perc(attackTime:0.2,releaseTime:sustain),doneAction:0);
		arpegDur = 1/5.5;
		audio = Mix.ar(PlayBuf.ar(1,kick,rate:0.85*(freq.cpsmidi%12).midiratio,doneAction:0));
		audio = audio + LPF.ar(audio,200,mul:2.dbamp);

		noise3 = RHPF.ar(WhiteNoise.ar(-40.dbamp),freq:Amplitude.kr(audio,attackTime:0.1,releaseTime:0.1).linlin(-1,1,5,22000),rq:0.1)*Line.ar(1,0,sustain);

		soft = Mix.ar(SinOsc.ar([1,1.001,1.002,1.003,1.004]*freq*Line.kr(6,4,sustain/8))*Line.ar(1,0,sustain)*(-40.dbamp));
		noise = Mix.ar(BPF.ar(WhiteNoise.ar,freq:[0,7,19,24,12,4,2,9,11,14,-12].midiratio*freq,rq:0.01)*(-18.dbamp))*Line.ar(1,0,sustain*1.5);

		arpegioFreqEnv = EnvGen.kr(Env.circle((0,7..200).collect({|v,i|[v,v].clip(0,100)}).flatten.midiratio,[0.99,0.01]*arpegDur));
		arpegioEnv = EnvGen.ar(Env.circle([0,1,0],[0.001,0.999]*arpegDur));
		arpegio = Mix.ar(SinOsc.ar(freq*arpegioFreqEnv+SinOsc.ar(freq*arpegioFreqEnv*16,mul:freq*8)))*(-16.dbamp)*arpegioEnv;
		// arpegio = arpegio*
		arpegio = LPF.ar(arpegio,Clip.kr(freq,5,21000));
		arpegio = arpegio*Line.ar(1,0,dur:sustain)*Line.ar(1,0,dur:sustain);

				noise2 = [Dust.ar(Line.ar(200,50,dur:sustain)),Dust.ar(Line.ar(200,50,dur:sustain))]*Line.ar(1,0,sustain*4);

		noise2 = noise2*EnvGen.ar(Env.new([0,0,1,0],[0.34,0.1,sustain]))*(-30.dbamp);

		arpegio = arpegio+noise+soft+noise3;
		arpegio = Compander.ar(arpegio,audio,thresh:(-30.dbamp),slopeBelow:1,slopeAbove:1/3,clampTime:0.01,relaxTime:0.2);


		audio = audio+ arpegio+noise2;

		audio = FreeVerb.ar(audio,0.3,0.8);
		audio = Compander.ar(audio,audio,-35.dbamp,slopeAbove:2,mul:12.dbamp)*amp;
		DetectSilence.ar(audio,amp:0.0001,doneAction:2);
		Out.ar(~outBus,Pan2.ar(audio,0));
}).add;

SynthDef(\tamb_m,
	{
		|freq,amp,sustain,pan=0|
		var sample,noise,pitch,coarse,audio,pitchEnv,pitchFreq;
		coarse = 6;
		sample = PlayBuf.ar(2,tamb);
		sample = sample+PlayBuf.ar(2,shaker);

		pitchEnv = EnvGen.ar(Env.perc(0.01,releaseTime:sustain*0.9),doneAction:0);
		// pitchFreq = Mix.ar(([0,7,12].midiratio)*freq*1*XLine.kr(1,1,sustain/8));
		// pitch = SinOsc.ar(pitchFreq);//+SinOsc.ar(freq*4,mul:freq*2));
		pitch = Mix.ar(SinOsc.ar(freq*2*([0,7,19].midiratio)));//+SinOsc.ar(freq*4,mul:freq*2));

		pitch = Latch.ar(pitch, Impulse.ar(SampleRate.ir /coarse));
		// pitch = HPF.ar(pitch,3000);
		pitch = pitch * pitchEnv*(-30.dbamp);


		audio = (sample+pitch)*amp;
		audio = FreeVerb.ar(audio,mix:0.4,room:0.7);

		DetectSilence.ar(audio,doneAction:2);

		Out.ar(~outBus,Pan2.ar(audio,pan));

	}
).add;

SynthDef(\kick_m2,
	{
		|freq,amp,sustain,pan=0|

		var kick, swamp, pitch, audio, env;

		env = EnvGen.ar(Env.perc(releaseTime:sustain));
		kick = PlayBuf.ar(2,kick17,rate:(freq.cpsmidi%12).midiratio);

		swamp = PlayBuf.ar(2,pai,rate:2.5,startPos:Rand(0,0.5))*Line.ar(1,0,sustain/2);

		pitch = Mix.ar(SinOsc.ar(freq*Line.ar(1,2,dur:sustain/16)*1*([0,12,-3,7].midiratio+Rand(-0,0.00))))*SinOsc.ar(4.3,mul:0.1,add:1);
		pitch = pitch*env*(-32.dbamp);
		audio = (kick+swamp+pitch)*amp;

		// audio = FreeVerb.ar(audio,mix:0.2,room:0.1);

		DetectSilence.ar(audio,doneAction:2);

		Out.ar(~outBus,Pan2.ar(audio,pan));


	}
).add;


SynthDef(\fmBass,
	{
		|amp, freq, mod=4, sustain,at=0.001,dt=0.01,release=0.5,detune=1,detunet=0.25|
		var audio,env,modEnv;
		var freq2 = XLine.ar(freq/2,freq*0.5*(detune.midiratio),sustain*detunet);
		modEnv = EnvGen.ar(Env.new([0,1,0],[at,dt+release],curve:\welch));
		audio = Mix.ar(SinOsc.ar( [1,3,1.5,0.5]*(freq2 + SinOsc.ar(freq2*6,mul:freq2*modEnv*mod))))*(-6.dbamp);
		// audio = LPF.ar(audio,freq);
		// audio = FreeVerb.ar(audio,room:0.4);
		env = EnvGen.ar(Env.new([0,1,0.4,0.4,0],[at,dt,sustain-at-dt-release,release],curve:\welch),timeScale:sustain,doneAction:2);

		audio = audio*env*amp;

		Out.ar(~outBus, Pan2.ar(audio));
	}
).add;

SynthDef(\click,
	{
		|amp, freq, mod=4, sustain,at=0.01,dt=0.01,release=0.15|
		var audio,env,brilEnv,noiseEnv,high,highEnv;

		audio = Mix.ar(SinOsc.ar((1,1.3..20.67)*30,mul:amp*(-20.dbamp)));

		env = EnvGen.ar(Env.new([0,1,0],[0.0001,0.002]),doneAction:2);

		audio = audio*env;

		Out.ar(~outBus, Pan2.ar(audio));
	}
).add;

SynthDef(\chordy,{
	|amp,freq,gate=1,at=0.01,dt=0.3,rt=1,pan=0|
	var audio,env,scale,noiseEnv,noise;
	scale = [0,3,7,10,14,15,19,22,24,27];

	audio = SinOsc.ar(freq/2,mul:amp);
	noise = SinOsc.ar(mul:0);
	8.do{
		|i|
		i=i+1;
		audio = audio+SinOsc.ar(freq*(scale[i].midiratio),mul:amp*((i*3).neg.dbamp));
		noise = noise + Mix.ar(BPF.ar(WhiteNoise.ar(1),freq:freq*(scale[i].midiratio)/2,rq:0.125/16,mul:amp*(30.dbamp)));
		noise = noise + Mix.ar(BPF.ar(WhiteNoise.ar(1),freq:2*freq*(scale[i].midiratio)/2,rq:0.125/16,mul:amp*(17.dbamp)));
	};
	// noise = Mix.ar(BPF.ar(PinkNoise.ar(1),freq:freq*[12,19,7].midiratio,rq:0.125/2,mul:amp*(30.dbamp)));
	noiseEnv = EnvGen.ar(Env.adsr(attackTime:at,decayTime:dt,sustainLevel:0.1,releaseTime:rt/2,curve:-1),gate:gate,doneAction:0);
	noise = noise*noiseEnv;
	audio = audio+noise;
	env = EnvGen.ar(Env.adsr(attackTime:at,decayTime:dt,sustainLevel:0.3,releaseTime:rt,curve:-1),gate:gate,doneAction:2);
	audio =audio*env;
	audio = audio*(-10.dbamp);
	audio = FreeVerb.ar(audio,mix:1,room:0.9,damp:0.9)+audio;
	Out.ar(~outBus, Pan2.ar(audio,pan));
}).add;




(
SynthDef(\whine,{
	|amp,freq,at=0.01,dt=4,rt=2,gate=1,pan=0,sustain=1,rate=0.05|
	var audio,env,env2, noise, noiseEnv;


	audio = Mix.ar(Saw.ar(freq*[1,1.01,1,02,1.03]*SinOsc.ar(rate+SinOsc.ar(freq:1,mul:0.05),mul:0.05,add:1),mul:amp))*(-12.dbamp);
	env = EnvGen.ar(Env.linen(attackTime:at,sustainTime:sustain,releaseTime:rt+4*0.3),gate:gate,doneAction:2);
	audio = audio*env;
	4.do{
		|i|
		audio = audio + DelayN.ar(audio,maxdelaytime:0.12,delaytime:((10.rand+1)/100),mul:((-2)*i).dbamp);
	};
	audio = BPF.ar(in:audio,freq:freq);
	audio = LPF.ar(audio, freq:XLine.kr(freq/4,end:24000,dur:sustain/2));
	audio = FreeVerb.ar(audio);


	// audio = GVerb.ar(audio,roomsize:10,revtime:3,damping:0.6,inputbw:0.8,drylevel:0.7,earlyreflevel:0.3,taillevel:1);
	audio = Pan2.ar(audio,pan);
	Out.ar(~outBus,audio);
}
).add;
);
SynthDef(\plick,{
	|amp,freq,at=0.001,dt=0.3,rt=2,gate=1|
	var audio,env;

	audio = Mix.ar(SinOsc.ar(freq:freq*[1,1.01,1.03,0.97]*Line.ar(2,1,dur:at),mul:amp*(-3.dbamp)));
	// audio = BPF.ar(audio,freq:(freq*3)/2,rq:1);
		// env = EnvGen.ar(Env.linen(attackTime:at,sustainTime:sustain,releaseTime:rt),doneAction:2);
	env = EnvGen.ar(Env.adsr(attackTime:at,decayTime:dt,sustainLevel:0.1,releaseTime:rt),gate:gate,doneAction:2);

	4.do{
		|i|
		audio = audio + DelayN.ar(audio,maxdelaytime:0.3,delaytime:0.15+(10.rand/60),mul:((-2)*i).dbamp);
	};

	audio = audio*env;

	// audio = GVerb.ar(audio,roomsize:10,revtime:3,damping:0.6,inputbw:0.8,drylevel:0.7,earlyreflevel:0.3,taillevel:1);

	Out.ar(~outBus,audio!2);
}
).add;





(
SynthDef(\saw6,{
	|amp, freq, out, sustain,gate=1,panFreq=0,panScatter=0,lpf=10000,rq=0.4|
	var audio, env,safeLpf;
	safeLpf = lpf.clip(10,20000);
	audio = Saw.ar((0.9994,0.9998..1.0006)*freq,mul:amp/4)+Saw.ar((0.9994,0.9998..1.0006)*freq/2,mul:amp/7)+Impulse.ar(freq,mul:amp/4);
	audio = BPF.ar(audio,freq:freq*2,rq:1)+SinOsc.ar(freq,mul:amp/7);
	audio = RLPF.ar(audio,safeLpf,rq);
	env = EnvGen.ar(Env.adsr(attackTime:0.5,decayTime:0.05,sustainLevel:0.8,releaseTime:3),gate:gate,doneAction:2);

	audio = audio*env;
	Out.ar(~outBus,Pan2.ar(audio,pos:SinOsc.ar(panFreq,mul:panScatter)));

}).add;
);
(
SynthDef(\stab2, {
	|freq=440, amp=0.1, pan, lpf=880, gate=1,at=0.0001,dur=1,begin, end, out=0,sustain=1|
	var osc1,osc2,osc3,audio,env,lpfEnv;

	osc1 = Mix.ar(SinOsc.ar([0.99,1,1.01]*freq,mul:amp));
	osc2 = Mix.ar(SinOsc.ar([0.99,1,1.01]*freq*(3.midiratio),mul:amp));
	osc3 = Mix.ar(SinOsc.ar([0.99,1,1.01]*freq*(7.midiratio),mul:amp));

	// env = EnvGen.ar(Env.xyc([[0,0,2],[0.01,1,-2],[0.3,0.5,0],[0.8,0.5,4],[1,0,0]]),timeScale:sustain,doneAction:2);
	// env = EnvGen.ar(Env.perc(0.001,releaseTime:0.999),timeScale:sustain,doneAction:0);
	// lpfEnv = EnvGen.ar(Env.xyc([[0,0,2],[0.001,1,-2],[0.4,1,0],[0.6,1,4],[1,0.1,0]]),timeScale:sustain,doneAction:2);
	env = EnvGen.ar(Env.adsr(0.005,0.01,0.25,0.2),gate:gate,doneAction:2);
	audio = osc1+osc2+osc3;//+Mix.ar(Pulse.ar(freq*([0,3,10].midiratio),mul:amp*4.dbamp));

	// audio = LPF.ar(audio,15000);
	audio = FreeVerb.ar(audio,0.60,room:0.1,damp:0.2);

	audio = audio*env;
	audio = audio;

	Out.ar(~outBus,audio!2);
}).add;
);
SynthDef(\bass6,{
	|freq, amp, out=0, gate=1, mod=2.5,sustain,at=0.01,pan=0|

	var audio, env,freq2,modulator;

	freq2=freq/2;

	modulator = SinOsc.ar(freq2*mod,mul:freq2*mod*XLine.ar(9,1,dur:at));

	audio = SinOsc.ar(freq2 + modulator,mul:amp);
	env = EnvGen.ar(Env.adsr(attackTime:at),gate:gate,doneAction:2);

	audio = LPF.ar(audio,freq:880);
	audio = Pan2.ar(audio,pan.clip(-1,1))*env;
	Out.ar(~outBus,channelsArray:audio!2);
	}
).add;

(
SynthDef(\filterSweep,
	{
		|amp,sustain=1,rq=0.2,curve=8|
		var audio,env,filtEnv;

		audio = WhiteNoise.ar(amp);

		filtEnv = EnvGen.ar(Env.xyc([[0,10,curve],[1,30000,0]]),timeScale:sustain*0.5);
		audio = BPF.ar(audio,filtEnv,rq);
		audio = FreeVerb.ar(audio);
		env = EnvGen.ar(Env.xyc(xyc:[[0,1,0],[0.5,1,2],[0.8,0,0]]),timeScale:sustain,doneAction:2);
		audio=audio*env;

		Out.ar(~outBus,audio!2);
}).add;
);


SynthDef(\kick, {
	|freq=32, amp=0.1, out=0, gate=1,at=0.002,dur|
	var audio,env;
	amp = amp.clip(0,1);
	audio = SinOsc.ar(freq:freq, mul:amp*1.5);
	audio = LPF.ar(audio,freq:freq*2*XLine.ar(4,1,at.clip(0.0001,1)/2)/2,mul:6.dbamp);
	audio = audio +LPF.ar(PinkNoise.ar(amp*4)*XLine.ar(2,0,at/2),freq*4);
	env = EnvGen.ar(Env.adsr(at,0.3,sustainLevel:0.1,releaseTime:0.25),gate:gate,doneAction:2);
	// audio = audio*EnvGen.ar(Env.adsr(at,0.1,sustainLevel:0.4,releaseTime:0.25),gate:gate,doneAction:0);
	// audio = audio*EnvGen.ar(Env.perc(at,releaseTime:1.5,curve:-8));

	audio = audio*env;

	Out.ar(~outBus,Pan2.ar(audio,0));
}).add;

SynthDef(\bass, {
	|freq=130, amp=0.1, out=0, gate=1,at=0.01,dt=0.03,sawMix=10,sustain,modMul=4|
	var audio,env,sawEnv,mod, modEnv;
	amp = amp.clip(0,1);
	modEnv = EnvGen.ar(Env.linen(at,0,sustain,0.5));//(at,dt*40,0.1,releaseTime:1),gate:gate,doneAction:2);
	mod = Mix.ar(SinOsc.ar(freq:freq/2, mul:freq*modMul)*modEnv);
	audio = Mix.ar(SinOsc.ar(freq:freq+mod, mul:amp/3)+SinOsc.ar(freq:freq*1.5+mod, mul:amp/8));
	env = EnvGen.ar(Env.adsr(at,dt,sustainLevel:0.2,releaseTime:0.25),gate:gate,doneAction:2);
	audio = audio*env;

	Out.ar(~outBus,Pan2.ar(audio,0));
}).add;


SynthDef(\hihat,
	{
		arg out,amp=0.1,dur,rt=0.25,hpf=4000,at=0.001;
		var audio, env;
		amp = amp.clip(0,1);
		audio = HPF.ar(PinkNoise.ar(amp/1),hpf);
		env = EnvGen.ar(Env.perc(attackTime:at,releaseTime:rt,curve:-8),doneAction:2);
		audio = audio*env;
		Out.ar(~outBus,Pan2.ar(audio,0));
	}
).add;


(
SynthDef(\pad4,
	{
	|freq=440, amp=0.1, out=0, at=2, rt=2, sustain=1,gate=1,rate=0.1,lfoFreq=0.25,sus=1,resonance=0.15, panScatter=0,lpf=1,delayT=0.1|
		var audio,env,circleEnv, lpfEnv,lfo, upRate;
		amp = amp.clip(0,1);
		resonance = resonance.clip(0,1)/2;
		audio = Mix.ar(Saw.ar(freq,mul:amp));
		lpfEnv = EnvGen.ar(Env.linen(attackTime:at,sustainTime:sustain,releaseTime:rt),gate:gate,doneAction:0);
		upRate = XLine.kr(1,freq/2,dur:at);
		lfo = SinOsc.ar(lfoFreq+upRate,mul:0.125,add:1);
		audio = RLPF.ar(audio, freq*lpf*lfo,0.25);
		audio = Compander.ar(audio,audio,-30.dbamp,1,slopeAbove:1/2,clampTime:0.01,relaxTime:0.001);
		env = EnvGen.ar(Env.linen(attackTime:at,sustainTime:sustain,releaseTime:rt),doneAction:0);

		circleEnv = EnvGen.ar(Env.circle([0.2,1],[0.05,0.95]/upRate));
		audio = audio*env*circleEnv;
		audio = audio*EnvGen.ar(Env([1,1],[at+sustain+rt+delayT*6+0.1]),doneAction:2);
		// audio = FreeVerb.ar(audio,0.6,room:0.9);
		audio = Pan2.ar(audio,panScatter*(lfo-0.875));

		Out.ar(~outBus,Pan2.ar(audio,0));
	}
).add;
);

(
SynthDef(\pad3,
	{
	|freq=440, amp=0.1, out=0, at=0.5, rt=2, sustain,gate=1,lfoFreq=0.25,sus=1,resonance=0.15, panScatter=0,lpf=1,delayT=0.1|
		var audio,env, lpfEnv,lfo;
		amp = amp.clip(0,1);
		resonance = resonance.clip(0,1)/2;
		audio = Mix.ar(Saw.ar([freq,freq*1.02,freq*0.98]++([freq,freq*1.02,freq*0.98]*1.5),mul:amp/40));
		lpfEnv = EnvGen.ar(Env.linen(attackTime:at,sustainTime:sustain,releaseTime:rt),doneAction:0);
		lfo = SinOsc.ar(lfoFreq,mul:0.5,add:1);
		audio = RLPF.ar(audio, freq*lpf*lfo,0.25);
		audio = Compander.ar(audio,audio,0.dbamp,1,slopeAbove:1/20,clampTime:0.001,relaxTime:0.001);
		env = EnvGen.ar(Env.linen(attackTime:at,sustainTime:sus,releaseTime:rt),doneAction:0);
		audio = audio*env;

		6.do{
			audio = audio +DelayN.ar(audio,0.5,delayT,-3.dbamp);
		};
		audio = audio*EnvGen.ar(Env([1,1],[at+sus+rt+delayT*6+0.1]),doneAction:2);
		// audio = FreeVerb.ar(audio,0.6,room:0.9);
		audio = Pan2.ar(audio,panScatter*(lfo-1));

		Out.ar(~outBus,Pan2.ar(audio,0));
	}
).add;
);

(
SynthDef(\pad5,
	{
	|freq=440, amp=0.1, out=0, at=0.5, rt=2, sustain,gate=1,lfoFreq=0.25,sus=1,resonance=0.15, panScatter=0,lpf=1,delayT=0.1|
		var audio,env, lpfEnv,lfo;
		amp = amp.clip(0,1);
		resonance = resonance.clip(0,1)/2;
		audio = Mix.ar(Saw.ar([freq,freq*1.02,freq*0.98]++([freq,freq*1.02,freq*0.98]*1.5),mul:amp/40));
		lpfEnv = EnvGen.ar(Env.linen(attackTime:at,sustainTime:sustain,releaseTime:rt),doneAction:0);
		lfo = SinOsc.ar(lfoFreq,mul:0.5,add:1);
		audio = RLPF.ar(audio, freq*lpf*lfo,0.25);
		audio = Compander.ar(audio,audio,0.dbamp,1,slopeAbove:1/20,clampTime:0.001,relaxTime:0.001);
		env = EnvGen.ar(Env.asr(attackTime:at,sustainLevel:0.8,releaseTime:rt),doneAction:0);
		audio = audio*env;

		6.do{
			audio = audio +DelayN.ar(audio,0.5,delayT,-3.dbamp);
		};

		audio = audio*EnvGate.new(i_level:1,gate:gate,fadeTime:rt+6*delayT+0.5);
		// audio = audio*EnvGen.ar(Env([1,1],[at+sus+rt+delayT*6+0.1]),doneAction:2);

		// audio = FreeVerb.ar(audio,0.6,room:0.9);
		audio = Pan2.ar(audio,panScatter*(lfo-1));

		Out.ar(~outBus,Pan2.ar(audio,0));
	}
).add;
);

(
SynthDef(\pad2,
	{
	|freq=440, amp=0.1, out=0, at=0.5, rt=2, sustain,gate=1,lfoFreq=0.25,resonance=0.15, panScatter=0,lpf=1|
		var audio,env, lpfEnv,lfo;
		amp = amp.clip(0,1);
		resonance = resonance.clip(0,1)/2;
		audio = Mix.ar(Saw.ar([freq,freq*1.02,freq*0.98]++([freq,freq*1.02,freq*0.98]*1.5),mul:amp/6));
		lpfEnv = EnvGen.ar(Env.linen(attackTime:at,sustainTime:sustain,releaseTime:rt),doneAction:0);
		lfo = SinOsc.ar(lfoFreq,mul:0.5,add:1);
		audio = RLPF.ar(audio, freq*lpf*lfo,0.25);
		audio = Compander.ar(audio,audio,0.dbamp,1,slopeAbove:1/20,clampTime:0.001,relaxTime:0.001);
		env = EnvGen.ar(Env.asr(attackTime:at,releaseTime:rt),gate:gate,doneAction:2);
		audio = audio*env;
		// audio = FreeVerb.ar(audio,0.6,room:0.9);
		audio = Pan2.ar(audio,panScatter*(lfo-1));

		Out.ar(~outBus,Pan2.ar(audio,0));
	}
).add;
);

(
SynthDef(\pad2,
	{
	|freq=440, amp=0.1, out=0, at=0.5, rt=2, sustain,gate=1,lfoFreq=0.25,resonance=0.15, panScatter=0,lpf=1|
		var audio,env, lpfEnv,lfo;
		amp = amp.clip(0,1);
		resonance = resonance.clip(0,1)/2;
		audio = Mix.ar(Saw.ar([freq,freq*1.02,freq*0.98]++([freq,freq*1.02,freq*0.98]*1.5),mul:amp/6));
		lpfEnv = EnvGen.ar(Env.linen(attackTime:at,sustainTime:sustain,releaseTime:rt),doneAction:0);
		lfo = SinOsc.ar(lfoFreq,mul:0.5,add:1);
		audio = RLPF.ar(audio, freq*lpf*(lpfEnv+0.51)*lfo, resonance.linexp(0, 1, 1, 0.001));
		audio = Compander.ar(audio,audio,0.dbamp,1,slopeAbove:1/20,clampTime:0.001,relaxTime:0.001);
		env = EnvGen.ar(Env.asr(attackTime:at,releaseTime:rt),gate:gate,doneAction:2);
		audio = audio*env;
		// audio = FreeVerb.ar(audio,0.6,room:0.9);
		audio = Pan2.ar(audio,panScatter*(lfo-1));

		Out.ar(~outBus,Pan2.ar(audio,0));
	}
).add;
);



SynthDef(\arpeg,
	{
	|freq=440, amp=0.1, out=0, at=0.5, rt=2, lpf, sustain,gate=1,lfoFreq=0.25,resonance=0.15,arpegFreq=0.0625,panFreq=0.0625,panScatter=0.125|
		var audio,env, arpegEnv,mod, lpfLfO,panEnv;
		amp = amp.clip(0,1);
		arpegEnv = EnvGen.ar(Env.circle([0,0,7,7,12,12,-5,-5,12,12,19,19].midiratio,[arpegFreq,0.01]),doneAction:0);
		panEnv = EnvGen.kr(Env.circle([-1,-1,1,1],[panFreq,0.01]),doneAction:0);
		mod = SinOsc.ar(freq*4,mul:freq);
		audio = SinOsc.ar(freq*arpegEnv+mod,mul:amp/2);
		lpfLfO = SinOsc.ar(0.3,mul:0.25,add:1);
		audio = RLPF.ar(audio,freq*lpfLfO,0.3);
		audio = Compander.ar(audio,audio,0.dbamp,1,slopeAbove:1/20,clampTime:0.001,relaxTime:0.001);
		env = EnvGen.ar(Env.asr(attackTime:at,releaseTime:rt),gate:gate,doneAction:2);
		audio = audio*env;
		audio = Pan2.ar(audio,panEnv*panScatter);
		Out.ar(~outBus,audio);
	}
).add;


(SynthDef(\rest,{
	var audio = EnvGen.ar(Env.perc(level:0),doneAction:2);
	Out.ar(~outBus,audio);
 }).add;);
// Crash
SynthDef(\crash,{
/*	arg dur;
	var audio=SinOsc.ar();
		Out.ar(0,[audio,audio]);*/
 }).add;

SynthDef(\pad,{
	arg out, freq, amp=0.1, gate=1,sus=8,vib=4;
	var audio,env;
	env = EnvGen.ar(Env.asr(2,sustainLevel:0.9,releaseTime:3),gate:gate,doneAction:2);


	audio = SinOsc.ar((freq+SinOsc.ar(freq,mul:freq)), mul:amp*SinOsc.ar(vib,mul:0.8))+BPF.ar(BrownNoise.ar(amp),freq,rq:0.25);

	audio = audio*env;

	Out.ar(~outBus,[audio,audio]);

}
).add;

SynthDef(\fm1, { arg bus = 0, freq = 440, carPartial = 1, modPartial = 1, index = 3, amp=0.1, dur, hfoMod=2;

	// index values usually are between 0 and 24
	// carPartial :: modPartial => car/mod ratio

	var hfo;
	var audio;

	var envhfo = EnvGen.ar(Env.sine(dur),doneAction:2);
	var env = EnvGen.ar(Env.perc(0.05*dur,0.9*dur,curve:-2),doneAction:2);

	hfo = SinOsc.ar(freq:freq * modPartial,phase:0,mul: freq*index*SinOsc.ar(hfoMod/dur,mul:0.5,add:0.5));
	audio = SinOsc.ar(freq:(freq * 1) + hfo,mul: amp).squared*env;

	Out.ar(	~outBus,[audio,audio])
}).add;


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

		Out.ar(~outBus,aud!2);
	}
).add;

SynthDef(\soft, {
	|freq=440, amp=0.1, out, lpf=880, modPartial=1,gate=1,at=0.05,dur|

	var audio = LPF.ar(Mix.ar(Saw.ar(freq:freq, mul:amp*2.5)),freq:freq*XLine.ar(0.25,1,at.clip(0.01,1))/2,mul:6.dbamp);
	var amb = BPF.ar(PinkNoise.ar(amp*3.5),freq,0.0225);



	// audio = LPF.ar(audio,lpf)*Line.ar(1,0.5,1);
	amb = amb*EnvGen.ar(Env.adsr(at+0.2,0.4,sustainLevel:0.9,releaseTime:1.5),gate:gate,doneAction:2);
	// audio = audio*EnvGen.ar(Env.adsr(at,0.1,sustainLevel:0.4,releaseTime:0.25),gate:gate,doneAction:0);
	audio = audio*EnvGen.ar(Env.perc(at,releaseTime:1.5,curve:-8));
	audio = audio+amb;


	Out.ar(~outBus,audio!2);

}).add;

SynthDef(\fm26, {
	|freq=440, amp=0.1, out, lpf=880, modPartial=1,gate=1,at=0.05,dur|

	var mod = SinOsc.ar(freq*modPartial,mul:freq*modPartial*4)*EnvGen.ar(Env.adsr(at,0.3,0.5,0.5,1));
	var audio = SinOsc.ar(freq:freq + mod,mul:amp);



	audio = LPF.ar(audio,lpf)*Line.ar(1,0.5,1);
	audio = audio*EnvGen.ar(Env.adsr(at,0.3,sustainLevel:0.4,releaseTime:0.5),gate:gate,doneAction:2);


	Out.ar(~outBus,audio!2);

}).add;

SynthDef(\flutter, {
	|freq=440, amp=0.1, out, lpf=880, modPartial=1,gate=1,at=0.05,dur,cycle=16|

	var mod = EnvGen.ar(Env.circle([2,2,1,1,3,3,4,4,5,5,9,9,7,7,8,8],[0.99,0.01]/cycle));
	var mod1 = SinOsc.ar(freq*modPartial,mul:freq*modPartial*2);
	var audio = SinOsc.ar(freq:freq*mod+mod1*mod,mul:amp);



	audio = LPF.ar(audio,lpf)*Line.ar(1,0.5,1);
	audio = audio*EnvGen.ar(Env.adsr(at,0.3,sustainLevel:0.8,releaseTime:1),gate:gate,doneAction:2);


	Out.ar(~outBus,audio!2);

}).add;

//808  _________________________________________________________________________________

SynthDef(\808,{
	|amp=0.1, freq=30, sustain, pan=0|
	var audio = SinOsc.ar(freq,mul:amp)*EnvGen.ar(Env(levels:[0,1,0.8,0],times:[0.0001,1,0.5],curve:'lin'),doneAction:2);

	Out.ar(~outBus,Pan2.ar(audio,pan));

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

	Out.ar(~outBus, [x,x]);
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

	Out.ar(~outBus, [audio,audio]);


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
		Out.ar(~outBus,[audio,audio]);
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
		Out.ar(~outBus,[audio,audio]);
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

	Out.ar( ~outBus,[audio,audio]);
}).add;

//Simple Closed Highat__________________________________________________________________________________

SynthDef(\chh,
	{
		arg out,amp= -20.dbamp,dur,curve= -20,gate=1,rt=1,bpf=4000;
		var audio = BPF.ar(WhiteNoise.ar(amp*0.1),bpf,0.5);

		var env = EnvGen.ar(Env.perc(attackTime:0.01,releaseTime:rt,curve:curve),doneAction:2);

		audio = audio*env;

		//audio=Compander.ar(audio,audio,0.1,slopeBelow:1,slopeAbove:0.1,clampTime:0.01,);
		Out.ar(~outBus, [audio,audio]);
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
		Out.ar(~outBus, [audio,audio]);
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


		Out.ar(~outBus, [audio,audio]);
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

	var hfo = SinOsc.ar(freq,mul:freq*XLine.ar(linb,line,sustain/2)*SinOsc.ar(Line.ar(chop,1,sustain)/sustain,mul:0.2,add:1));
	var audio = SinOsc.ar(freq+hfo,phase:hfo, mul:amp);

	var env = EnvGen.ar(Env.asr(attackTime:at,sustainLevel:0.9, releaseTime:1),gate:gate,doneAction:2);

	audio = audio*env;

	audio=Clip.ar(audio,-100.dbamp,30.dbamp);

	audio=Compander.ar(audio,audio,-10.dbamp,slopeAbove:1/20,clampTime:0.001,relaxTime:0.5);

	Out.ar(~outBus, [audio,audio]);


}).add;

SynthDef(\space2,{
arg sustain=1, freq,at=2, amp,chop=2*sustain,linb=0.04,line=1,out=0,gate=1,rt=1, fnoise = 0.03;

	var hfo = SinOsc.ar(freq*Rand(1-fnoise,1+fnoise),mul:freq*XLine.ar(linb,line,sustain/2)*SinOsc.ar(XLine.ar(1,chop,sustain)/sustain,mul:0.2,add:1));
	var audio = SinOsc.ar(freq+hfo, mul:amp);

	var env = EnvGen.ar(Env.linen(attackTime:at,sustainTime:sustain, releaseTime:rt),gate:gate,doneAction:2);

	audio = audio*env;

	audio=Clip.ar(audio,-100.dbamp,30.dbamp);

	audio=Compander.ar(audio,audio,-10.dbamp,slopeAbove:1/20,clampTime:0.001,relaxTime:0.5);

	Out.ar(~outBus, [audio,audio]);


}).add;


//HFO FM Synth (Triangular HFO Oscillator)_____________________________________________________________________________________
// Multiuse

SynthDef(\fmt, { arg bus = 0, freq = 440, gate=1,modPartial = 1, index = 3, amp=0.1, dur, hfoMod=3;



	var hfo = LFTri.ar(freq:freq * modPartial,mul: freq*index*SinOsc.ar(hfoMod/dur,mul:0.5,add:0.5),add:0);
	var audio = SinOsc.ar(freq:freq + hfo,mul: amp).max;
	var env = EnvGen.ar(Env.adsr(attackTime:0.01,decayTime:0.03,sustainLevel:0.2,curve:-4),gate:gate,doneAction:2);


	audio = audio*env;

	audio=Clip.ar(audio,-100.dbamp,30.dbamp);


	Out.ar( ~outBus,[audio,audio])
}).add;


//HFO FM Synth 3 - linear envelope_______________________________________________________________________________
// Multiuse

SynthDef(\fm3, { arg bus = 0, freq = 440, carPartial = 1, modPartial = 1, index = 3, amp=0.1, dur, hfoMod=3;

	// index values usually are between 0 and 24
	// carPartial :: modPartial => car/mod ratio

	var hfo;
	var audio;

	var env = EnvGen.ar(Env.linen(attackTime:0.8*dur,sustainTime:0.1*dur,releaseTime:0.4*dur),doneAction:2);

	hfo = SinOsc.ar(freq:freq * modPartial,phase:0,mul: freq*index*SinOsc.ar(hfoMod/dur,mul:0.5,add:0.5));
	audio = SinOsc.ar(freq:(freq * 1) + hfo,mul: amp).squared*env;

	audio=Clip.ar(audio,-100.dbamp,30.dbamp);

	Out.ar(	~outBus,[audio,audio])
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

		Out.ar(~outBus, [audio,audio]);
	}
).add;

SynthDef(\noise,
	{
		arg freq = 440, out = 0, amp = 0.1, lpf = 2500, sustain=6.001, fnoise = 0.003,hm=1;
		var audio = LFTri.ar(freq*Rand(1-fnoise,1+fnoise)+PinkNoise.ar(mul:freq*hm),mul:amp*SinOsc.ar(freq:1,mul:0.5,add:1));
//		audio = LPF.ar(audio,freq:lpf);
		audio = audio*EnvGen.ar(Env.linen((sustain-0.001)*0.33,0.001,(sustain-0.001)*0.67),doneAction:2);
		Out.ar(~outBus,audio);
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



		Out.ar(~outBus, [audio,audio]);
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
		Out.ar(~outBus, [audio,audio]);
	}
).add;


//Future house fm synth_____________________________________________________________________________



SynthDef(\fm6, {
	arg out = 0, freq = 220, gate=1,modPartial=5, curve= -4,index = 3, amp=0.01, sustain=1;



	var hfo = SinOsc.ar(freq:freq*modPartial,mul: freq*modPartial);
	var envhfo= EnvGen.ar(Env.adsr(attackTime:0.02,decayTime:2,sustainLevel:0.1,releaseTime:0.01,curve:-16),doneAction:0)*hfo;

	var topOctave = SinOsc.ar(freq:(freq+envhfo),mul: amp/4)*EnvGen.ar(Env.linen(0.01,0.03,sustain));
	var audio = SinOsc.ar(freq:(freq+envhfo)/2,mul: amp/2) + SinOsc.ar(freq:freq+envhfo,mul: amp/2) + topOctave;
	var env = EnvGen.ar(Env.adsr(attackTime:0.01,decayTime:0.2,sustainLevel:0.4,curve:-2),gate:gate,doneAction:2);


	audio = audio*env;
	audio=Compander.ar(audio,audio,20.dbamp,slopeAbove:1/20,clampTime:0.001,relaxTime:0.5);

	Out.ar( ~outBus,[audio,audio]);
}).add;


SynthDef(\sawBass,
	{
		|amp, freq, gate=1, at=0.01,rt=0.9,pan=0, lpfMul=1,sustain, out|

		var audio, env,lpfEnv;
		audio = Shaper.ar(chevBuf ,Mix.ar(LPF.ar(Saw.ar(freq/4)*EnvGen.ar(Env.perc(attackTime:at,releaseTime:1-at,curve:-1),timeScale:sustain,doneAction:2),freq*lpfMul)), amp*(15.dbamp));

		Out.ar(~outBus,Pan2.ar(audio,pan));
	}
).add;
(


SynthDef(\fut, {
	arg out = 0, dt=0.2, at=0.01,freq = 220, gate=1,modPartial=4, curve= -4,index = 3, amp=0.1;
	var hfo = SinOsc.ar(freq:freq*modPartial/4,mul: freq*modPartial);
	var envhfo= EnvGen.ar(Env.adsr(attackTime:at,decayTime:dt,sustainLevel:0.1,releaseTime:0.1,curve:-3),gate:gate,doneAction:0)*hfo;
	var audio = SinOsc.ar(freq:freq+envhfo,mul: amp);
	// var env = EnvGen.ar(Env.adsr(attackTime:0.01,decayTime:dt,sustainLevel:0.3,curve:curve),gate:gate,doneAction:2);
	var env = EnvGen.ar(Env.perc(at,level:dt),doneAction:2);

	audio = audio*env;

	// audio=Compander.ar(audio,audio,20.dbamp,slopeAbove:1/20,clampTime:0.001,relaxTime:0.5);

	Out.ar( ~outBus,[audio,audio]);
}).add;

);


//Fm simple_____________________________________________________________________________________
// Multiuse

SynthDef(\fms, { arg bus = 0, dt=0.02,at=0.02,freq = 440, gate=1,modPartial = 1, curve= -8,index = 3, amp=0.1, dur, hfoMod=3;



	var hfo = SinOsc.ar(freq:freq*modPartial,mul: freq*3,add:0);
	var audio = SinOsc.ar(freq:freq+hfo,mul: amp).squared;
	var env = EnvGen.ar(Env.adsr(attackTime:at,decayTime:dt,sustainLevel:0.3,curve:curve),gate:gate,doneAction:2);

	audio = audio*env;

	audio=Clip.ar(audio,-100.dbamp,30.dbamp);

	Out.ar( ~outBus,[audio,audio])
}).add;


//HFO FM Synth ADSR Env._____________________________________________________________________________________
// Multiuse

SynthDef(\fma, { arg bus = 0, dt=0.02,at=0.02,freq = 440, gate=1,modPartial = 1, curve= -8,index = 3, amp=0.1, dur, hfoMod=3;



	var hfo = LFTri.ar(freq:freq * modPartial,mul: freq*index*SinOsc.ar(hfoMod/dur,mul:0.5,add:0.5),add:0);
	var audio = SinOsc.ar(freq:freq + hfo,mul: amp).max;
	var env = EnvGen.ar(Env.adsr(attackTime:at,decayTime:dt,sustainLevel:0.3,curve:curve),gate:gate,doneAction:2);

	audio = audio*env;

	audio=Clip.ar(audio,-100.dbamp,30.dbamp);

	Out.ar( ~outBus,[audio,audio])
}).add;

//HFO FM Synth 2 Perc Env._____________________________________________________________________________________
// Multiuse


SynthDef(\fmp, { arg bus = 0, freq = 440, carPartial = 1, modPartial = 1, index = 3, amp=0.1, dur, hfoMod=3;
	var env = EnvGen.ar(Env.perc(0.05*dur,0.9*dur,curve:-2),doneAction:2);
	var hfo = SinOsc.ar(freq:freq * modPartial,phase:0,mul: freq*index*SinOsc.ar(hfoMod/dur,mul:0.5,add:0.5));
	var audio = SinOsc.ar(freq:(freq * 1) + hfo,mul: amp).squared*env;
	audio=Clip.ar(audio,-100.dbamp,30.dbamp);
	Out.ar(	~outBus,[audio,audio])
}).add;

//HFO FM Synth__________________________________________________________________________________________
// Multiuse

SynthDef(\fm1, { arg bus = 0, freq = 440, carPartial = 1, modPartial = 1, index = 3, amp=0.1, dur;
	var hfo;
	var audio;

	var envhfo = EnvGen.ar(Env.sine(dur),doneAction:2);
	var env = EnvGen.ar(Env.perc(0.05*dur,0.95*dur,curve:-4),doneAction:2);

	hfo = SinOsc.ar(freq:freq * modPartial,phase:0,mul: freq*index*env);
	audio = GVerb.ar(SinOsc.ar(freq:(freq * carPartial) + hfo,mul: amp),25)*env;

	audio=Clip.ar(audio,-100.dbamp,30.dbamp);

	Out.ar(	~outBus,[audio,audio])
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

	Out.ar(~outBus, [audio,audio]);
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

		Out.ar(~outBus ,[audio,audio]);
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

		Out.ar(~outBus ,[audio,audio]);
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

		Out.ar(~outBus ,[audio1,audio1]);
	}
).add;


//Verb_________________________________________________________________________________
SynthDef(\verb,
	{
		arg freq, gate=1, amp=0.1, out=0,div=2;

		var mod = SinOsc.ar(freq*div,mul:freq*(1/div),add:freq);

		var car = SinOsc.ar(mod,mul:amp)+SinOsc.ar(mod*2,mul:amp);

		var env = EnvGen.ar(Env.adsr(attackTime:0.3,decayTime:0.3,sustainLevel:0.3,releaseTime:0.2),gate:gate,doneAction:2);

		car =car*env;

		Out.ar(~outBus,[car,car]);
	}




).add;

//Womp2____________________________________________________________________________________

SynthDef(\womp2,
	{
	arg freq, amp=0.1, sustain,chopr=3, numharm,sustainlvl=0.4,gate=1;
		var nh = SinOsc.ar(freq:1/4,mul:1,add:1);
		var audio = LPF.ar(Blip.ar(freq,mul:amp,numharm:numharm*nh),freq:6000*LFPar.ar(freq:sustain*chopr,add:0.5,mul:0.5));
		var env = EnvGen.ar(Env.adsr(attackTime:0.05,decayTime:0.3,sustainLevel:sustainlvl,releaseTime:0.5),gate:gate,doneAction:2);
		audio = audio*env;

		Out.ar(~outBus, [audio,audio]);
	}
).add;
//Womp____________________________________________________________________________________

SynthDef(\womp,
	{
	arg freq, out=0, amp=0.1, chopr, dur, numharm,sustainlvl=0.4,gate=1,at=0.03,dt=0.3,rt=0.5;
		var nh = SinOsc.ar(freq:chopr,phase:SinOsc.ar(freq:1/2,mul:3.14/2,add:3.14/2),mul:1,add:1);
		var audio = LPF.ar(Blip.ar(freq,mul:amp,numharm:numharm*nh),freq:6000*LFPar.ar(freq:dur*chopr,add:0.5,mul:0.5));
		var env = EnvGen.ar(Env.adsr(attackTime:at,decayTime:dt,sustainLevel:sustainlvl,releaseTime:rt),gate:gate,doneAction:2);
		audio = audio*env;

		audio=Compander.ar(audio,audio,-10.dbamp,slopeAbove:1/20,clampTime:0.001,relaxTime:0.5);

		Out.ar(~outBus,[audio,audio]);
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

		Out.ar(~outBus ,[audio1,audio1]);


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
		Out.ar(~outBus,[audio1,audio1]);
	}
).add;

// Build Release_______________________________________________________________________________________
// Situational
SynthDef(\release,
	{
		arg amp=0.1, lpf=4000, dur;

		var bpfl = EnvGen.ar(Env.linen(attackTime:0.01*dur,sustainTime:0.06*dur,releaseTime:0.89*dur,curve:\lin),doneAction:2);
		var a = BPF.ar(WhiteNoise.ar(amp*SinOsc.ar(2,mul:0.2,add:1)),1600*bpfl);

		var env = EnvGen.ar(Env.linen(attackTime:0,sustainTime:dur),doneAction:2);
		//var clip = BPF.ar(WhiteNoise.ar(amp+5.dbamp),500);
		var env2 = EnvGen.ar(Env.perc(attackTime:0.01,releaseTime:0.1,curve:-8,level:1.5),doneAction:0);

		var clip=a*env2;

		a = a*env;
		Out.ar(~outBus, [[clip,a],[a,clip]]);
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
		Out.ar(~outBus ,[audio1,audio1]);
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

		Out.ar(~outBus ,[audio1,audio1]);


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

		Out.ar(~outBus ,[audio1,audio1]);

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
		Out.ar(~outBus,audio);
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

		Out.ar(~outBus,[audio1,audio1]);


	}
).add;


// x__________________________________________________
SynthDef(\x,
	{
		arg freq, amp=0.1, wobbler=3,gate=1, sustain,vibrato=10;
		var wobble = LFTri.ar(wobbler, mul:1.midicps);
		var a = LFTri.ar(freq+wobble,mul:amp*SinOsc.ar(vibrato,mul:0.2,add:0.8));
		var env = EnvGen.ar(Env.adsr(attackTime:0.01,decayTime:0.3,sustainLevel:0.9,releaseTime:1),gate, doneAction:2);
		a= a*env;
		Out.ar(~outBus, [a,a]);
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

		Out.ar(~outBus,[audio1,audio1]);

	}
).add;
//BRUSH SNARE__________________________________________________________________________________

SynthDef(\brushsnare,
	{
		arg amp= -20.dbamp;
		var audio = WhiteNoise.ar(amp);
		var env = EnvGen.ar(Env.perc(attackTime:0.01,releaseTime:0.5,curve:-8),doneAction:2);
		audio = audio*env;
		Out.ar(~outBus, [audio,audio]);
	}
).add;


//WAVE  __________________________________________________________________________________
SynthDef(\wave,
	{
		arg out=0, amp=0.1, lpf,gate=1;

		var audio = LPF.ar(BrownNoise.ar(),lpf,mul:amp+0.dbamp);
		var env = EnvGen.ar(Env.adsr(attackTime:0.03,decayTime:0.03,sustainLevel:0.1,releaseTime:0.2),gate:gate,doneAction:2);

		audio = audio*env;

		Out.ar(~outBus, [audio,audio]);
	}
).add;



//Drum____________________________________________________________________________
 SynthDef(\bd,
	{
		arg  amp = 0.1, freq=36.midicps;
		var env = EnvGen.ar(Env.perc(attackTime:0.01,releaseTime:1,curve:-8),doneAction:2);
		var audio1 = SinOsc.ar(freq,mul:amp);
		audio1=audio1*env;
		Out.ar(~outBus ,[audio1,audio1]);
	}
).add;

//Verb whin____________________________________________________________________________
 SynthDef(\form,
	{
		arg  amp = 0.1, freq=36.midicps, numharm=0,curve= -8,gate=1;
		var env = EnvGen.ar(Env.adsr(attackTime:0.03,sustainLevel:0.3,releaseTime:0.2,curve:curve),gate:gate,doneAction:2);

		var audio1 = Formlet.ar(Impulse.ar(freq,mul:amp), 800, 0.01, 0.1);
		audio1=audio1*env;

		Out.ar(~outBus,[audio1,audio1]);


	}
).add;

//Release___________________________________________________________________________
SynthDef(\release,
	{
		arg amp=0.1, lpf=4000, dur;

		var bpfl = EnvGen.ar(Env.linen(attackTime:0.01*dur,sustainTime:0.06*dur,releaseTime:0.89*dur,curve:\lin),doneAction:2);
		var a = BPF.ar(WhiteNoise.ar(amp*SinOsc.ar(2,mul:0.2,add:1)),1600*bpfl);

		var env = EnvGen.ar(Env.linen(attackTime:0,sustainTime:dur),doneAction:2);
		//var clip = BPF.ar(WhiteNoise.ar(amp+5.dbamp),500);
		var env2 = EnvGen.ar(Env.perc(attackTime:0.01,releaseTime:0.1,curve:-8,level:1.5),doneAction:0);

		var clip=a*env2;

		a = a*env;
		Out.ar(~outBus, [[clip,a],[a,clip]]);
	}
).add;

//

SynthDef(\bassa, {
	arg out = 0, dt=0.3, at=0.01,freq = 220, gate=1,modPartial=4, curve= -4,index = 3, amp=0.1, sustain;



	var one = SinOsc.ar(freq,mul:amp);
	var two = SinOsc.ar(freq+SinOsc.ar(freq*3,mul:freq*3),mul:amp);
	var three = SinOsc.ar(freq+SinOsc.ar(freq*5,mul:freq*5),mul:amp);
	var four = SinOsc.ar(freq+SinOsc.ar(freq*7,mul:freq*7),mul:amp);
	var audio;
	var fourenv = Line.ar(1,0,4);
	var env = EnvGen.ar(Env.adsr(at,dt,1),doneAction:2,gate:gate);

	audio = (one+two+three+four)*(-6.dbamp);

	audio = audio*env;

	audio=Compander.ar(audio,audio,-10.dbamp,slopeAbove:1/20,clampTime:0.001,relaxTime:0.5);

	Out.ar( ~outBus,[audio,audio]);
}).add;

//Spec_____________________________________________________________________________________________________
SynthDef(\spec, {
	arg out = 0, dt=0.2, at=0.01,n=2,freq = 220,ad=100, gate=1,modPartial=4, curve= -4,index = 3, amp=0.1, sustain;

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

	Out.ar(~outBus,[audio,audio]);
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

		Out.ar(~outBus ,[audio1,audio1]);


	}
).add;
