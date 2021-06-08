-- live

engine.name="IDLive"

-- this order matters
include("gatherum/lib/utils")
music=include("gatherum/lib/music")
include("gatherum/lib/live")
lattice=require("lattice")
midipal_=include("gatherum/lib/midipal")
drummer=include("supertonic/lib/drummer")


e=engine
last_command=""

function init()
  local patches_=include("supertonic/lib/patches")
  local patches=patches_:new()
  local patches_loaded=patches:load("/home/we/dust/data/supertonic/presets/default.mtpreset")
  kick=drummer:new({id=1})
  sd=drummer:new({id=2})
  hh=drummer:new({id=3})
  oh=drummer:new({id=4})
  clap=drummer:new({id=5})
  kick:update_patch_manually(patches_loaded[1])
  sd:update_patch_manually(patches_loaded[2])
  hh:update_patch_manually(patches_loaded[3])
  oh:update_patch_manually(patches_loaded[4])
  clap:update_patch_manually(patches_loaded[5])
  ta=TA:new()
  sched=lattice:new{
    ppqn=16
  }
  sched:new_pattern({
    action=function(t)
      ta:step()
      redraw()
    end,
    division=1/16,
  })
  mp=midipal_:new()
end

local naturevol=-1
function nature(vol)
  if naturevol<0 then
    e.s_load(2,"/home/we/dust/audio/field/birds_eating.wav")
    e.s_load(3,"/home/we/dust/audio/field/birds_morning.wav")
    e.s_load(4,"/home/we/dust/audio/field/ocean_waves_puget_sound.wav");
  end
  if naturevol>0 then
    naturevol=0
  else
    naturevol=4
  end
  if vol~=nil then
    naturevol=vol
  end
  for i=2,4 do
    e.s_amp(i,vol/(i*i))
  end
end

function break()
  e.bl()
end

function rename(name)
  if name=="geode" then
    name="usb"
  elseif name=="sho01a" then
    name="bou"
  end
  return name
end

function stop(name)
  name=rename(name)
  if mp:ismidi(name) then
    mp:off(name,-1)
  end
  ta:rm(name)
end

function measures(name,num)
  ta:expand(rename(name),num)
end

function play(name,notes,i)
  if name=="drone" then
    ta:add(name,sound(notes,"e.d_midi(<m>)"),i)
  else
    ta:addm(rename(name),notes,i)
  end
end

function tapestop()
  e.bl()
  e.bl_rate(0.01)
end

function tapestart()
  clock.run(function()
    e.bl_rate(1)
    clock.sync(8)
    e.bl()
  end)
end

function key(k,z)
  if k==2 and z==1 then
    sched:start()
  elseif k==3 and z==1 then
    sched:stop()
  end
end

function string.wrap(s,num)
  ss={}
  while #s>num do
    local s2=string.sub(s,1,num)
    table.insert(ss,s2)
    local s=string.sub(s,num+1,#s)
    if s=="" then 
      break
    end
  end
  return ss
end

function redraw()
  screen.clear()
  local print_command=last_command..ta.last_command
  for i,s in ipairs(string.wrap(print_command,36)) do 
    screen.move(1,8+12*(i-1))
    screen.text(s)
  end
  screen.move(32,32)
  screen.text_center(ta.measure+1)
  screen.move(32+32,32)
  screen.text_center(ta.qn)
  screen.move(32+32+32,32)
  screen.text_center(ta.sn)
  screen.update()
end

function rerun()
  norns.script.load(norns.state.script)
end
