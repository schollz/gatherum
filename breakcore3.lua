-- breakcore3

engine.name="Breakcore3"

local lattice_=require("lattice")
s=require("sequins")

function table.shuffle(tbl)
  for i=#tbl,2,-1 do
    local j=math.random(i)
    tbl[i],tbl[j]=tbl[j],tbl[i]
    do return end
  end
end

function init()
  engine.sample(_path.code.."gatherum/data/dd_bpm160.wav")
  -- aubio onset -m energy -M 100ms -t 2.5 -B 64 -H 64 -i dd_bpm160.wav
  sample_duration=6.0
  onsets={
    0.000000,
    0.107208,
    0.373521,
    0.937896,
    1.304833,
    1.492083,
    1.669896,
    1.870146,
    2.165854,
    2.345937,
    2.629729,
    2.803604,
    2.991437,
    3.376521,
    3.564604,
    3.938521,
    4.139125,
    4.497604,
    4.682854,
    4.866021,
    5.051021,
    5.250396,
    5.426625,
    5.802937,
  }
  sliceindices={}
  for i,onset in ipairs(onsets) do
    table.insert(sliceindices,i)
    onsets[i]=onset/sample_duration
  end
  sliceindices={}
  for i=1,16 do
    table.insert(sliceindices,i)
    onsets[i]=(i-1)/16
  end
  -- table.shuffle(sliceindices)
  -- table.shuffle(sliceindices)
  -- table.shuffle(sliceindices)
  -- table.shuffle(sliceindices)
  -- table.shuffle(sliceindices)
  -- table.shuffle(sliceindices)
  -- table.shuffle(sliceindices)
  -- table.shuffle(sliceindices)
  -- table.shuffle(sliceindices)
  -- table.shuffle(sliceindices)
  -- table.shuffle(sliceindices)
  -- table.shuffle(sliceindices)

  tempo=160
  slices=16*4
  rates=s{1}
  ratesm=s{1}
  ratesp=s{0}
  slicep=s(sliceindices)
  slicep=s{1,2,3,4,5,6,7,8}
  slicep2=s{0,0,0,1,1,1,0,0,0,2,2,2}
  slicep3=s{0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0}
  rate_main=1
  slice=0
  my_lattice=lattice_:new{}
  local division=1/16
  do_run()
end

-- function go()
--   clock.run(function()
--     while true do
--       print("resettting")
--       slicep:reset()
--       do_run()
--       clock.sleep(12)
--     end
--   end)
-- end

function do_run()
  if clock_running~=nil then
    engine.freeall()
    clock.cancel(clock_running)
  end
  clock_running=clock.run(function()
    while true do
      local sp=slicep()+slicep2()*math.random(1,8)+slicep3()*math.random(1,8)
      if sp==1 then
        print("START")
      end
      local rate=clock.get_tempo()/tempo
      local amp=1
      local pos=onsets[sp]
      local pos_next=onsets[sp+1]
      if pos_next==nil then
        pos_next=1.0
      end
      local duration=math.abs(pos_next-pos)*sample_duration/rate
      local fade=0.001
      local stutters=math.random()<0.9 and 1 or math.random(1,6)*2
      while duration/stutters<3*fade do
        stutters=stutters-2
      end
      duration=duration/stutters
      local backwards=math.random()<0.1
      for i=1,stutters do
        print(pos,duration)
        engine.play(
          amp*(i/stutters)*(i/stutters),
          rate*(backwards and-1 or 1),
          pos+(backwards and duration or 0),
          duration,
          fade
        )
        clock.sleep(duration-fade)
      end
    end
  end)
end

function redraw()
  screen.clear()
  screen.move(64,32)
  screen.text_center("<br></br><br></br><br></br>")
  screen.update()
end
