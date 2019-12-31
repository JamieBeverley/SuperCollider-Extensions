(
// var bounds = Window.screenBounds;
var width = Window.screenBounds.width*3/4;
var height = Window.screenBounds.height*3/4;
var bounds = Rect(0,0,width,height);
var window = Window("yamboot",bounds);
var margin = 20;
var sequencerBounds = Rect(left:margin, top:margin,width:(width-(margin*2))*0.6,height:height-(2*margin)*5/6);
var sequencerView = CompositeView(window, sequencerBounds);

var sequencerVolumes = CompositeView(window, Rect(left:margin+sequencerBounds.width,top:margin,width:(width-(margin*2))*0.25/5,height:sequencerBounds.height));

var sequencerEffects = CompositeView(window, Rect(left:margin+sequencerBounds.width+sequencerVolumes.bounds.width,top:margin,width:(width-(margin*2))*0.25*4/5,height:sequencerBounds.height));


var instruments = 8;
var spots = 16;
var buttons = Array2D(rows:instruments,cols:spots);

var buttonFaders = nil!instruments;
var textFields = nil!instruments;
var numberOfKnobs = 4;
var knobs = Array2D(rows:instruments,cols:numberOfKnobs);

var textFieldsView = CompositeView(window, Rect(left:margin+sequencerBounds.width+sequencerVolumes.bounds.width+sequencerEffects.bounds.width,top:margin,width:(width-(margin*2))*0.15,height:sequencerBounds.height)).background_(Color(0.2,0.2,0.2));

var c1 = Color(red:0.7,green:0.8,blue:0.95,alpha:1);

var stepperView = CompositeView(window, Rect(left:margin,top:sequencerBounds.top+sequencerBounds.height,width:sequencerBounds.width,height:height-(margin*2)-sequencerBounds.height));
var steppers = nil!spots;

var masterViewContainer = CompositeView(window, Rect(left:margin+sequencerBounds.width,top:sequencerBounds.height+margin,width:width-(margin*2)-sequencerBounds.width-textFieldsView.bounds.width,height:stepperView.bounds.height));

var masterView = CompositeView(masterViewContainer, Rect(left:masterViewContainer.bounds.width*0.02,top:masterViewContainer.bounds.width*0.02,width:masterViewContainer.bounds.width*0.96,height:masterViewContainer.bounds.height*0.96));

var masterKnobs = nil!4;
var serverMeterViewContainer = CompositeView (window,Rect(masterViewContainer.bounds.left+masterViewContainer.bounds.width, masterViewContainer.bounds.top,textFieldsView.bounds.width,height:masterViewContainer.bounds.height));


var serverMeterView = CompositeView(serverMeterViewContainer,Rect(left:serverMeterViewContainer.bounds.width*0.02,top:serverMeterViewContainer.bounds.width*0.02,width:0.96*serverMeterViewContainer.bounds.width,height:0.96*serverMeterViewContainer.bounds.height)); ServerMeterView(Server.default,serverMeterViewContainer,leftUp:Point(serverMeterViewContainer.bounds.width*0.02,serverMeterViewContainer.bounds.width*0.02),numIns:4,numOuts:4);
// serverMeterView.background = Color.white;
masterView.background =(Color.black);
serverMeterView.background = Color.rand;
stepperView.background=Color.black;





window.background = Color(0.1,0.1,0.1);

sequencerView.background = c1;

steppers.collectInPlace({
	|v,i|
	CompositeView(stepperView,bounds:Rect(left:i*stepperView.bounds.width/spots,top:0.25*stepperView.bounds.height,width:stepperView.bounds.width/spots/2,height:stepperView.bounds.width/spots/2)).background_(Color(red:0.5,green:0.2,blue:0.3));
});


buttonFaders.collectInPlace({
	|v,i|
	var a = NumberBox(sequencerVolumes,Rect(sequencerVolumes.bounds.width*0.1,top:i*sequencerBounds.height/instruments,width:sequencerVolumes.bounds.width/2,height:sequencerVolumes.bounds.height/instruments/2)).background_(Color(0.45,0.45,0.45));
	a.value = -20;
});

textFields.collectInPlace({
	|v,i|
	var a = TextField(textFieldsView, Rect(left:textFieldsView.bounds.width*0.1,top:i*sequencerBounds.height/instruments,width:textFieldsView.bounds.width*0.4,height:textFieldsView.bounds.height/instruments*0.5));
	Button(textFieldsView, Rect(left:textFieldsView.bounds.width*0.6,top:(i*sequencerBounds.height/instruments),width:textFieldsView.bounds.width*0.2,height:textFieldsView.bounds.height/instruments*0.25)).states_([["open",Color.white,Color(0.1,0.1,0.1)]]);
	a;
});


knobs.rows.do{
	|i|
	knobs.cols.do{
		|j|
		knobs[i,j] = Knob(sequencerEffects,Rect(left:j*sequencerEffects.bounds.width/numberOfKnobs,top:i*sequencerEffects.bounds.height/instruments,width:sequencerEffects.bounds.width/numberOfKnobs,height:sequencerEffects.bounds.height/instruments/1.5)).color_([Color.white,Color.red,Color.white,Color.red]);

		};
};


buttons.rows.do{
	|i|
	buttons.cols.do{
		|j|
		if (j%4==0,{CompositeView(sequencerView,bounds:Rect(left:j*sequencerBounds.width/spots,top:i*sequencerBounds.height/instruments,width:2,height:sequencerBounds.height/instruments)).background=Color.black});
		buttons[i,j] = Button(sequencerView, Rect(left:j*sequencerBounds.width/spots,top:i*sequencerBounds.height/instruments)).states_([["",Color(0.4,0.4,0.4),Color(0.4,0.4,0.4)],["",Color(0.3,0.1,0.7),Color(0.3,0.1,0.7)]]).mouseDownAction_({});

	};
};
width.postln;
height.postln;
window.front();

)
Slider2D


Knob

(
w = Window("Slider2D", Rect(100, 100, 140, 140));
t = Slider2D(w, Rect(20, 20, 80, 80))
        .x_(0.5) // initial location of x
        .y_(1)   // initial location of y
        .action_({|sl|
            [\sliderX, sl.x, \sliderY, sl.y].postln;
        });
w.front;
)
w = Window.new.front;
c = NumberBox(w, Rect(20, 20, 150, 20));
a = Slider(w, Rect(20, 60, 150, 20))
    .action_({
        c.value_(a.value)
        });
a.action.value;


[[1,1,1],[2,2,2],[3,3,3]]

(
a.rows.do{
	|i|
	a.cols.do{
		|j|
		a[i,j]=2;
	};
}
)
a
a = Array2D(8,16)

a.at_(1,2,3)

a.at(0,1)

a.collectInPlace({|v,i| v.collectInPlace({3});});

a.rows