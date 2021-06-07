-- live

engine.name="IDLive"

-- this order matters
require("live/lib/utils")
music=require("live/lib/music")
require("live/lib/live")
lattice=require("lattice")

function init()
  local sched=lattice:new{
    ppqn=16
  }
  sched:new_pattern({
    action=function(t)
      print(t)
      tva:step()
    end,
    division=1/4,
    enabled=true
  })
end

 