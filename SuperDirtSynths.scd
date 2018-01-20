var adsr = Env.xyc([[0,0,3],[0.001,1,-4],[0.03,0.3,0],[0.4,0.3,4],[1,0]]);
var chevBuf = Buffer.alloc(s, 512, 1, {arg buf; buf.chebyMsg(amplitudes:[1,1,0.7,0.5,0.4,0.3])});
(
SynthDef(\chordy,{
	|amp,freq,gate=1,pan=0,out,sustain|
	var audio,env,scale,noise;
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
	env = EnvGen.ar(adsr,timeScale:sustain,gate:gate,doneAction:2);
	noise = noise*env;
	audio = audio+noise;
	audio =audio*env;
	audio = audio*(18.dbamp);
	audio = FreeVerb.ar(audio,mix:1,room:0.9,damp:0.9)+audio;
	OffsetOut.ar(out, DirtPan.ar(audio, ~dirt.numChannels, pan, env));
}).add;
);

SynthDef(\fmBass,
	{
		|amp, freq, mod=4,out,pan, sustain,at=0.001,dt=0.01,release=0.5,detune=1,detunet=0.25|
		var audio,env,modEnv;
		var freq2 = XLine.ar(freq/2,freq*0.5*(detune.midiratio),sustain*detunet);
		modEnv = EnvGen.ar(Env.new([0,1,0],[at,dt+release],curve:\welch));
		audio = Mix.ar(SinOsc.ar( [1,3,1.5,0.5]*(freq2 + SinOsc.ar(freq2*6,mul:freq2*modEnv*mod))))*(-6.dbamp);
		// audio = LPF.ar(audio,freq);
		// audio = FreeVerb.ar(audio,room:0.4);
		env = EnvGen.ar(Env.new([0,1,0.4,0.4,0],[at,dt,sustain-at-dt-release,release],curve:\welch),timeScale:sustain,doneAction:2);

		audio = audio*env;

		OffsetOut.ar(out,DirtPan.ar(audio,~dirt.numChannels,pan,env));
	}
).add;

SynthDef(\click,
	{
		|amp, freq, mod=4, out,pan,sustain,at=0.01,dt=0.01,release=0.15|
		var audio,env,brilEnv,noiseEnv,high,highEnv;

		audio = Mix.ar(SinOsc.ar((1,1.3..20.67)*30,mul:amp*(-20.dbamp)));

		env = EnvGen.ar(Env.new([0,1,0],[0.0001,0.002]),doneAction:2);

		audio = audio*env;

		OffsetOut.ar(out,DirtPan.ar(audio,~dirt.numChannels,pan,env));
	}
).add;

SynthDef(\sawBass,
	{
		|amp, freq, gate=1, at=0.01,rt=0.9,pan, lpfMul=1,sustain, out|

		var audio, env,lpfEnv;
		audio = Shaper.ar(chevBuf ,Mix.ar(LPF.ar(Saw.ar(freq/4)*EnvGen.ar(Env.perc(attackTime:at,releaseTime:1-at,curve:-1),timeScale:sustain,doneAction:2),freq*lpfMul)), amp*(15.dbamp));

		OffsetOut.ar(out, DirtPan.ar(audio, ~dirt.numChannels, pan, env));
	}
).add;


SynthDef(\fif, {
	|freq=110, amp=0.1, pan, lpf=880, modPartial=1,gate=1,at=0.0001,dur=1,begin, end, out=0,sustain=1|
	var len = end-begin;
	var audio = SinOsc.ar(freq+SinOsc.ar(freq/4,mul:freq)*Line.ar(1.5,1,sustain/16),mul:amp);
	var fifth = SinOsc.ar(freq*1.5,mul:amp);
	var env = EnvGen.ar(Env.perc(0.001,0.999),timeScale:sustain,gate:gate,timeScale:sustain,doneAction:2);
	audio = (audio+fifth);
	audio = audio*env;
	audio = audio;

	OffsetOut.ar(out, DirtPan.ar(audio, ~dirt.numChannels, pan, env));
}).add;

