-- keep it super stupid

-- imports
if clock==nil then
  require("utils")
  music=require("music")
end

TA={}

function TA:new(o)
  o=o or {} -- create object if user does not provide one
  setmetatable(o,self)
  self.__index=self
  o.patterns={}
  o.pulse=0
  o.sn=0
  o.qn=0
  o.measure=0
  return o
end

function TA:step()
  self.pulse=self.pulse+1
  self.sn=self.sn+1
  if self.pulse>16 then
    self.pulse=1
    self.measure=self.measure+1
  end
  if self.pulse%4==1 then
    self.qn=self.qn+1
  end

  -- emit anything in the time authority
  for k,v in pairs(self.patterns) do
    local current=self.measure%#v+1
    if v[current][self.pulse]~="" then
      local cmd=v[current][self.pulse]
      if cmd~=nil then
        cmd=cmd:gsub("<qn>",self.qn)
        cmd=cmd:gsub("<sn>",self.sn)
        print(self.measure+1,self.qn,self.sn,self.pulse,k,cmd)
        rc(cmd)
      end
    end
  end
end

function ct()
  return clock.get_beat_sec()*clock.get_beats()
end


function lfo(period,dlo,dhi)
  local m=math.sin(2*math.pi*ct()/period)
  return util.linlin(-1,1,dlo,dhi,m)
end

function TA:addm(name,snd,measure)
  self:add(name,sound(snd,"mp:on('"..name.."',<m>,<sn>)"),measure)
end

-- add row or rows to the time authority for instrument s
function TA:add(s,t,i)
  if i~=nil then
    self:expand(s,i)
    if #t[1]==16 and #t>1 then
      for j,t2 in ipairs(t) do
        self.patterns[s][i+j-1]=t2
      end
    else
      self.patterns[s][i]=t
    end
    do return end
  end
  if self.patterns[s]==nil then
    self.patterns[s]={}
  end
  if #t[1]==16 and #t>1 then
    for _,t2 in ipairs(t) do
      table.insert(self.patterns[s],t2)
    end
  else
    table.insert(self.patterns[s],t)
  end
end

-- rm will remove instrument s from the time authority
function TA:rm(s,i)
  if self.patterns[s]==nil then
    do return end
  end
  if i~=nil then
    if self.patterns[s][i]==nil then
      do return end
    end
    self.patterns[s][i]={"","","","","","","","","","","","","","","",""}
  else
    self.patterns[s]=nil
  end
end

-- expand will expand instrument s to n rows
function TA:expand(s,n)
  if self.patterns[s]==nil then
    self.patterns[s]={}
  end
  for j=1,n do
    if self.patterns[s][j]==nil then
      self.patterns[s][j]={"","","","","","","","","","","","","","","",""}
    end
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
function er(item,num,size)
  if size==nil then
    size=16
  end
  local ray={}
  local bucket=0
  for i=1,size do
    ray[size+1-i]=""
    bucket=bucket+num
    if bucket>=size then
      bucket=bucket-size
      ray[size+1-i]=item
    end
  end
  return ray
end


-- adds two arrays
function add(t,t2)
  local t3={}
  for i,v1 in ipairs(t) do
    local v2=t2[i]
    if v1~="" then
      table.insert(t3,v1)
    else
      table.insert(t3,v2)
    end
  end
  return t3
end

-- subtract two arrays
function sub(t,t2)
  local t3={}
  for i,v1 in ipairs(t) do
    local v2=t2[i]
    if v1~="" and v2~="" then
      table.insert(t3,"")
    else
      table.insert(t3,v1)
    end
  end
  return t3
end

-- rotates an array by amt
function rot(t,amt)
  local rotated={}
  for i=#t-amt+1,#t do
    table.insert(rotated,t[i])
  end
  for i=1,#t-amt do
    table.insert(rotated,t[i])
  end
  return rotated
end


function sound(s,ctx)
  local rays={}
  local lines=string.split(s,";")
  for i,line in ipairs(lines) do
    local words=string.split(line," ")
    local ray=er("-",#words)
    local cmds={}
    for j,word in ipairs(words) do
      local cmd=""
      if word~="." then
        local notes=music.to_midi(word)
        for _,note in ipairs(notes) do
          for _,ctxn in ipairs({"m","v","f","n"}) do
            if string.find(ctx,"<"..ctxn..">") then
              cmd=cmd..ctx:gsub("<"..ctxn..">",note[ctxn])..";"
            end
          end
        end
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
  if #rays==1 then
    return rays[1]
  else
    return rays
  end
end


-- make a new time authority
ta=TA:new()
-- add some chords and stuff for op-1
-- expand to 16 measure phrase
-- ta:expand("op-1",16)
-- ta:add("op-1",sound("Cm7 c4; Dmaj7 d6 . e6","print('<n>')"),1)
-- add kick on 2nd measure
-- ta:add("kick",r(e("print('kick',<qn>)",4),0),1)
-- for i=1,(2*16) do
-- ta:step()
-- end

-- table.print(r(e("print('kick')",1),4))
-- table.print(ta.patterns["kick"][4])
