local AcrosticGrid={}

function AcrosticGrid:new(args)
  local m=setmetatable({},{
    __index=AcrosticGrid
  })
  local args=args==nil and {} or args

  m.self_=args.self_
  m.add_sequence=args.add_sequence
  m.get_sequences=args.get_sequences
  m.grid_on=args.grid_on==nil and true or args.grid_on

  -- initiate the grid
  local grid=util.file_exists(_path.code.."midigrid") and include "midigrid/lib/mg_128" or grid
  m.g=grid.connect()
  m.g.key=function(x,y,z)
    if m.grid_on then
      m:grid_key(x,y,z)
    end
  end
  print("grid columns: "..m.g.cols)

  -- setup visual
  m.visual={}
  m.toggles={}
  m.grid_width=16
  for i=1,8 do
    m.visual[i]={}
    m.toggles[i]={}
    for j=1,m.grid_width do
      m.visual[i][j]=0
      m.toggles[i][j]=0
    end
  end

  -- keep track of pressed buttons
  m.pressed_buttons={}

  -- grid refreshing
  m.grid_refresh=metro.init()
  m.grid_refresh.time=0.03
  m.grid_refresh.event=function()
    if m.grid_on then
      m:grid_redraw()
    end
  end
  m.grid_refresh:start()

  m.fingers_on_notes=nil
  m.fingers_on_sequence=nil
  return m
end

function AcrosticGrid:grid_key(x,y,z)
  self:key_press(y,x,z==1)
  self:grid_redraw()
end

function AcrosticGrid:key_press(row,col,on)
  if on then
    self.pressed_buttons[row..","..col]=1
  else
    self.pressed_buttons[row..","..col]=nil
  end
  if not on then 
    if self.fingers_on_notes~=nil and self.fingers_on_notes[1]==row and self.fingers_on_notes[2]==col then 
        self.fingers_on_notes=nil 
    end
    if self.fingers_on_sequence~=nil and self.fingers_on_sequence[1]==row and self.fingers_on_sequence[2]==col then 
        self.fingers_on_sequence=nil 
    end
    do return end 
  end
  if row<=6 then 
    if self.fingers_on_notes~=nil then 
        self:toggle_note_from_to(self.fingers_on_notes[1],self.fingers_on_notes[2],row,col)
    else
        self.fingers_on_notes={row,col}
        self.toggle_note(row,col)
    end
  elseif row==7 then 
    if self.fingers_on_sequence~=nil then 
        self:toggle_note_from_to(self.fingers_on_sequence[1],self.fingers_on_sequence[2],row,col)
    else
        self.fingers_on_sequence={row,col}
        self.toggle_note(row,col)
    end
  end
end

function AcrosticGrid:toggle_note(row,col)
    if row<7 then 
        toggle_note[row][col]=toggle_note[row][col]+1
        if toggle_note[row][col]>2 then 
            toggle_note[row][col]=0
        end
    elseif row==7 then 
        toggle_note[row][col]=1-toggle_note[row][col]
    end
    -- TODO: update the sequins sequence
end

function AcrosticGrid:toggle_note_from_to(row1,col1,row2,col2,toggle_note_from)
    if col2==col1 then 
        do return end
    end
    local m=(row2-row1)/(col2-col1)
    local b=row2-(m*col2)
    local startcol=col1+1 
    if toggle_note_from~=nil and toggle_note_from==true then 
        startcol=col1
    end
    for col=startcol,col2 do 
        row=util.round(m*col+b)
        self:toggle_note(row,col)
    end
end

function AcrosticGrid:get_visual()
  -- clear visual
  for row=1,8 do
    for col=1,self.grid_width do
      -- self.visual[row][col]=self.visual[row][col]-2
      -- if self.visual[row][col]<0 then
        self.visual[row][col]=0
      -- end
    end
  end

  -- illuminate the state of steps
  for i=1,16 do 
    for j,name in ipairs({"pitch","strength","duration"}) do
      local v=params:get(i..name)
      if v<=-15 then
        self.visual[1+(j-1)*2][i]=15-(30+v)
        self.visual[2+(j-1)*2][i]=15
      elseif v<=0 then
        self.visual[1+(j-1)*2][i]=0
        self.visual[2+(j-1)*2][i]=15-(15+v)
      elseif v<=15 then
        self.visual[1+(j-1)*2][i]=15-(15-v)
        self.visual[2+(j-1)*2][i]=0
      else
        self.visual[1+(j-1)*2][i]=15
        self.visual[2+(j-1)*2][i]=15-(15-(v-15))
      end
    end
  end

  -- illuminate current sequence 
  if self.current_sequence~=nil then
    for _, col in ipairs(self.current_sequence) do 
      self.visual[8][col]=self.visual[8][col]+2
    end
  else
    -- illuminate current sequences 
    for _, seq in ipairs(self.get_sequences(self.self_)) do 
      for i,col in ipairs(seq.seq) do 
        if col==seq.cur then
          self.visual[8][col]=self.visual[8][col]+4
        else
          self.visual[8][col]=self.visual[8][col]+2
        end
      end
    end
  end


  -- illuminate currently pressed button
  for k,v in pairs(self.pressed_buttons) do
    local row,col=k:match("(%d+),(%d+)")
    row=tonumber(row)
    col=tonumber(col)
    if v>10 and v%3==0 and row<7 then
      self:change_control(row,col)
    end
    self.pressed_buttons[k]=v+1
  end

  return self.visual
end

function AcrosticGrid:grid_redraw()
  local gd=self:get_visual()
  if self.g.rows==0 then
    do return end
  end
  self.g:all(0)
  local s=1
  local e=self.grid_width
  local adj=0
  for row=1,8 do
    for col=s,e do
      if gd[row][col]~=0 then
        self.g:led(col+adj,row,gd[row][col])
      end
    end
  end
  self.g:refresh()
end

return AcrosticGrid
