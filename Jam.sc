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
		// Pdef(patterns[0].key,\db,Pfunc({cc[0]}));

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

	*loadSynths{

		Server.default = Server.local;


		Server.default.waitForBoot({
			(Platform.userAppSupportDir.asString++"\\Extensions\\supercollider-Extensions\\Instruments.scd").loadPaths
/*
			Tdef (\work, {
				"/Users/JamieBeverley/Desktop/SuperCollider Stuff/LoadPaths/SampleBuffers.scd".loadPaths;
				(Platform.userAppSupportDir.asString++"\\Extensions\\supercollider-Extensions\\Instruments.scd").loadPaths
				2.wait;
				"/Users/JamieBeverley/Desktop/SuperCollider Stuff/LoadPaths/SampleInstruments.scd".loadPaths;
			}).play;*/
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



}