SynthDef(\bass6,{
	|freq, amp, out=0, gate=1, mod=2.5,sustain,att=0.01, pan, lpf|
	var audio, env,freq2,modulator;

	freq2=freq/2;

	modulator = SinOsc.ar(freq2*mod,mul:freq2*mod*XLine.ar(9,1,dur:att));

	audio = SinOsc.ar(freq2 + modulator,mul:amp);//+Pulse.ar(freq2/4,width:0.5,mul:amp/2);

	env = EnvGen.ar(Env.xyc([[0,0,3],[0.001,1,-4],[0.03,0.3,0],[0.4,0.3,4],[1,0]]),timeScale:sustain,doneAction:2);

	audio = LPF.ar(audio,freq:880)*env*6.dbamp;
	OffsetOut.ar(out, DirtPan.ar(audio, ~dirt.numChannels, pan, env));
	}
).add;



SynthDef(\filterSweep,
	{
		|amp,sustain=1,rq=0.2,curve=8,out,pan|
		var audio,env,filtEnv;

		audio = WhiteNoise.ar(amp);

		filtEnv = EnvGen.ar(Env.xyc([[0,10,curve],[1,30000,0]]),timeScale:sustain*0.5);
		audio = BPF.ar(audio,filtEnv,rq);
		audio = FreeVerb.ar(audio);
		env = EnvGen.ar(Env.xyc(xyc:[[0,1,0],[0.5,1,2],[0.8,0,0]]),timeScale:sustain,doneAction:2);
		audio=audio*env;

		OffsetOut.ar(out, DirtPan.ar(audio, ~dirt.numChannels, pan, env));
}).add;



SynthDef(\kick2, {
	|freq=110, amp=0.1, pan, lpf=880, gate=1,at=0.0001,dur=1,begin, end, out=0,sustain=1|
	var osc1,osc2,osc3,audio,env,lpfEnv,noise,noise2,noiseEnv,env2;


	osc2 = Mix.ar(SinOsc.ar([60,23,10],mul:amp*(24.dbamp)));
	osc1 = Mix.ar(SinOsc.ar(200*[1,1.01,0.99],mul:amp));
	noise=  RHPF.ar(WhiteNoise.ar(amp),200,rq:1.3);
	env = EnvGen.ar(Env.xyc([[0,0,2],[0.001,1,-2],[0.3,0.1,0],[0.5,0,1],[1,0,0]]),timeScale:sustain,doneAction:2);
	env2 = EnvGen.ar(Env.xyc([[0,0,2],[0.001,1,-2],[0.1,0.4,0],[0.5,0,4],[1,0,0]]),timeScale:sustain,doneAction:2);
	noise2 = BPF.ar(WhiteNoise.ar(amp*1.0),freq:2000,rq:1);
	noiseEnv = EnvGen.ar(Env.xyc([[0,0,2],[0.001,1,-2],[0.1,0.1,0],[0.5,0,4],[1,0,0]]),timeScale:sustain,doneAction:2);
	// env = EnvGen.ar(Env.perc(0.00001,releaseTime:0.5),timeScale:sustain,doneAction:2);
	// lpfEnv = EnvGen.ar(Env.xyc([[0,0,2],[0.001,1,-2],[0.4,1,0],[0.6,1,4],[1,0.1,0]]),timeScale:sustain,doneAction:2);
	// lpfEnv = EnvGen.ar(Env.xyc([[0,0,2],[0.001,1,-2],[0.03,0.5,0],[0.6,0.5,4],[1,0.1,0]]),timeScale:sustain,doneAction:2);

	noise2= noise2*noiseEnv;
	noise = noise*noiseEnv;
	osc1=osc1*env;
	osc2 = osc2*env2;
	audio = osc1+noise+noise2+osc2;//+PlayBuf.ar(1,b.bufnum,doneAction:0)*(6.dbamp);
	// audio = PlayBuf.ar(1,b.bufnum,doneAction:0)*(6.dbamp);
	// audio = osc1+noise2;

	// audio = LPF.ar(audio,16*freq*lpfEnv*SinOsc.ar(0.125,mul:0.5,add:1));

	// audio = HPF.ar(audio,300);

	// audio = BPF.ar(audio,6000,10);
	// audio = Decay.ar(audio,decayTime: sustain,mul:0.1);

	// audio = audio+CombC.ar(audio,maxdelaytime: 1,delaytime:1/4,decaytime:sustain*0.99);

	// audio = LPF.ar(audio,10000);

	audio = FreeVerb.ar(audio,0.350,room:0.8,damp:0.7);

	audio = Compander.ar(audio,audio,(-25.dbamp),1,slopeAbove:1/3,clampTime:0.005,relaxTime:0.2,mul:6.dbamp);
	// audio = audio*env;
	audio = audio;

	OffsetOut.ar(out, DirtPan.ar(audio, ~dirt.numChannels, pan, env));
}).add;

