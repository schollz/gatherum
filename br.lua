-- noisey breakbeats
-- turn any knob

engine.name="Breakcore"

function init()
  print("init")
  params:add{type="control",id="amp",name="amp",controlspec=controlspec.new(0,0.5,'lin',0,0,'amp',0.01/0.5),action=function(v)
    engine.bb_amp(v)
  end
  }
  engine.bb_load("/home/we/dust/code/infinitedigits/data/breakbeats_160bpm2.wav",160)
  engine.bb_bpm(clock.get_tempo())
end

function enc(k,d)
  params:delta("amp",d)
end

function redraw()
  screen.clear()
  screen.move(64,32)
  screen.text_center("<br></br>")
  screen.update()
end