-- if it ain't broken
-- break it


engine.name="Breakcore"

amp=0
function init()
  print("init")
end

function key(k,z)
  if k==2 and z==1 then 
    print("loading engine")
    engine.bb_load("/home/we/dust/code/infinitedigits/data/beats16_bpm150_Ultimate_Jack_Loops_014__BPM_150_.wav",150)
    engine.bb_bpm(clock.get_tempo())
  elseif k==3 and z==1 then 
    print("loading engine")
    engine.bb_load("/home/we/dust/code/infinitedigits/data/breakbeats_160bpm2.wav",160)
    engine.bb_bpm(clock.get_tempo())
  end
  redraw()
end

function enc(k,d)
  amp = util.clamp(amp+d/10,0,1)
  engine.bb_amp(amp)
end

function redraw()
  screen.clear()
  screen.move(64,32)
  screen.text_center("if it ain't broke, break it.")
  screen.update()
end