SynthDef(\detroit, {
	|freq=110, amp=0.1, pan, lpf=880, gate=1,at=0.0001,dur=1,begin, end, out=0,sustain=1|
	var osc1,osc2,osc3,audio,env,lpfEnv;

	osc1 = Mix.ar(Saw.ar([0.99,1,1.01]*freq,mul:amp));
	osc2 = Mix.ar(Saw.ar([0.99,1,1.01]*freq*(3.midiratio),mul:amp));
	osc3 = Mix.ar(Saw.ar([0.99,1,1.01]*freq*(7.midiratio),mul:amp));

	// env = EnvGen.ar(Env.xyc([[0,0,2],[0.01,1,-2],[0.3,0.5,0],[0.8,0.5,4],[1,0,0]]),timeScale:sustain,doneAction:2);
	env = EnvGen.ar(Env.perc(0.001,releaseTime:0.999),timeScale:sustain,doneAction:0);
	// lpfEnv = EnvGen.ar(Env.xyc([[0,0,2],[0.001,1,-2],[0.4,1,0],[0.6,1,4],[1,0.1,0]]),timeScale:sustain,doneAction:2);
	lpfEnv = EnvGen.ar(Env.xyc([[0,0,2],[0.001,1,-2],[0.03,0.5,0],[0.6,0.5,4],[1,0.1,0]]),timeScale:sustain,doneAction:2);
	audio = osc1+osc2+osc3+Mix.ar(Pulse.ar(freq*([0,3,10].midiratio),mul:amp*4.dbamp));

	audio = LPF.ar(audio,15000);
	// audio = LPF.ar(audio,16*freq*lpfEnv*SinOsc.ar(0.125,mul:0.5,add:1));

	// audio = HPF.ar(audio,300);

	// audio = BPF.ar(audio,6000,10);
	// audio = Decay.ar(audio,decayTime: sustain,mul:0.1);

	// audio = audio+CombC.ar(audio,maxdelaytime: 1,delaytime:1/4,decaytime:sustain*0.99);

	// audio = LPF.ar(audio,10000);

	audio = FreeVerb.ar(audio,0.60,room:0.8,damp:0.8);

	audio = audio*env;
	audio = audio;

	OffsetOut.ar(out, DirtPan.ar(audio, ~dirt.numChannels, pan, env));
}).add;
(
SynthDef(\saw6,{
	|amp, freq, out, sustain,gate=1,panFreq=0,panScatter=0,lpf=10000,rq=0.4,pan|
	var audio, env;
	lpf = lpf.clip(10,20000);
	audio = Saw.ar((0.9994,0.9998..1.0006)*freq,mul:amp/4)+Saw.ar((0.9994,0.9998..1.0006)*freq/2,mul:amp/7)+Impulse.ar(freq,mul:amp/4);

	env = EnvGen.ar(Env.xyc([[0,0,2],[0.01,1,-2],[0.3,0.5,0],[0.8,0.5,4],[1,0,0]]),timeScale:sustain,doneAction:2);
	audio = BPF.ar(audio,freq:freq*2,rq:1)+SinOsc.ar(freq,mul:amp/4);
	audio = RLPF.ar(audio,lpf,rq);

	audio = audio*env;
	OffsetOut.ar(out, DirtPan.ar(audio, ~dirt.numChannels, pan, env));

}).add;
);
SynthDef(\kick, {
	|amp=0.1, out=0, gate=1,at=0.002,dur,pan,begin,end|
	var audio,env,len;
	len = end-begin;
	amp = amp.clip(0,1);
	audio = SinOsc.ar(freq:46, mul:amp*1.5);
	audio = LPF.ar(audio,freq:46*2*XLine.ar(4,1,at.clip(0.0001,1)/2)/2,mul:6.dbamp);
	audio = audio +LPF.ar(PinkNoise.ar(amp*4)*XLine.ar(2,0,at/2),46*4);
	env = EnvGen.ar(Env.perc(at,len),doneAction:2);
	audio = audio*env;

	OffsetOut.ar(out, DirtPan.ar(audio, ~dirt.numChannels, pan, env));
}).add;



