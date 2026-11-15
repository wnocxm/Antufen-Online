FORM_SERVER_SEL= { }
FORM_SERVER_SEL.Main = function( m )
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
FORM_SERVER_SEL.C50041_OnClick = function( m )
--m:OnClick(m.userSelectItem)
end
FORM_SERVER_SEL.C50041_OnUpdate = function( m )
local formIndex ,name,state= m:GetGateList(m.offset)
UI_Engine.SetText(formIndex,SERVERSEL_COMPOSIT_LIST0,name,0)
UI_Engine.SetText(formIndex,SERVERSEL_COMPOSIT_LIST0,state,1)


end
FORM_SERVER_SEL.C50042_OnClick = function( m )
--m:OnClick(m.userSelectItem)
end
FORM_SERVER_SEL.C50042_OnUpdate = function( m )
local formIndex ,name,state= m:GetGateList(m.offset+1)
UI_Engine.SetText(formIndex,SERVERSEL_COMPOSIT_LIST1,name,0)
UI_Engine.SetText(formIndex,SERVERSEL_COMPOSIT_LIST1,state,1)



end
FORM_SERVER_SEL.C50043_OnClick = function( m )
--m:OnClick(m.userSelectItem)
end
FORM_SERVER_SEL.C50043_OnUpdate = function( m )
local formIndex ,name,state= m:GetGateList(m.offset+2)
UI_Engine.SetText(formIndex,SERVERSEL_COMPOSIT_LIST2,name,0)
UI_Engine.SetText(formIndex,SERVERSEL_COMPOSIT_LIST2,state,1)



end
FORM_SERVER_SEL.C50044_OnClick = function( m )
--m:OnClick(m.userSelectItem)
end
FORM_SERVER_SEL.C50044_OnUpdate = function( m )
local formIndex ,name,state= m:GetGateList(m.offset+3)
UI_Engine.SetText(formIndex,SERVERSEL_COMPOSIT_LIST3,name,0)
UI_Engine.SetText(formIndex,SERVERSEL_COMPOSIT_LIST3,state,1)



end
FORM_SERVER_SEL.C50045_OnClick = function( m )
--m:OnClick(m.userSelectItem)
end
FORM_SERVER_SEL.C50045_OnUpdate = function( m )
local formIndex ,name,state= m:GetGateList(m.offset+4)
UI_Engine.SetText(formIndex,SERVERSEL_COMPOSIT_LIST4,name,0)
UI_Engine.SetText(formIndex,SERVERSEL_COMPOSIT_LIST4,state,1)



end
FORM_SERVER_SEL.C50046_OnClick = function( m )
--m:OnClick(m.userSelectItem)
end
FORM_SERVER_SEL.C50046_OnUpdate = function( m )
local formIndex ,name,state= m:GetGateList(m.offset+5)
UI_Engine.SetText(formIndex,SERVERSEL_COMPOSIT_LIST5,name,0)
UI_Engine.SetText(formIndex,SERVERSEL_COMPOSIT_LIST5,state,1)
end
FORM_SERVER_SEL.C50768_OnClick = function( m )
--m:OnClick(m.userSelectItem)
end
FORM_SERVER_SEL.C50768_OnUpdate = function( m )
local formIndex ,name,state= m:GetGateList(m.offset+6)
UI_Engine.SetText(formIndex,SERVERSEL_COMPOSIT_LIST6,name,0)
UI_Engine.SetText(formIndex,SERVERSEL_COMPOSIT_LIST6,state,1)
end
FORM_SERVER_SEL.C50769_OnClick = function( m )
--m:OnClick(m.userSelectItem)
end
FORM_SERVER_SEL.C50769_OnUpdate = function( m )
local formIndex ,name,state= m:GetGateList(m.offset+7)
UI_Engine.SetText(formIndex,SERVERSEL_COMPOSIT_LIST7,name,0)
UI_Engine.SetText(formIndex,SERVERSEL_COMPOSIT_LIST7,state,1)
end
FORM_SERVER_SEL.C52673_OnClick = function( m )
m:OnClick(m.userSelectItem)
end
FORM_SERVER_SEL.C52214_OnClick = function( m )
m:Close()
end
