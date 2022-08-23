// Engine_Breakcore3

// Inherit methods from CroneEngine
Engine_Breakcore3 : CroneEngine {

    // Breakcore3 specific v0.1.0
    var bufSample;
    // Breakcore3 ^

    *new { arg context, doneCallback;
        ^super.new(context, doneCallback);
    }

    alloc {
        // Breakcore3 specific v0.0.1

        SynthDef("breakcore3", {
            arg buf, out=0, amp=0, rate=1, pos=0, duration=0.5, fade=0.1;
            var snd,frames,env;

            env=EnvGen.ar(
                Env.new(
                    levels: [0,1,1,0],
                    times: [fade,duration-fade,fade],
                ),
                doneAction:2
            );

            snd=PlayBuf.ar(
                numChannels:2,
                bufnum:buf*BufRateScale.ir(buf),
                rate:rate,
                startPos:pos*BufFrames.ir(buf),
                loop:1,
            );

            snd = snd*env*amp;

            Out.ar(out,snd)
        }).add;


        this.addCommand("sample","s", { arg msg;
            bufSample.free;
            "loading file".postln;
            bufSample = Buffer.read(context.server,msg[1],action:{
                "loaded file".postln;
            });
                       
        });

        this.addCommand("freeall","", { arg msg;
            context.server.freeAll();
        });

        this.addCommand("play","fffff", { arg msg;
            Synth.new("breakcore3",[
                \buf,bufSample,
                \out,0,
                \amp,msg[1],
                \rate,msg[2],
                \pos,msg[3],
                \duration,msg[4],
                \fade,msg[5],
            ],target:context.server);
        });

        // ^ Breakcore3 specific

    }

    free {
        // Breakcore3 Specific v0.0.1
        bufSample.free;
        // ^ Breakcore3 specific
    }
}
