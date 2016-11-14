TabletTouchOSCSequencer : Object{

	classvar <>numSequencers=0;

	var <>deviceIP;
	var <>deviceOSCPort;
	var <>phoneAddr;
	var <>instruments;
	var <>instrumentArray;
	var <>midiNoteArray;
	var <>recvOSCPort;

	*initClass{

	}

	*new{
		|phoneIP, deviceOSCPort=9000, recvPort|
		TouchOSCSequencer.numSequencers=TouchOSCSequencer.numSequencers+1;
		^super.new.init(phoneIP,deviceOSCPort,recvPort);
	}

	init{
	|phoneIP, oscPort=9000,recvPort|

		this.deviceIP = phoneIP;
		this.deviceOSCPort=oscPort;
		this.recvOSCPort = recvPort;

		this.phoneAddr = NetAddr.new(hostname:phoneIP, port:oscPort);
		this.instruments = ['bds','sn2','clak','fut','womp','string'];
		this.instrumentArray = Array.fill2D(6,16,'rest');
		this.midiNoteArray = Array.fill2D(6,16,48);

		this.phoneAddr.hostname.postln;
		this.phoneAddr.port.postln;
		for (0,5,{
			arg i;
			for (0,15,{
				|j|
				OSCFunc({
					|msg|
					"oscrecieved".postln;
					this.instruments[i].postln;
					if (msg[1]==1, {this.instrumentArray[i][j]=this.instruments[i]});
					if (msg[1]==0, {this.instrumentArray[i][j]=\rest;});
				}, "1/multitoggle1/"++(i+1)++"/"++(j+1),recvPort:this.recvOSCPort);
			});

		});


		Jam.d1(("onet"++numSequencers).asSymbol,[Pfuncn({this.instrumentArray[0][0]},1), Pfuncn({this.instrumentArray[0][1]},1), Pfuncn({this.instrumentArray[0][2]},1), Pfuncn({this.instrumentArray[0][3]},1), Pfuncn({this.instrumentArray[0][4]},1), Pfuncn({this.instrumentArray[0][5]},1), Pfuncn({this.instrumentArray[0][6]},1), Pfuncn({this.instrumentArray[0][7]},1),Pfuncn({this.instrumentArray[0][8]},1),Pfuncn({this.instrumentArray[0][9]},1),Pfuncn({this.instrumentArray[0][10]},1),Pfuncn({this.instrumentArray[0][11]},1),Pfuncn({this.instrumentArray[0][12]},1),Pfuncn({this.instrumentArray[0][13]},1),Pfuncn({this.instrumentArray[0][14]},1),Pfuncn({this.instrumentArray[0][15]},1)]);

		Pbindef(("onet"++numSequencers).asSymbol, \midinote, Pseq([Pfunc({this.midiNoteArray[0]})].flatten,inf));

		Jam.d1(("twot"++numSequencers).asSymbol,[Pfuncn({this.instrumentArray[1][0]},1), Pfuncn({this.instrumentArray[1][1]},1), Pfuncn({this.instrumentArray[1][2]},1), Pfuncn({this.instrumentArray[1][3]},1), Pfuncn({this.instrumentArray[1][4]},1), Pfuncn({this.instrumentArray[1][5]},1), Pfuncn({this.instrumentArray[1][6]},1), Pfuncn({this.instrumentArray[1][7]},1), Pfuncn({this.instrumentArray[1][8]},1), Pfuncn({this.instrumentArray[1][9]},1), Pfuncn({this.instrumentArray[1][10]},1), Pfuncn({this.instrumentArray[1][11]},1), Pfuncn({this.instrumentArray[1][12]},1), Pfuncn({this.instrumentArray[1][13]},1), Pfuncn({this.instrumentArray[1][14]},1), Pfuncn({this.instrumentArray[1][15]},1)]);

		Pbindef(("twot"++numSequencers).asSymbol,\midinote,Pseq([Pfunc({this.midiNoteArray[1]})].flatten,inf));

		Jam.d1(("threet"++numSequencers).asSymbol,[Pfuncn({this.instrumentArray[2][0]},1), Pfuncn({this.instrumentArray[2][1]},1), Pfuncn({this.instrumentArray[2][2]},1), Pfuncn({this.instrumentArray[2][3]},1), Pfuncn({this.instrumentArray[2][4]},1), Pfuncn({this.instrumentArray[2][5]},1), Pfuncn({this.instrumentArray[2][6]},1), Pfuncn({this.instrumentArray[2][7]},1), Pfuncn({this.instrumentArray[2][8]},1), Pfuncn({this.instrumentArray[2][9]},1), Pfuncn({this.instrumentArray[2][10]},1), Pfuncn({this.instrumentArray[2][11]},1), Pfuncn({this.instrumentArray[2][12]},1), Pfuncn({this.instrumentArray[2][13]},1), Pfuncn({this.instrumentArray[2][14]},1), Pfuncn({this.instrumentArray[2][15]},1)]);

		Pbindef(("threet"++numSequencers).asSymbol,\midinote,Pseq([Pfunc({this.midiNoteArray[2]})].flatten,inf));


		Jam.d1(("fourt"++numSequencers).asSymbol,[Pfuncn({this.instrumentArray[3][0]},1), Pfuncn({this.instrumentArray[3][1]},1), Pfuncn({this.instrumentArray[3][2]},1), Pfuncn({this.instrumentArray[3][3]},1), Pfuncn({this.instrumentArray[3][4]},1), Pfuncn({this.instrumentArray[3][5]},1), Pfuncn({this.instrumentArray[3][6]},1), Pfuncn({this.instrumentArray[3][7]},1), Pfuncn({this.instrumentArray[3][8]},1), Pfuncn({this.instrumentArray[3][9]},1), Pfuncn({this.instrumentArray[3][10]},1), Pfuncn({this.instrumentArray[3][11]},1), Pfuncn({this.instrumentArray[3][12]},1), Pfuncn({this.instrumentArray[3][13]},1), Pfuncn({this.instrumentArray[3][14]},1), Pfuncn({this.instrumentArray[3][15]},1)]);

		Pbindef(("fourt"++numSequencers).asSymbol,\midinote,Pseq([Pfunc({this.midiNoteArray[3]})].flatten,inf));

		Jam.d1(("fivet"++numSequencers).asSymbol,[Pfuncn({this.instrumentArray[4][0]},1), Pfuncn({this.instrumentArray[4][1]},1), Pfuncn({this.instrumentArray[4][2]},1), Pfuncn({this.instrumentArray[4][3]},1), Pfuncn({this.instrumentArray[4][4]},1), Pfuncn({this.instrumentArray[4][5]},1), Pfuncn({this.instrumentArray[4][6]},1), Pfuncn({this.instrumentArray[4][7]},1), Pfuncn({this.instrumentArray[4][8]},1), Pfuncn({this.instrumentArray[4][9]},1), Pfuncn({this.instrumentArray[4][10]},1), Pfuncn({this.instrumentArray[4][11]},1), Pfuncn({this.instrumentArray[4][12]},1), Pfuncn({this.instrumentArray[4][13]},1), Pfuncn({this.instrumentArray[4][14]},1), Pfuncn({this.instrumentArray[4][15]},1)]);

		Pbindef(("fivet"++numSequencers).asSymbol,\midinote,Pseq([Pfunc({this.midiNoteArray[4]})].flatten,inf));

		Jam.d1(("sixt"++numSequencers).asSymbol,[Pfuncn({this.instrumentArray[5][0]},1), Pfuncn({this.instrumentArray[5][1]},1), Pfuncn({this.instrumentArray[5][2]},1), Pfuncn({this.instrumentArray[5][3]},1), Pfuncn({this.instrumentArray[5][4]},1), Pfuncn({this.instrumentArray[5][5]},1), Pfuncn({this.instrumentArray[5][6]},1), Pfuncn({this.instrumentArray[5][7]},1), Pfuncn({this.instrumentArray[5][8]},1), Pfuncn({this.instrumentArray[5][9]},1), Pfuncn({this.instrumentArray[5][10]},1), Pfuncn({this.instrumentArray[5][11]},1), Pfuncn({this.instrumentArray[5][12]},1), Pfuncn({this.instrumentArray[5][13]},1), Pfuncn({this.instrumentArray[5][14]},1), Pfuncn({this.instrumentArray[5][15]},1)]);

		Pbindef(("sixt"++numSequencers).asSymbol,\midinote,Pseq([Pfunc({this.midiNoteArray[5]})].flatten,inf));

		Tdef("ledst"++numSequencers,{
			loop{
				this.phoneAddr.sendMsg('1/led1', 1);
				(TempoClock.tempo/16).wait;
				this.phoneAddr.sendMsg('1/led1', 0);

				this.phoneAddr.sendMsg('1/led2', 1);
				(TempoClock.tempo/16).wait;
				this.phoneAddr.sendMsg('1/led2', 0);

				this.phoneAddr.sendMsg('1/led3', 1);
				(TempoClock.tempo/16).wait;
				this.phoneAddr.sendMsg('1/led3', 0);

				this.phoneAddr.sendMsg('1/led4', 1);
				(TempoClock.tempo/16).wait;
				this.phoneAddr.sendMsg('1/led4', 0);

				this.phoneAddr.sendMsg('1/led5', 1);
				(TempoClock.tempo/16).wait;
				this.phoneAddr.sendMsg('1/led5', 0);

				this.phoneAddr.sendMsg('1/led6', 1);
				(TempoClock.tempo/16).wait;
				this.phoneAddr.sendMsg('1/led6', 0);

				this.phoneAddr.sendMsg('1/led7', 1);
				(TempoClock.tempo/16).wait;
				this.phoneAddr.sendMsg('1/led7', 0);

				this.phoneAddr.sendMsg('1/led8', 1);
				(TempoClock.tempo/16).wait;
				this.phoneAddr.sendMsg('1/led8', 0);

				this.phoneAddr.sendMsg('1/led9', 1);
				(TempoClock.tempo/16).wait;
				this.phoneAddr.sendMsg('1/led9', 0);

				this.phoneAddr.sendMsg('1/led10', 1);
				(TempoClock.tempo/16).wait;
				this.phoneAddr.sendMsg('1/led10', 0);

				this.phoneAddr.sendMsg('1/led11', 1);
				(TempoClock.tempo/16).wait;
				this.phoneAddr.sendMsg('1/led11', 0);

				this.phoneAddr.sendMsg('1/led12', 1);
				(TempoClock.tempo/16).wait;
				this.phoneAddr.sendMsg('1/led12', 0);

				this.phoneAddr.sendMsg('1/led13', 1);
				(TempoClock.tempo/16).wait;
				this.phoneAddr.sendMsg('1/led13', 0);

				this.phoneAddr.sendMsg('1/led14', 1);
				(TempoClock.tempo/16).wait;
				this.phoneAddr.sendMsg('1/led14', 0);

				this.phoneAddr.sendMsg('1/led15', 1);
				(TempoClock.tempo/16).wait;
				this.phoneAddr.sendMsg('1/led15', 0);

				this.phoneAddr.sendMsg('1/led16', 1);
				(TempoClock.tempo/16).wait;
				this.phoneAddr.sendMsg('1/led16', 0);
			}
		}).play;
	}//End init


}


