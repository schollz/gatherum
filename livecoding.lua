--   _   _   _   _   _   _   _   _     _   _   _   _   _   _  
--  / \ / \ / \ / \ / \ / \ / \ / \   / \ / \ / \ / \ / \ / \ 
-- ( i | n | f | i | n | i | t | e ) ( d | i | g | i | t | s )
--  \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/   \_/ \_/ \_/ \_/ \_/ \_/ 


norns.script.load("code/tuner/tuner.lua"); crow.output[1].volts=3 -- A3

-- don't forget
-- vim run  :silent.w !wscat
-- time authority   ta:rm ta:add(name,er,index)

norns.script.load("code/gatherum/live.lua")

-- pre show

e.s_load(1,"/home/we/dust/audio/field/birds_eating.wav"); e.s_load(2,"/home/we/dust/audio/field/birds_morning.wav"); e.s_load(3,"/home/we/dust/audio/field/ocean_waves_puget_sound.wav"); 
local vol=3.0 for i=1,3 do e.s_amp(i,vol/(i*i*i)) end

-- waiting

params:set("clock_tempo",136)
sched:start()
sched:stop()

ta:rm("op1")
ta:addm("op1","Dm",1)
ta:addm("op1","Am:3",2)
ta:addm("op1","Bb:3",3)
ta:addm("op1","C Am/C",4)

ta:addm("op1",". f4 f4",1)
ta:addm("op1",". e4 . f .  d . . . ",2)
ta:addm("op1",". g4 f",3)
ta:addm("op1",". e4 . f .  e . . . ",4)
ta:addm("op1",". f4 f4",5)
ta:addm("op1",". e4 . f .  d . . . ",6)
ta:addm("op1","f4 g4",7)
ta:addm("op1","a4",8)

ta:rm("usb")
ta:addm("usb","d1 d1 a1 d d d1 a1 d",1)
ta:addm("usb","a1 a1 e1 a a e1 a1 e",2)
ta:addm("usb","bb1 bb f1 bb bb bb1 f1 bb",3)
ta:addm("usb","c1 c g c c a c1 a",4)

ta:addm("usb",". f4 f4",1)
ta:addm("usb",". e4 . f .  d . . . ",2)
ta:addm("usb",". g4 f",3)
ta:addm("usb",". e4 . f .  e . . . ",4)
ta:addm("usb",". f4 f4",5)
ta:addm("usb",". e4 . f .  d . . . ",6)
ta:addm("usb","f4 g4",7)
ta:addm("usb","a4",8)

ta:rm("strega")
ta:add("strega",sound("a4","crow.output[1].volts=<v>"),1)

ta:add("strega",sound(". f3 f3","crow.output[1].volts=<v>"),1)
ta:add("strega",sound(". e3 . f3 . d3 . . .","crow.output[1].volts=<v>"),2)
ta:add("strega",sound(". g3 f3","crow.output[1].volts=<v>"),3)
ta:add("strega",sound(". e3 . f3 . e3 . . .","crow.output[1].volts=<v>"),4)
ta:add("strega",sound(". f3 f3","crow.output[1].volts=<v>"),5)
ta:add("strega",sound(". e3 . f3 . d3 . . .","crow.output[1].volts=<v>"),6)
ta:add("strega",sound("f3 g","crow.output[1].volts=<v>"),7)
ta:add("strega",sound("a3","crow.output[1].volts=<v>"),8)

e.bb_load("/home/we/dust/audio/breakbeat/breakbeat_136bpm_4beats.wav",clock.get_tempo(),136)
e.bb_amp(0.0)
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
ta:add("kick",er("kick:hit()",2),1)
ta:add("kick",add(er("kick:hit()",2),rot(er("kick:hit()",1),3)),2)


ta:add("strega",sound("d4","crow.output[1].volts=<v>"),1)
ta:add("strega",sound("f#4","crow.output[1].volts=<v>"),2)
ta:add("strega",sound("f#4 g","crow.output[1].volts=<v>"),3)
ta:add("strega",sound("a4","crow.output[1].volts=<v>"),4)
ta:expand("strega",7)

e.d_amp(0.0)
ta:add("drone",sound("d1","e.d_midi(<m>)"),1)
ta:add("drone",sound("b1","e.d_midi(<m>)"),4)
ta:add("drone",sound("d5","e.d_midi(<m>)"),1)
ta:add("drone",sound("b4","e.d_midi(<m>)"),4)

ta:add("drone",sound("d1","e.d_midi(<m>)"),1)


e.bb_load("/home/we/dust/audio/breakbeat/breakbeat_168bpm_4beats.wav",clock.get_tempo(),168)
e.bb_amp(0.0)
ta:add("bb",er("if math.random()<0.5 then e.bb_sync((<sn>-1)%64/64) end",4))
ta:add("bbb",er("if math.random()<0.1 then; v=math.random(); e.bb_break(v,v+math.random()/40+0.01) end",4),1)

juststop()
juststart()


ta:rm("hh")
ta:add("hh",er("hh:hit()",6),1)
ta:add("hh",sub(er("hh:hit()",15),er("hh:hit()",4)),2)
ta:add("hh",sub(er("hh:hit()",15),er("hh:hit()",2)),3)

kick.patch.distAmt=5; kick.patch.oscDcy=500
kick.patch.level=-5; hh.patch.level=-5
e.bl()

juststop()
juststart()

ta:add("drone",sound("a3","e.d_midi(<m>)"),2)
ta:add("drone",sound("e4","e.d_midi(<m>)"),3)
ta:add("drone",sound("d4","e.d_midi(<m>)"),4)

e.bb_load("/home/we/dust/code/gatherum/data/breakbeats_160bpm2_4beats.wav",clock.get_tempo(),160)
e.bb_amp(0.1)
ta:rm("bb")
ta:add("bb",er("if math.random()<0.5 then e.bb_sync((<sn>-1)%64/64) end",4))
ta:rm("bbb")
ta:add("bbb",er("if math.random()<0.4 then; v=math.random(); e.bb_break(v,v+math.random()/40+0.01) end",4),1)
