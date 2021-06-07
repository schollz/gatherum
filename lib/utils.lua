
function os.time2()
	if clock~=nil then 
		return clock.get_beat_sec()*clock.get_beats()
	else
		return os.time()
	end
end

function string.split(input_string,split_character)
  local s=split_character~=nil and split_character or "%s"
  local t={}
  if split_character=="" then
    for str in string.gmatch(input_string,".") do
      table.insert(t,str)
    end
  else
    for str in string.gmatch(input_string,"([^"..s.."]+)") do
      table.insert(t,str)
    end
  end
  return t
end

-- table.print prints the table
function table.print(t)
	for k,v in pairs(t) do 
		print(k,v)
	end
end
