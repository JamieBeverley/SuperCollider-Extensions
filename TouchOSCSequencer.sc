TouchOSCSequencer : Object{

	classvar <>numSequencers=0;

	var <>deviceIP;
	var <>deviceOSCPort;
	var <>phoneAddr;
	var <>numInstruments;
	var <>seqLength;
	var <>page;
	var <>instruments;
	var <>instrumentArray;
	var <>midiNoteArray;
	var <>recvOSCPort;
	var <>slow;
	var <>volumeFaders; // Bool
	var <>volArray;
	*initClass{

	}

	*new{
		|phoneIP, deviceOSCPort=9000, recvPort,numInstruments=5, seqLength=8,page=1, slow=1, volumeFaders=false|
		TouchOSCSequencer.numSequencers=TouchOSCSequencer.numSequencers+1;
		^super.new.init(phoneIP,deviceOSCPort,recvPort,numInstruments, seqLength,page,slow,volumeFaders);
	}

	init{
	|phoneIP, oscPort=9000,recvPort,numInstruments,seqLength,page,slow,volumeFaders|

		this.deviceIP = phoneIP;
		this.deviceOSCPort=oscPort;
		this.recvOSCPort = recvPort;
		this.numInstruments=numInstruments;
		this.seqLength=seqLength;
		this.page = page;
		this.phoneAddr = NetAddr.new(hostname:phoneIP, port:oscPort);
		this.instruments = 'bds'!(this.numInstruments);
		this.instrumentArray = Array.fill2D(this.numInstruments,this.seqLength,'rest');
		this.midiNoteArray = Array.fill2D(this.numInstruments, this.seqLength,48);
		this.slow=slow;
		this.volumeFaders=volumeFaders;

		this.phoneAddr.hostname.postln;
		this.phoneAddr.port.postln;



		if (this.volumeFaders==true,{
			volArray = Array.fill(16,(-20));
			for (1,this.seqLength,{
				|i|
				OSCFunc({
					|msg|
					this.volArray[i-1] = Pfuncn({msg[1]},1);
					this.volArray.postln;
				},("/"++this.page++"/multifader1/"++i),recvPort:this.recvOSCPort);

			});
		});

		if (this.volumeFaders==false,{this.volArray=[-20];});


		for (0,this.numInstruments-1,{
			arg i;
			var pFuncList= Array.new();
			for (0,this.seqLength-1,{
				|j|

				pFuncList = pFuncList.add(Pfuncn({this.instrumentArray[i][j]},1));

				OSCFunc({
					|msg|
					this.instruments[i].postln;
					if (msg[1]==1, {this.instrumentArray[i][j]=this.instruments[i]});
					if (msg[1]==0, {this.instrumentArray[i][j]=\rest;});

				}, ("/"++this.page++"/multitoggle1/"++(i+1)++"/"++(j+1)),recvPort:this.recvOSCPort);


			});

			Jam.d1((i.asString++numSequencers).asSymbol, pFuncList,slow:this.slow);
			Pbindef((i.asString++numSequencers).asSymbol, \midinote, Pseq([Pfunc({this.midiNoteArray[i]})].flatten,inf), \db, Pseq(this.volArray,inf));
		});

		Tdef("leds"++numSequencers,{
			loop{
				for(1,this.seqLength,{
					|i|
					this.phoneAddr.sendMsg((this.page.asSymbol++'/led'++i.asSymbol),1);
					(this.slow*(TempoClock.tempo/seqLength)).wait;
					this.phoneAddr.sendMsg((this.page.asSymbol++'/led'++i.asSymbol),0);

				});
			}
		}).play;

	}//End init

}