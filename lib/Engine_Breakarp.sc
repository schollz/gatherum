// Engine_Breakarp

// Inherit methods from CroneEngine
Engine_Breakarp : CroneEngine {

    // Breakarp specific v0.1.0
    var bufSample;
    var synSample;
    // Breakarp ^

    *new { arg context, doneCallback;
        ^super.new(context, doneCallback);
    }

    alloc {
        // Breakarp specific v0.0.1

        SynthDef("xPlayBuf", {
            arg out=0, amp=1.0, bufnum=0, rate=1, pos=0, t_trig=1, xfade=0.05;
            var snd,snd2,frames;
            var posA,posB,crossfade,aOrB;

            rate = rate*BufRateScale.ir(bufnum);
            frames=BufFrames.ir(bufnum);

            // latch to change trigger between the two
            pos=pos*frames;
            aOrB=ToggleFF.kr(t_trig);
            posA=Latch.kr(pos,aOrB);
            posB=Latch.kr(pos,1-aOrB);
            crossfade=VarLag.ar(K2A.ar(aOrB),xfade,warp:\sine);


            snd=PlayBuf.ar(
                numChannels:2,
                bufnum:bufnum,
                rate:rate,
                trigger:(1-aOrB),
                startPos:posA,
                loop:1,
            )*crossfade;

            snd2=PlayBuf.ar(
                numChannels:2,
                bufnum:bufnum,
                rate:rate,
                trigger:aOrB,
                startPos:posB,
                loop:1,
            )*(1-crossfade);

            snd=snd+snd2;

            Out.ar(out,snd*amp);
        }).add;


        this.addCommand("sample","s", { arg msg;
            bufSample.free;
            "loading file".postln;
            bufSample = Buffer.read(context.server,msg[1],action:{
                "loaded file".postln;
                synSample=Synth.new("xPlayBuf",[
                    \bufnum,bufSample,
                    \out,0,
                    \xfade,0.05,
                ]);
            });  

        });

        this.addCommand("freeall","", { arg msg;
            context.server.freeAll();
        });

        this.addCommand("play","ffff", { arg msg;
            synSample.set(
                \amp,msg[1],
                \rate,msg[2],
                \pos,msg[3],
                \xfade,msg[4],
                \t_trig,1,
            );
        });

        // ^ Breakarp specific

    }

    free {
        // Breakarp Specific v0.0.1
        bufSample.free;
        synSample.free;
        // ^ Breakarp specific
    }
}
