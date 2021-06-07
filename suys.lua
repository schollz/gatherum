-- keep it super stupid 

-- imports 
music=require("music")

TimeVariantAuthority={}

function TimeVariantAuthority:new(o)
  o = o or {}   -- create object if user does not provide one
  setmetatable(o, self)
  self.__index = self
  o.patterns={}
  o.pulse=0
  o.measure=1
  return o
end

function TimeVariantAuthority:step()
	self.pulse = self.pulse+1
	if self.pulse > 16 then 
		self.pulse=1
		self.measure = self.measure+1
	end
	-- emit anything in the tva
	for k,v in pairs(tva.patterns) do
		local current=self.measure%#v+1
		if v[current][self.pulse]~="" then
			rc(v[current][self.pulse])
		end
	end
end

function TimeVariantAuthority:add(s,t)
	if self.patterns[s]==nil then
		self.patterns[s]={}
	end
	table.insert(self.patterns[s],t)
end

tva=TimeVariantAuthority:new()



-- utils
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

-- rc runs any code, even stupid code
function rc(code)
	local ok,f=pcall(load(code))
	if ok then
		if f~=nil then
			f()
		end
	else
		print(string.format("rc: could not run '%s': %s",code,f))
	end
end

-- returns an euclidean spaced array of "item"
function e(item,num,size) 
	if size==nil then 
		size=16
	end
	local ray={}
	local bucket=0
	for i=1,size do
		ray[size+1-i]="" 
		bucket=bucket+num 
		if bucket >= size then 
			bucket=bucket-size
			ray[size+1-i]=item
		end
	end
	return ray
end

-- rotates an array by amt
function r(t,amt)
	local rotated={}
	for i=#t-amt+1,#t do
		table.insert(rotated,t[i])
	end
	for i=1,#t-amt do
		table.insert(rotated,t[i])
	end
	return rotated
end



local his=e("print('hi')",4)
table.print(his)
table.print(r(his,2))
rc('prinasdflkj')
local foo=music.chord_to_midi("Cm;3")
for i,v in ipairs(foo) do
	table.print(v)
end
print(table.print(foo[1]))
local foo=music.note_to_midi("d#2")
for i,v in ipairs(foo) do
	table.print(v)
end

table.print(e("print('hi')",4))
tva:add("op-1",e("print('okokok')",4))
