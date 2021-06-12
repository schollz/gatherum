norns.script.load("code/gatherum/live.lua")

tapestop()
tapestart()
tapebreak()

clock.run(function() clock.sleep(1.5);tapestop();clock.sleep(2.5);tapestart() end)
clock.run(function() clock.sleep(1.5);tapebreak() clock.sleep(1.5);tapebreak() end)

for _, v in ipairs({"crow","bou","hh","bou","usb","op1"}) do stop(v) end

