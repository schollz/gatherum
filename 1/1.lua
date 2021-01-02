-- 1
--


local Formatters=require 'formatters'

engine.name = "ID1"

softcut_loop_starts = {1,1,1,1,1,1}
softcut_loop_ends = {60,60,60,60,60,60}
loop_max_beats = 16
update_ui=false

-- constants

-- WAVEFORMS
waveform_samples = {{}}
current_positions={1,1,1,1,1,1}

function init()
	engine.amp1(0.0)
	engine.amp2(0.0)
	engine.amp3(0.0)
	engine.amp4(0.0)
	engine.amp5(0.0)


  updater = metro.init()
  updater.time = 0.1
  updater.count = -1
  updater.event = update_screen
  updater:start()
	reset_softcut()
  softcut.event_phase(update_positions)
  softcut.event_render(on_render)
  softcut.poll_start_phase()

  params:add_separator("engine")
  for i=1,5 do 
    params:add {
      type='control',
      id=i..'a',
      name='a'..i,
      controlspec=controlspec.new(0,1,'lin',0,0,'',0.01),
      action=function(value)
        local f=load("engine.amp"..i.."("..value..")")
        f()
      end
    }
  end

  -- add params
  for i=1,3 do 
    params:add_separator("loop "..i)
    params:add {
      type='control',
      id=i..'start',
      name='start',
      controlspec=controlspec.new(0,loop_max_beats-1,'lin',1,0,'beats'),
      action=function(value)
        local loop_length = clock.get_beat_sec()*value
        softcut.loop_start(i*2,softcut_loop_starts[i*2]+loop_length)
        softcut.loop_start(i*2-1,softcut_loop_starts[i*2-1]+loop_length)
      end
    }
    params:add {
      type='control',
      id=i..'end',
      name='end',
      controlspec=controlspec.new(1,loop_max_beats,'lin',1,loop_max_beats,'beats'),
      action=function(value)
        local loop_length = clock.get_beat_sec()*value
        softcut.loop_end(i*2,softcut_loop_starts[i*2]+loop_length)
        softcut.loop_end(i*2-1,softcut_loop_starts[i*2-1]+loop_length)
      end
    }
    params:add{ type='binary', name="record",id=i..'rec', behavior='toggle', action=function(v) 
      softcut.rec_level(i*2,v)
      softcut.rec_level(i*2-1,v)
    end 
    }
    params:add {
      type='control',
      id=i..'filter_frequency',
      name='filter cutoff',
      controlspec=controlspec.new(20,20000,'exp',0,20000,'Hz',100/20000),
      formatter=Formatters.format_freq,
      action=function(value)
        softcut.post_filter_fc(i*2,value)
        softcut.post_filter_fc(i*2-1,value)
      end
    }
    params:add{type='binary',name="reset",id=i..'reset',behavior='trigger',
      action=function(v)
        softcut.position(i*2,softcut_loop_starts[i*2])
        softcut.position(i*2-1,softcut_loop_starts[i*2-1])
      end
    }
  end

  params:set("1rec",1)
end

function update_positions(i,x)
  current_positions[i] = x
end

function update_screen()
  softcut.render_buffer(1, 1, clock.get_beat_sec()*loop_max_beats*3+1, 128)
  softcut.render_buffer(2, 1, clock.get_beat_sec()*loop_max_beats*3+1, 128)
	redraw()
end

function on_render(ch, start, i, s)
  waveform_samples[ch] = s
end

function reset_softcut()
  audio.level_eng_cut(0)
  audio.level_adc_cut(1)
  audio.level_tape_cut(1)

	loop_start = 1 
	loop_length = clock.get_beat_sec()*loop_max_beats
	softcut.reset()
	for i=1,6 do
    softcut.enable(i,1)

    softcut.level(i,0.5)
    if i%2==1 then
      softcut.pan(i,1)
      softcut.buffer(i,1)
      softcut.level_input_cut(1,i,1)
      softcut.level_input_cut(2,i,0)
    else
      softcut.pan(i,-1)
      softcut.buffer(i,2)
      softcut.level_input_cut(1,i,0)
      softcut.level_input_cut(2,i,1)
    end

    softcut.rec(i,1)
    softcut.play(i,1)
    softcut.rate(i,1)
    softcut.loop_start(i,loop_start)
    softcut.loop_end(i,loop_start+loop_length)
    softcut_loop_starts[i] = loop_start
    softcut_loop_ends[i] = loop_start+loop_length
    softcut.loop(i,1)

    softcut.level_slew_time(i,0.4)
    softcut.rate_slew_time(i,0.4)

    softcut.rec_level(i,0.0)
    softcut.pre_level(i,1.0)
    softcut.position(i,loop_start)
    softcut.phase_quant(i,0.025)

    softcut.post_filter_dry(i,0.0)
    softcut.post_filter_lp(i,1.0)
    softcut.post_filter_rq(i,1.0)
    softcut.post_filter_fc(i,20100)

    softcut.pre_filter_dry(i,1.0)
    softcut.pre_filter_lp(i,1.0)
    softcut.pre_filter_rq(i,1.0)
    softcut.pre_filter_fc(i,20100)
    -- iterate
    if i==2 or i==4 then
      loop_start = loop_start + loop_length+0.5
    end
  end
end


function key(k,z)
  redraw()
end

function draw_bar(x,y,w,h,v,highlight,name)
  -- (x,y) midpoint of bottom
  -- w = width
  -- h = max height
  -- v = [0,1]
  if highlight then 
    screen.level(15)
  else
    screen.level(1)
  end
  screen.rect(x-w/2,y-v*h,w,v*h)
  screen.fill()
  screen.move(x,y+8)
  screen.text_center(name)
end

function redraw()
  screen.clear()
  screen.level(15)
  
  -- draw engine bars
  for i=1,5 do
    draw_bar(6+(i-1)*12,18,4,18,params:get(i.."a"),true,"a"..i)
  end
  -- show samples
  screen.level(15)
  for i=1,3 do 
    if params:get(i.."rec")==1 then
      screen.level(15)
    else
      screen.level(1)
    end
    screen.rect(1+42*(i-1),30,42,64-30)
    screen.stroke()
  end

  local waveform_height = 26  

  local positions = {}
  for i,p in ipairs(current_positions) do 
    local frac = math.ceil(i/2-1)/3
    positions[i] = util.round(util.linlin(softcut_loop_starts[i],softcut_loop_ends[i],math.ceil(i/2-1)/3*128,math.ceil(i/2)/3*128,p))
  end

  if waveform_samples[1] ~=nil and waveform_samples[2] ~=nil then
    for j=1,2 do 
      for i,s in ipairs(waveform_samples[j]) do
        if i==1 or i==1+42 or i==1+42+42 or i>=127 then 
          goto continue 
        end
        if i==positions[1] or i==positions[2] or i==positions[3] or i==positions[4] or i==positions[5] or i==positions[6] then 
          screen.level(15)
        else
          screen.level(1)
        end
        local height = util.round(math.abs(s) * waveform_height)
        screen.move(i,  60-waveform_height/2)
        screen.line_rel(0, (j*2-3)*height)
        screen.stroke()
        ::continue::
      end
    end
  end
  -- for i=1,3 do
  --   screen.level(15)
  --   screen.move(3+42*(i-1),37)
  --   screen.text(i)
  -- end
  screen.update()
end



function rerun()
  norns.script.load(norns.state.script)
end
