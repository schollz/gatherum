-- vim
-- nnoremap <C-c> <esc>:silent.w !wscat<enter>
-- inoremap <C-c> <esc>:silent.w !wscat<enter>i
-- vim run  :silent.w !wscat

-- norns.script.load("code/tuner/tuner.lua"); crow.output[1].volts=3 -- A3
norns.script.load("code/gatherum/live.lua")

nature(0.0)

tapebreak()
tapestop()

-- closer
params:set("clock_tempo",120)

e.s_load(1,"/home/we/dust/audio/live/closer.wav"); 
e.s_amp(1,0.8); 
e.s_mov(1,3/28)
play("closer",er("e.s_mov(1,3/28)",1),1)
expand("closer",64)
ta:rm("closer")

crow.output[2].action="{ to(10,2),to(0,6) }"; crow.output[2]()
crow.output[3].action="lfo(3.1415,10)"; crow.output[3]()
stop("crow")
expand("crow",8)
play("crow","ab3",1)
play("crow","db4",3)
play("crow",". eb4",5)
play("crow","gb4",7)
play("crow","gb4",8)

stop("crow")
crow.output[2].action="{ to(10,0),to(0,0.1) }"; crow.output[2]()
play("crow","ab4 ab4 bb3 eb3 ab eb bb bb3 eb ab eb db bb ab eb bb ",1)
crow.output[2].action="{ to(10,0),to(0,0.2) }"; crow.output[2]()
play("crow","bb bb3 eb ab eb db bb ab",1)
play("sh",". b6 . b5 e5 g#6 eb b",2)
play("sh","gb6 db5 bb6 db bb . .",3)
play("sh","db6 ab . . . db f5 f4",4)

stop("op1")
play("op1","Abm/Eb:3",1)
play("op1","E:3",2)
play("op1","Gb/Db:3",3)
play("op1","Ebm:3",4)
play("op1","Abm/Eb:3",5)
play("op1","E:3",6)
play("op1","Gb:3",7)
play("op1","Db/F:3",8)

stop("drone")
e.d_amp(0.1)
play("drone","eb5",1)
play("drone","bb5",5)
play("drone","db4",8)

stop("geo")
play("geo","ab1 ab ab . ab  . eb ab ab1 ab ab . ab  . eb ab",1)
play("geo","b2  e1 e1 . b2  . g# b b2  e1 e1 . b2  . g# b",2)
play("geo","gb1 gb db . gb3 . b  db gb1 gb db . gb3 . b  db",3)
play("geo","eb1 eb bb . bb .  ab bb eb1 eb bb . bb .  ab bb",4)

e.bb_load("/home/we/dust/audio/breakbeat/bpm120/beats8_bpm120_adt_120_drum_break_leak.wav",clock.get_tempo(),120)
e.bb_load("/home/we/dust/audio/breakbeat/bpm120/beats8_bpm120_rb_drum_loop_break_byrd_120.wav",clock.get_tempo(),120)
e.bb_load("/home/we/dust/audio/breakbeat/bpm120/beats8_bpm120_rb_drum_loop_break_duke_120.wav",clock.get_tempo(),120)
e.bb_load("/home/we/dust/audio/breakbeat/bpm120/beats8_bpm120_rb_drum_loop_break_west_120.wav",clock.get_tempo(),120)
e.bb_load("/home/we/dust/audio/breakbeat/bpm120/beats8_bpm120_rb_drum_loop_break_pult_120.wav",clock.get_tempo(),120)
e.bb_amp(0.7)
ta:rm("bb")
play("bb",er("if math.random()<0.5 then e.bb_sync((<sn>-1)%64/64) end",4))

tapebreak()
tapestop()
tapestart()

-- waiting

params:set("clock_tempo",136)
sched:start()
sched:stop()

ta:rm("op1")
play("op1","Dm",1)
play("op1","Am:3",2)
play("op1","Bb:3",3)
play("op1","C Am/C",4)

ta:rm("sh")
play("sh",". f4 f4",1)
play("sh","e4 . f .  d . . . ",2)
play("sh",". g4 f",3)
play("sh",". e4 . f .  e . . . ",4)
play("sh",". f4 f4",5)
play("sh",". e4 . f .  d . . . ",6)
play("sh",". . f4 . . g4 . .",7)
play("sh",". . a4 . . . . .",8)

e.d_amp(0.0)
play("drone",sound("c5","e.d_midi(<m>)"),1)

