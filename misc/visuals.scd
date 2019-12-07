SuperDirt.start()
Jam.loadSuperDirtSynths
(
var processingPort = 9003;
var processing = NetAddr.new("127.0.0.1", processingPort);
var r=255;
var g=255;
var b=255;
~node = NetAddr.new("127.0.0.1",port:9000);

OSCdef(\repackageTidal,{
		|msg|
	var sus, legato, dur, cps, delta;
	var sample = "";
	msg.postln;
	msg.size.do{
		|i|
		if(msg[i] == 'sustain',{sus = msg[i+1]});
		if(msg[i] == 'legato',{legato = msg[i+1]});
		if(msg[i] == 's', {sample = msg[i+1]});
		if(msg[i] == 'cps', {cps = msg[i+1]});
		if(msg[i] == 'delta', {delta = msg[i+1]});
		if(msg[i] == 'backgroundR', {r = msg[i+1]});
		if(msg[i] == 'backgroundG', {g = msg[i+1]});
		if(msg[i] == 'backgroundB', {b = msg[i+1]});
	};

	if(sus == nil, {
		if (legato !=nil,
			{dur = (1/cps)*delta*legato},
			{dur = (1/cps)*delta}
		);
	},{dur = sus}
	);

	processing.sendMsg("/sound",sample,dur);
	processing.sendMsg("/backgroundColor",r,g,b);

	~node.sendBundle(0,["/play"]++(msg[7..]));

},path:'/play2',recvPort:57130)
)
a==nil

(
var buf = Buffer(s,numFrames:2048,numChannels:1);
var low = 0!33;
var high = 0!33;
var mid = 0!33;
var amp = 0!33;
var c =0;

SynthDef("global_ml", { |vRate=16, dryBus,effectsBus,out|

	var in = Mix.ar( In.ar(out, ~dirt.numChannels));
		var fft = FFT(buf,in);
		/*SendReply.kr(Impulse.kr(vRate,1.0.rand),cmdName:'/visuals',values:[Amplitude.kr(in)]++MFCC.kr(fft,13),replyID:-2);*/
	SendReply.kr(Impulse.kr(vRate,1.0.rand),cmdName:'/visuals',values:[Amplitude.kr(in)],replyID:-2);
}).add;



OSCdef(\visuals,
	{
		|msg|
		var roundval = 3.round;
	msg.postln;

		/*	var mfcc = Array.new();
		var low,bright;
		msg.postln;
		13.do{
			|i|
			mfcc = mfcc.add(((msg[4+i]*10).round.abs)/10)
		};
		mfcc.postln;
		mfcc = mfcc.normalizeSum;

		amp = amp.add(msg[3]).keep(-33);
		/*if (amp.mean>0.1,{"##############################".postln;Jam.soundTest()});*/
		low = low.add(mfcc[..4].sum).keep(-33);
		mid = mid.add(mfcc[4..8].sum).keep(-33);
		high = high.add(mfcc[8..].sum).keep(-33);
		Routine({
			0.01.wait;
			// ~unity.sendMsg("/soundData",amp,low.mean,high.mean);
		}).play;
		("low:  "+low.mean).postln;
		("mid:  "+mid.mean).postln;
		("high: "+high.mean).postln;
		("amp:  "+amp.mean).postln;
		"______".postln;*/
},path:'/visuals',recvPort:57120);
)


Synth.new("global_ml",[\out,0,\vRate,4],target:1,addAction:'addToTail');





(var sus; (sus ==nil).postln;)
(
var sus;
var legato;
var cps = 1;
var portion = 0.5;
var dur;
var list = [1,2,3,\a,2,\somethingEsle,3,\legato,5];
list.size.do{
	|i|
	if(list[i] == \sustain,{sus = list[i+1]});
	if(list[i] == \legato,{legato = list[i+1]});
};
if(sus == nil, {
	if (legato !=nil,
		{dur = cps*portion*legato},
		{dur = cps*portion}
	);
},{dur = sus}
);

dur.postln;
)

SuperDirt.start()

3.do{|x|x.postln;}

[1,2,3].size













// these are the global effects on each orbit
~dirt.orbits.do { |x| x.globalEffects.postln }

