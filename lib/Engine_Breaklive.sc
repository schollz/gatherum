// Engine_Breaklive

// Inherit methods from CroneEngine
Engine_Breaklive : CroneEngine {

    // Breaklive specific v0.1.0
    var sampleBuffLive;
    var synRecorder;
    var synPlayer;
    // Breaklive ^

    *new { arg context, doneCallback;
        ^super.new(context, doneCallback);
    }

    alloc {
        // Breaklive specific v0.0.1
        sampleBuffLive = Buffer.alloc(context.server, context.server.sampleRate * 18.0, 2);

        context.server.sync;

        SynthDef("recorder", {
            arg bufnum;
            RecordBuf.ar(SoundIn.ar([0,1]),bufnum);
        }).add;

        
        SynthDef("player", {
            arg amp=1, t_trig=0, bpm=140,bufnum, rate=1,ampmin=0;
            var timer, pos, start, end, snd, aOrB, crossfade, mainamp;
            aOrB=ToggleFF.kr(t_trig);
            crossfade=Lag.ar(K2A.ar(aOrB),0.5);

            timer=Phasor.ar(1,1,0,BufFrames.ir(bufnum));
            start=Latch.kr(timer-(60/bpm/16*(LFNoise0.kr(1).range(1,16).floor.poll)*BufSampleRate.ir(bufnum)),aOrB);
            start=(start>0*start)+(start<0*0);
            end=Latch.kr(timer,aOrB);
            pos=Phasor.ar(aOrB,
                rate:rate,
                start:(((rate>0)*start)+((rate<0)*end)),
                end:(((rate>0)*end)+((rate<0)*start)),
                resetPos:(((rate>0)*start)+((rate<0)*end)),
            );
            snd=BufRd.ar(2,bufnum,pos,interpolation:4);
            snd=(crossfade.poll*snd)+(LinLin.kr(1-crossfade,0,1,ampmin,1)*SoundIn.ar([0,1]));
            Out.ar(0,snd*amp);
        }).add;

        context.server.sync;

        synRecorder = Synth("recorder",[\bufnum,sampleBuffLive],context.xg);
        synPlayer = Synth("player",[\bufnum,sampleBuffLive],context.xg);

        this.addCommand("bb_break","", { arg msg;
            synPlayer.set(\t_trig,1)
        });

        this.addCommand("bb_rate","f", { arg msg;
            synPlayer.set(\rate,msg[1])
        });


        this.addCommand("bb_bpm","f", { arg msg;
            synPlayer.set(\bpm,msg[1])
        });

        this.addCommand("bb_ampmin","f", { arg msg;
            synPlayer.set(\ampmin,msg[1])
        });

        // ^ Breaklive specific

    }

    free {
        // Breaklive Specific v0.0.1
        sampleBuffLive.free;
        synRecorder.free;
        synPlayer.free;
        // ^ Breaklive specific
    }
}
