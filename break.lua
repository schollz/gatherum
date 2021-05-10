-- if it ain't broken
-- break it


engine.name="Breakcore"

amp=0
function init()
  print("init")

end

function key(k,z)
  if z==1 then 
    print("loading engine")
    engine.bb_load("/home/we/dust/audio/breakbeat/beats16_bpm150_Ultimate_Jack_Loops_014__BPM_150_.wav")
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