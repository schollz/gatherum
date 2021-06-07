--   _   _   _   _   _   _   _   _     _   _   _   _   _   _  
--  / \ / \ / \ / \ / \ / \ / \ / \   / \ / \ / \ / \ / \ / \ 
-- ( i | n | f | i | n | i | t | e ) ( d | i | g | i | t | s )
--  \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/   \_/ \_/ \_/ \_/ \_/ \_/ 


-- don't forget
-- vim run  :silent.w !wscat
-- time authority   ta:rm ta:add(name,er,index)


-- tock

params:set("clock_tempo",168)
norns.script.load("code/gatherum/live.lua")
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

e.d_amp(0.03)
ta:add("drone",sound("d5","e.d_midi(<m>)"),1)
ta:add("drone",sound("b4","e.d_midi(<m>)"),4)

e.bb_load("/home/we/dust/audio/breakbeat/breakbeat_168bpm_4beats.wav",clock.get_tempo(),168)
e.bb_amp(0.00)
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
