Imprint {

	*imprint {
		|path, begin = 0, end = 1, fftSize=2048, components=5, sampleRate=100|
		var buf;

		Server.defaut.waitForBoot({

			OSCdef(\imprint,{
				|msg|
				msg.postln;
			});

			buf = Buffer.read(Server.default,path,action:{
				|loadedBuf|

				SynthDef(\imprint,{
					var audio = PlayBuf.ar(loadedBuf.numChannels,loadedBuf,startPos:begin*loadedBuf.numFrames);
					var env = EnvGen.ar(Env.new([1,1,0],[end*loadedBuf.numFrames/loadedBuf.sampleRate,0]),doneAction:2);
					var fft;
					audio = audio*env;

					fft = FFT(LocalBuf(fftSize),audio);

					SendReply.kr(Impulse.kr(sampleRate),cmdName:"/imprintFrame",values:fft);

					// chain = FFT(LocalBuf(2048), in);
					// chain.inspect;
				}).add;
				Synth.new(\imprint);


			});
		});

	}

	*imprintOSCFunc{
		|msg|
		msg.postln;
	}


}