SynthDef(\sc_bass, {
	|freq=130, amp=0.1, out=0, gate=1,at=0.01,dt=0.03,sawMix=10,sustain,modMul=4,pan,end,begin|
	var audio,env,sawEnv,mod, modEnv,len;
	len = end-begin;
	amp = amp.clip(0,1);
	modEnv = EnvGen.ar(Env.linen(at,0,sustain,0.5));//(at,dt*40,0.1,releaseTime:1),gate:gate,doneAction:2);
	mod = Mix.ar(SinOsc.ar(freq:freq/2, mul:freq*modMul)*modEnv);
	audio = Mix.ar(SinOsc.ar(freq:freq+mod, mul:amp/3)+SinOsc.ar(freq:freq*1.5+mod, mul:amp/8));
	env = EnvGen.ar(Env.perc(at,releaseTime:0.25),doneAction:2);
	audio = audio*env;
	OffsetOut.ar(out, DirtPan.ar(audio, ~dirt.numChannels, pan, env));
}).add;


(

SynthDef(\scbass, {
	|freq=130, amp=0.1, out=0, gate=1,at=0.01,dt=0.03,sawMix=10,sustain,modMul=4,pan,end,begin|
	var audio,env,sawEnv,mod, modEnv,len,mod2,modEnv2;
	len = end-begin;


/*
	modEnv = EnvGen.ar(Env.xyc([[0,0,2],[0.01,1,-2],[0.3,0.5,0],[0.8,0.5],[1,0,0]]),timeScale:sustain);
	modEnv2 = EnvGen.ar(Env.xyc([[0,0,2],[0.01,1,-2],[0.2,0.1,0],[0.3,0.1],[1,0,0]]),timeScale:sustain);


	mod = SinOsc.ar(freq:freq/4, mul:freq*3.6)*modEnv;
	mod2 = SinOsc.ar(freq:freq*12, mul:freq*modMul*4)*modEnv2;



	*/

	audio = Mix.ar( Mix.ar(LFTri.ar(freq *4+0.125.midiratio,mul:amp/4))+Mix.ar(Pulse.ar(freq/2,0.22,mul:amp/4)));

	// audio = LPF.ar(audio,freq*8);

	env = EnvGen.ar(Env.xyc([[0,0,2],[0.01,1,-2],[0.3,0.5,0],[0.8,0.5,4],[1,0,0]]),timeScale:sustain,doneAction:2);

	audio = audio*env;
	OffsetOut.ar(out, DirtPan.ar(audio, ~dirt.numChannels, pan, env));
}).add;
// (instrument:\bass,midinote:Scale.minor.degrees.choose+48+[-12,0 ].choose).play
);


SynthDef(\vrb, {
	|freq=130, amp=0.1, out=0, gate=1,at=0.01,dt=0.03,sawMix=10,sustain=1,modMul=4,pan,end,begin,speed|
	var audio,env,sawEnv,mod, modEnv, modEnv2, env2;
	amp = amp.clip(0,1);


	modEnv = EnvGen.ar(Env.xyc([[0,0,2],[0.01,1,-3],[1,0,0]]),timeScale:sustain);//(at,dt*40,0.1,releaseTime:1),gate:gate,doneAction:2);
	modEnv2 = EnvGen.ar(Env.xyc([[0,0,3],[0.99,1,-2],[1,0,0]]),timeScale:sustain);

	modEnv = Select.kr(((speed.sign)/2)+0.5,[modEnv2,modEnv]);

	mod = SinOsc.ar(freq:freq*4, mul:freq*2)*modEnv;

	env = EnvGen.ar(Env.linen(0.01,sustainTime:0,releaseTime:0.99,curve:[\sine]),timeScale:sustain,doneAction:2);
	env2 = EnvGen.ar(Env.linen(0.99,sustainTime:0,releaseTime:0.01,curve:[\sine]),timeScale:sustain,doneAction:2);

	env = Select.kr(((speed.sign)/2)+0.5,[env2,env]);
	audio = Mix.ar(SinOsc.ar(freq:freq+mod, mul:amp/2)+Saw.ar(freq:[1,2]*freq/2,mul:amp/4));//*SinOsc.ar(freq+SinOsc.ar(freq/2,mul:freq*2),mul:1);
	audio = LPF.ar(audio,900);
	audio = audio*env;
	OffsetOut.ar(out, DirtPan.ar(audio, ~dirt.numChannels, pan, env));
}).add;




