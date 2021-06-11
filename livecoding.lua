-- vim
-- nnoremap <C-c> <esc>:silent.w !wscat<enter>
-- inoremap <C-c> <esc>:silent.w !wscat<enter>i
-- vim run  :silent.w !wscat

norns.script.load("code/tuner/tuner.lua"); crow.output[1].volts=3 -- A3
norns.script.load("code/gatherum/live.lua")

nature(0.0)

tapebreak()
tapestop()
tapestart()

-- closer
params:set("clock_tempo",120)

e.s_load(1,"/home/we/dust/audio/live/closer.wav"); 
e.s_amp(1,1.2);
e.s_amp(1,0); 
e.s_mov(1,3/28)
e.s_mov(1,26/28)
ta:expand("closer",64)
play("closer",er("engine.s_mov(1,3/28)",1),1)
play("closer",er("e.s_mov(1,26/28)",1),4)
stop("closer")

crow.output[2].action="{ to(10,2),to(0,6) }"; crow.output[2]()
crow.output[3].action="lfo(3.1415,10)"; crow.output[3]()
stop("crow")
ta:expand("crow",8)
play("crow","ab3",1)
play("crow","db4",3)
play("crow",". eb4",5)
play("crow","gb4",7)
play("crow","gb4",8)


play("crow","ab4",1)
play("crow","bb4",1)
play("crow","gb4",1)

stop("crow")
crow.output[2].action="{ to(10,0),to(0,0.07) }"; crow.output[2]()
play("crow","ab4 ab4 bb3 eb3 ab eb bb bb3 eb ab eb db bb ab eb bb ",1)
crow.output[2].action="{ to(10,0),to(0,0.2) }"; crow.output[2]()

stop("op1")
ta:add("op1cc1",er('mp:cc("op1",1,lfo(11,60,80))',12),1)
ta:add("op1cc4",er('mp:cc("op1",4,lfo(3,10,60))',12),1)
play("op1","bb4 bb3 eb4 ab4 eb4 db4 bb4 ab bb4 bb3 eb4 ab4 eb4 db4 bb4 ab",1)
play("op1","gb4 db4 bb4 db4 bb4 gb4 gb4 db4 bb4 db4 bb4 ab4 bb4 ab4 gb4 eb4",2)

stop("bou")
ta:add("shcc",er('mp:cc("bou",26,lfo(7.1,0,127))',12),1)
ta:add("shcc2",er('mp:cc("bou",19,lfo(7.2,0,127))',12),1)
ta:add("shcc3",er('mp:cc("bou",15,lfo(7.3,0,127))',12),1)
play("bou","Abm/Eb:3",1)
play("bou","E:3",2)
play("bou","Gb/Db:3",3)
play("bou","Ebm:3",4)
play("bou","Abm/Eb:3",5)
play("bou","E:3",6)
play("bou","Gb:3",7)
play("bou","Db/F:3",8)

stop("drone")
e.d_amp(0.1)
play("drone","eb5",1)
play("drone","bb5",5)
play("drone","db4",8)

stop("usb")
play("usb","ab1 ab ab . ab  . eb ab ab1 ab ab . ab  . eb ab",1)
play("usb","b2  e1 e1 . b2  . g# b b2  e1 e1 . b2  . g# b",2)
play("usb","gb1 gb db . gb3 . b  db gb1 gb db . gb3 . b  db",3)
play("usb","eb1 eb bb . bb .  ab bb eb1 eb bb . bb .  ab bb",4)

e.bb_load("/home/we/dust/audio/breakbeat/bpm120/beats8_bpm120_rb_drum_loop_break_byrd_120.wav",clock.get_tempo(),120)
e.bb_load("/home/we/dust/audio/breakbeat/bpm120/beats8_bpm120_rb_drum_loop_break_duke_120.wav",clock.get_tempo(),120)
e.bb_load("/home/we/dust/audio/breakbeat/bpm120/beats8_bpm120_rb_drum_loop_break_pult_120.wav",clock.get_tempo(),120)
e.bb_load("/home/we/dust/audio/breakbeat/bpm120/beats8_bpm120_rb_drum_loop_break_west_120.wav",clock.get_tempo(),120)
e.bb_load("/home/we/dust/audio/breakbeat/bpm120/beats8_bpm120_adt_120_drum_break_vinylised.wav",clock.get_tempo(),120)
e.bb_amp(1.0)
e.bb_amp(0.0)
ta:rm("bb")
play("bb",er("if math.random()<0.5 then e.bb_sync((<sn>-1)%64/64) end",4))

clock.run(function() clock.sleep(1); tapestop(); clock.sleep(3); tapestart() end)
clock.run(function() clock.sleep(1); tapebreak() clock.sleep(4); tapebreak() end)
tapestop()
tapestart()

-- waiting

params:set("clock_tempo",136)
sched:start()
sched:stop()

