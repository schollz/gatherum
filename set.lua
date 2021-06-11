norns.script.load("code/gatherum/live.lua")

tapestop()
tapestart()
tapebreak()

params:set("clock_tempo",120)

play("bou","Abm/Eb:3",1)
play("bou","E:3",2)
play("bou","Gb/Db:3",3)
play("bou","Ebm:3",4)

e=engine

e.s_load(1,"/home/we/dust/closer.wav");
e.s_amp(1,1.0);
play("closer",er("engine.s_mov(1,3/28)",1),1)
stop("closer")
ta:expand("closer",64)

play("kick",er(2),1)
play("kick",er_add(er(2),rot(er(1),3)),2)
play("hh",er_sub(er(13),er(4)),1)
play("clap",rot(er(2),4),1)

play("bou","Abm/Eb:3",5)
play("bou","E:3",6)
play("bou","Gb:3",7)
play("bou","Db/F:3",8)

play("closer",er("e.s_mov(1,26/28)",1),4)

play("op1",shufexpand("bb4 bb3 eb4 ab4 db4"),1)

play("usb","ab1",1)
play("usb","b2",2)
play("usb","gb1",3)
play("usb","eb1",4)

e.s_amp(1,0.0);

crow.output[2].action="{ to(10,2),to(0,6) }";crow.output[2]()
crow.output[3].action="lfo(3,10)";crow.output[3]()
play("crow","ab3",1)
play("crow","gb4",3)
play("crow","bb4",4)

crow.output[2].action="{ to(10,0),to(0,0.07) }";crow.output[2]()
play("crow",shufexpand("ab4 bb3 eb3 ab3 bb4",16),1)

stop("usb")
play("usb",shufexpand("ab1 ab1 ab1 eb2 eb2 ."),1)
play("usb","ab1 ab ab . ab  . eb ab ab1 ab ab . ab  . eb ab",1)
play("usb","b2  e1 e1 . b2  . g# b b2  e1 e1 . b2  . g# b",2)
play("usb","gb1 gb db . gb3 . b  db gb1 gb db . gb3 . b  db",3)
play("usb","eb1 eb bb . bb .  ab bb eb1 eb bb . bb .  ab bb",4)

-- todo copy over
e.bb_load("/home/we/dust/audio/breakbeat/bpm120/beats8_bpm120_rb_drum_loop_break_byrd_120.wav",clock.get_tempo(),120)
e.bb_load("/home/we/dust/audio/breakbeat/bpm120/beats8_bpm120_rb_drum_loop_break_duke_120.wav",clock.get_tempo(),120)
e.bb_load("/home/we/dust/audio/breakbeat/bpm120/beats8_bpm120_rb_drum_loop_break_pult_120.wav",clock.get_tempo(),120)
e.bb_load("/home/we/dust/audio/breakbeat/bpm120/beats8_bpm120_rb_drum_loop_break_west_120.wav",clock.get_tempo(),120)
e.bb_load("/home/we/dust/audio/breakbeat/bpm120/beats8_bpm120_adt_120_drum_break_vinylised.wav",clock.get_tempo(),120)
e.bb_load("/home/we/dust/drum1.wav",clock.get_tempo(),120)
e.bb_amp(0.5)
e.bb_amp(0.0)
play("bbr",er("if math.random()<0.2 then e.bb_rev(1) end",5))
play("bbb",er("if math.random()<0.1 then; v=math.random(); e.bb_break(v,v+math.random()/40+0.01) end",4),1)

clock.run(function() clock.sleep(1);tapestop();clock.sleep(3);tapestart() end)
clock.run(function() clock.sleep(1);tapebreak() clock.sleep(1);tapebreak() end)
tapestop()
tapestart()

-- tock
params:set("clock_tempo",168)

e.s_load(1,"/home/we/dust/audio/ladadadida.wav");
play("la",er("engine.s_mov(1,0)",1),1)
ta:expand("la",8)
e.s_amp(1,0.2)

play("bou","G/B:3",1)
play("bou","Bm:3",3)
play("bou","F#m/A:3",5)
play("bou","Amaj:3",7)
play("bou","Amaj:3",8)

play("usb","b2",1)
play("usb","d2",2)

play("op1","f#5 . e5 c#5 f#5 . e5 c#5",1/2)
play("op1","f#5 . d5 c#5 f#5 . d5 c#5",3/4)
play("op1","a5 . d5 c#5 a5 . d5 c#5",5/6)
play("op1","b5 . e5 c#5 b5 . e5 c#5",7/8)

play("usb","b2 d3 b2 a2 f#3 g4 g4 a4",1)
play("usb","d3 e3 f#4 a4 g4 f#4 b1 a1",2)
play("usb","b2 . . . b2 . . .  e3 . d3 . f#3 . g3 .",1)
play("usb",". . d3 .  e3  d3  . f#1  . . g1 . . ",2)

stop("crow")
crow.output[2].action="{ to(10,0),to(0,0.07) }";crow.output[2]()
play("crow",shufexpand("d5 b4 g5",16),1)

crow.output[2].action="{ to(10,2),to(0,6) }";crow.output[2]()
crow.output[3].action="lfo(3.1415,10)";crow.output[3]()
stop("crow")
ta:expand("crow",8)
play("crow","d3",1)
play("crow","f#3",3)
play("crow","a3",5)
play("crow","e4",7)
play("crow","e4",8)

e.bb_load("/home/we/dust/audio/live/breakbeat168bpm.wav",clock.get_tempo(),168)
e.bb_load("/home/we/dust/audio/live/breakbeat_165bpm.wav",clock.get_tempo(),165)
e.bb_load("/home/we/dust/audio/breakbeat/breakbeat_168bpm_4beats.wav",clock.get_tempo(),168)
e.bb_load("/home/we/dust/audio/breakbeat/bpm165/beats8_bpm165_Duplex_Break_165_PL.wav",clock.get_tempo(),165)
e.bb_load("/home/we/dust/audio/breakbeat/bpm165/beats8_bpm165_Rope_Break_165_PL.wav",clock.get_tempo(),165)
e.bb_load("/home/we/dust/audio/breakbeat/bpm165/beats8_bpm165_Absorb_Break_165_PL.wav",clock.get_tempo(),165)
e.bb_amp(0.0)
e.bb_amp(0)

nature(1.0)
