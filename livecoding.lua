norns.script.load("code/tuner/tuner.lua"); crow.output[1].volts=3 -- A3

-- don't forget
-- nnoremap <C-enter> <esc>:silent.w !wscat>>out<enter>i
-- inoremap <C-enter> <esc>:silent.w !wscat>>out<enter>i
-- vim run  :silent.w !wscat
-- time authority   ta:rm ta:add(name,er,index)

norns.script.load("code/gatherum/live.lua")

-- pre show

e.s_load(1,"/home/we/dust/audio/field/birds_eating.wav"); e.s_load(2,"/home/we/dust/audio/field/birds_morning.wav"); e.s_load(3,"/home/we/dust/audio/field/ocean_waves_puget_sound.wav"); 
local vol=0.0 for i=1,3 do e.s_amp(i,vol/(i*i*i)) end


-- closer
params:set("clock_tempo",120)
sched:start()

e.s_load(1,"/home/we/dust/audio/live/closer.wav"); 
e.s_amp(1,0.5); 
e.s_mov(1,3/28)
ta:rm("closer")
ta:expand("closer",64)
ta:add("closer",er("e.s_mov(1,3/8)",1),1)

ta:rm("bou")
ta:addm("bou","ab6 bb5 eb5 ab6 eb bb . .",1)
ta:addm("bou",". b6 . b5 e5 g#6 eb b",2)
ta:addm("bou","gb6 db5 bb6 db bb . .",3)
ta:addm("bou","db6 ab . . . db f5 f4",4)

ta:rm("op1")
ta:addm("op1","Abm/Eb:3",1)
ta:addm("op1","E:3",2)
ta:addm("op1","Gb/Db:3",3)
ta:addm("op1","Ebm:3",4)
ta:addm("op1","Abm/Eb:3",5)
ta:addm("op1","E:3",6)
ta:addm("op1","Gb:3",7)
ta:addm("op1","Db/F:3",8)

e.d_amp(0.0)
ta:add("drone",sound("db6","e.d_midi(<m>)"),1)

ta:rm("usb")
ta:addm("usb","ab1 ab ab . ab  . eb ab ab1 ab ab . ab  . eb ab",1)
ta:addm("usb","b2  e1 e1 . b2  . g# b b2  e1 e1 . b2  . g# b",2)
ta:addm("usb","gb1 gb db . gb3 . b  db gb1 gb db . gb3 . b  db",3)
ta:addm("usb","eb1 eb bb . bb .  ab bb eb1 eb bb . bb .  ab bb",4)

e.bb_load("/home/we/dust/audio/breakbeat/bpm120/beats8_bpm120_adt_120_drum_break_leak.wav",clock.get_tempo(),120)
e.bb_load("/home/we/dust/audio/breakbeat/bpm120/beats8_bpm120_rb_drum_loop_break_byrd_120.wav",clock.get_tempo(),120)
e.bb_load("/home/we/dust/audio/breakbeat/bpm120/beats8_bpm120_rb_drum_loop_break_duke_120.wav",clock.get_tempo(),120)
e.bb_load("/home/we/dust/audio/breakbeat/bpm120/beats8_bpm120_rb_drum_loop_break_west_120.wav",clock.get_tempo(),120)
e.bb_load("/home/we/dust/audio/breakbeat/bpm120/beats8_bpm120_rb_drum_loop_break_pult_120.wav",clock.get_tempo(),120)
e.bb_amp(0.3)
ta:rm("bb")
ta:add("bb",er("if math.random()<0.5 then e.bb_sync((<sn>-1)%64/64) end",4))

juststop()
juststart()

-- waiting

params:set("clock_tempo",136)
sched:start()
sched:stop()

ta:rm("op1")
ta:addm("op1","Dm",1)
ta:addm("op1","Am:3",2)
ta:addm("op1","Bb:3",3)
ta:addm("op1","C Am/C",4)

ta:rm("bou")
ta:addm("bou",". f4 f4",1)
ta:addm("bou","e4 . f .  d . . . ",2)
ta:addm("bou",". g4 f",3)
ta:addm("bou",". e4 . f .  e . . . ",4)
ta:addm("bou",". f4 f4",5)
ta:addm("bou",". e4 . f .  d . . . ",6)
ta:addm("bou",". . f4 . . g4 . .",7)
ta:addm("bou",". . a4 . . . . .",8)

e.d_amp(0.0)
ta:add("drone",sound("c5","e.d_midi(<m>)"),1)

