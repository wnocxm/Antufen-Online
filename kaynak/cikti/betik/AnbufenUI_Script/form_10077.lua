FORM_DEADSELECT= { }
FORM_DEADSELECT.Main = function( m )
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
FORM_DEADSELECT.C52040_OnClick = function( m )
m:Relive(m.userSelectItem)
end
FORM_DEADSELECT.C52040_OnUpdate = function( m )
local formIndex,str=m:GetList(m.offset)
UI_Engine.SetText(formIndex,COMPOSIT_DDSLT1,str,0)

end
FORM_DEADSELECT.C52039_OnClick = function( m )
m:Relive(m.userSelectItem)
end
FORM_DEADSELECT.C52039_OnUpdate = function( m )
local formIndex,str=m:GetList(m.offset+1)
UI_Engine.SetText(formIndex,COMPOSIT_DDSLT2,str,0)
end
FORM_DEADSELECT.C52038_OnClick = function( m )
m:Relive(m.userSelectItem)
end
FORM_DEADSELECT.C52038_OnUpdate = function( m )
local formIndex,str=m:GetList(m.offset+2)
UI_Engine.SetText(formIndex,COMPOSIT_DDSLT3,str,0)
end
FORM_DEADSELECT.C52037_OnClick = function( m )
m:Relive(m.userSelectItem)
end
FORM_DEADSELECT.C52037_OnUpdate = function( m )
local formIndex,str=m:GetList(m.offset+3)
UI_Engine.SetText(formIndex,COMPOSIT_DDSLT4,str,0)
end
FORM_DEADSELECT.C52036_OnClick = function( m )
m:Relive(m.userSelectItem)
end
FORM_DEADSELECT.C52036_OnUpdate = function( m )
local formIndex,str=m:GetList(m.offset+4)
UI_Engine.SetText(formIndex,COMPOSIT_DDSLT5,str,0)
end
FORM_DEADSELECT.C52785_OnClick = function( m )
m:Relive(m.userSelectItem)
end
FORM_DEADSELECT.C52785_OnUpdate = function( m )
local formIndex,str=m:GetList(m.offset+5)
UI_Engine.SetText(formIndex,COMPOSIT_DDSLT6,str,0)
end
