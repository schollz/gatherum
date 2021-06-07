--   _   _   _   _   _   _   _   _     _   _   _   _   _   _  
--  / \ / \ / \ / \ / \ / \ / \ / \   / \ / \ / \ / \ / \ / \ 
-- ( i | n | f | i | n | i | t | e ) ( d | i | g | i | t | s )
--  \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/   \_/ \_/ \_/ \_/ \_/ \_/ 


-- don't forget
-- vim run  :silent.w !wscat
-- time authority   ta:rm ta:add(name,er,index)


norns.script.load("code/gatherum/live.lua")
sched:start()

ta:rm("kick")
ta:add("kick",er("kick:hit()",1),2)
ta:add("kick",add(er("kick:hit()",2),rot(er("kick:hit()",1),3)),1)

ta:rm("hh")
ta:add("hh",er("hh:hit()",15),1)
ta:add("hh",sub(er("hh:hit()",15),er("hh:hit()",4)),2)
ta:add("hh",sub(er("hh:hit()",15),er("hh:hit()",2)),3)

kick.patch.distAmt=8; kick.patch.oscDcy=500
kick.patch.level=-10; hh.patch.level=-10
e.bl()

juststop()
juststart()

e.d_amp(0.00)
ta:add("drone",sound("c4","e.d_midi(<m>)"),1)
ta:add("drone",sound("a3","e.d_midi(<m>)"),2)
ta:add("drone",sound("e4","e.d_midi(<m>)"),3)
ta:add("drone",sound("d4","e.d_midi(<m>)"),4)

e.bb_load("/home/we/dust/code/gatherum/data/breakbeats_160bpm2_4beats.wav",clock.get_tempo(),160)
e.bb_amp(0.00)
ta:rm("bb")
ta:add("bb",er("if math.random()<0.5 then e.bb_sync((<sn>-1)%64/64) end",4))
ta:rm("bbb")
ta:add("bbb",er("if math.random()<0.4 then; v=math.random(); e.bb_break(v,v+math.random()/40+0.01) end",4),1)
