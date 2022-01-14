-- breakcore3

engine.name="Breakcore3"

local lattice_=require("lattice")

function init()
  engine.sample(_path.code.."gaterhum/data/breakbeats_160bpm2_4beats.wav")
  tempo=160
  slices=16

  slice=0
  my_lattice=lattice:new{}
  local division=1/8
  pattern_a=my_lattice:new_pattern{
    action=function(t)
      slice=slice+1
      if slice>slices then
        slice=1
      end
      local amp=1
      local rate=clock.get_tempo()/tempo
      local duration=clock.get_beat_sec()*division
      local fade=0.05
      local pos=(slice-1)/slices
      engine.play(
        amp,
        rate,
        pos,
        duration,
        fade,
      )
    end,
    division=division,
  }
end

function redraw()
  screen.clear()
  screen.move(64,32)
  screen.text_center("<br></br><br></br><br></br>")
  screen.update()
end
