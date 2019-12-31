Jam{

	classvar <>layers;

	*initClass{

		"@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@".postln;

	}

	*soundTest{
		{SinOsc.ar(440,mul:0.1)*EnvGen.ar(Env.perc(),doneAction:2)}.play
	}

	*codeShare{
		|oscPort=8000,ipAddr="127.0.0.1",name|
		var addr = NetAddr.new(hostname:ipAddr, port:oscPort);
		Document.globalKeyDownAction = {addr.sendMsg("/"++name,Jam.getTenLines )}
	}



	*sampleChopper{
		|file, outputFolder, bpm, offset=0, beatsPerPhrase=16|

		var counter = 0;
		var sampleDuration;
		outputFolder.mkdir;
		"chopping...".postln;
		Server.default.waitForBoot({

			var buffer = Buffer.read(Server.default, file,action:{

				buffer.loadToFloatArray(action:{
					|array|
					var chans = buffer.numChannels;
					buffer = Buffer.loadCollection(Server.default,array,chans,action:{
						|buff|


						var numBeats = buff.numFrames/buff.sampleRate*bpm/60;
						var phraseDur = beatsPerPhrase/(bpm/60);
						var samplesPerPhrase = phraseDur*buff.sampleRate;
						var offsetInSamples = offset*buff.sampleRate;
						(numBeats/beatsPerPhrase).floor.do{
							|k|

							buff.write(path:(outputFolder++"/"++k++".wav"),headerFormat:"WAV",sampleFormat:"int16",numFrames:buff.sampleRate*phraseDur,startFrame:k*samplesPerPhrase+offsetInSamples);
						};
						buff.free;
						buffer.free;
					});
				});
			});
			"done".postln;
		});
	}


	*bootAgain{
		~out = Synth.new(\out);
		MIDIClient.init;
		MIDIIn.connectAll;

		(
			MIDIdef(\lpd8Vol,{
				|val,nm,chan,src|
				var v = (val/127).postln;
				nm.postln;
				if (nm==1,{
					~out.set(\db,(v*2).ampdb);

				});
				if (nm==2,{
					v= ((v*v*v*v)*23000).clip(10,23000);
					v.postln;
					~out.set(\lpf, v);
				});
				if (nm==3,{
					v= ((v*v*v*v)*23000).clip(10,23000);
					v.postln;
					~out.set(\hpf, v);
				});
				if (nm==4,{
					~out.set(\reverb, v);
				});

			},msgType:\control);
		);

	}

	*boot {
		|superdirt=false,outSynth=true|
		var cmdPFunc;
		Server.default.options.memSize =32768/2;
		Server.default.options.numBuffers = 1024*4;

		if(superdirt,{
			Server.default.waitForBoot({
				SuperDirt.start(numOrbits:4);
				Jam.loadSuperDirtSynths;
			});
		},{

			Server.default.waitForBoot({

				if(outSynth ,{
					~outBus = Bus.audio(Server.default,2);
					(Platform.userAppSupportDir++"/Extensions/SuperCollider-Extensions/Synths.scd").loadPaths;
					MIDIClient.init;
					MIDIIn.connectAll;

					cmdPFunc = {
						"Adding new out synth".postln;
						Tdef(\uhg,{
							0.1.wait;
							~out = Synth.new(\out);
							// MIDIIn.connectAll;
							(
								/*								MIDIdef(\lpd8Vol,{
								|val,nm,chan,src|
								var v = (val/127).postln;
								("num: "+nm).postln;
								if (nm==1,{
								~out.set(\db,(v*v).ampdb);
								});
								if (nm==2,{
								v= ((v*v*v*v)*22000).clip(10,22000);
								v.postln;
								~out.set(\lpf, v);
								});
								if (nm==3,{
								v= ((v*v*v*v)*22000).clip(10,22000);
								v.postln;
								~out.set(\hpf, v);
								});
								if (nm==4,{
								~out.set(\reverb, v);
								});
								},msgType:\control);*/
							);
						}).play;
					};
					CmdPeriod.add(cmdPFunc);
					cmdPFunc.value();
				},{
					~outBus = 0;
					(Platform.userAppSupportDir++"/Extensions/SuperCollider-Extensions/Synths.scd").loadPaths;
				});
			});
		});
		/*Tdef(\dumb,{
		Server.default.options.memSize =32768;
		Server.default.boot;
		3.wait;

		(Platform.userAppSupportDir++"/Extensions/SuperCollider-Extensions/Synths.scd").loadPaths;
		MIDIClient.init;
		MIDIIn.connectAll;
		cmdPFunc = {
		~out = Synth.new(\out);
		// MIDIIn.connectAll;
		(
		MIDIdef(\lpd8Vol,{
		|val,nm,chan,src|
		var v = (val/127).postln;
		nm.postln;
		if (nm==1,{
		~out.set(\db,(v*2).ampdb);

		});
		if (nm==2,{
		v= ((v*v*v*v)*23000).clip(10,23000);
		v.postln;
		~out.set(\lpf, v);
		});
		if (nm==3,{
		v= ((v*v*v*v)*23000).clip(10,23000);
		v.postln;
		~out.set(\hpf, v);
		});
		if (nm==4,{
		~out.set(\reverb, v);
		});
		},msgType:\control);
		);
		};
		CmdPeriod.add(cmdPFunc);
		cmdPFunc.value();
		}).play;*/
	}

	*startOutSynth{
		Synth(\out);
	}

	*setLpf {
		|lpf,resonance|
		~out.set([\lpf,lpf]);
		~out.set([\resonance, resonance]);
	}

	*setDb {
		|db|
		~out.set([\db,db]);
	}

	*getTenLines{

		var a=Document.current.selectionStart;
		var str = Document.current.string;
		var b=str[a];
		var i =a;
		var counter =0;
		var decrementer = a;

		while({(counter<10)&&(decrementer>(-5))},{
			if((b == Char.nl),{counter=counter+1});
			decrementer = decrementer-1;
			b=str[decrementer];
		});

		^Document.current.getSelectedLines(decrementer, 10000);
	}

	*connectLPD8{

		MIDIClient.init;
		MIDIIn.connectAll;

		~note = 0;
		~vel = 0;
		~pulse=0;
		~k = 0!9;

		MIDIdef(\lpd8on,{
			|val,nm,chan,src|
			~pulse = 1;
			~note = nm-36;
			~vel = val;
		},msgType:'noteOn');

		MIDIFunc.noteOff({~pulse=0;});

		MIDIFunc.cc({
			arg val,nm;
			~k[nm]=val/127;
		});

	}

	*lpd8PatternController{

		var width = 800/(3/2);
		var height = 200/(3/2);
		var patterns = Object!8;
		var cc = (-80.dbamp)!8;
		var windowBounds = Rect(0,0,width,height);
		var patternTextFields = (Object!8);

		var window = Window("LPD8",windowBounds);

		MIDIClient.init;
		MIDIIn.connectAll;

		window.front;



		for(0,7,{
			|i|
			var left = ((width/8)*(i%4)+(width/20/8));
			// var textBounds = Rect(left:(width/8)*(i%4)+(width/20/8),top: 0.2*height+(60*((i/4).floor)),width: (9/10)*(width/8),height: 25);
			var textBounds = Rect(left:left,top: 0.2*height+(60*((i/4).floor)),width: (9/10)*(width/8),height: 25);
			// var staticTextBounds = Rect(left:left,top:0.15*height-20+60*((i/4).floor), width:(9/10)*(width/8),height: 25);
			var staticTextBounds = Rect(left:((width/8)*(i%4))+((width/20)/8)+(((9/10)*(width/8))/2),top:0.15*height-20+60*((i/4).floor), width:(9/10)*(width/8),height: 25);
			var staticText = StaticText(window, staticTextBounds);

			staticText.string = (((i+4)%8)+1).asString;
			patternTextFields[i]=TextField(window,textBounds);
			patternTextFields[i].keyDownAction = {
				|doc, char, mod, unicode, keycode, key|
				if((mod==1048576)&& (key==16777220),{
					patterns[((i+4)%8)] = Pdef(patternTextFields[i].string.asSymbol);
					Pbindef(patterns[((i+4)%8)].key).quant=0.5;
					Pbindef(patterns[((i+4)%8)].key,\db,Pfunc({cc[((i))]}));
				});
			};


		});




		MIDIdef(\lpd8Triggers,{
			|val,nm,chan,src|
			var j = (nm/12).floor;
			nm = ((nm+4)%8);
			// if(patterns[j][nm-1].isPlaying, {patterns[j][nm-1].stop;},  {patterns[j][nm-1].play;});
			nm.postln;
			patterns[nm].postln;
			if(patterns[nm].isPlaying, {patterns[nm].stop;},{patterns[nm].play;})
		},msgType:\noteOn,srcID:1627846547
		);

		MIDIdef(\launchKeyMiniCC,{
			|val,nm,chan,src|

			val = val.linexp(0,127,0.0001,1).ampdb;
			val.postln;
			cc[nm-1]=val;
		},msgType:\control,srcID:1627846547
		);
	}

	*fireMeUp{
		|phoneIP,deviceOSCPort=9000,recvPort=9000|
		InterfaceGUI("Tablet",phoneIP, deviceOSCPort, recvPort, 6,16,1,1,false);
		Jam.lpd8PatternController();
		Jam.launchKeyGui();
	}

	*startEsp{

		TempoClock.default=EspClock.new.start;
		Tdef(\k,{1.wait;
			"Tempo: ".post;
			(TempoClock.tempo*60).postln;

		}).play;
	}

	*duet{

		Server.local.options.device = "Dante Virtual Soundcard";
		Server.local.options.sampleRate = 48000;
		Server.local.options.numOutputBusChannels = 16;
		Server.local.waitForBoot({
			Server.default = Server.local;
			Jam.afterBoot;
		});
	}

	*havn{

		Server.local.options.device = "MOTU UltraLite mk3 Hybrid";
		Server.local.options.numOutputBusChannels = 8;
		Server.default = Server.local;
		Server.local.waitForBoot({
			Pbindef(\perc,\out, (0..7));
			Pbindef(\bass,\out, (0..7));
		});
	}

	*launchKeyGui{
		|width=600,height=200|

		var patterns = Object!8;
		var synthDefs = ''!8;
		var currentSynth= 'default';
		var synths = Object!127;
		var cc = (-80.dbamp)!8;
		var windowBounds = Rect(0,0,width,height);
		var patternTextFields = Object!8;
		var synthDefTextFields = ''!8;

		var window = Window("Launch Key",windowBounds);
		~really = 0.001;
		MIDIClient.init;
		MIDIIn.connectAll;

		window.front;

		for(0,7,{
			|i|
			var textBounds = Rect((width/8)*i+(width/20/8),0.1*height, (9/10)*(width/8), 25);
			var staticTextBounds = Rect(((width/8)*i)+((width/20)/8)+(((9/10)*(width/8))/2),0.1*height-20, (9/10)*(width/8), 25);
			var staticText = StaticText(window, staticTextBounds);
			staticText.string = (i+1).asString;
			patternTextFields[i]=TextField(window,textBounds);
			patternTextFields[i].keyDownAction = {
				|doc, char, mod, unicode, keycode, key|
				if((mod==1048576)&& (key==16777220),{
					patterns[i] = Pdef(patternTextFields[i].string.asSymbol);
					Pbindef(patterns[i].key).quant=0.5;
					Pbindef(patterns[i].key,\db,Pfunc({cc[i]}));
				});
			};


		});


		for(0,7,{
			|i|
			var textBounds = Rect((width/8)*i+(width/20/8),0.9*height-20, (9/10)*(width/8), 25);
			var staticTextBounds = Rect(((width/8)*i)+((width/20)/8)+(((9/10)*(width/8))/2),0.9*height, (9/10)*(width/8), 25);
			var staticText = StaticText(window, staticTextBounds);
			staticText.string = (i+9).asString;
			synthDefTextFields[i]=TextField(window,textBounds);
			synthDefTextFields[i].keyDownAction = {synthDefs[i] = synthDefTextFields[i].string.asSymbol;};


		});

		/*	for(0,7,{
		|i|


		});*/

		MIDIdef(\keyboardOn,{
			|val,nm,chan,src|
			val = val.linexp(0,127,-60.dbamp,0.dbamp);
			synths[nm] = Synth(currentSynth,[freq:nm.midicps,gate:1,amp:val]);

			[val,nm,chan,src].postln;

		},msgType:\noteOn,chan:0,srcID:2002797388);

		MIDIdef(\keyboardOff,{
			|val,nm,chan,src|

			synths[nm].set(\gate,0);

			[val,nm,chan,src].postln;

		},msgType:\noteOff,chan:0,srcID:2002797388);

		MIDIdef(\launchKeyMini,{
			|val,nm,chan,src|

			if (((nm<40) && (nm>35)),{nm=nm-27});
			if (((nm>39) && (nm<44)),{nm=nm-39});
			if (((nm>47) && (nm<52)),{nm=nm-43});
			if (((nm>43) && (nm <48)), {nm=nm-31});
			//If its a performance pad:
			if ((nm<9),{
				if(patterns[nm-1].isPlaying, {patterns[nm-1].stop;},  {patterns[nm-1].play;});
			},
			{
				currentSynth = synthDefs[nm-9];
			}
			);

			[val,nm,chan,src].postln;
		},msgType:\noteOn,chan:9,srcID:2002797388
		);

		MIDIdef(\launchKeyMiniCC,{
			|val,nm,chan,src|
			nm = nm-20;
			val = val.linexp(0,127,0.0001,1).ampdb;

			// val = (val*val*val*val/(127*127*127*127)).ampdb;
			/*
			Pbindef(patterns[nm-1].key).quant=0;
			Pbindef(patterns[nm-1].key, \db, Pfunc({val},1));
			Pbindef(patterns[nm-1].key).stop;
			Pbindef(patterns[nm-1].key).play;
			Pbindef(patterns[nm-1].key).quant = 0.5;*/
			cc[nm-1]= val;
			patterns[nm-1].key.postln;
			// Pbindef(patterns[i].key,\db,Pfuncn(cc[i],inf));
			// Pbindef(patterns[nm-1].key,\db,Pfuncn({cc[nm-1]},inf));
			[val,nm,chan,src].postln;
		},msgType:\control,srcID:2002797388
		);
		// Pdef(patterns[0].key,\db,Pfunc({cc[0]}));
	}

	*afterBootLiveLab {
		fork {
			Pdefn(\front,Pxrand([0,1,2],inf));
			Pdefn(\back,Pxrand([8,9,10],inf));
			//Pdefn(\left,Pxrand([],inf));
			//Pdefn(\right,Pxrand([],inf));
			Pdefn(\backandforth,Pseq([0,8],inf)+Pxrand([0,1,2],inf));
			Server.default.recChannels = 16;
			1.wait;
			Server.default.prepareForRecord;
			1.wait;
			Server.default.record;
			Pbindef(\ambient,\out,(0..15));
			Pbindef(\bass,\out,(0..15));
			Pbindef(\perc,\out,Pxrand((0..15),inf));
			Pbindef(\light,\out,Pxrand((0..15),inf));
		}
	}


	*setMelody{
		|notes|
		Pdef(\m, Pbind(\midinote, Pseq(notes,inf)));
	}

	*loadSuperDirtSynths{
		Platform.case(
			\osx, {(Platform.userAppSupportDir++"/Extensions/SuperCollider-Extensions/SuperDirtSynths.scd").loadPaths;},
			\linux, {(Platform.userAppSupportDir++"/Extensions/SuperCollider-Extensions/SuperDirtSynths.scd").loadPaths;},
			\windows, {(Platform.userAppSupportDir++"\\Extensions\\SuperCollider-Extensions\\SuperDirtSynths.scd").loadPaths;}
		);
	}

	*loadSynths{

		Server.default = Server.local;



		Server.default.waitForBoot({

			Platform.case(
				\osx, {			Routine({
					(Platform.userAppSupportDir++"/Extensions/SuperCollider-Extensions/Instruments.scd").loadPaths;
					(Platform.userAppSupportDir++"/Extensions/SuperCollider-Extensions/SampleBuffers.scd").loadPaths;
					2.wait;
					(Platform.userAppSupportDir++"/Extensions/SuperCollider-Extensions/SampleInstruments.scd").loadPaths;
					(Platform.userAppSupportDir++"/Extensions/SuperCollider-Extensions/SuperDirtSynths.scd").loadPaths;
				}).play},
				\linux, {Routine({
					(Platform.userAppSupportDir++"/Extensions/SuperCollider-Extensions/Instruments.scd").loadPaths;
					(Platform.userAppSupportDir++"/Extensions/SuperCollider-Extensions/SampleBuffers.scd").loadPaths;
					2.wait;
					(Platform.userAppSupportDir++"/Extensions/SuperCollider-Extensions/SampleInstruments.scd").loadPaths;
					(Platform.userAppSupportDir++"/Extensions/SuperCollider-Extensions/SuperDirtSynths.scd").loadPaths;
				}).play},
				\windows, {		Tdef(\a,{
					(Platform.userAppSupportDir.asString++"\\Extensions\\SuperCollider-Extensions\\Instruments.scd").loadPaths;
					(Platform.userAppSupportDir++"\\Extensions\\SuperCollider-Extensions\\SampleBuffers.scd").loadPaths;
					2.wait;
					(Platform.userAppSupportDir++"\\Extensions\\SuperCollider-Extensions\\SampleInstruments.scd").loadPaths;
					(Platform.userAppSupportDir++"\\Extensions\\SuperCollider-Extensions\\SuperDirtSynths.scd").loadPaths;
			}).play;});



		});
	}


	*fadeParam{
		|pattern,key,start,second,end|
		Pbindef(pattern,key,Pseq([Pseq((start,second..end),1),Pseq([end],inf)],1));
	}


	*stop{
		|key,time=0|

		Tdef(\stop,{

			40.do({
				//This is an arbitrary amount of time, didn't feel like calculating.
				(time/10).wait;
				Pbindef(key,\db-1);
			});

			Pbindef(\key).stop;
		}
		).play;

	}

	*crash{
		|time|


		Tdef(\crash,
			{
				1016.do({
					(instrument:\crash).play;
					(time/1016).wait;
				});

			}
		).play;


	}

	*d1{
		|patternName,patternType,pattern,slow=1,degradeBy=0|
		var e=Jam.spreadDurations(pattern);
		var instPat=pattern.flat;
		var randomPattern=[];

		for(0,pattern.flat.size-1,{
			arg i;
			randomPattern=randomPattern.add(Pwrand([instPat[i],\rest],[1-degradeBy,degradeBy],1));
		});


		if( degradeBy!=0,{
			Pbindef(patternName,patternType,Pseq(randomPattern,inf),\dur, Pseq(e*slow,inf)).play;});

		if( degradeBy==0,{Pbindef(patternName,patternType,Pseq(pattern.flat,inf),\dur, Pseq(e*slow,inf)).play;	});


		Jam.layers = Jam.layers.add(Pbindef(patternName));
	}

	*stopAll{
		for(0, Jam.layers.size,{arg i;
			Jam.layers[i].stop;
		});
	}

	*spreadDurations{
		|a|
		var d=[];
		var b=[];
		for(0,a.size-1,{
			arg i;
			if (a[i].class==Array,
				{
					b = Jam.spreadDurations(a[i]);
					for(0,b.size-1,{
						arg j;
						if(b[j].class==Float,{b[j]=b[j]/a.size});
						d=d.add(b[j]);
					});//End internal for loop
			});//End of if type == Array
			if(a[i].class!=Array,{d=d.add(TempoClock.tempo/a.size);})
		});
		//Return d
		^d;

	}

	*sequencer{
		"/Users/JamieBeverley/Desktop/SuperCollider Stuff/GUIbeat sequencer.scd".loadPaths;
	}

	*words{
		|string|

		var splitList = string.split($ ).asList;
		var result = List[];
		for(0,splitList.size-1,{
			arg i;
			if((splitList[i]!="") && (splitList[i]!=" "),{result.add(splitList[i]);});

		});

		// for(0 ,result.size-1, {
		// 	arg i;
		// 	//if first char is a bracket and last char is a number,
		// 	//question mark, closing bracket
		// 	if ( (result[i][0] == ($[)) && ("]*/123456789".contains(result[i][result[i].size].asString)),{
		// 		"lol".postln;
		// 	});
		// });

		^result;


	}

	*parseList{
		|list|
		var result = List[];
		var i =0;

		while( {i<(list.size-1);},{

			var rightBracketCounter=0;
			list[i].postln;

			if((list[i].contains("[")),{

				var l = i+1;
				rightBracketCounter=1;

				while({rightBracketCounter>0},{

					if((list[l].contains("[")),{rightBracketCounter=rightBracketCounter+1;});
					if((list[l].contains("]")),{rightBracketCounter=rightBracketCounter-1;});

					l=l+1;
				});
				result.add(Jam.parseList(Jam.subList(list,i,l)));

				i=l+1;
			});

			if((list[i].contains("[")).not,{result.add(list[i])});
			i=i+1;
		});
		^result;
	}
	/*	*parseListString{
	|list|
	var string =list.asArray.asString;
	resultlist = List[];
	acc = "";
	breakPoints= string.findAll(",",false,0)++string.findAll("[",false,1);
	breakPoints= breakPoints.sort
	offset = 0;
	for(1,string.size-2,{
	arg i;

	if (breakPoints.contains(i),




	});

	}*/

	*subList{
		|list,beg,end|
		var newList=List[];
		for(end,beg,{
			arg i;
			newList.add(list[i]);
		});
		^newList.reverse
	}


	*bootVolca{

		var synth;
		var quant = 4;
		var noteDowns = false!4;
		var effects = [\amp,\lpf,\hpf,\pan,\reverb,\room,\pitch,\unassigned];
		var defaultLastLoop=4;
		var lastLoop=defaultLastLoop;
		Server.default.waitForBoot({
			MIDIIn.connectAll;
			Routine({
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
						// audio = Compander.ar(audio,audio,-20.dbamp,slopeBelow:1.5);
						Out.ar(0,Pan2.ar(audio,pan));
					}
				).add;
				1.wait;
				synth= Synth(\volca_beats);

				MIDIdef.noteOn(\volca_beats_lpd8_loopOn,
					{
						|vel,note|
						var dur =((((TempoClock.beats*quant).ceil)/quant)-TempoClock.beats);
						note = note-60+1;
						lastLoop=note;
						noteDowns[note-1]=true;

						Routine{
							(dur*TempoClock.tempo).wait;
							synth.set(\loop,note);
							"played".postln;
						}.play;
					},(60..63)
				);
				MIDIdef.noteOff(\volca_beatss_lpd8_loopOff,
					{
						|vel, note|
						var dur = ((((TempoClock.beats*quant).ceil)/quant)-TempoClock.beats);
						note = note-60+1;
						noteDowns[note-1 ]=false;
						Routine{
							(dur*TempoClock.tempo).wait;
							if( (noteDowns[0]||noteDowns[1]||noteDowns[2]||noteDowns[3]).not, {
								synth.set(\loop,0);
								lastLoop=defaultLastLoop;
							});
						}.play;
					},(60..63)
				);


				MIDIdef.cc(\volca_beats_lpd8_effects,{
					|val,k|

					switch(k,
						1,{synth.set(\amp,(val*20+16)/127)},
						2,{synth.set(\lpf,((val*val/127/127)*24000).clip(20,24000))},
						3,{synth.set(\hpf,((val*val/127/127)*24000).clip(20,24000))},
						4,{synth.set(\pan, ((val/127)*2)-1 )},
						5,{synth.set(\reverb, (val/127))},
						6,{synth.set(\room, (val/127))},
						7,{synth.set(\pitch, ((val/127)*12).round/12)},
						8,{}
					);

				}
				);
				"volca booted".postln;
			}).play;
		});
	}

	*deadMidi{
		var on, off, cc, osc, lpd8;
		MIDIClient.init;

		// MidiOut
		~minilogue = MIDIOut.newByName("Tbox 2X2", "Tbox 2X2 MIDI 1");
		~dirt.soundLibrary.addMIDI(\minilogue, ~minilogue);
		~volca = MIDIOut.newByName("Tbox 2X2", "Tbox 2X2 MIDI 2");
		~dirt.soundLibrary.addMIDI(\volca, ~volca);

		// MIDIIn
		MIDIClient.sources.do{
			|i,index|
			if(i.asString=="MIDIEndPoint(\"LPD8\", \"LPD8 MIDI 1\")",{lpd8=index});
		};
		if(lpd8!=nil,{

		MIDIIn.connect(inport:lpd8,device:MIDIClient.sources.at(lpd8));
		},{
			"LPD8 MIDI controller not found".warn;
		});
		osc = NetAddr.new("127.0.0.1", 6010);

		on = MIDIFunc.noteOn({ |val, num, chan, src|
			osc.sendMsg("/ctrl", num.asString, val/127);
		},);

		off = MIDIFunc.noteOff({ |val, num, chan, src|
			osc.sendMsg("/ctrl", num.asString, 0);
		});

		cc = MIDIFunc.cc({ |val, num, chan, src|
			osc.sendMsg("/ctrl", num.asString, val/127);
		});

		if (~stopMidiToOsc != nil, {
			~stopMidiToOsc.value;
		});

		~stopMidiToOsc = {
			on.free;
			off.free;
			cc.free;
		};
	}

	*superDirt{
		Server.default.options.memSize = 16384;
		Server.default.latency = 0.4;
		SuperDirt.start(server:Server.default);
		Jam.loadSuperDirtSynths;
	}

	*smartphoneSoundscapes{
		|processingPort=9003, nodePort=9000,visuals=false|
		var processing = NetAddr.new("127.0.0.1", processingPort);
		var node = NetAddr.new("127.0.0.1",port: nodePort);
		var r=255;
		var g=255;
		var b=255;


		OSCdef(\audience,{
			|msg|
			var sus, legato, dur, cps, delta;
			var sample = "";
			// msg.postln;
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

			// processing.sendMsg("/sound",sample,dur);
			// processing.sendMsg("/backgroundColor",r,g,b);

			node.sendBundle(0,["/play"]++(msg[1..]));

		},path:'/play2',recvPort:57130);
		if(visuals,{
			OSCdef(\visuals,{
				|msg|
				var sus, legato, dur, cps, delta;
				var sample = "";
				// msg.postln;
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
			},path:'/play2',recvPort:NetAddr.langPort);
		});
	}

	// *superDirt{
	// 	|numChannels=2, numOrbits=3, port=57120,sendAddr,path,visuals=false,visualsNetAddr,debug=false|
	//
	//
	// 	var cmdPFunc;
	// 	Server.default.options.memSize =32768;
	// 	Server.default.options.numBuffers = 1024*8;
	//
	//
	// 	Server.default.waitForBoot({
	// 		SuperDirt.start(numChannels:numChannels,numOrbits:numOrbits,port:port,sendAddr:sendAddr,path:path);
	// 		Jam.loadSuperDirtSynths;
	// 	});
	//
	//
	// 	if(visuals,{
	// 		if(visualsNetAddr.isNil,{visualsNetAddr = NetAddr.new("127.0.0.1",9000)});
	//
	// 		cmdPFunc = {
	//
	// 			OSCdef(\visuals,{
	// 				|msg|
	// 				if(debug,{msg.postln;});
	// 				msg[0] = '/tidal';
	// 				Routine({
	// 					0.2.wait;
	// 					visualsNetAddr.sendBundle(0,msg);
	// 				}).play;
	// 			},path:'/play2',recvPort:port);
	// 			"adding visuals oscdef".postln;
	// 		};
	// 		cmdPFunc.value();
	// 		CmdPeriod.add(cmdPFunc);
	// 	});
	//
	//
	// }


}