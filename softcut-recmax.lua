-- softcut-recmax

function init()
  boundaries={
    {1,1,80},
    {1,82,161},
    {1,163,243},
    {2,1,80},
    {2,82,161},
    {2,163,243},
  }
  local loop_length=10

  softcut.reset()
  audio.level_cut(1)
  audio.level_adc_cut(1)
  audio.level_eng_cut(1)
  audio.level_tape_cut(1)
  for i=1,6 do
    softcut.enable(i,1)

    softcut.level_input_cut(1,i,0.5)
    softcut.level_input_cut(2,i,0.5)

    softcut.buffer(i,boundaries[i][1])
    softcut.level(i,1.0)
    softcut.pan(i,0)
    softcut.rate(i,1)
    softcut.loop(i,1)
    softcut.loop_start(i,boundaries[i][2])
    softcut.loop_end(i,boundaries[i][2]+loop_length)

    softcut.level_slew_time(i,0.2)
    softcut.rate_slew_time(i,0.2)
    softcut.recpre_slew_time(i,0.1)
    softcut.fade_time(i,0.2)

    softcut.rec_level(i,0.5)
    softcut.pre_level(i,0.5)
    softcut.phase_quant(i,0.025)

    softcut.post_filter_dry(i,0.0)
    softcut.post_filter_lp(i,1.0)
    softcut.post_filter_rq(i,1.0)
    softcut.post_filter_fc(i,20100)

    softcut.pre_filter_dry(i,1.0)
    softcut.pre_filter_lp(i,1.0)
    softcut.pre_filter_rq(i,1.0)
    softcut.pre_filter_fc(i,20100)

    softcut.position(i,boundaries[i][2])
    softcut.play(i,0)
    softcut.rec(i,0)
  end
end

function rec_once()
  for i=1,6 do
    softcut.rec_once(i,boundaries[i][2])
  end
end


function rec(x)
  for i=1,6 do
    softcut.rec(i,x)
  end
end

function play(x)
  for i=1,6 do
    softcut.play(i,x)
  end
end

function rate(x)
  for i=1,6 do
    softcut.rate(i,x)
  end
end