(
SynthDef(\upr,{
	|freq=440, amp=0.1, out=0, at=0.5, rt=2, lpf, sustain=1,gate=1,lfoFreq=0.125,resonance=0.15,pan,begin,end,speed|
	var audio, env, mod, modEnv,lpfEnv, noiseEnv, noise, noise2, highNoiseEnv;

	modEnv = EnvGen.ar(Env.xyc([[0,0,4],[0.001,2,4],[2,4,0]]),doneAction:0);

	mod = SinOsc.ar(freq,mul:freq*16*EnvGen.ar(Env.xyc([[0,1,0],[2,1,2],[4,4,0]])));
	mod=mod*modEnv;

	env = EnvGen.ar(Env.xyc([[0,0,4],[0.001,1,-2],[0.01,0.5,0],[0.98,0.5,4],[1,0,0]]),timeScale:sustain,doneAction:2);
	audio = SinOsc.ar(freq+mod,mul:amp)+SinOsc.ar(freq,mul:amp/2);
	// audio = Mix.ar(Saw.ar([1.001,1,0.999,0.5]*freq,mul:amp));


	highNoiseEnv = EnvGen.ar(Env.xyc([[0,1,2],[0.01,8]]),timeScale:sustain);
	noiseEnv = EnvGen.ar(Env.xyc([[0,0,4],[0.001,0.2,-2],[0.01,0.5,0],[0.1,0.7,4],[1,0,0]]),doneAction:0);

	noise = RHPF.ar(WhiteNoise.ar(amp*1),(freq*2*highNoiseEnv).clip(10,22000),rq:0.5)*noiseEnv;

	noise2 = RLPF.ar(PinkNoise.ar(1/8),freq*Line.ar(0.5,0.125/4,0.125),rq:0.1)*noiseEnv;

	audio = audio+noise+noise2;

	lpfEnv = EnvGen.ar(Env.xyc([[0,0.5,4],[0.1,1,4],[2,8,0]]),doneAction:0);

	audio = LPF.ar(audio,freq*lpfEnv*3);

	audio = audio*env;

	audio = Compander.ar(audio,audio,thresh:-40.dbamp,slopeBelow:1,slopeAbove:1/1.2,clampTime:0.01,relaxTime:0.02,mul:8.dbamp);

	OffsetOut.ar(out, DirtPan.ar(audio, ~dirt.numChannels, pan, env));
}).add;


// (instrument:\upr,midinote:[72],speed:[-1,1].choose,sustain:4).play
);



SynthDef(\det,
	{
	|freq=440, amp=0.1, out=0, at=0.5, rt=2, lpf, sustain=1,gate=1,lfoFreq=0.125,resonance=0.15,pan,begin,end|
		var audio,env, lpfEnv,len;
		len = end-begin;
		amp = amp.clip(0,1);
		resonance = resonance.clip(0,1)/2;
		audio = Mix.ar(Saw.ar([freq,freq*1.02,freq*0.98]++([freq,freq*1.02,freq*0.98]*1.5),mul:amp));
		lpfEnv = EnvGen.ar(Env.linen(attackTime:at,sustainTime:sustain,releaseTime:rt),doneAction:0);
		audio = RLPF.ar(audio, freq*0.5*(lpfEnv+0.51)*SinOsc.ar(lfoFreq,mul:0.5,add:1), resonance.linexp(0, 1, 1, 0.001));
		audio = Compander.ar(audio,audio,0.dbamp,1,slopeAbove:1/20,clampTime:0.001,relaxTime:0.001);
		env = EnvGen.ar(Env.perc(0.2, 0.8, 1, -1), timeScale:sustain, doneAction:2);
		audio = audio*env;
		OffsetOut.ar(out, DirtPan.ar(audio, ~dirt.numChannels, pan, env));
	}
).add;

