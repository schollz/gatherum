-- live

engine.name="IDLive"

-- this order matters
include("gatherum/lib/utils")
music=include("gatherum/lib/music")
timeauthority_=include("gatherum/lib/timeauthority")
ta=timeauthority_:new()
lattice=require("lattice")
midipal_=include("gatherum/lib/midipal")
mp=midipal_:new()


e=engine
last_command=""

function init()
  audio.level_monitor(0)
  local drummer=include("supertonic/lib/drummer")
  local patches_=include("supertonic/lib/patches")
  local patches=patches_:new()
  local patches_loaded=patches:load("/home/we/dust/data/supertonic/presets/default.mtpreset")
  kick=drummer:new({id=1})
  kick.patch.oscDcy=500
  kick.patch.level=5
  sd=drummer:new({id=2})
  hh=drummer:new({id=3})
  oh=drummer:new({id=4})
  clap=drummer:new({id=5})
  kick:update_patch_manually(patches_loaded[1])
  sd:update_patch_manually(patches_loaded[2])
  hh:update_patch_manually(patches_loaded[3])
  oh:update_patch_manually(patches_loaded[4])
  clap:update_patch_manually(patches_loaded[5])

  -- scheduling
  sched=lattice:new{
    ppqn=16
  }
  local redrawer=1
  sched:new_pattern({
    action=function(t)
      ta:step()
      redrawer=redrawer+1
      if redrawer%16==0 then 
	redraw()
end
    end,
    division=1/16,
  })

  -- add syncing for drums
  ta:add("bb",er("if math.random()<0.5 then e.bb_sync((<sn>-1)%64/64) end",4))

  -- start scheduler
  sched:start()
end

function key(k,z)
  if k==2 and z==1 then
    sched:start()
  elseif k==3 and z==1 then
    sched:stop()
  end
end

function redraw()
  screen.clear()
  screen.font_size(6)
  local print_command=last_command..ta.last_command
  for i,s in ipairs(string.wrap(print_command,32)) do
    screen.move(1,8+8*(i-1))
    screen.text(s)
  end
  screen.update()
end

function rerun()
  norns.script.load(norns.state.script)
end

-----------
-- shims --
-----------

function glitch(v)
  if v==nil then
    v=0
  end
  ta:add("bbb",er("if math.random()<"..v.." then; v=math.random(); e.bb_break(v,v+math.random()/40+0.01) end",4),1)
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
    e.s_amp(i,6*vol/(i*i))
  end
end

function rename(name)
  if name:find("ge")==1 then
    name="usb"
  elseif name:find("sh")==1 then
    name="bou"
  elseif name:find("op")==1 then
    name="op1"
  end
  return name
end

function measures(name,num)
  ta:expand(rename(name),num)
end

function play(name,notes,i)
  name=rename(name)
  if name=="drone" then
    ta:add(name,sound(notes,"e.d_midi(<m>)"),i)
  elseif name=="pp" then
    ta:add(name,sound(notes,"e.pp_midi(<m>)"),i)
  elseif name=="kick" or name=="hh" or name=="clap" or name=="sd" or name=="oh" then
    for i,v in ipairs(notes) do
	if v~="" then
		notes[i]=name..":hit()"
	end
    end
    ta:add(name,notes,i)
  elseif mp:ismidi(name) then
    ta:add(name,sound(notes,"mp:on('"..name.."',<m>,<sn>)"),i)
  end
end

function stop(name)
  name=rename(name)
  if mp:ismidi(name) then
    mp:off(name,-1)
  end
  ta:rm(name)
end

function tapebreak()
  e.bl()
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

