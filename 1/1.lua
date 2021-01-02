-- downtown v0.0.1
-- the cityscape is full of sound.
--
-- llllllll.co/t/downtown
--
--
--
--    ▼ instructions below ▼
--
-- K2 switches sample
-- K3 toggles recording
-- E2 changes modulator
-- E3 modulates


local Formatters=require 'formatters'

engine.name = "ID1"

---------           START CHANGING CODE           ---------
-- this modulates the length of softcut loops
loop_max_beats = 16 

-- these show up as "towers" which you can scale
-- if you change the engine you should change these
modulators = {  
  -- these are engine related (see the engine)
  {name="birds",engine="amp1",max=0.5},
  {name="bells",engine="amp2",max=0.5},
  {name="bass",engine="amp3",max=0.5},
  {name="bass note",engine="midinote",min=12,max=60,interval=1,default=29},
  {name="drums",engine="amp4",max=0.5},
  {name="kick",engine="amp5",max=0.5},
  {name="bongo",engine="amp6",max=0.5},
  -- add another engine here!
--------- STOP CHANGING CODE unless you want to :) ---------

  -- put loops in the city
  {name="loop1",max=0.5,default=0.5},
  {name="loop2",max=0.5,default=0.3},
  {name="loop3",max=0.5,default=0.2},
}

-- state
update_ui=false
softcut_loop_starts = {1,1,1,1,1,1}
softcut_loop_ends = {60,60,60,60,60,60}
modulator_ordering = {}
ui_choice_sample = 0
ui_choice_mod = 0
city_widths = {}
defaults_set=false

-- WAVEFORMS
waveform_samples = {{}}
current_positions={1,1,1,1,1,1}
-- drawing
bar_position = 20
waveform_height = 26  
bar_height = 5

