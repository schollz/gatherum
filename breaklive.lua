-- if it ain't broken
-- break it


engine.name="Breaklive"

function init()
  print("init")
end

function key(k,z)
  if z==1 then 
    engine.bb_break()
    engine.bb_rate(math.random(1,2)*2-3)
  end
end
function redraw()
  screen.clear()
  screen.move(64,32)
  screen.text_center("<infinite>digits</infinite>")
  screen.update()
end