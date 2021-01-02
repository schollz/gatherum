-- colkol v0.0.1
-- lift every voice
--
-- llllllll.co/t/colkol
--
--
--
--    ▼ instructions below ▼
--
-- K2 changes sample
-- K3 toggles recorindg
-- E2 changes modulator
-- E3 modulates


local Formatters=require 'formatters'

engine.name = "ID1"

-- things to customize
loop_max_beats = 16
modulators = {
  {name="birds",para="1engine",engine="amp1"},
  {name="bells",para="2engine",engine="amp2"},
  {name="bass",para="3engine",engine="amp3"},
  {name="bass note",para="3enginenote",engine="notescale"},
  {name="drums",para="4engine",engine="amp4"},
  {name="kick",para="5engine",engine="amp5"},
  {name="bongo",para="6engine",engine="amp6"},
  {name="loop1",para="1level"},
  {name="loop2",para="2level"},
  {name="loop3",para="3level"},
}

-- state
update_ui=false
softcut_loop_starts = {1,1,1,1,1,1}
softcut_loop_ends = {60,60,60,60,60,60}
ui_choice_sample = 0
ui_choice_mod = 0

-- WAVEFORMS
waveform_samples = {{}}
current_positions={1,1,1,1,1,1}

function init()
  norns.enc.sens(2,4) 
  norns.enc.sens(3,4) 

  engine.bpm(clock.get_tempo())
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
  for _,m in ipairs(modulators) do 
    if m.engine ~= nil then 
      params:add {
        type='control',
        id=m.para,
        name=m.name,
        controlspec=controlspec.new(0,1,'lin',0,0,'',0.01),
        action=function(value)
          local f=load("engine."..m.engine.."("..value..")")
          f()
        end
      }
    end
  end

  -- add params
  for i=1,3 do 
    params:add_separator("loop "..i)
    params:add {
      type='control',
      id=i..'level',
      name='level',
      controlspec=controlspec.new(0,0.5,'lin',0.01,0.5,''),
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

  -- params:set("1rec",1)
  -- params:set("5engine_modulator",0.15)
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
    ui_choice_mod = sign_cycle(ui_choice_mod,d,0,#modulators)
  elseif k==3 and ui_choice_mod > 0 then 
    params:set(modulators[ui_choice_mod].para,util.clamp(params:get(modulators[ui_choice_mod].para)+d/100,0,1))
  end
end

function key(k,z)
  if k==2 and z==1 then 
    ui_choice_sample = sign_cycle(ui_choice_sample,z,0,3)
  elseif k==3 and z==1 and ui_choice_sample > 0 then 
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
  -- w = math.floor(w/3)
  -- screen.rect(x-w/2,y-v*h+2,w,v*h-4)
  -- screen.fill()
  -- if highlight then 
  --   screen.level(15)
  -- else
  --   screen.level(1)
  -- end 
  -- screen.move(x,y-1)
  -- screen.text_center_rotate(x-4,y-16,name,-90)
end

function redraw()
  screen.clear()

  local bar_position = 20
  local waveform_height = 26  
  local bar_height = 5

  -- draw engine bars
  for i,m in ipairs(modulators) do
    x = (i-1)*math.floor(128/(#modulators))+1
    y = bar_position
    w = math.floor(128/#modulators)+2
    if i==#modulators then 
      w = w -3
    end
    h = bar_position-1
    v = 0.0
    name = ""
    highlight = i==ui_choice_mod
    v = params:get(m.para)
    name = m.name
    if highlight then 
      screen.level(15)
    else
      screen.level(1)
    end
    screen.rect(x,y-v*h,w,v*h)
    screen.stroke()
  end

  -- show samples
  screen.level(15)
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
        screen.move(i,  58-waveform_height/2)
        screen.line_rel(0, (j*2-3)*height)
        screen.stroke()
        ::continue::
      end
    end
  end

  -- draw rect around current sample
  if ui_choice_sample > 0 then 
    if params:get(ui_choice_sample.."rec")==1 then 
      screen.level(15)
    else
      screen.level(1)
    end
    screen.rect(1+42*(ui_choice_sample-1),bar_position+bar_height+1,43,64-bar_position-bar_height-1)
    screen.stroke()
  end

  -- draw middle bar
  screen.level(15)
  screen.rect(0,bar_position-1,128,bar_height+2)
  screen.fill()
  screen.level(0)
  
  -- label which modulator is selected
  if ui_choice_mod > 0 then 
    x = math.floor((ui_choice_mod-1)/(#modulators)*128)+2
    y = bar_position+bar_height
    screen.level(0)
    if ui_choice_mod >= #modulators-1 then 
      x = math.floor((ui_choice_mod)/(#modulators)*128)-2
      screen.move(x,y)
      screen.text_right(modulators[ui_choice_mod].name)
    elseif ui_choice_mod == 1 then 
      screen.move(x,y)
      screen.text(modulators[ui_choice_mod].name)
    else
      screen.move(x+w/2,y)
      screen.text_center(modulators[ui_choice_mod].name)
    end
  else
    draw_colkol(100,bar_position)
  end

  screen.update()
end

function draw_colkol(x,y)
  local pixels = {
    {44,50},
    {45,50},
    {46,50},
    {47,50},
    {47,51},
    {47,52},
    {47,53},
    {47,54},
    {46,54},
    {45,54},
    {44,54},
    {45,52},
    {39,50},
    {39,51},
    {40,51},
    {41,51},
    {42,51},
    {42,52},
    {41,53},
    {40,53},
    {40,54},
    {32,50},
    {33,50},
    {34,50},
    {35,50},
    {35,51},
    {34,52},
    {34,53},
    {34,54},
    {32,52},
    {32,53},
    {32,54},
    {32,55},
    {30,50},
    {29,52},
    {30,52},
    {30,53},
    {30,54},
    {24,50},
    {24,51},
    {25,51},
    {26,51},
    {27,51},
    {27,52},
    {26,53},
    {25,53},
    {25,54},
  }
  xmin = 24
  ymin = 50
  screen.level(0)
  for _, p in ipairs(pixels) do
    screen.pixel(p[1]-xmin+x,p[2]-ymin+y)
  end
  screen.fill()
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
