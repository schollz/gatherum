-- link est

engine.name="PolyPerc"

lattice_=require("lattice")
beat=0
function init()

  lattice=lattice_:new()
  pattern=lattice:new_pattern{
    action=function(t)
      beat=math.floor(t/96)+1
      redraw()
      engine.hz(220)
      engine.pan(-1)
    end,
    division=1/4,
  }
  lattice:start()
  lattice:stop()
  beat=0

  redraw()
end

function key(k,z)
  if z==0 then 
    do return end 
  end
  if k==2 then 
    print("clock.link.stop()")
    clock.link.stop()
  elseif k==3 then 
    print("clock.link.start()")
    clock.link.start()
  end
end

function clock.transport.start()
  print("we begin")
  lattice:hard_restart()
end

function clock.transport.stop()
  print("we end")
  lattice:stop()
  beat=0
  redraw()
end

function redraw()
  screen.clear()
  screen.font_size(24)
  screen.move(64,32)
  screen.text_center(beat)
  screen.update()
end