// say you want to add a global low pass filter on the first orbit
SuperDirt.start
// first you generate the synth defs for it

SuperDirt.maxSampleNumChannels
(1..2)
(
var numChannels = ~dirt.numChannels;
(1..SuperDirt.maxSampleNumChannels).do { |numChannels|
	SynthDef("global_ml" ++ numChannels, { |vRate=16, dryBus,effectsBus|

		var in = Mix.ar( In.ar(out, numChannels));

		var fft = FFT(LocalBuf(2048,1),in);
		SendReply.kr(Impulse.kr(vRate,1.0.rand),cmdName:'/visuals',values:[dryBus,Amplitude.kr(in)]++MFCC.kr(fft,13),replyID:-2);

	}).add;
};
)
// then add the effect to the orbit
(
~dirt.orbits.do { |x|
	x.globalEffects = ~dirt.orbits[0].globalEffects.insert(~dirt.orbits[0].globalEffects.size-1,
		GlobalDirtEffect(\global_ml, [\vRate])
	)
};
~dirt.orbits[0].initNodeTree;
)

~dirt.orbits.do { |x| x.globalEffects.postln; " ----------".postln; }

Server.default

(
var c =0;
OSCdef(\visuals,
	{
		|msg|
/*		var mfcc = Array.new();
		var amp = msg[3];
		var low,bright;
		13.do{
			|i|
			mfcc = mfcc.add(((msg[3+i]*10).round.abs)/10)
		};
		mfcc = mfcc.normalizeSum;
		low = low.add(mfcc[..6].sum).keep(-8000);
		high = high.add(mfcc[6..].sum).keep(-8000);
		Routine({
			0.01.wait;
			~unity.sendMsg("/soundData",amp,low.mean,high.mean);
		}).play;*/
		msg.postln;
		c=c+1;
		c.post;
		"______".postln;
},path:'/visuals',recvPort:57120);
)










(
var low = 0!33;
var high = 0!33;
var processingPort = 8002;
~unity = NetAddr.new("127.0.0.1",port:processingPort);
~unity.sendMsg("/test",2);
OSCdef(\visuals,
	{
		|msg|
		var mfcc = Array.new();
		var amp = msg[3];
		var low,bright;
		13.do{
			|i|
			mfcc = mfcc.add(((msg[3+i]*10).round.abs)/10)
		};
		mfcc = mfcc.normalizeSum;
		low = low.add(mfcc[..6].sum).keep(-8000);
		high = high.add(mfcc[6..].sum).keep(-8000);
		Routine({
			0.01.wait;
			~unity.sendMsg("/soundData",amp,low.mean,high.mean);
		}).play;
},path:'/visuals',recvPort:57120);
)
~unity.sendMsg("/soundData",2,4,5,6,7);

Synth(\listen,addAction:'addToTail')

(
var numChannels =2;
// var buf = Buffer(s,2048,numChannels);
{
	var audio = Mix.ar(SinOsc.ar([1]*20000*MouseY.kr(0.01,1),mul:0.1));
	var fft = FFT(LocalBuf(2048,1),audio);
	SendReply.kr(Impulse.kr(32),cmdName:'/visuals',values:[Amplitude.ar(audio)]++MFCC.kr(fft,13),replyID:-2);

	Out.ar(0,audio);
}.play

)

(
SynthDef(\visuals,
	{
		|numChannels=2,rate=16|
		// var in = In.ar((0..(numChannels-1)));

		numChannels.do{
			|i|
			var in = In.ar(i);
			SendReply.kr(Impulse.kr(rate),cmdName:'/visuals',values:[Amplitude.ar(In.ar(i))]);
		};

	}
).add;
)

(
SynthDef(\asdf,
	{
		|numChannels=2,rate=16|
		// var in = In.ar((0..(numChannels-1)));

		Out.ar(0,SinOsc.ar(mul:0.1));

	}
).add;
)

Ndef(\a,{SinOsc.ar(mul:0.1)})
Ndef(\a).play
x = Synth.new(\asdf)
x
Synth.new(\visuals,target:x,addAction:'addToTail')

Synth.tail(x,\visuals)