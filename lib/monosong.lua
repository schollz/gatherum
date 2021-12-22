local Monosong={}

function Monosong:new (o)
  o=o or {} -- create object if user does not provide one
  setmetatable(o,self)
  self.__index=self
  self.chords={
    {60,64,67},
    {72,63,67},
  }
  self.lattice=lattice_:new()
  return o
end

function Monosong:play()
  -- TODO: these might be made to be optional...
  self:minimize_transposition()
  self:minimize_changes()
  print("chord changes:")
  table.print_matrix(self.chords)

  -- create chord index
  local foo={}
  for i,_ in ipairs(self.chords) do
    table.insert(foo,i)
  end
  self.chord_index=s(foo)
  -- reset chord index
  for i,_ in ipairs(self.chords) do
    if i>1 then
      self.chord_index()
    end
  end

  -- create the chord sequences
  self.chord_seq={}
  for _,notes in ipairs(self.chords) do
    table.insert(self.chord_seq,s(notes))
  end

  -- startup some lattices
  self.lattice=lattice_:new()
  self.pattern_chord=self.lattice:new_pattern{
    action=function(x)
      -- iterate chord index
      local ind=self.chord_index()

    end,
    division=1,
  }

  self.lattice:hard_restart()
end

function Monosong:stop()
  self.lattice:destroy()
end

-- minimize_transposition transposes each chord for minimal distance
function Monosong:minimize_transposition()
  local current_chord=self.chords[1]
  for i,chord in ipairs(self.chords) do
    self.chords[i]=table.smallest_modded_rot(current_chord,chord,12)
    current_chord=self.chords[i]
  end
end

-- rotates order of notes in chord to monosong playing
function Monosong:minimize_changes()
  self.chords=table.minimize_row_changes(self.chords)
end

return Monosong
