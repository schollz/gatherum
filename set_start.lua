norns.script.load("code/gatherum/live.lua")

tapestop()
tapestart()
tapebreak()

clock.run(function() clock.sleep(1.5);tapestop();clock.sleep(2.5);tapestart() end)
clock.run(function() clock.sleep(1.5);tapebreak() clock.sleep(1.5);tapebreak() end)

play("bbr",er("if math.random()<0.2 then e.brev(1) end",5))
play("bbb",er("if math.random()<0.1 then; v=math.random(); e.bbreak(v,v+math.random()/40+0.01) end",4),1)

for _, v in ipairs({"crow","bou","hh","bou","usb","op1"}) do stop(v) end

