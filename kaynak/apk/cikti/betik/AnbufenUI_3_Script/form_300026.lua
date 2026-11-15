NEW_FORM_DEADSELECT= { }
NEW_FORM_DEADSELECT.Main = function( m )
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
NEW_FORM_DEADSELECT.C50447_OnLoad = function( m )
UI_Engine.SetLevel(m.formIndex, 3)
end
NEW_FORM_DEADSELECT.C50447_OnClick = function( m )
m:Relive(m.userSelectItem)

end
NEW_FORM_DEADSELECT.C50447_OnUpdate = function( m )
local formIndex,str=m:GetList(m.offset)
UI_Engine.SetText(formIndex,UI3_COMPOSIT_DDSLT1,str,0)
end
NEW_FORM_DEADSELECT.C50448_OnClick = function( m )
m:Relive(m.userSelectItem)


end
NEW_FORM_DEADSELECT.C50448_OnUpdate = function( m )
local formIndex,str=m:GetList(m.offset+1)
UI_Engine.SetText(formIndex,UI3_COMPOSIT_DDSLT2,str,0)
end
NEW_FORM_DEADSELECT.C50449_OnClick = function( m )
m:Relive(m.userSelectItem)


end
NEW_FORM_DEADSELECT.C50449_OnUpdate = function( m )
local formIndex,str=m:GetList(m.offset+2)
UI_Engine.SetText(formIndex,UI3_COMPOSIT_DDSLT3,str,0)
end
NEW_FORM_DEADSELECT.C50450_OnClick = function( m )
m:Relive(m.userSelectItem)


end
NEW_FORM_DEADSELECT.C50450_OnUpdate = function( m )
local formIndex,str=m:GetList(m.offset+3)
UI_Engine.SetText(formIndex,UI3_COMPOSIT_DDSLT4,str,0)
end
NEW_FORM_DEADSELECT.C50451_OnClick = function( m )
m:Relive(m.userSelectItem)

end
NEW_FORM_DEADSELECT.C50451_OnUpdate = function( m )
local formIndex,str=m:GetList(m.offset+4)
UI_Engine.SetText(formIndex,UI3_COMPOSIT_DDSLT5,str,0)
end
