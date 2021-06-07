-- less-noisy chaotic breakbeats
-- turn any knob
-- play sequence on midi
-- device to sync it

engine.name="Breakcore2"

function init()
  params:add{type="control",id="amp",name="amp",controlspec=controlspec.new(0,0.5,'lin',0,0,'amp',0.01/0.5),action=function(v)
    engine.bb_amp(v)
  end
  }
  print("init")
  midistarter()
  print("loading engine")
  engine.bb_load("/home/we/dust/code/gatherum/data/breakbeats_160bpm2_4beats.wav",160)
  engine.bb_bpm(clock.get_tempo())
end


function midistarter()
  for i,dev in pairs(midi.devices) do
    if dev.port~=nil then
      local conn=midi.connect(dev.port)
      conn.event=function(data)
        local msg=midi.to_msg(data)
        if msg.type=="clock" then do return end end
        -- OP-1 fix for transport
        if msg.type=='start' or msg.type=='continue' then
          print("starting")
          engine.bb_reset()
          engine.bb_amp(params:get("amp"))
        elseif msg.type=="stop" then
          print("stopping")
          engine.bb_amp(0)
        end
      end
    end
  end
end

function enc(k,d)
  params:delta("amp",d)
end

function redraw()
  screen.clear()
  screen.move(64,32)
  screen.text_center("press any key to breakbeat")
  screen.update()
end