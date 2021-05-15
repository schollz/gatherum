// Engine_Breakcore2

// Inherit methods from CroneEngine
Engine_Breakcore2 : CroneEngine {

    // Breakcore2 specific v0.1.0
    var sampleBuffBreakcore2;
    var synBreakcore2;
    var taskBreakcore2;
    // Breakcore2 ^

    *new { arg context, doneCallback;
        ^super.new(context, doneCallback);
    }

    alloc {
        // Breakcore2 specific v0.0.1
        sampleBuffBreakcore2 = Buffer.new(context.server);

        SynthDef("SynDefBreakcore2", {
            arg out=0, amp=0,bufnum=0, rate=1, start=0, end=1, reset=0, t_trig=0,
            bpm=120,bpmsource=120,
            loops=1;
            var snd,snd2,pos,pos2,frames,duration,env;
            var startA,endA,startB,endB,resetA,resetB,crossfade,aOrB;

            // latch to change trigger between the two
            aOrB=ToggleFF.kr(t_trig);
            startA=Latch.kr(start,aOrB);
            endA=Latch.kr(end,aOrB);
            resetA=Latch.kr(reset,aOrB);
            startB=Latch.kr(start,1-aOrB);
            endB=Latch.kr(end,1-aOrB);
            resetB=Latch.kr(reset,1-aOrB);
            crossfade=Lag.ar(K2A.ar(aOrB),0.05);


            rate = rate*BufRateScale.kr(bufnum)*bpm/bpmsource;
            frames = BufFrames.kr(bufnum);
            duration = frames*(end-start)/rate.abs/context.server.sampleRate*loops;

            // envelope to clamp looping
            env=EnvGen.ar(
                Env.new(
                    levels: [0,1,1,0],
                    times: [0,duration-0.05,0.05],
                ),
                gate:t_trig,
            );

            pos=Phasor.ar(
                trig:aOrB,
                rate:rate,
                start:(((rate>0)*startA)+((rate<0)*endA))*frames,
                end:(((rate>0)*endA)+((rate<0)*startA))*frames,
                resetPos:(((rate>0)*resetA)+((rate<0)*endA))*frames,
            );
            snd=BufRd.ar(
                numChannels:2,
                bufnum:bufnum,
                phase:pos,
                interpolation:4,
            );

            // add a second reader
            pos2=Phasor.ar(
                trig:(1-aOrB),
                rate:rate,
                start:(((rate>0)*startB)+((rate<0)*endB))*frames,
                end:(((rate>0)*endB)+((rate<0)*startB))*frames,
                resetPos:(((rate>0)*resetB)+((rate<0)*endB))*frames,
            );
            snd2=BufRd.ar(
                numChannels:2,
                bufnum:bufnum,
                phase:pos2,
                interpolation:4,
            );

            Out.ar(out,(crossfade*snd)+((1-crossfade)*snd2) * env * amp)
        }).add;

        context.server.sync;

        synBreakcore2 = Synth("SynDefBreakcore2",[
            \out,0,
            \bufnum,sampleBuffBreakcore2;
        ], context.xg);

        context.server.sync;

        this.addCommand("bb_load","sf", { arg msg;
            sampleBuffBreakcore2.free;
            "loading file".postln;
            sampleBuffBreakcore2 = Buffer.read(context.server,msg[1],action:{
                "loaded file".postln;
                synBreakcore2.set(\bufnum,sampleBuffBreakcore2.bufnum,\bpmsource,msg[2]);
                taskBreakcore2 = Task({
                    var bpm=140;
                    var bpm_source=160;
                    var beats=4;
                    var subdivision=4;
                    synBreakcore2.set(\t_trig,1,\start,0,\end,1,\rate,1,\loops,1000);
                    inf.do({ arg i;
                        var curtick;
                        (60/bpm/(subdivision)).wait;
                        curtick=i%(beats*subdivision);
                        curtick.postln;

                        // random lock in to the actual beat
                        if (64.rand>60,{
                            "locking".postln;
                            synBreakcore2.set(\t_trig,1,\reset,curtick/(beats*subdivision),\start,0,\end,1,\rate,1,\loops,1000);
                        },{});
                        // randomly break the beat
                        if (64.rand>58,{
                            "breaking".postln;
                            synBreakcore2.set(\t_trig,1,\start,curtick/(beats*subdivision),\reset,curtick/(beats*subdivision)+(100.rand/1000),\end,(curtick+((beats*subdivision)-curtick).rand)/(beats*subdivision)+(100.rand/1000),\loops,1000);
                        },{});

                        // // randomly reverse
                        if (512.rand>510,{
                            "reversing?".postln;
                            synBreakcore2.set(\rate,(2.rand*2-1));
                        },{});
                        // // randomly slow
                        // if (128.rand>125,{
                        //  "slowdown".postln;
                        //  synBreakcore2.set(\rate,bpm/bpm_source*(2.rand*2-1)*0.5);
                        // },{});
                        // // randomly speed
                        // if (128.rand>125,{
                        //  "speedup".postln;
                        //  synBreakcore2.set(\rate,bpm/bpm_source*(2.rand*2-1)*2);
                        // },{});
                    });
                }).play; 
            });
                       
        });

        this.addCommand("bb_bpm","f", { arg msg;
            synBreakcore2.set(\bpm,msg[1])
        });

        this.addCommand("bb_amp","f", { arg msg;
            synBreakcore2.set(\amp,msg[1])
        });


        this.addCommand("bb_reset","", { arg msg;
            taskBreakcore2.stop;
            taskBreakcore2.start;
        });

        // ^ Breakcore2 specific

    }

    free {
        // Breakcore2 Specific v0.0.1
        sampleBuffBreakcore2.free;
        synBreakcore2.free;
        taskBreakcore2.free;
        // ^ Breakcore2 specific
    }
}