SynthDef(\stab2, {
	|freq=110, amp=0.1, pan, lpf=880, gate=1,at=0.001,dur=1,begin, end, out=0,sustain=1|
	var osc1,osc2,osc3,audio,env,lpfEnv;

	osc1 = Mix.ar(SinOsc.ar([0.99,1,1.01]*freq,mul:amp));
	osc2 = Mix.ar(SinOsc.ar([0.99,1,1.01]*freq*(3.midiratio),mul:amp));
	osc3 = Mix.ar(SinOsc.ar([0.99,1,1.01]*freq*(7.midiratio),mul:amp));

	env = EnvGen.ar(Env.xyc([[0,0,3],[0.001,1,-4],[0.03,0.3,0],[0.4,0.3,4],[1,0]]),timeScale:sustain,doneAction:1);
	audio = osc1+osc2+osc3;//+Mix.ar(Pulse.ar(freq*([0,3,10].midiratio),mul:amp*4.dbamp));

	audio = FreeVerb.ar(audio,0.60,room:0.1,damp:0.2);

	audio = audio*env;

	OffsetOut.ar(out, DirtPan.ar(audio, ~dirt.numChannels, pan, env));
}).add;

(
SynthDef(\stab3,
	{
	|freq=440, amp=0.1, out=0, at=0.001, rt=0.999, sustain=1,gate=1,lfoFreq=0.125,resonance=0.15,pan,begin,end, mod=16|
		var audio,env, lpfEnv,len,freq2,modulator;
		len = end-begin;
		amp = amp.clip(0,1);
		resonance = resonance.clip(0,1)/2;
		// audio = Mix.ar(SinOsc.ar(((0.995,0.997..1.005)*freq)++((0.995,0.997..1.005)*freq)*1.5,mul:amp*(-20.dbamp)));
		freq2= ([0,10,-12,3].midiratio)*freq;

		env = EnvGen.ar(Env.perc(attackTime:at,releaseTime: rt,level: 1,curve:-1), timeScale:sustain, doneAction:2);

		modulator = SinOsc.ar(freq*2,mul:freq*mod)*env;
		audio = SinOsc.ar(freq2+modulator, mul:amp);

		// audio = SinOsc.ar(2*freq*([0,10,-12,3].midiratio),mul:amp*(-12.dbamp))+audio;

		audio = Mix.ar(audio);
		// lpfEnv = EnvGen.ar(Env.linen(attackTime:at,sustainTime:sustain,releaseTime:rt),doneAction:0);
		// audio = RLPF.ar(audio, freq*0.5*(lpfEnv+0.51)*SinOsc.ar(lfoFreq,mul:0.5,add:1), resonance);
		audio = Compander.ar(audio,audio,0.dbamp,1,slopeAbove:1/20,clampTime:0.001,relaxTime:0.001);
		env = EnvGen.ar(Env.perc(attackTime:at,releaseTime: rt,level: 1,curve:-1), timeScale:sustain, doneAction:2);
		audio = audio*env;
		OffsetOut.ar(out, DirtPan.ar(audio, ~dirt.numChannels, pan, env));
	}
).add;

);

(
SynthDef(\pad4,
	{
	|freq=440, amp=0.1, out=0, att=0.2, sustain,gate=1,rate=0.1,pan,lfoFreq=0.25,sus=1,resonance=0.15, panScatter=0,lpf=1,delayT=0.1|
		var audio,env,circleEnv, lpfEnv,lfo, upRate;
		amp = amp.clip(0,1);
		resonance = resonance.clip(0,1)/2;
		audio = Mix.ar(Saw.ar(freq,mul:amp));
		lpfEnv = EnvGen.ar(Env.linen(attackTime:att,sustainTime:sustain,releaseTime:2),doneAction:0);
		upRate = XLine.kr(1,freq/2,dur:att);
		lfo = SinOsc.ar(lfoFreq+upRate,mul:0.125,add:1);
		audio = RLPF.ar(audio, freq*lpf*lfo,0.25);
		audio = Compander.ar(audio,audio,-30.dbamp,1,slopeAbove:1/2,clampTime:0.01,relaxTime:0.001);
		env = EnvGen.ar(Env.linen(attackTime:att,sustainTime:1-att-att,releaseTime:att),timeScale:sustain,doneAction:0);

		circleEnv = EnvGen.ar(Env.circle([0.2,1],[0.05,0.95]/upRate));
		audio = audio*env*circleEnv;
		// audio = FreeVerb.ar(audio,0.6,room:0.9);
		audio = Pan2.ar(audio,panScatter*(lfo-0.875));

		OffsetOut.ar(out, DirtPan.ar(audio, ~dirt.numChannels, pan, env));
	}
).add;
);


