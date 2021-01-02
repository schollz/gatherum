-- 1
--


local Formatters=require 'formatters'

engine.name = "ID1"

-- things to customize
loop_max_beats = 16
engine_modulators = {"amp1","amp2","amp3","amp4","amp5"}


-- state
update_ui=false
softcut_loop_starts = {1,1,1,1,1,1}
softcut_loop_ends = {60,60,60,60,60,60}
ui_choice_sample = 1
ui_choice_engine = 1

-- WAVEFORMS
waveform_samples = {{}}
current_positions={1,1,1,1,1,1}

function init()
  norns.enc.sens(2,4) 
  norns.enc.sens(3,4) 

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
  for i=1,#engine_modulators do 
    params:add {
      type='control',
      id=i..'engine_modulator',
      name=engine_modulators[i],
      controlspec=controlspec.new(0,1,'lin',0,0,'',0.01),
      action=function(value)
        local f=load("engine."..engine_modulators[i].."("..value..")")
        f()
      end
    }
  end

  -- add params
  for i=1,3 do 
    params:add_separator("loop "..i)
    params:add {
      type='control',
      id=i..'level',
      name='level',
      controlspec=controlspec.new(0,1,'lin',0.01,1,''),
      action=function(value)
        softcut.level(i*2,value)
        softcut.level(i*2-1,value)
      end
    }
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
    params:add {
      type='control',
      id=i..'erase',
      name='erase (each loop)',
      controlspec=controlspec.new(0,100,'lin',1,0,'%'),
      action=function(value)
        softcut.pre_level(i*2,(1-value/100))
        softcut.pre_level(i*2-1,(1-value/100))
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

  params:set("1rec",0)
  params:set("1engine_modulator",0)
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


function enc(k,d)
  if k==2 then 
    ui_choice_engine = sign_cycle(ui_choice_engine,d,1,#engine_modulators+3)
  elseif k==3 then 
    if ui_choice_engine <= #engine_modulators then
      params:set(ui_choice_engine.."engine_modulator",util.clamp(params:get(ui_choice_engine.."engine_modulator")+d/100,0,1))
    else
      local loop_num = ui_choice_engine-#engine_modulators
      params:set(loop_num.."level",util.clamp(params:get(loop_num.."level")+d/100,0,1))
    end
  end
end
function key(k,z)
  if k==2 and z==1 then 
    ui_choice_sample = sign_cycle(ui_choice_sample,z,1,3)
  elseif k==3 and z==1 then 
    params:set(ui_choice_sample.."rec",1-params:get(ui_choice_sample.."rec"))
  end
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
  screen.level(0)
  w = math.floor(w/3)
  screen.rect(x-w/2,y-v*h+2,w,v*h-4)
  screen.fill()
  if highlight then 
    screen.level(15)
  else
    screen.level(1)
  end 
  screen.move(x,y-1)
  screen.text_center_rotate(x-4,y-16,name,-90)
end

function redraw()
  screen.clear()

  -- draw engine bars
  for i=1,#engine_modulators+3 do
    if i<=#engine_modulators then 
      draw_bar(8+(i-1)*13,30,3,30,params:get(i.."engine_modulator"),i==ui_choice_engine,engine_modulators[i])
    else
      local j = i-#engine_modulators
      draw_bar(8+(i-1)*13,30,3,30,params:get(j.."level"),i==ui_choice_engine,"loop"..j)
    end
  end
  -- show samples
  screen.level(15)

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
        local highlight = false
        if i==positions[1] or i==positions[2] or i==positions[3] or i==positions[4] or i==positions[5] or i==positions[6] then 
          highlight = true
        end
        for k=1,3 do 
          if params:get(k.."rec")==1 and i > 42*(k-1) and i <= 42*k then 
            highlight = not highlight
            break
          end
        end
        if highlight then 
          screen.level(15)
        else
          screen.level(1)
        end
        local height = util.clamp(0,waveform_height,util.round(math.abs(s) * waveform_height*2))
        screen.move(i,  60-waveform_height/2)
        screen.line_rel(0, (j*2-3)*height)
        screen.stroke()
        ::continue::
      end
    end
  end
  screen.level(1)
  screen.move(14+42*(ui_choice_sample-1),64)
  screen.line_rel(14,0)
  screen.stroke()
  screen.update()
end


function sign_cycle(value,d,min,max)
  if d > 0 then 
    value = value + 1 
  elseif d < 0 then 
    value = value - 1
  end
  if value > max then 
    value = min
  elseif value < min then 
    value = max
  end
  return value
end


function rerun()
  norns.script.load(norns.state.script)
end
