-- live

engine.name="IDLive"

-- this order matters
include("gatherum/lib/utils")
music=include("gatherum/lib/music")
include("gatherum/lib/live")
lattice=require("lattice")
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
end

 
function key(k,z)
  if k==2 and z==1 then
      sched:start()
      e.bb_load("/home/we/dust/code/gatherum/data/beats16_bpm150_Ultimate_Jack_Loops_014__BPM_150_.wav",clock.get_tempo(),150)
      e.bb_amp(0.5)
      ta:add("bb",er("if math.random()<0.5 then e.bb_sync((<sn>-1)%64/64) end",4))
      ta:add("bbb",er("if math.random()<0.4 then; v=math.random(); e.bb_break(v,v+math.random()/40+0.01) end",4),1)
      ta:add("bbbamp",er("e.bb_amp(0.5)",1),1)
      ta:add("bbbamp",er("e.bb_amp(1)",1),2)
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