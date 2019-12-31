(
// var bounds = Window.screenBounds;
var width = Window.screenBounds.width*3/4;
var height = Window.screenBounds.height*3/4;
var bounds = Rect(0,0,width,height);
var window = Window("yamboot",bounds);
var margin = 20;

var effects = CompositeView(window, Rect(left:margin,top:margin,width:(width-(margin*2)),height:bounds.height-(margin*2)));

var numberOfKnobs = 5;
var instruments = 4;

var knobs = Array2D(rows:instruments,cols:numberOfKnobs);

var c1 = Color(red:0.7,green:0.8,blue:0.95,alpha:1);

var tidal = NetAddr.new("127.0.0.1", 6010);

~ks = (0!numberOfKnobs)!instruments;

window.background = Color(0,0,0);

effects.bounds.postln;

knobs.rows.do{
	|i|
	i.postln;
	knobs.cols.do{
		|j|
		knobs[i,j] = Knob(effects,Rect(left:j*effects.bounds.width/numberOfKnobs,top:i*effects.bounds.height/instruments,width:effects.bounds.width/numberOfKnobs,height:effects.bounds.height/instruments/1.5)).color_([Color.white,Color.red,Color.white,Color.red]).action_({
			|a|
			~ks[i][j] = a.value;
			// tidal.sendMsg("/ctrl",i.asString++j.asString, a.value);
		});
		};
};


window.front();
)














// For gran. synth thing

(
b = Buffer.read(s,"C:/Users/jamie/AppData/Local/SuperCollider/downloaded-quarks/Dirt-Samples/asgmayl/9.wav");


SynthDef(\grain,{
	arg rate=1,pos=0,amp=0.1,out=0,pan=0,sustain=1.0;
	var audio = Mix.ar(PlayBuf.ar(2,b.bufnum,rate:rate.clip(0,16)*BufRateScale.kr(b.bufnum),startPos:pos.clip(0,1)*BufFrames.kr(b.bufnum)));
	audio=audio*EnvGen.ar(Env([0,1,0],[sustain/2,sustain/2],curve:'welch'),doneAction:2);

	audio = Pan2.ar(audio,pan);
	Out.ar(~outBus,audio*(amp.clip(0,1)));
}).add;
)

(
Pdef(\a,
	Pbind(
		\instrument,\grain,
		\db,-25,
		\rate,1,
		\dur,0.005,
		\pos,Pfunc({~ks[0][1]})+Pwhite(Pfunc({-1*~ks[0][2]}),Pfunc({~ks[0][2]})),
		\sustain,Pfunc({~ks[0][5]*0.2})+ Pwhite(-0.01,0.01),
		\pan,Pfunc({~ks[0][3].linlin(0,1,-1,1)})+Pwhite(Pfunc({(-1)*~ks[0][4]}),Pfunc({~ks[0][4]}))
	)
).play

)



