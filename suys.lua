
function table.print(t)
	for k,v in pairs(t) do 
		print(k,v)
	end
end


-- returns an euclidean spaced array of "item"
function e(num,item) 
	local ray={}
	local bucket=0
	for i=1,16 do
		ray[17-i]="" 
		bucket=bucket+num 
		if bucket >= 16 then 
			bucket=bucket-16
			ray[17-i]=item
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

local his=e(4,"print('hi')")
table.print(his)
table.print(r(his,2))