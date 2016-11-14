InterfaceGUI : Object{
	var <>width;
	var <>hieght;
	var <>window;
	var <>sequencerWidget;
	var <>page;
	var <>seqLength;
	var <>numInstruments;

	*new{
		|title="Interface", phoneIP,deviceOSCPort, recvPort, numInstruments=5, seqLength=8, page=1, slow=1, volumeFaders=false|
		^super.new.init(title,600,400,phoneIP,deviceOSCPort, recvPort,numInstruments,seqLength,page,slow,volumeFaders);
	}

	init{
		|title, wi, hi,phoneIP,deviceOSCPort, recvPort,numInstruments,seqLength,page,slow,volumeFaders|
		this.width = wi;
		this.hieght = hi;
		this.window = GUI.window.new(title);
		this.window.bounds = Rect(left:0,top:0,width:this.width,height:this.hieght);
		this.sequencerWidget = SequencerWidget.new(this.window, this.window.bounds,phoneIP,deviceOSCPort, recvPort, numInstruments, seqLength, page,slow, volumeFaders);
		this.window.front;

	}

}


SequencerWidget : Object{
	var <>instrumentFields;
	var <>midiNoteFields;
	var <>loadButtons;
	var <>sequencer;
	var <>numInstruments;
	var <>page;
	var <>seqLength;

	*new{
		|parentWindow, parentBounds,phoneIP,deviceOSCPort, recvPort, numInstruments, seqLength, page, slow, volumeFaders=false|
		^super.new.init(parentWindow,parentBounds,phoneIP,deviceOSCPort, recvPort, numInstruments, seqLength, page, slow, volumeFaders);
	}


	init{
		|parentWindow,parentBounds,phoneIP,deviceOSCPort, recvPort, numInstruments, seqLength, page, slow, volumeFaders|

		StaticText.new(parentWindow, Rect(left:parentBounds.left+10, top: parentBounds.top+5,width:500,height:15)).string_("Sequencer Synths");
		//Jam.touchOSCSequencer(phoneIP:phoneIP,phonePort:9000);
		this.sequencer = TouchOSCSequencer.new(phoneIP,deviceOSCPort,recvPort,numInstruments,seqLength,page, slow, volumeFaders);
		this.numInstruments = numInstruments;

		this.instrumentFields = Array.new(this.numInstruments);
		this.midiNoteFields = Array.new(this.numInstruments);
		this.loadButtons = Array.new(this.numInstruments);
		this.seqLength = seqLength;
		this.page = page;


		for(0,this.numInstruments-1,{
			|i|
			var textBounds = Rect(left:parentBounds.left+10,top:parentBounds.top+1+i*30,width:50,height:20);
			var midiFieldBounds = Rect(left:parentBounds.left+80,top:parentBounds.top+1+i*30,width:300,height:20);
			var buttonBounds = Rect(left:parentBounds.left+80+300+10,top: parentBounds.top+1+i*30, width: 20, height: 20);

			var instrumentField = TextField.new(parentWindow, textBounds);
			var midiField = TextField.new(parentWindow, midiFieldBounds);

			instrumentField.keyDownAction = {
				|doc, char, mod, unicode, keycode, key|

				if((mod==1048576)&& (key==16777220),{
					this.sequencer.instruments[(i-(this.numInstruments-1)).abs]=instrumentField.value;

					//Update all the instruments
					for(0,this.numInstruments-1,{
						|j|
						if(this.sequencer.instrumentArray[(i-(this.numInstruments-1)).abs][j]!=\rest,{this.sequencer.instrumentArray[(i-(this.numInstruments-1)).abs][j]=instrumentField.value;});
					});
				});
			};

			midiField.keyDownAction = {
				|doc, char, mod, unicode, keycode, key|

				if((mod==1048576)&& (key==16777220),{
					if( midiField.value.interpret!=nil, {
						this.sequencer.midiNoteArray[(i-(this.numInstruments-1)).abs]=midiField.value.interpret;

					});
				});
			};

			this.instrumentFields.add(instrumentField);
			this.midiNoteFields.add(midiField);


			this.loadButtons.add(Button(parentWindow,buttonBounds).action_({
				if( midiField.value.interpret!=nil, {
					this.sequencer.midiNoteArray[(i-(this.numInstruments-1)).abs]=midiField.value.interpret;

				});
				this.sequencer.instruments[(i-(this.numInstruments-1)).abs]=instrumentField.value;
			}));

		});//End For loop 0-4
	}//END INIT
}

/*
TabletSequencerWidget : Object{
	var <>instrumentFields;
	var <>midiNoteFields;
	var <>loadButtons;
	var <>sequencer;

	*new{
		|parentWindow, parentBounds,phoneIP,deviceOSCPort, recvPort|
		^super.new.init(parentWindow,parentBounds,phoneIP,deviceOSCPort, recvPort);
	}

	init{
		|parentWindow,parentBounds,phoneIP,deviceOSCPort, recvPort|
		StaticText.new(parentWindow, Rect(left:parentBounds.left+10, top: parentBounds.top+5,width:500,height:15)).string_("Sequencer Synths");
		//Jam.touchOSCSequencer(phoneIP:phoneIP,phonePort:9000);
		this.sequencer = TabletTouchOSCSequencer.new(phoneIP,deviceOSCPort,recvPort);
		this.instrumentFields = Array.new(6);
		this.midiNoteFields = Array.new(6);
		this.loadButtons = Array.new(6);

		for(0,5,{
			|i|
			var textBounds = Rect(left:parentBounds.left+10,top:parentBounds.top+1+i*30,width:50,height:20);
			var midiFieldBounds = Rect(left:parentBounds.left+80,top:parentBounds.top+1+i*30,width:300,height:20);
			var buttonBounds = Rect(left:parentBounds.left+80+300+10,top: parentBounds.top+1+i*30, width: 20, height: 20);

			var instrumentField = TextField.new(parentWindow, textBounds);
			var midiField = TextField.new(parentWindow, midiFieldBounds);

			instrumentField.keyDownAction = {
				|doc, char, mod, unicode, keycode, key|

				if((mod==1048576)&& (key==16777220),{
					this.sequencer.instruments[(i-5).abs]=instrumentField.value;

					//Update all the instruments
					for(0,this.sequencer.instrumentArray[0].size-1,{
						|j|
						if(this.sequencer.instrumentArray[(i-5).abs][j]!=\rest,{this.sequencer.instrumentArray[(i-5).abs][j]=instrumentField.value;});
					});
				});
			};

			midiField.keyDownAction = {
				|doc, char, mod, unicode, keycode, key|

				if((mod==1048576)&& (key==16777220),{
					if( midiField.value.interpret!=nil, {
						this.sequencer.midiNoteArray[(i-5).abs]=midiField.value.interpret;

					});
				});
			};

			this.instrumentFields.add(instrumentField);
			this.midiNoteFields.add(midiField);


			this.loadButtons.add(Button(parentWindow,buttonBounds).action_({
				if( midiField.value.interpret!=nil, {
					this.sequencer.midiNoteArray[(i-5).abs]=midiField.value.interpret;

				});
				this.sequencer.instruments[(i-5).abs]=instrumentField.value;
			}));

		});//End For loop 0-4
	}//END INIT


}*/
