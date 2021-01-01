-- 1
--

engine.name = "ID1"

softcut_loop_starts = {1,1,1,1,1,1}
softcut_loop_ends = {60,60,60,60,60,60}
loop_beats = 8
update_ui=false

-- WAVEFORMS
local interval = 0
waveform_samples = {}
scale = 30

function init()
	engine.amp1(0.5)
	engine.amp2(0.5)
	engine.amp3(0.25)
	engine.amp4(0.5)
	engine.amp5(1)

  updater = metro.init()
  updater.time = 0.05
  updater.count = -1
  updater.event = update_screen
  updater:start()
	reset_softcut()
end

function update_screen()
	redraw()
	softcut.render_buffer(1, 1, clock.get_beat_sec()*loop_beats*6+6, 128)
end

function on_render(ch, start, i, s)
  waveform_samples = s
  interval = i
end

function reset_softcut()
	loop_start = 1 
	loop_length = clock.get_beat_sec()*loop_beats
	softcut.reset()
	for i=1,6 do
		loop_start = loop_start + loop_length+1

    softcut.level(i,0.5)
    if i%2==1 then
  	  softcut.pan(i,1)
    else
	    softcut.pan(i,-1)
    end
    softcut.enable(i,1)

    softcut.rec(i,0)
    softcut.play(i,1)
    softcut.rate(i,1)
    softcut.loop_start(i,loop_start)
    softcut.loop_end(i,loop_start+loop_length)
    softcut.loop(i,1)

    softcut.level_slew_time(i,0.4)
    softcut.rate_slew_time(i,0.4)

    softcut.rec_level(i,1.0)
    softcut.pre_level(i,0.5)
    softcut.buffer(i,1)
    softcut.position(i,1)
    softcut.phase_quant(i,0.025)

    softcut.post_filter_dry(i,0.0)
    softcut.post_filter_lp(i,1.0)
    softcut.post_filter_rq(i,1.0)
    softcut.post_filter_fc(i,20100)

    softcut.pre_filter_dry(i,1.0)
    softcut.pre_filter_lp(i,1.0)
    softcut.pre_filter_rq(i,1.0)
    softcut.pre_filter_fc(i,20100)
  end
end


function key(k,z)
	if k==2 then 
		engine.amp1(1)
	else
		engine.amp1(0)
	end
end


function redraw()
  screen.level(4)
  local x_pos = 0
  for i,s in ipairs(waveform_samples) do
    local height = util.round(math.abs(s) * 32)
    screen.move(util.linlin(0,128,10,120,x_pos), 35 - height)
    screen.line_rel(0, 2 * height)
    screen.stroke()
    x_pos = x_pos + 1
  end
end



function rerun()
  norns.script.load(norns.state.script)
end