function init()
  norns.enc.sens(2,4) 
  norns.enc.sens(3,4) 

  modulator_ordering = {}
  for i, _ in ipairs(modulators) do 
    local pos = math.random(1,#modulator_ordering+1)
    table.insert(modulator_ordering,pos,i)
    city_widths[i] = util.clamp(gaussian(1,0.15),0.3,1)
  end

  -- setup the running clock
  updater = metro.init()
  updater.time = 0.1
  updater.count = -1
  updater.event = update_screen
  updater:start()

  -- build up the modulators
  for i,m in ipairs(modulators) do
      if m.default == nil then 
        modulators[i].default = 0
      end
      if m.min == nil then 
        modulators[i].min = 0
      end
      if m.max == nil then 
        modulators[i].max = 1
      end
      if m.interval==nil then
        modulators[i].interval = 0.01
      end    
  end

  params:add_separator("engine")
  for i,m in ipairs(modulators) do 
    if m.engine ~= nil then 
      params:add {
        type='control',
        id=m.name,
        name=m.name,
        controlspec=controlspec.new(m.min,m.max,'lin',m.interval,m.default,''),
        action=function(value)
          local enginecmd="engine."..m.engine.."("..value..")"
          print(enginecmd)
          local f=load(enginecmd)
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
      id='loop'..i,
      name='level',
      controlspec=controlspec.new(0,0.5,'lin',0.01,modulators[#modulators-(3-i)].default,''),
      action=function(value)
        softcut.level(i*2,value)
        softcut.level(i*2-1,value)
      end
    }
    params:add {
      type='control',
      id=i..'start',
      name='start',
      controlspec=controlspec.new(1,loop_max_beats-1,'lin',1,1,'beats'),
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

  reset_softcut()
  softcut.event_phase(update_positions)
  softcut.event_render(on_render)
  softcut.poll_start_phase()
  params:bang()

  -- setup audio
  audio.level_eng_cut(0)
  audio.level_adc_cut(1)
  audio.level_tape_cut(1)

  -- more defaults
  params:set("1erase",5)
  params:set("2erase",15)
  params:set("3erase",10)
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
    m = modulators[ui_choice_mod]
    if m.interval == 1 then 
      d = sign(d)
    end
    params:set(m.name,util.clamp(params:get(m.name)+d*m.interval,m.min,m.max))
  end
end

function key(k,z)
  if k==2 and z==1 then 
    ui_choice_sample = sign_cycle(ui_choice_sample,z,0,3)
  elseif k==3 and z==1 and ui_choice_sample > 0 then 
    params:set(ui_choice_sample.."rec",1-params:get(ui_choice_sample.."rec"))
  end
end

function draw_building(i,order)
    m = modulators[i]
    v = params:get(m.name)/m.max
    if v == 0 then 
      do return end
    end
    x = (i-1)*math.floor(128/(#modulators))+1
    y = bar_position
    w = math.floor(128/#modulators)+2
    if i==#modulators then 
      w = w -3
    end
    w = city_widths[i]*w
    h = bar_position-1
    name = ""
    highlight = i==ui_choice_mod
    name = m.name
    screen.level(0)
    screen.rect(x,y-v*h,w,v*h)
    screen.fill()
    if highlight then 
      screen.level(15)
    else
      screen.level(math.ceil(10*order/#modulators))
    end
    screen.rect(x,y-v*h,w,v*h)
    screen.stroke()

    x = math.floor(x)
    w = math.floor(w)
    y = math.floor(y-v*h)
    vh = math.floor(v*h)
    math.randomseed(i)
    xspacing=math.random(2,4)
    yspacing=math.random(2,4)
    xspacing2 = math.random(1,2)
    density = math.random(20,90)/100.0
    xpos = x + xspacing - xspacing2
    ypos = y + yspacing
    while ypos < y+vh do 
      if xpos >= x+w then 
        ypos = ypos + yspacing 
        xpos = x + xspacing - xspacing2
      else
        if math.random() < density then
          if xpos == x+w-1 then 
            screen.pixel(xpos-1,ypos)
          else
            screen.pixel(xpos,ypos)
          end
          screen.fill()
        end
        xpos = xpos + xspacing        
      end
    end

end

function redraw()
  screen.clear()

  -- draw engine skyline
  draw_godzilla()
  for order,i in ipairs(modulator_ordering) do
    draw_building(i,order)
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
        local height = util.clamp(0,waveform_height,util.round(math.abs(s) * waveform_height))
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
    w = math.floor(128/#modulators)+2
    if ui_choice_mod==#modulators then 
      w = w -3
    end
    w = city_widths[ui_choice_mod]*w
    screen.level(0)
    if ui_choice_mod >= #modulators-1 then 
      x = math.floor((ui_choice_mod)/(#modulators)*128)-2
      screen.move(x,y)
      screen.text_right(modulators[ui_choice_mod].name)
    elseif ui_choice_mod == 1 then 
      screen.move(x,y)
      screen.text(modulators[ui_choice_mod].name)
    else
      screen.move(x+w/3,y)
      screen.text_center(modulators[ui_choice_mod].name)
    end
  end

  screen.update()
end

function draw_godzilla()
  local pixels = {
{114,0},{115,0},{116,0},{117,0},{118,0},{119,0},{120,0},{121,0},{122,0},{112,1},{113,1},{122,1},{124,1},{125,1},{126,1},{112,2},{119,2},{122,2},{123,2},{124,2},{126,2},{112,3},{113,3},{114,3},{115,3},{116,3},{117,3},{124,3},{126,3},{127,3},{128,3},{129,3},{117,4},{124,4},{125,4},{126,4},{129,4},{115,5},{116,5},{126,5},{127,5},{129,5},{114,6},{127,6},{128,6},{129,6},{130,6},{114,7},{115,7},{116,7},{117,7},{118,7},{123,7},{128,7},{129,7},{119,8},{123,8},{129,8},{130,8},{120,9},{121,9},{123,9},{130,9},{119,10},{120,10},{119,11},{121,11},{122,11},{122,12},{122,13},{123,13},{128,13},{129,13},{123,14},{124,14},{125,14},{127,14},{128,14},{122,15},{123,15},{127,15},{121,16},{127,16},{120,17},{121,17},{122,17},{126,17},{127,17},{128,17},{129,17},
  }
  screen.level(5)
  if ui_choice_mod == 0 then 
    screen.level(10)
  end
  for _, p in ipairs(pixels) do
    screen.pixel(p[1],p[2]+1)
  end
  screen.fill()
end

function sign(value)
  if value > 0 then 
    return 1
  elseif value < 0 then 
    return -1
  end
  return 0
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

function gaussian (mean, variance)
    return  math.sqrt(-2 * variance * math.log(math.random())) *
            math.cos(2 * math.pi * math.random()) + mean
end

function rerun()
  norns.script.load(norns.state.script)
end
