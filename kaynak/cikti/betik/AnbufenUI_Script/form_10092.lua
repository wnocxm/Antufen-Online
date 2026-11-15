FORM_SELF= { }
FORM_SELF.Main = function( m )
  while true do
      m.DoEvt = nil
      m.arg = nil
      m.result = nil
      m:WaitEvt()
      if m.DoEvt~=nil then
          m:DoEvt()
      end
    end
end
FORM_SELF.C52492_OnClick = function( m )
m:OnLeave()
end
FORM_SELF.C52491_OnClick = function( m )
m.NPCLook = NewNPCLook(m)
m.NPCLook:WaitUserInput(m)
DelNPCLook(m.NPCLook)
end
FORM_SELF.C52490_OnClick = function( m )
NewRelationMenu(m)
end
FORM_SELF.C52489_OnClick = function( m )
NewTask(m)
end
FORM_SELF.C52488_OnClick = function( m )
m:OnBag()
end
FORM_SELF.C52487_OnClick = function( m )
NewPlayerInfo(m)
end
