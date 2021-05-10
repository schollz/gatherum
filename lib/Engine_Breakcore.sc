// Engine_Breakcore

// Inherit methods from CroneEngine
Engine_Breakcore : CroneEngine {

    // Breakcore specific v0.1.0
    var sampleBuffBreakcore;
    var breakBuffBreakcore;
    var synBreakcore;
    // Breakcore ^

    *new { arg context, doneCallback;
        ^super.new(context, doneCallback);
    }

    alloc {
        // Breakcore specific v0.0.1
        breakBuffBreakcore = Buffer.alloc(context.server,48000*4,2);
        sampleBuffBreakcore = Buffer.new(context.server);

        SynthDef("SynDefBreakcore",{
            arg out=0,amp=0,bpmsource=150,bpm=150,t_trig=0,bufnum,bufnumtemp;
            var playbuf,snd,rate,tempotrigger;
            tempotrigger=Impulse.kr(bpm/60);
            rate = bpm/bpmsource*BufRateScale.kr(bufnum);
            rate = rate*Lag.kr(TChoose.kr(tempotrigger,[1,1,1,1,1,-1]),60/bpm*TChoose.kr(Dust.kr(1),[0,0,0,1,2,4]));
            playbuf=PlayBuf.ar(2,bufnum,rate,Impulse.kr(bpm/60/8),TChoose.kr(tempotrigger,(0..16)/16)*BufFrames.kr(bufnum),loop:1);
            snd=Breakcore.ar(bufnumtemp,playbuf,
                capturetrigger:Impulse.kr(bpm/60*TChoose.kr(tempotrigger,0.125*(1..32))),
                duration:TWChoose.kr(tempotrigger,[0.125/4,0.125/2,0.125,0.25,0.5,1,2,4,8],[0.25,0.5,1,1,3,3,3,3,4],1)*48000*60/bpm,
                ampdropout:1
            );
            snd=HPF.ar(snd,100);
            snd=LPF.ar(snd,6000);
            Out.ar(0,snd*Lag.kr(amp,1))
        }).add;

        context.server.sync;

        synBreakcore = Synth("SynDefBreakcore",[
            \out,0,
            \bufnumtemp,breakBuffBreakcore;
        ], context.xg);

        context.server.sync;

        this.addCommand("bb_load","sf", { arg msg;
            sampleBuffBreakcore.free;
            "loading file".postln;
            sampleBuffBreakcore = Buffer.read(context.server,msg[1],action:{
                "loaded file".postln;
                synBreakcore.set(\bufnum,sampleBuffBreakcore.bufnum,\bpmsource,msg[2]);
            });
        });

        this.addCommand("bb_bpm","f", { arg msg;
            synBreakcore.set(\bpm,msg[1])
        });

        this.addCommand("bb_amp","f", { arg msg;
            synBreakcore.set(\amp,msg[1])
        });

        // ^ Breakcore specific

    }

    free {
        // Breakcore Specific v0.0.1
        sampleBuffBreakcore.free;
        breakBuffBreakcore.free;
        synBreakcore.free;
        // ^ Breakcore specific
    }
}
