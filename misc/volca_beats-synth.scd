(
SynthDef(\volca_beats,
	{
		|loop=0, lpf = 22000, hpf=10, amp = 1, channel =1, pan=0, pitch = 0,reverb =0.33,room=0.5|

		var audio= AudioIn.ar(channel);
		var busses =[];
		var record = [];
		var numLoops = 7;
		audio = RLPF.ar(audio,freq:Clip.kr(lpf,20,hi:23000),rq:0.2);
		audio = RHPF.ar(audio,freq:Clip.kr(hpf,20,23000),rq:0.2);


		numLoops.do{
			|i|
			busses = busses.add(LocalBuf((Server.default.sampleRate*(i+1))/8));
			RecordBuf.ar(inputArray:audio,bufnum:busses[i],run:Select.kr(loop,(0!(i)++[1]++(0!((numLoops-i))))));
			record = record.add((PlayBuf.ar(busses[i].numChannels,bufnum:busses[i],trigger:Impulse.ar((i+1)/4),loop:1)));
			// record = record.add(WhiteNoise.ar(mul:0.01));
		};

		audio = Select.ar(loop,[audio]++record);

		audio = PitchShift.ar(audio,pitchRatio:pitch.midiratio);
		audio = FreeVerb.ar(audio,mix:Clip.kr(reverb,0,1),room:Clip.kr(room,0,1));
		audio = audio*amp;
		Out.ar(0,Pan2.ar(audio,pan));
	}
).add
)





TempoClock.tempo


(
SynthDef(\volca_beats,
	{
		|loop=0, lpf = 22000, hpf=10, amp = 1, channel =1, pan=0, pitch = 0,reverb =0.33,room=0.5, begin=0|

		var audio= AudioIn.ar(channel,mul:amp);
		var buf;
		var bufLoop;

		// 4 seconds
		buf = LocalBuf(Server.default.sampleRate*4);
		RecordBuf.ar(inputArray:audio,bufnum:buf,run:Select.kr(loop,[1,0,0,0,0,0,0,0]));

		bufLoop = PlayBuf.ar(buf.numChannels,buf,rate:1,trigger:Impulse.ar(4/2.pow(loop)),loop:1,startPos:begin*BufFrames.kr(buf));


		audio = Select.ar(loop,[audio,bufLoop,bufLoop,bufLoop,bufLoop,bufLoop,bufLoop,bufLoop,bufLoop]);
		audio = RLPF.ar(audio,freq:Clip.kr(lpf,20,hi:23000),rq:0.2);
		audio = RHPF.ar(audio,freq:Clip.kr(hpf,20,23000),rq:0.2);
		audio = PitchShift.ar(audio,pitchRatio:pitch.midiratio);
		audio = FreeVerb.ar(audio,mix:Clip.kr(reverb,0,1),room:Clip.kr(room,0,1));
		Out.ar(0,Pan2.ar(audio,pan));
	}
).add
)
4.pow(6)*0.125/2

Select.kr(loop,[4,2,1,0.5,0.25,0.125,0.125/2,0.125/4].reverse)

[4,2,1,0.5,0.25,0.125,0.125/2,0.125/4].plot
[]

4/(2.pow(loop))


2.pow(3)

(
var i =0;
var j = 8;
(0!(i)++[1]++(0!((j-i))))
)

TempoClock.beats

x = Synth(\volca_beats)



x.set(\lpf,20000)

x.set(\pitch,0)

x.set(\amp,2 )

x.set(\loop,0)


{AudioIn.ar(1)}.play


Server.default.sampleRate

[1]++[1,2]

Jam.soundTest()

(
{


}
)