ta:rm("geo")
play("geo","d1 d1 a1 d d d1 a1 d",1)
play("geo","a1 a1 e1 a a e1 a1 e",2)
play("geo","bb1 bb f1 bb bb bb1 f1 bb",3)
play("geo","c1 c g c c a c1 a",4)


e.bb_amp(0.4)
play("bb",er("if math.random()<0.5 then e.bb_sync((<sn>-1)%64/64) end",4))
play("bbb",er("if math.random()<0.1 then; v=math.random(); e.bb_break(v,v+math.random()/40+0.01) end",4),1)

-- tock

params:set("clock_tempo",168)
sched:start()
sched:stop()

nature(0)
e.s_amp(1,0)

stop("op1")
expand("op1",8)
play("op1","G/B:3",1)
play("op1","G/D:4",2)
play("op1","Bm:3",3)
play("op1","Bm/F#:4",4)
play("op1","F#m/A:3",5)
play("op1","F#m/C#:4",6)
play("op1","Amaj:3",7)
play("op1","Amaj/E:4",8)

stop("geo")
play("geo","b2 d3 b2 a2 f#3 g4 g4 a4",1)
play("geo","d3 e3 f#4 a4 g4 f#4 b1 a1",2)
play("geo","b2 . . . b2 . . .  e3 . d3 . f#3 . g3 .",1)
play("geo",". d3 .  e3  d3  . f#1  . . g1 . . ",2)
play("geo","b2",1)
play("geo","d2",2)

stop("kick")
play("kick",er(2),1)
play("kick",er_add(er(2),rot(er(1),3)),2)
kick.patch.level=-1
stop("hh")
play("hh",er_sub(er(16),er(4)),1)
hh.patch.level=1

stop("sd")
play("sd",er_add(rot(er(2),4),rot(er(4),2)),1)
sd.patch.distAmt=58; sd.patch.level=-5; sd.patch.nEnvDcy=220;
stop("clap")
play("clap",rot(er(2),4),1)
clap.patch.level=0

stop("crow")
crow.output[2].action="{ to(10,0),to(0,0.05) }"; crow.output[2]()
play("crow","d5 b d b d g b d d5  b d d5 b b g g",1)
play("sh","b5 d f#5 b d b f#6 d",2)
play("sh","f#5 a5 c#6 c# a c#5 f# a",3)
play("sh","a5 c# e c# e5 e a6 c# ",4)


crow.output[2].action="{ to(10,2),to(0,6) }"; crow.output[2]()
crow.output[3].action="lfo(3.1415,10)"; crow.output[3]()
stop("crow")
play("crow","d3",1)
play("crow","f#3",3)
play("crow","f#3 g",5)
play("crow","b2",8)
play("crow","b2",9)
play("crow","c#4",10)
play("crow","e4",12)
play("crow","a3",14)

tapestop()
tapestart()
tapebreak()

e.bb_load("/home/we/dust/audio/breakbeat/breakbeat_168bpm_4beats.wav",clock.get_tempo(),168)
e.bb_load("/home/we/dust/audio/live/breakbeat168bpm.wav",clock.get_tempo(),168)
e.bb_load("/home/we/dust/audio/live/breakbeat_165bpm.wav",clock.get_tempo(),165)
e.bb_amp(0.6)
play("bb",er("if math.random()<0.5 then e.bb_sync((<sn>-1)%64/64) end",4))
play("bbb",er("if math.random()<0.1 then; v=math.random(); e.bb_break(v,v+math.random()/40+0.01) end",4),1)

juststop()
juststart()

ta:rm("kick")
ta:rm("hh")
play("hh",er("hh:hit()",6),1)
play("hh",sub(er("hh:hit()",15),er("hh:hit()",4)),2)
play("hh",sub(er("hh:hit()",15),er("hh:hit()",2)),3)

kick.patch.distAmt=5; kick.patch.oscDcy=500
kick.patch.level=0; hh.patch.level=2
e.bl()

juststop()
juststart()

play("drone",sound("a3","e.d_midi(<m>)"),2)
play("drone",sound("e4","e.d_midi(<m>)"),3)
play("drone",sound("d4","e.d_midi(<m>)"),4)

e.bb_load("/home/we/dust/code/gatherum/data/breakbeats_160bpm2_4beats.wav",clock.get_tempo(),160)
e.bb_amp(0.2)
ta:rm("bb")
play("bb",er("if math.random()<0.5 then e.bb_sync((<sn>-1)%64/64) end",4))
ta:rm("bbb")
play("bbb",er("if math.random()<0.4 then; v=math.random(); e.bb_break(v,v+math.random()/40+0.01) end",4),1)
