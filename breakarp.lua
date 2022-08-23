-- breakcore3

-- engine.name="Breakcore3"

local lattice=require("lattice")
engine.name="Breakarp"

function table.shuffle(tbl)
  for i=#tbl,2,-1 do
    local j=math.random(i)
    tbl[i],tbl[j]=tbl[j],tbl[i]
    do return end
  end
end

function init()
  local fname=_path.code.."gatherum/data/dd_bpm160.wav"
  local ch,samples,sr=audio.file_info(fname)
  local duration=samples/sr
  local onset_string=util.os_capture("aubio onset -m energy -M 100ms -t 2.5 -B 64 -H 64 -i "..fname)
  local onsets={}
  for w in onset_string:gmatch("%S+") do
    table.insert(onsets,tonumber(w)/duration)
  end
  tab.print(onsets)

  seq={}
  pos={}
  for i=1,16 do
    table.insert(seq,i)
    table.insert(pos,(i-1)/16)
  end
  seq2={0,0,0,1,1,1,1,0,0,0,2,2,2,2}
  seq3={0,0,0,0,0,0,0,1,2,3,4,1,1,1,1}
  -- update the pos
  for i,p in ipairs(pos) do
    for _,onset in ipairs(onsets) do
      if math.abs(onset-p)<0.002 then
        pos[i]=onset
      end
    end
  end
  -- table.shuffle(pos)
  -- tab.print(pos)

  engine.sample(fname)
  -- aubio onset -m energy -M 100ms -t 2.5 -B 64 -H 64 -i dd_bpm160.wav
  local tempo=200
  params:set("clock_tempo",tempo)

  lat=lattice:new()
  beat=0
  pp={amp=1.0,rate=tempo/160,pos=p,xfade=0.005}
  lat:new_pattern{
    action=function(v)
      beat=beat+1
      local ind=seq[(beat-1)%#seq+1]
      ind=ind+seq2[(beat-1)%#seq2+1]
      ind=ind+seq3[(beat-1)%#seq3+1]*math.random(1,3)
      -- ind=(ind-1)%#seq+1
      print(ind)
      pp.pos=pos[(ind-1)%#pos+1]
    end,
    division=1/4,
  }
  gatepat_beat=0
  gatepat=lat:new_pattern{
    action=function(v)
      engine.play(pp.amp,pp.rate*(math.random()<0.0 and-1 or 1),pp.pos,pp.xfade)
    end,
    division=1/4,
  }
  lat:start()
end

function stutter()
  clock.run(function()
    gatepat:set_division(1/(math.random(1,2)*16))
    clock.sync(1/2)
    gatepat:set_division(1/4)
  end)
end
function redraw()
  screen.clear()
  screen.move(64,32)
  screen.text_center("<brarp></brarp>")
  screen.update()
end