(
SynthDef(\pad3,
	{
	|freq=440, amp=0.1, out=0, att=0.5, rt=2, pan,sustain,gate=1,lfoFreq=0.25,sus=1,resonance=0.15, panScatter=0,lpf=1,delayT=0.1|
		var audio,env, lpfEnv,lfo,killEnv;
		amp = amp.clip(0,1);
		resonance = resonance.clip(0,1)/2;
		audio = Mix.ar(Saw.ar([freq,freq*1.02,freq*0.98]++([freq,freq*1.02,freq*0.98]*1.5),mul:amp/40));
		lpfEnv = EnvGen.ar(Env.linen(attackTime:att,sustainTime:sustain,releaseTime:rt),doneAction:0);
		lfo = SinOsc.ar(lfoFreq,mul:0.5,add:1);
		audio = RLPF.ar(audio, freq*lpf*lfo,0.25);
		audio = Compander.ar(audio,audio,0.dbamp,1,slopeAbove:1/20,clampTime:0.001,relaxTime:0.001);
		env = EnvGen.ar(Env.linen(attackTime:att,sustainTime:sus,releaseTime:rt),doneAction:0);
		audio = audio*env;

		6.do{
			audio = audio +DelayN.ar(audio,0.5,delayT,-3.dbamp);
		};
		killEnv = EnvGen.ar(Env([1,1,0],[0.9,0.1]),timeScale:sustain,doneAction:2);
		audio = audio*killEnv;
		// audio = FreeVerb.ar(audio,0.6,room:0.9);
		audio = Pan2.ar(audio,panScatter*(lfo-1));

		OffsetOut.ar(out, DirtPan.ar(audio, ~dirt.numChannels, pan, killEnv));
	}
).add;
);

(
SynthDef(\arpeg,
	{
	|freq=440, amp=0.1, out=0, at=0.5, rt=2, lpfFreq=500, sustain=1,gate=1,lfoFreq=0.25,resonance=0.15,arpegFreq=0.015,panFreq=0.0625,panScatter=0.125,pan,begin,end|
		var audio,env, arpegEnv,mod, lpfLfO,panEnv,len;
		len = end-begin;
		amp = amp.clip(0,1);
		arpegEnv = EnvGen.ar(Env.circle([0,0,8,8,12,12,-5,-5,10,12,19,19,0,0,3,3,12,12,-5,-5,10,12,19,19].midiratio,[arpegFreq*0.99,arpegFreq*0.01]),doneAction:0);
		panEnv = EnvGen.kr(Env.circle([-1,-1,1,1],[panFreq,0.01]),doneAction:0);
		mod = SinOsc.ar(freq*4,mul:freq);
		audio = SinOsc.ar(freq*arpegEnv+mod,mul:amp/2);
		lpfLfO = SinOsc.ar(0.3,mul:0.25,add:1);

		audio = RLPF.ar(audio,lpfFreq.clip(10,22000)*lpfLfO,0.3);
		audio = Compander.ar(audio,audio,0.dbamp,1,slopeAbove:1/20,clampTime:0.001,relaxTime:0.001);
		env = EnvGen.ar(Env.linen(attackTime:0.01,sustainTime:0.79,releaseTime:0.2),timeScale:sustain,gate:gate,doneAction:2);
		audio = audio*env;
		// audio = Pan2.ar(audio,panEnv*panScatter);
		OffsetOut.ar(out, DirtPan.ar(audio, ~dirt.numChannels, pan, env));
	}
).add;
);


SynthDef(\pad2,
	{
	|freq=440, amp=0.1, out=0, at=0.01, rt=2, lpf,pan, sustain=1,gate=1,lfoFreq=0.25,resonance=0.15, panScatter=0|
		var audio,env, lpfEnv,lfo;
		amp = amp.clip(0,1);
		resonance = resonance.clip(0,1)/2;
		audio = Mix.ar(Saw.ar([freq,freq*1.02,freq*0.98]++([freq,freq*1.02,freq*0.98]*1.5),mul:amp/6));
		lpfEnv = EnvGen.ar(Env.linen(attackTime:0.01,sustainTime:0.79,releaseTime:0.2),timeScale:sustain,doneAction:0);
		lfo = SinOsc.ar(lfoFreq,mul:0.5,add:1);
		audio = RLPF.ar(audio, freq*0.5*(lpfEnv+0.51)*lfo, resonance.linexp(0, 1, 1, 0.001));
		audio = Compander.ar(audio,audio,0.dbamp,1,slopeAbove:1/20,clampTime:0.001,relaxTime:0.001);
		env = EnvGen.ar(Env.linen(attackTime:at,sustainTime:0.79,releaseTime:0.2),timeScale:sustain,gate:gate,doneAction:2);
		audio = audio*env;
		audio = Pan2.ar(audio,panScatter*(lfo-1));
		OffsetOut.ar(out, DirtPan.ar(audio, ~dirt.numChannels, pan, env));
	}
).add;



