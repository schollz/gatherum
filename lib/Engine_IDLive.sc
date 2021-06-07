// Engine_IDLive

// Inherit methods from CroneEngine
Engine_IDLive : CroneEngine {

    // IDLive specific v0.1.0
    var bufBreakbeat;
    var synBreakbeat;
    var synDrone;
    // IDLive ^

    *new { arg context, doneCallback;
        ^super.new(context, doneCallback);
    }

    alloc {
        // IDLive specific v0.0.1
        bufBreakbeat = Buffer.new(context.server);

        SynthDef("defBreakbeat", {
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
            amp=Lag.kr(amp,4);


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

        synBreakbeat = Synth("defBreakbeat",[
            \out,0,
            \bufnum,bufBreakbeat;
        ], context.xg);

        context.server.sync;

        this.addCommand("bb_load","sff", { arg msg;
            bufBreakbeat.free;
            ("loading "++msg[1]).postln;
            bufBreakbeat = Buffer.read(context.server,msg[1],action:{
                ("loaded "++msg[1]).postln;
                synBreakbeat.set(\bufnum,bufBreakbeat.bufnum,\bpm,msg[2],\bpmsource,msg[3],\t_trig,1,\reset,msg[1],\start,0,\end,1,\rate,1,\loops,1000);
            });
                       
        });

        this.addCommand("bb_amp","f", { arg msg;
            synBreakbeat.set(\amp,msg[1])
        });

        this.addCommand("bb_sync","f", {arg msg;
            synBreakbeat.set(\t_trig,1,\reset,msg[1],\start,0,\end,1,\rate,1,\loops,1000);
        });

        this.addCommand("bb_break","ff", {arg msg;
            synBreakbeat.set(\t_trig,1,\start,msg[1],\reset,msg[1],\end,msg[2],\loops,1000);
        });



        // the drone
        SynthDef("defDrone", {
            arg freq=110.0,amp=0;
            var local, in, ampcheck,movement, snd;

            amp=Lag.kr(amp,8);

            in = Splay.ar(Pulse.ar(Lag.kr(freq*
                LinLin.kr(SinOsc.kr(LFNoise0.kr(1)/2),-1,1,0.99,1.01),1),
                LinLin.kr(SinOsc.kr(LFNoise0.kr(1)),-1,1,0.45,0.55)
            )!1)/1;
            in = Balance2.ar(in[0] ,in[1],SinOsc.kr(
                LinLin.kr(LFNoise0.kr(0.1),-1,1,0.05,0.2)
            )*0.1);

            // from tape example
            // https://depts.washington.edu/dxscdoc/Help/Classes/LocalOut.html
            ampcheck = Amplitude.kr(Mix.ar(in));
            in = in * (ampcheck > 0.02); // noise gate
            local = LocalIn.ar(2);
            local = OnePole.ar(local, 0.4);
            local = OnePole.ar(local, -0.08);
            local = Rotate2.ar(local[0], local[1],0.2);
            local = DelayN.ar(local, 0.3,
                VarLag.kr(LinLin.kr(LFNoise0.kr(0.1),-1,1,0.15,0.3),1/0.1,warp:\sine)
            );
            local = LeakDC.ar(local);
            local = ((local + in) * 1.25).softclip;

            // for the drone
            local = LPF.ar(local,
                VarLag.kr(LinLin.kr(LFNoise0.kr(0.3),-1,1,ArrayMin.kr([freq,80]),16000),1/0.3,warp:\sine)
            );
            LocalOut.ar(local*
                VarLag.kr(LinLin.kr(LFNoise0.kr(2),-1,1,1.01,1.5),1/2,warp:\sine)
            );
            snd = Balance2.ar(local[0] * 0.2,local[1]*0.2,SinOsc.kr(
                LinLin.kr(LFNoise0.kr(0.1),-1,1,0.05,0.2)
            )*0.1)*amp;
            Out.ar(0,snd);
        }).add;


        context.server.sync;

        synDrone = Synth("defDrone", target:context.xg);

        context.server.sync;

        this.addCommand("d_amp","f", { arg msg;
            synDrone.set(\amp,msg[1]);
        });
        this.addCommand("d_midi","i", { arg msg;
            synDrone.set(\freq,msg[1].midicps);
        });
        // ^ IDLive specific

    }

    free {
        // IDLive Specific v0.0.1
        bufBreakbeat.free;
        synBreakbeat.free;
        synDrone.free;
        // ^ IDLive specific
    }
}
