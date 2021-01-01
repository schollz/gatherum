-- 1
--

engine.name = "ID1"

softcut_loop_starts = {1,1,1,1,1,1}
softcut_loop_ends = {60,60,60,60,60,60}
loop_beats = 16
update_ui=false

-- constants

-- WAVEFORMS
waveform_samples = {{}}
waveform_loaded=false
current_positions={1,1,1,1,1,1}

function init()
	engine.amp1(0.5)
	engine.amp2(0.5)
	engine.amp3(0.25)
	engine.amp4(0.5)
	engine.amp5(0.2)


  updater = metro.init()
  updater.time = 0.1
  updater.count = -1
  updater.event = update_screen
  updater:start()
	reset_softcut()
  softcut.event_phase(update_positions)
  softcut.event_render(on_render)
  softcut.poll_start_phase()
  for i=3,6 do
    softcut.rec(i,0)
  end
end

function update_positions(i,x)
  current_positions[i] = x
end

function update_screen()
  softcut.render_buffer(1, 1, clock.get_beat_sec()*loop_beats*3+1, 128)
  softcut.render_buffer(2, 1, clock.get_beat_sec()*loop_beats*3+1, 128)
	redraw()
end

function on_render(ch, start, i, s)
  waveform_samples[ch] = s
  waveform_loaded = true 
end

function reset_softcut()
  audio.level_eng_cut(0)
  audio.level_adc_cut(1)
  audio.level_tape_cut(1)

	loop_start = 1 
	loop_length = clock.get_beat_sec()*loop_beats
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

    softcut.rec_level(i,1.0)
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

end


function redraw()
  screen.clear()
  screen.level(15)
  screen.move(64,32)
  screen.text_center("hold K1 to load sample")
  local positions = {}
  for i,p in ipairs(current_positions) do 
    local frac = math.ceil(i/2-1)/3
    positions[i] = util.round(util.linlin(softcut_loop_starts[i],softcut_loop_ends[i],math.ceil(i/2-1)/3*128,math.ceil(i/2)/3*128,p))
  end
  local waveform_height = 40
  if waveform_loaded then
    for i,s in ipairs(waveform_samples[1]) do
      if i==positions[1] or i==positions[2] or i==positions[3] or i==positions[4] or i==positions[5] or i==positions[6] then 
        screen.level(15)
      else
        screen.level(1)
      end
      local height = util.round(math.abs(s) * waveform_height/2)
      screen.move(i,  64-waveform_height/2)
      screen.line_rel(0, height)
      screen.stroke()
    end
    screen.level(1)
    for i,s in ipairs(waveform_samples[2]) do
      if i==positions[1] or i==positions[2] or i==positions[3] or i==positions[4] or i==positions[5] or i==positions[6] then 
        screen.level(15)
      else
        screen.level(1)
      end
      local height = util.round(math.abs(s) * waveform_height/2)
      screen.move(i, 64-waveform_height/2)
      screen.line_rel(0, -1*height)
      screen.stroke()
    end
  end
  screen.update()
end



function rerun()
  norns.script.load(norns.state.script)
end
