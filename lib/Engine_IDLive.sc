// Engine_IDLive

// Inherit methods from CroneEngine
Engine_IDLive : CroneEngine {

    // IDLive specific v0.1.0
    var bufBreakbeat;
    var synBreakbeat;
    var synDrone;
    var synSupertonic;
    var synVoice=0;
    var maxVoices=5;
    var bufBreaklive;
    var synBreakliveRec;
    var synBreaklivePlay;
    var mainBus;
    var synSample;
    var bufSample;
    // IDLive ^

    *new { arg context, doneCallback;
        ^super.new(context, doneCallback);
    }

    alloc {
        // IDLive specific v0.0.1
        // break live
        mainBus=Bus.audio(context.server,2);

        bufBreaklive = Buffer.alloc(context.server, context.server.sampleRate * 18.0, 2);

        context.server.sync;

        SynthDef("defBreakliveRec", {
            arg bufnum, in;
            RecordBuf.ar(SoundIn.ar([0,1])+In.ar(in,2),bufnum);
        }).add;

        
        SynthDef("defBreaklivePlay", {
            arg amp=1, t_trig=0, bpm=140,bufnum, rate=1,ampmin=0, in;
            var timer, pos, start, end, snd, aOrB, crossfade, mainamp;
            aOrB=ToggleFF.kr(t_trig);
            crossfade=Lag.ar(K2A.ar(aOrB),0.5);
            rate=Lag.kr(rate,8);
            timer=Phasor.ar(1,1,0,BufFrames.ir(bufnum));
            start=Latch.kr(timer-(60/bpm/16*(LFNoise0.kr(1).range(1,16).floor)*BufSampleRate.ir(bufnum)),aOrB);
            start=(start>0*start)+(start<0*0);
            end=Latch.kr(timer,aOrB);
            pos=Phasor.ar(aOrB,
                rate:rate,
                start:(((rate>0)*start)+((rate<0)*end)),
                end:(((rate>0)*end)+((rate<0)*start)),
                resetPos:(((rate>0)*start)+((rate<0)*end)),
            );
            snd=BufRd.ar(2,bufnum,pos,interpolation:4);
            snd=(crossfade*snd)+(LinLin.kr(1-crossfade,0,1,ampmin,1)*(SoundIn.ar([0,1])+In.ar(in,2)));
            Out.ar(0,(snd*0.5).tanh);
        }).add;

        context.server.sync;

        synBreakliveRec = Synth("defBreakliveRec",[\bufnum,bufBreaklive,\in,mainBus.index],context.xg);
        synBreaklivePlay = Synth("defBreaklivePlay",[\bufnum,bufBreaklive,\in,mainBus.index],context.xg);

        this.addCommand("bl","", { arg msg;
            synBreaklivePlay.set(\t_trig,1)
        });

        this.addCommand("bl_rate","f", { arg msg;
            synBreaklivePlay.set(\rate,msg[1])
        });


        this.addCommand("bl_bpm","f", { arg msg;
            synBreaklivePlay.set(\bpm,msg[1])
        });

        this.addCommand("bl_ampmin","f", { arg msg;
            synBreaklivePlay.set(\ampmin,msg[1])
        });

	   context.server.sync;

        bufSample=Array.fill(4,{arg i;
            Buffer.new(context.server);
        });
        synSample=Array.fill(4,{arg i;{
                arg amp=0,bufnum=0,t_trig=1,start=0,out=0;
                Out.ar(out,PlayBuf.ar(2,bufnum,BufRateScale.kr(bufnum),t_trig,start*BufFrames.kr(bufnum),loop:1)*VarLag.kr(amp,20,warp:\linear));
            }.play(target:context.xg);
        });

        this.addCommand("s_load","is", { arg msg;
            bufSample[msg[1]-1].free;
            ("loading "++msg[2]).postln;
            bufSample[msg[1]-1] = Buffer.read(context.server,msg[2],action:{
                ("loaded "++msg[2]).postln;
                synSample[msg[1]-1].set(\out,mainBus,\bufnum,bufSample[msg[1]-1].bufnum,\t_trig,1);
            });
        });
        
	   this.addCommand("s_amp","if", { arg msg;
            synSample[msg[1]-1].set(\amp,msg[2]);
        });

        this.addCommand("s_mov","if", { arg msg;
            synSample[msg[1]-1].set(\start,msg[2],\t_trig,1);
        });


        // break beat

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
            \out,mainBus.index,
            \bufnum,bufBreakbeat;
        ], target:context.xg);

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
            arg freq=110.0,amp=0,out;
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
            Out.ar(out,snd);
        }).add;


        context.server.sync;

        synDrone = Synth("defDrone",[\out,mainBus.index],target:context.xg);

        context.server.sync;

        this.addCommand("d_amp","f", { arg msg;
            synDrone.set(\amp,msg[1]);
        });
        this.addCommand("d_midi","i", { arg msg;
            synDrone.set(\freq,msg[1].midicps);
        });

        SynthDef("supertonic", {
            arg out,
            mix=50,level=(-5),distAmt=2,
            eQFreq=632.4,eQGain=(-20),
            oscAtk=0,oscDcy=500,
            oscWave=0,oscFreq=54,
            modMode=0,modRate=400,modAmt=18,
            nEnvAtk=26,nEnvDcy=200,
            nFilFrq=1000,nFilQ=2.5,
            nFilMod=0,nEnvMod=0,nStereo=1,
            oscLevel=1,nLevel=1,
            oscVel=100,nVel=100,modVel=100,
            fx_lowpass_freq=20000,fx_lowpass_rq=1,
            vel=64;

            // variables
            var osc,noz,nozPostF,snd,pitchMod,nozEnv,numClaps,oscFreeSelf,wn1,wn2,clapFrequency,decayer;

            // convert to seconds from milliseconds
            vel=LinLin.kr(vel,0,128,0,2);
            oscAtk=DC.kr(oscAtk/1000);
            oscDcy=DC.kr(oscDcy/1000);
            nEnvAtk=DC.kr(nEnvAtk/1000);
            nEnvDcy=DC.kr(nEnvDcy/1000*1.4);
            level=DC.kr(level);
            // add logistic curve to the mix
            mix=DC.kr(100/(1+(2.7182**((50-mix)/8))));
            // this is important at low freq
            oscFreq=oscFreq+5;

            // white noise generators (expensive)
            // wn1=SoundIn.ar(0); 
            // wn2=SoundIn.ar(1);
            wn1=WhiteNoise.ar();
            wn2=WhiteNoise.ar();
            wn1=Clip.ar(wn1*100,-1,1);
            wn2=Clip.ar(wn2*100,-1,1);
            clapFrequency=DC.kr((4311/(nEnvAtk*1000+28.4))+11.44); // fit using matlab
            // determine who should free
            oscFreeSelf=DC.kr(Select.kr(((oscAtk+oscDcy)>(nEnvAtk+nEnvDcy)),[0,2]));

            // define pitch modulation1
            pitchMod=Select.ar(modMode,[
                Decay.ar(Impulse.ar(0.0001),(1/(2*modRate))), // decay
                SinOsc.ar(-1*modRate), // sine
                Lag.ar(LFNoise0.ar(4*modRate),1/(4*modRate)), // random
            ]);

            // mix in the the pitch mod
            pitchMod=pitchMod*modAmt/2*(LinLin.kr(modVel,0,200,2,0)*vel);
            oscFreq=((oscFreq).cpsmidi+pitchMod).midicps;

            // define the oscillator
            osc=Select.ar(oscWave,[
                SinOsc.ar(oscFreq),
                LFTri.ar(oscFreq,mul:0.5),
                SawDPW.ar(oscFreq,mul:0.5),
            ]);
            osc=Select.ar(modMode>1,[
                osc,
                SelectX.ar(oscDcy<0.1,[
                    LPF.ar(wn2,modRate),
                    osc,
                ])
            ]);


            // add oscillator envelope
            decayer=SelectX.kr(distAmt/100,[0.05,distAmt/100*0.3]);
            osc=osc*EnvGen.ar(Env.new([0.0001,1,0.9,0.0001],[oscAtk,oscDcy*decayer,oscDcy],\exponential),doneAction:oscFreeSelf);

            // apply velocity
            osc=(osc*LinLin.kr(oscVel,0,200,1,0)*vel).softclip;

            // generate noise
            noz=wn1;

            // optional stereo noise
            noz=Select.ar(nStereo,[wn1,[wn1,wn2]]);


            // define noise envelope
            nozEnv=Select.ar(nEnvMod,[
                EnvGen.ar(Env.new(levels: [0.001, 1, 0.0001], times: [nEnvAtk, nEnvDcy],curve:\exponential),doneAction:(2-oscFreeSelf)),
                EnvGen.ar(Env.new([0.0001,1,0.9,0.0001],[nEnvAtk,nEnvDcy*decayer,nEnvDcy*(1-decayer)],\linear)),
                Decay.ar(Impulse.ar(clapFrequency),1/clapFrequency,0.85,0.15)*Trig.ar(1,nEnvAtk+0.001)+EnvGen.ar(Env.new(levels: [0.001, 0.001, 1,0.0001], times: [nEnvAtk,0.001, nEnvDcy],curve:\exponential)),
            ]);

            // apply noise filter
            nozPostF=Select.ar(nFilMod,[
                BLowPass.ar(noz,nFilFrq,Clip.kr(1/nFilQ,0.5,3)),
                BBandPass.ar(noz,nFilFrq,Clip.kr(2/nFilQ,0.1,6)),
                BHiPass.ar(noz,nFilFrq,Clip.kr(1/nFilQ,0.5,3))
            ]);
            // special Q
            nozPostF=SelectX.ar((0.1092*(nFilQ.log)+0.0343),[nozPostF,SinOsc.ar(nFilFrq)]);

            // apply envelope to noise
            noz=Splay.ar(nozPostF*nozEnv);

            // apply velocities
            noz=(noz*LinLin.kr(nVel,0,200,1,0)*vel).softclip;



            // mix oscillator and noise
            snd=SelectX.ar(mix/100*2,[
                noz*0.5,
                noz*2,
                osc*1
            ]);

            // apply distortion
            snd=SineShaper.ar(snd,1.0,1+(10/(1+(2.7182**((50-distAmt)/8))))).softclip;

            // apply eq after distortion
            snd=BPeakEQ.ar(snd,eQFreq,1,eQGain/2);

            snd=HPF.ar(snd,20);

            snd=snd*level.dbamp*0.2;

            // free self if its quiet
            FreeSelf.kr((Amplitude.kr(snd)<0.001)*TDelay.kr(DC.kr(1),0.03));

            // apply some global fx
            snd=RLPF.ar(snd,fx_lowpass_freq,fx_lowpass_rq);

            Out.ar(out, snd);
        }).add;

        context.server.sync;

        synSupertonic = Array.fill(maxVoices,{arg i;
            Synth("supertonic", [\level,-100,\out,0],target:context.xg);
        });

        context.server.sync;

        this.addCommand("supertonic","ffffffffffffffffffffffffi", { arg msg;
            // lua is sending 1-index
            synVoice=synVoice+1;
            if (synVoice>(maxVoices-1),{synVoice=0});
            if (synSupertonic[synVoice].isRunning,{
                ("freeing "++synVoice).postln;
                synSupertonic[synVoice].free;
            });
            synSupertonic[synVoice]=Synth.after(synBreaklivePlay,"supertonic",[
                \out,0,
                \distAmt, msg[1],
                \eQFreq, msg[2],
                \eQGain, msg[3],
                \level, msg[4],
                \mix, msg[5],
                \modAmt, msg[6],
                \modMode, msg[7],
                \modRate, msg[8],
                \nEnvAtk, msg[9],
                \nEnvDcy, msg[10],
                \nEnvMod, msg[11],
                \nFilFrq, msg[12],
                \nFilMod, msg[13],
                \nFilQ, msg[14],
                \nStereo, msg[15],
                \oscAtk, msg[16],
                \oscDcy, msg[17],
                \oscFreq, msg[18],
                \oscWave, msg[19],
                \oscVel, msg[20],
                \nVel, msg[21],
                \modVel, msg[22],
                \fx_lowpass_freq,msg[23],
                \fx_lowpass_rq,msg[24],
            ]);
            NodeWatcher.register(synSupertonic[synVoice]);
        });


        // ^ IDLive specific


    }

    free {
        // IDLive Specific v0.0.1
        bufBreakbeat.free;
        synBreakbeat.free;
        synDrone.free;
        (0..maxVoices).do({arg i; synSupertonic[i].free});
        synBreaklivePlay.free;
        synBreakliveRec.free;
        mainBus.free;
        4.do({arg i; bufSample[i].free});
        4.do({arg i; synSample[i].free});
    }
}