ta:rm("usb")
ta:addm("usb","d1 d1 a1 d d d1 a1 d",1)
ta:addm("usb","a1 a1 e1 a a e1 a1 e",2)
ta:addm("usb","bb1 bb f1 bb bb bb1 f1 bb",3)
ta:addm("usb","c1 c g c c a c1 a",4)


e.bb_amp(0.4)
ta:add("bb",er("if math.random()<0.5 then e.bb_sync((<sn>-1)%64/64) end",4))
ta:add("bbb",er("if math.random()<0.1 then; v=math.random(); e.bb_break(v,v+math.random()/40+0.01) end",4),1)

-- tock

params:set("clock_tempo",168)
sched:start()
sched:stop()

ta:rm("op1")
ta:expand("op1",8)
ta:addm("op1","G/B:3",1)
ta:addm("op1","G/D:4",2)
ta:addm("op1","Bm:3",3)
ta:addm("op1","Bm/F#:4",4)
ta:addm("op1","F#m/A:3",5)
ta:addm("op1","F#m/C#:4",6)
ta:addm("op1","Amaj:3",7)
ta:addm("op1","Amaj/E:4",8)

ta:rm("usb")
ta:addm("usb","b2 d3 b2 a2 f#3 g4 g4 a4",1)
ta:addm("usb","d3 e3 f#4 a4 g4 f#4 b1 a1",2)
ta:addm("usb","b2 . . . b2 . . .  e3 . d3 . f#3 . g3 .",1)
ta:addm("usb",". d3 .  e3  d3  . f#1  . . g1 . . ",2)
ta:addm("usb","b2",1)
ta:addm("usb","d2",2)

ta:rm("kick")
ta:add("kick",er("kick:hit()",4),1)
ta:add("kick",add(er("kick:hit()",2),rot(er("kick:hit()",1),3)),2)

ta:rm("bou")
ta:addm("bou","d5 b d b d g b d ",1)
ta:addm("bou","b5 d f#5 b d b f#6 d",2)
ta:addm("bou","f#5 a5 c#6 c# a c#5 f# a",3)
ta:addm("bou","a5 c# e c# e5 e a6 c# ",4)


ta:rm("drone")
e.d_amp(0.6)
ta:add("drone",sound("d5","e.d_midi(<m>)"),1)
ta:add("drone",sound("f#5","e.d_midi(<m>)"),2)
ta:add("drone",sound("f#5 g","e.d_midi(<m>)"),3)
ta:add("drone",sound("b4","e.d_midi(<m>)"),4)



e.bb_load("/home/we/dust/audio/breakbeat/breakbeat_168bpm_4beats.wav",clock.get_tempo(),168)
e.bb_load("/home/we/dust/audio/live/breakbeat168bpm.wav",clock.get_tempo(),168)
e.bb_load("/home/we/dust/audio/live/breakbeat_165bpm.wav",clock.get_tempo(),165)
e.bb_amp(0.3)
ta:add("bb",er("if math.random()<0.5 then e.bb_sync((<sn>-1)%64/64) end",4))
ta:add("bbb",er("if math.random()<0.1 then; v=math.random(); e.bb_break(v,v+math.random()/40+0.01) end",4),1)

juststop()
juststart()

ta:rm("kick")
ta:rm("hh")
ta:add("hh",er("hh:hit()",6),1)
ta:add("hh",sub(er("hh:hit()",15),er("hh:hit()",4)),2)
ta:add("hh",sub(er("hh:hit()",15),er("hh:hit()",2)),3)

kick.patch.distAmt=5; kick.patch.oscDcy=500
kick.patch.level=0; hh.patch.level=2
e.bl()

juststop()
juststart()

ta:add("drone",sound("a3","e.d_midi(<m>)"),2)
ta:add("drone",sound("e4","e.d_midi(<m>)"),3)
ta:add("drone",sound("d4","e.d_midi(<m>)"),4)

e.bb_load("/home/we/dust/code/gatherum/data/breakbeats_160bpm2_4beats.wav",clock.get_tempo(),160)
e.bb_amp(0.2)
ta:rm("bb")
ta:add("bb",er("if math.random()<0.5 then e.bb_sync((<sn>-1)%64/64) end",4))
ta:rm("bbb")
ta:add("bbb",er("if math.random()<0.4 then; v=math.random(); e.bb_break(v,v+math.random()/40+0.01) end",4),1)
