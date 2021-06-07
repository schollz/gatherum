-- keep it super stupid 

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
		f()
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