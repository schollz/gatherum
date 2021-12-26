-- link est
lattice_=require("lattice")
beat=0
function init()

  lattice=lattice_:new()
  pattern=lattice:new_pattern{
    action=function(t)
      beat=math.floor(t/96)+1
      print(beat)
    end,
    division=1/4,
  }
  lattice:start()
  lattice:stop()

  clock.run(function()
    while true do
      clock.sleep(1/15)
      redraw()
    end
  end)
end

function key(k,z)
  -- if z==1 then
  --   lattice:hard_restart()
  -- end
  if z==0 then 
    do return end 
  end
  if k==2 then 
    clock.link.set_transport(false)
  elseif k==3 then 
    clock.link.set_transport(true)
  end
end

function clock.transport.start()
  print("we begin")
  lattice:hard_restart()
end

function clock.transport.stop()
  print("we end")
  lattice:stop()
end

function redraw()
  screen.clear()
  screen.font_size(24)
  screen.move(64,32)
  screen.text_center(beat)
  screen.update()
end