stop("op1")
play("op1","Dm",1)
play("op1","Am:3",2)
play("op1","Bb:3",3)
play("op1","C Am/C",4)

stop("bou")
play("bou",". f4 f4",1)
play("bou","e4 . f .  d . . . ",2)
play("bou",". g4 f",3)
play("bou",". e4 . f .  e . . . ",4)
play("bou",". f4 f4",5)
play("bou",". e4 . f .  d . . . ",6)
play("bou",". . f4 . . g4 . .",7)
play("bou",". . a4 . . . . .",8)

e.d_amp(0.0)
play("drone",sound("c5","e.d_midi(<m>)"),1)

ta:rm("usb")
play("usb","d1 d1 a1 d d d1 a1 d",1)
play("usb","a1 a1 e1 a a e1 a1 e",2)
play("usb","bb1 bb f1 bb bb bb1 f1 bb",3)
play("usb","c1 c g c c a c1 a",4)


e.bb_amp(0.4)
play("bb",er("if math.random()<0.5 then e.bb_sync((<sn>-1)%64/64) end",4))
play("bbb",er("if math.random()<0.1 then; v=math.random(); e.bb_break(v,v+math.random()/40+0.01) end",4),1)

-- tock

params:set("clock_tempo",168)
sched:start()
sched:stop()

nature(1.0)
e.s_amp(1,0)

stop("bou")
ta:expand("bou",8)
play("bou","G/B:3",1)
play("bou","Bm:3",3)
play("bou","F#m/A:3",5)
play("bou","Amaj:3",7)
play("bou","Amaj:3",8)

stop("op1")
play("op1","f#5 . e5 c#5 f#5 . e5 c#5",1)
play("op1","f#5 . e5 c#5 f#5 . e5 c#5",2)
play("op1","f#5 . d5 c#5 f#5 . d5 c#5",3)
play("op1","f#5 . d5 c#5 f#5 . d5 c#5",4)
play("op1","a5 . d5 c#5 a5 . d5 c#5",5)
play("op1","a5 . d5 c#5 a5 . d5 c#5",6)
play("op1","b5 . e5 c#5 b5 . e5 c#5",7)
play("op1","b5 . e5 c#5 b5 b5 b5 b5",8)


stop("usb")
play("usb","b2 d3 b2 a2 f#3 g4 g4 a4",1)
play("usb","d3 e3 f#4 a4 g4 f#4 b1 a1",2)
play("usb","b2 . . . b2 . . .  e3 . d3 . f#3 . g3 .",1)
play("usb",". . d3 .  e3  d3  . f#1  . . g1 . . ",2)
play("usb","b2",1)
play("usb","d2",2)

stop("kick")
play("kick",er(1),1)
play("kick",er_add(er(2),rot(er(1),3)),2)
kick.patch.level=-1
stop("hh")
play("hh",er_sub(er(13),er(4)),1)
hh.patch.level=1

stop("clap")
play("clap",rot(er(2),4),1)
play("clap",rot(er(1),4),2)
clap.patch.level=0


stop("crow")
crow.output[2].action="{ to(10,0),to(0,0.07) }"; crow.output[2]()
play("crow","d5 b d b d g b d d5  b d d5 b b g g",1)
play("crow","b5 d f#5 b d b f#6 d",2)
play("crow","f#5 a5 c#6 c# a c#5 f# a",3)
play("crow","a5 c# e c# e5 e a6 c# ",4)


crow.output[2].action="{ to(10,2),to(0,6) }"; crow.output[2]()
crow.output[3].action="lfo(3.1415,10)"; crow.output[3]()
stop("crow")
ta:expand("crow",8)
play("crow","d3",1)
play("crow","f#3",3)
play("crow","a3",5)
play("crow","e4",7)
play("crow","b2",9)
play("crow","c#4",10)
play("crow","e4",12)
play("crow","a3",14)

tapestop()
tapestart()
tapebreak()
e.bb_amp(0.7)

e.bb_load("/home/we/dust/audio/breakbeat/breakbeat_168bpm_4beats.wav",clock.get_tempo(),168)
e.bb_load("/home/we/dust/audio/live/breakbeat168bpm.wav",clock.get_tempo(),168)
e.bb_load("/home/we/dust/audio/live/breakbeat_165bpm.wav",clock.get_tempo(),165)
e.bb_load("/home/we/dust/audio/breakbeat/bpm165/beats8_bpm165_Duplex_Break_165_PL.wav",clock.get_tempo(),165)
e.bb_load("/home/we/dust/audio/breakbeat/bpm165/beats8_bpm165_Rope_Break_165_PL.wav",clock.get_tempo(),165)
e.bb_load("/home/we/dust/audio/breakbeat/bpm165/beats8_bpm165_Absorb_Break_165_PL.wav",clock.get_tempo(),165)
e.bb_amp(0.8)
e.bb_amp(0)
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
