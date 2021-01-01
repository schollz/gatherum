-- 1
--

engine.name = "ID1"

function init()
	engine.amp1(0.5)
	engine.amp2(0.5)
	engine.amp3(0.25)
	engine.amp4(0.5)
	engine.amp5(1)
end


function key(k,z)
	if k==2 then 
		engine.amp1(1)
	else
		engine.amp1(0)
	end
end

function rerun()
  norns.script.load(norns.state.script)
end