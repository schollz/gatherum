-- live

engine.name="IDLive"

-- this order matters
include("gatherum/lib/utils")
music=include("gatherum/lib/music")
include("gatherum/lib/live")
lattice=require("lattice")
midipal_=include("gatherum/lib/midipal")
e=engine

function init()
  ta=TA:new()
  sched=lattice:new{
    ppqn=16
  }
  sched:new_pattern({
    action=function(t)
      ta:step()
      redraw()
    end,
    division=1/16,
  })
  mp=midipal_:new()
end

function key(k,z)
  if k==2 and z==1 then
      sched:start()
      ta:expand("op1",4)
      ta:addm("op1","Am:4",1)
      ta:addm("op1","Em:4",3)
      ta:addm("op1","F:4",4)
      ta:addm("op1","Am:4",5)
      ta:addm("op1","Dm:4",7)
      ta:addm("op1","F:4",8)
      ta:rm("op1")
      ta:addm("op1","Cma7:4",1)
      ta:addm("op1","Gma7/B:4",3)
      ta:addm("op1","Em7:4",4)
      e.d_amp(0.1)
      ta:add("drone",sound("a2","e.d_midi(<m>)"))
      ta:add("drone",sound("e2","e.d_midi(<m>)"),3)
      ta:add("drone",sound("f2","e.d_midi(<m>)"),4)
      -- ta:add("op1",sound("Amin7:4","mp:on('op1',<m>,<sn>)"),1)

      -- ta:add("op1",sound("Gmaj:4","mp:on('op1',<m>,<sn>)"),3)
      -- e.bb_load("/home/we/dust/code/gatherum/data/beats16_bpm150_Ultimate_Jack_Loops_014__BPM_150_.wav",clock.get_tempo(),150)
      e.bb_load("/home/we/dust/code/gatherum/data/breakbeats_160bpm2_4beats.wav",clock.get_tempo(),160)
      -- e.bb_amp(0.5)
      -- ta:add("bb",er("if math.random()<0.5 then e.bb_sync((<sn>-1)%64/64) end",4))
      -- ta:add("bbb",er("if math.random()<0.4 then; v=math.random(); e.bb_break(v,v+math.random()/40+0.01) end",4),1)
      -- ta:add("bbbamp",er("e.bb_amp(0.5)",1),1)
      -- ta:add("bbbamp",er("e.bb_amp(1)",1),2)
  elseif k==3 and z==1 then 
    sched:stop()
  end
end

 function redraw()
  screen.clear()
  screen.move(32,32)
  screen.text_center(ta.measure+1)
  screen.move(32+32,32)
  screen.text_center(ta.qn)
  screen.move(32+32+32,32)
  screen.text_center(ta.sn)
  screen.update()
 end

function rerun()
  norns.script.load(norns.state.script)
end