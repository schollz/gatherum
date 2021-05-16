// CroneEngine_PolyPerc
// pulse wave with perc envelopes, triggered on freq
Engine_Kalimba : CroneEngine {
	var pg;
    var amp=0.3;
    var pw=0.5;
    var cutoff=1000;
    var gain=2;
    var pan = 0;
    var mix = 0.1;

	*new { arg context, doneCallback;
		^super.new(context, doneCallback);
	}

	alloc {
		pg = ParGroup.tail(context.xg);
    SynthDef("Kalimba", {
			arg out, freq = 440, pw=pw, amp=amp, cutoff=cutoff, gain=gain, pan=pan, mix=mix;
			
			var snd, snd2, click, release;
			// release is a function of amplitude
			release = amp * 6 + 2;
		    // Basic tone is a SinOsc
		    snd = SinOsc.ar(freq) * EnvGen.ar(Env.perc(0.03, release, 1, -7), doneAction: 2);
			snd = HPF.ar( LPF.ar(snd, 380), 120);
		    // The "clicking" sounds are modeled with a bank of resonators excited by enveloped white noise
			click = DynKlank.ar(`[
		        // the resonant frequencies are randomized a little to add variation
		        // there are two high resonant freqs and one quiet "bass" freq to give it some depth
		        [240*ExpRand(0.97, 1.02), 2020*ExpRand(0.97, 1.02), 3151*ExpRand(0.97, 1.02)],
		        [-9, 0, -5].dbamp,
		        [0.8, 0.07, 0.08]
			], BPF.ar(PinkNoise.ar, 6500, 0.1) * EnvGen.ar(Env.perc(0.001, 0.01))) * 0.1;
			snd = (snd*mix) + (click*(1-mix));
			snd = Mix( snd );

		    // Basic tone is a SinOsc
		    snd2 = SinOsc.ar(freq) * EnvGen.ar(Env.perc(0.005,release, 1, -6), doneAction: 2);
		    // The "clicking" sounds are modeled with a bank of resonators excited by enveloped pink noise
		    snd2 = (snd2 * (1 - mix)) + (DynKlank.ar(`[
		        // the resonant frequencies are randomized a little to add variation
		        // there are two high resonant freqs and one quiet "bass" freq to give it some depth
		        [240*ExpRand(0.9, 1.1), 2020*ExpRand(0.9, 1.1), 3151*ExpRand(0.9, 1.1)],
		        [-7, 0, 3].dbamp,
		        [0.8, 0.05, 0.07]
		    ], PinkNoise.ar * EnvGen.ar(Env.perc(0.001, 0.01))) * mix);
			
			snd = snd/2 + snd2/2;

			Out.ar(out, Pan2.ar(snd,1,amp));
		}).add;

		this.addCommand("hz", "f", { arg msg;
			var val = msg[1];
      Synth("Kalimba", [\out, context.out_b, \freq,val,\pw,pw,\amp,amp,\cutoff,cutoff,\gain,gain,\pan,pan], target:pg);
		});

		this.addCommand("amp", "f", { arg msg;
			amp = msg[1];
		});

		this.addCommand("pw", "f", { arg msg;
			pw = msg[1];
		});
		
		this.addCommand("cutoff", "f", { arg msg;
			cutoff = msg[1];
		});
		
		this.addCommand("gain", "f", { arg msg;
			gain = msg[1];
		});
		
		this.addCommand("pan", "f", { arg msg;
		  postln("pan: " ++ msg[1]);
			pan = msg[1];
		});
	}
}
