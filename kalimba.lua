-- kalimba

engine.name='Kalimba'

local SCREEN_FRAMERATE=15
local DEBOUNCE_TIME=0.1
local debounce_timer={0,0,0,0}
local current_freq=-1
local last_freq=-1
local currrent_amp=-1
local last_amp=-1
local amp_min=0.01
local amp_max=0.06
local note_activated=false
local viewport={width=128,height=64,time=0}
-- A2 C3 E3 F3 A3 B3 C4 E4
local frequency_percent_tolerance=0.05
local frequency_available={229,261,328,350,440,494,523,660}

-- Encoder input
function enc(n,delta)
  
end

-- Key input
function key(n,z)
  
end

function init()
  engine.amp(0)
  
  -- Polls
  --update pitch
  local pitch_poll_l=poll.set("pitch_in_l",function(value)
    update_freq(value)
  end)
  pitch_poll_l:start()
  
  -- initiate engine playback on incoming audio
  p_amp_in=poll.set("amp_in_l")
  p_amp_in.time=0.1
  p_amp_in.callback=function(val)
    -- print(val)
    -- local filetest=io.open("/tmp/test.data","a")
    -- io.output(filetest)
    -- io.write(val.."\n")
    -- io.close(filetest)
    current_amp_diff=val-last_amp
    if current_amp_diff>amp_min then
      debounce_timer[4]=util.time()
      if debounce_timer[4]-debounce_timer[3]>DEBOUNCE_TIME then
        -- TODO: scale amplitude based on amp threshold
        local amp_set=(current_amp_diff-amp_min)/amp_max
        if amp_set>1 then
          amp_set=1
        end
        print("amp_set "..amp_set)
        engine.amp(amp_set)
        debounce_timer[3]=util.time()
        note_activated=true
      end
    end
    last_amp=val
  end
  p_amp_in:start()
  
  -- update screen
  re=metro.init()
  re.time=0.1
  re.event=function()
    viewport.time=viewport.time+0.1
    redraw()
  end
  re:start()
end

function redraw()
  screen.clear()
  screen.update()
end

local function update_freq(freq)
  current_freq=freq
  if current_freq>0 then
    debounce_timer[2]=util.time()
    -- add debounce time for each note
    if debounce_timer[2]-debounce_timer[1]>DEBOUNCE_TIME and note_activated then
      -- quantize notes to available notes
      hzs=snap_to_frequency(current_freq)
      print("new freq "..current_freq)
      for k,v in pairs(hzs) do
        if v>0 then
          print("playing "..v)
          engine.hz(v)
        end
      end
      debounce_timer[1]=util.time()
      note_activated=false
    end
  end
  if current_freq>0 then last_freq=current_freq end
end

function snap_to_frequency(hz)
  -- is within tolerance of any?
  for k,v in pairs(frequency_available) do
    if hz>v*(1-frequency_percent_tolerance) and hz<v*(1+frequency_percent_tolerance) then
      return {hz}
    end
  end
  -- is in between any pair?
  for k,v in pairs(frequency_available) do
    if k>1 then
      if hz>frequency_available[k-1] and hz<v then
        return {frequency_available[k-1],v}
      end
    end
  end
  return {-1}
end
