Jam{

	classvar <>layers;

	*initClass{

		"@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@".postln;

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

	*afterBoot {
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
			"/Users/JamieBeverley/Desktop/SuperCollider Stuff/Instruments.scd".loadPaths;
			//"/Users/JamieBeverley/InstrumentsSend.scd".loadPaths;


			Tdef (\work, {
				"/Users/JamieBeverley/Desktop/SuperCollider Stuff/LoadPaths/SampleBuffers.scd".loadPaths;
				2.wait;
				"/Users/JamieBeverley/Desktop/SuperCollider Stuff/LoadPaths/SampleInstruments.scd".loadPaths;
			}).play;
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
		|patternName,instrumentPattern,slow=1,degradeBy=0,db=(-20)|
		var e=Jam.spreadDurations(instrumentPattern);
		var instPat=instrumentPattern.flat;
		var randomPattern=[];

		for(0,instrumentPattern.flat.size-1,{
			arg i;
			randomPattern=randomPattern.add(Pwrand([instPat[i],\rest],[1-degradeBy,degradeBy],1));
		});


		if( degradeBy!=0,{
			Pbindef(patternName,\db,db,\instrument,Pseq(randomPattern,inf),\dur, Pseq(e*slow,inf)).play(quant:instrumentPattern.flatten.size);});

		if( degradeBy==0,{Pbindef(patternName,\db,db,\instrument,Pseq(instrumentPattern.flat,inf),\dur, Pseq(e*slow,inf)).play(quant:instrumentPattern.flatten.size);	});


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