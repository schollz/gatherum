-- keep it super stupid 

-- imports 
require("lib/utils")
music=require("lib/music")

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
			print(self.measure,self.pulse,v[current][self.pulse])
			rc(v[current][self.pulse])
		end
	end
end

function TimeVariantAuthority:add(s,t)
	if self.patterns[s]==nil then
		self.patterns[s]={}
	end
	if #t[1]==16 and #t>1 then
		for _, t2 in ipairs(t) do
			table.insert(self.patterns[s],t2)
		end
	else
		table.insert(self.patterns[s],t)
	end
end


function TimeVariantAuthority:rm(s)
	self.patterns[s]=nil
end

tva=TimeVariantAuthority:new()




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



function sound(s,ctx)
	local rays={}
	local lines = string.split(s,";")
	for i,line in ipairs(lines) do
		local words=string.split(line," ")
		local ray=e("-",#words)
		local cmds={}
		for j,word in ipairs(words) do
			print(i,j,word)
			local notes=music.to_midi(word)
			local cmd=""
			for _, note in ipairs(notes) do
				cmd=cmd..ctx:gsub("<m>",note.m)..";"
			end
			table.insert(cmds,cmd)
			
		end
		local k=1
		for j,rayw in ipairs(ray) do
			if rayw=="-" then
				ray[j]=cmds[k]
				k=k+1
			end
		end
		table.insert(rays,ray)
	end
	return rays
end

print("testing")
tva:add("op-1",sound("Cm7 c4; Dmaj7 d6 . e6","print('<m>')"))

for i=1,32 do
	tva:step()
end

-- local rays=sound("Cm7 c4; Dmaj7 d6 . e6","print('<m>')")
-- for _, ray in ipairs(rays) do
-- 	tva:add("op-1",ray)
-- 	table.print(ray)
-- end
-- for i=1,16 do
-- 	tva:step()
-- end
-- for i=1,16 do
-- 	tva:step()
-- end


