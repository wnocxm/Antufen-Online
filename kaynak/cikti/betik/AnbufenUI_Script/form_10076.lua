FORM_REPAIR= { }
FORM_REPAIR.Main = function( m )
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
FORM_REPAIR.C52750_OnClick = function( m )
DBGPRINTF("Exit")
m:Cancel()
end
FORM_REPAIR.C52011_OnUpdate = function( m )
m:UpdateList(m.offset+1,COMPOSIT_2011,0)
end
FORM_REPAIR.C52012_OnUpdate = function( m )
m:UpdateList(m.offset+2,COMPOSIT_2012,0)
end
FORM_REPAIR.C52013_OnUpdate = function( m )
m:UpdateList(m.offset+3,COMPOSIT_2013,0)
end
FORM_REPAIR.C52014_OnUpdate = function( m )
m:UpdateList(m.offset+4,COMPOSIT_2014,0)
end
FORM_REPAIR.C52015_OnUpdate = function( m )
m:UpdateList(m.offset+5,COMPOSIT_2015,0)
end
FORM_REPAIR.C52016_OnUpdate = function( m )
m:UpdateList(m.offset+6,COMPOSIT_2016,0)

end
FORM_REPAIR.C52006_OnClick = function( m )
m:RepairAll()
end
FORM_REPAIR.C52005_OnClick = function( m )
m:OnClickList( m.userSelectItem )
m:Repair()
end
