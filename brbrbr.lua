-- play audio in
-- press any key to break it

engine.name="Breaklive"

local amp=0

function init()
  print("init")
  audio.level_monitor(0)
  params:add{type="control",id="amp",name="amp",controlspec=controlspec.new(0,1,'lin',0,0,'amp',0.01/1),action=function(v)
    engine.bb_ampmin(v)
  end
  }
end

function key(k,z)
  engine.bb_break()
  engine.bb_rate(math.random(1,2)*2-3)
  engine.bb_bpm(clock.get_tempo())
end

function enc(k,d)
  params:delta("amp",d)
end

function redraw()
  screen.clear()
  screen.move(64,32)
  screen.text_center("<br></br><br></br><br></br>")
  screen.update()
end