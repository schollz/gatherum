-- breakcore3

engine.name="Breakcore3"

local lattice_=require("lattice")
s=require("sequins")
function init()
  engine.sample(_path.code.."gatherum/data/beats16_bpm150_Ultimate_Jack_Loops_014__BPM_150_.wav")
  tempo=150
  slices=16*4
  rates=s{1}
  ratesm=s{1}
  ratesp=s{0}
  slicep=s{1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16}
  rate_main=1
  slice=0
  my_lattice=lattice_:new{}
  local division=1/16
  pattern_a=my_lattice:new_pattern{
    action=function(t)
      slice=slice+1
      if slice>slices then
        slice=1
      end
      local amp=1
      rate_main=rate_main+ratesp()
      local rate=clock.get_tempo()/tempo*rate_main*ratesm()
      local duration=clock.get_beat_sec()*division*4
      local fade=duration/6
      local pos=(slicep()-1)/slices
      engine.play(
        amp,
        rate,
        pos,
        duration,
        fade
      )
    end,
    division=division,
  }
  my_lattice:start()
end

function redraw()
  screen.clear()
  screen.move(64,32)
  screen.text_center("<br></br><br></br><br></br>")
  screen.update()
end
