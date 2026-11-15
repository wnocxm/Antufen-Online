FORM_GATESERVER_SEL= { }
FORM_GATESERVER_SEL.Main = function( m )
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
FORM_GATESERVER_SEL.C52212_OnClick = function( m )
m:Close()
end
FORM_GATESERVER_SEL.C52672_OnClick = function( m )
m:OnClick(m.userSelectItem)
end
FORM_GATESERVER_SEL.C50052_OnClick = function( m )
--m:OnClick(m.userSelectItem)
end
FORM_GATESERVER_SEL.C50052_OnUpdate = function( m )
local formIndex ,name= m:GetGateList(m.offset)
UI_Engine.SetText(formIndex,GATESERVERSEL_COMPOSIT_LIST0,name,0)
end
FORM_GATESERVER_SEL.C50053_OnLoad = function( m )
UI_Engine.SetState(m.formIndex,COMPOSIT_SHORTCUT_TAB1,1)
end
FORM_GATESERVER_SEL.C50053_OnFocus = function( m )


end
FORM_GATESERVER_SEL.C50053_OnClick = function( m )
--m:OnClick(m.userSelectItem)

end
FORM_GATESERVER_SEL.C50053_OnUpdate = function( m )
local formIndex ,name= m:GetGateList(m.offset+1)
UI_Engine.SetText(formIndex,GATESERVERSEL_COMPOSIT_LIST1,name,0)

end
FORM_GATESERVER_SEL.C50054_OnFocus = function( m )


end
FORM_GATESERVER_SEL.C50054_OnClick = function( m )
--m:OnClick(m.userSelectItem)


end
FORM_GATESERVER_SEL.C50054_OnUpdate = function( m )
local formIndex ,name= m:GetGateList(m.offset+2)
UI_Engine.SetText(formIndex,GATESERVERSEL_COMPOSIT_LIST2,name,0)

end
FORM_GATESERVER_SEL.C50055_OnClick = function( m )
--m:OnClick(m.userSelectItem)

end
FORM_GATESERVER_SEL.C50055_OnUpdate = function( m )
local formIndex ,name= m:GetGateList(m.offset+3)
UI_Engine.SetText(formIndex,GATESERVERSEL_COMPOSIT_LIST3,name,0)

end
FORM_GATESERVER_SEL.C50056_OnClick = function( m )
--m:OnClick(m.userSelectItem)


end
FORM_GATESERVER_SEL.C50056_OnUpdate = function( m )
local formIndex ,name= m:GetGateList(m.offset+4)
UI_Engine.SetText(formIndex,GATESERVERSEL_COMPOSIT_LIST4,name,0)

end
FORM_GATESERVER_SEL.C50057_OnClick = function( m )
--m:OnClick(m.userSelectItem)

end
FORM_GATESERVER_SEL.C50057_OnUpdate = function( m )
local formIndex ,name= m:GetGateList(m.offset+5)
UI_Engine.SetText(formIndex,GATESERVERSEL_COMPOSIT_LIST5,name,0)

end
FORM_GATESERVER_SEL.C50730_OnClick = function( m )
--m:OnClick(m.userSelectItem)
end
FORM_GATESERVER_SEL.C50730_OnUpdate = function( m )
local formIndex ,name= m:GetGateList(m.offset+6)
UI_Engine.SetText(formIndex,GATESERVERSEL_COMPOSIT_LIST6,name,0)
end
FORM_GATESERVER_SEL.C50731_OnClick = function( m )
--m:OnClick(m.userSelectItem)
end
FORM_GATESERVER_SEL.C50731_OnUpdate = function( m )
local formIndex ,name= m:GetGateList(m.offset+7)
UI_Engine.SetText(formIndex,GATESERVERSEL_COMPOSIT_LIST7,name,0)
end