SynthDef(\lzr,
	{
	|freq=440, amp=0.1, out=0, at=0.5, rt=2, lpf,pan, sustain=1,gate=1,lfoFreq=0.25,resonance=0.15, panScatter=0, speed=1|
		var audio,env, lpfEnv,lfo, mod, modEnv,env2;
		amp = amp.clip(0,1);

		env = EnvGen.ar(Env.xyc([[0,0,1],[0.01,1,-3],[0.3,0.5,0],[0.4,0.5,4],[1,0]]),timeScale:sustain,doneAction:2);

		env2 = EnvGen.ar(Env.linen(attackTime:0.8,sustainTime:0.1,releaseTime:0.1),timeScale:sustain,doneAction:2);

		env = Select.kr((speed/2+0.5).round,[env2,env]);

		modEnv = EnvGen.ar(Env.pairs([[0,1],[1,0]],curve:-4),timeScale:sustain,doneAction:0);

		mod = SinOsc.ar(freq*XLine.ar(1,16,dur:sustain/2),mul:freq*16);

		audio = Mix.ar(SinOsc.ar([1,1.5]*freq+mod,mul:amp));

		audio = LPF.ar(audio,freq:freq*4*SinOsc.ar(1,phase:6*pi/4,add:1,mul:0.2),mul:0.25);

		audio = audio*env;
		OffsetOut.ar(out, DirtPan.ar(audio, ~dirt.numChannels, pan + SinOsc.ar(4,mul:0.05*Line.ar(1,8,3)), env));
	}
).add;

(
SynthDef(\fm6, {
	arg out = 0, freq = 220,pan, gate=1,modPartial=5, curve= -4,index = 3, amp=0.01, sustain;



	var hfo = SinOsc.ar(freq:freq*modPartial,mul: freq*modPartial);
	var envhfo= EnvGen.ar(Env.adsr(attackTime:0.02,decayTime:2,sustainLevel:0.1,releaseTime:0.01,curve:-16),doneAction:0)*hfo;

	var topOctave = SinOsc.ar(freq:(freq+envhfo),mul: amp/4)*EnvGen.ar(Env.linen(0.01,0.03,sustain));
	var audio = SinOsc.ar(freq:(freq+envhfo)/2,mul: amp/2) + SinOsc.ar(freq:freq+envhfo,mul: amp/2) + topOctave;
	var env = EnvGen.ar(Env.xyc([[0,0,3],[0.001,1,-4],[0.03,0.3,0],[0.4,0.3,4],[1,0]]),timeScale:sustain);
	audio = audio*env;
	audio=Compander.ar(audio,audio,20.dbamp,slopeAbove:1/20,clampTime:0.001,relaxTime:0.5);

	OffsetOut.ar(out, DirtPan.ar(audio, ~dirt.numChannels, pan, env));
}).add;
);


SynthDef(\chord,
	{
	|freq=440, amp=0.1, out=0, at=0.5, rt=2, lpf,pan, sustain=1,gate=1,lfoFreq=0.25,resonance=0.15, panScatter=0|
		var audio,env, lpfEnv,lfo, mod, modEnv;
		amp = amp.clip(0,1);

		env = EnvGen.ar(Env.xyc([[0,0,3],[0.001,1,-4],[0.03,0.3,0],[0.4,0.3,4],[1,0]]),timeScale:sustain,doneAction:2);

		audio = Mix.ar(SinOsc.ar([1,3.midiratio,10.midiratio]*freq+SinOsc.ar(freq*8,mul:freq*8),mul:amp));

		audio = LPF.ar(audio,freq:freq*4*SinOsc.ar(1*XLine.ar(1,2,2),phase:6*pi/4,add:1,mul:0.3));

		audio = audio*env;
		OffsetOut.ar(out, DirtPan.ar(audio, ~dirt.numChannels, pan, env));
	}
).add;
