FORM_IAP_SETTING= { }
FORM_IAP_SETTING.Main = function( m )
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
FORM_IAP_SETTING.C52105_OnLoad = function( m )

local nValue = m:GetSaveIap()
UI_Engine.SetState(m.formIndex, COMPOSIT_2105, nValue)

end
FORM_IAP_SETTING.C52104_OnLoad = function( m )
UI_Engine.UpdateList(m.formIndex,COMPOSIT_2104)
end
FORM_IAP_SETTING.C52104_OnClick = function( m )
DBGPRINTF(m.userSelectItem)
end
FORM_IAP_SETTING.C52104_OnUpdate = function( m )
DBGPRINTF(m.offset.."m.offset")
local text = m:GetListText(m.offset + 0)
UI_Engine.SetText(m.formIndex,COMPOSIT_2104,text ,0)
DBGPRINTF("composit 1:"..COMPOSIT_2104)

end
FORM_IAP_SETTING.C52103_OnClick = function( m )
DBGPRINTF(m.userSelectItem)
end
FORM_IAP_SETTING.C52103_OnUpdate = function( m )
local text = m:GetListText(m.offset + 1)
UI_Engine.SetText(m.formIndex,COMPOSIT_2103,text ,0)
DBGPRINTF("composit 2:"..COMPOSIT_2103)
end
FORM_IAP_SETTING.C52102_OnClick = function( m )
DBGPRINTF(m.userSelectItem)
end
FORM_IAP_SETTING.C52102_OnUpdate = function( m )
local text = m:GetListText(m.offset + 2)
UI_Engine.SetText(m.formIndex,COMPOSIT_2102,text ,0)
end
FORM_IAP_SETTING.C52101_OnClick = function( m )
DBGPRINTF(m.userSelectItem)
end
FORM_IAP_SETTING.C52101_OnUpdate = function( m )
local text = m:GetListText(m.offset + 3)
UI_Engine.SetText(m.formIndex,COMPOSIT_2101,text ,0)
end
FORM_IAP_SETTING.C52100_OnClick = function( m )
DBGPRINTF(m.userSelectItem)
end
FORM_IAP_SETTING.C52100_OnUpdate = function( m )
local text = m:GetListText(m.offset + 4)
UI_Engine.SetText(m.formIndex,COMPOSIT_2100,text ,0)
end
FORM_IAP_SETTING.C52099_OnClick = function( m )
DBGPRINTF(m.userSelectItem)
end
FORM_IAP_SETTING.C52099_OnUpdate = function( m )
local text = m:GetListText(m.offset + 5)
UI_Engine.SetText(m.formIndex,COMPOSIT_2099,text ,0)
end
FORM_IAP_SETTING.C52098_OnClick = function( m )
DBGPRINTF(m.userSelectItem)
end
FORM_IAP_SETTING.C52098_OnUpdate = function( m )
local text = m:GetListText(m.offset + 6)
UI_Engine.SetText(m.formIndex,COMPOSIT_2098,text ,0)
end
FORM_IAP_SETTING.C52120_OnClick = function( m )
DBGPRINTF(m.userSelectItem)
end
FORM_IAP_SETTING.C52120_OnUpdate = function( m )
local text = m:GetListText(m.offset + 7)
UI_Engine.SetText(m.formIndex,COMPOSIT_2120,text ,0)
end
FORM_IAP_SETTING.C52094_OnClick = function( m )
local nValue = UI_Engine.GetState(m.formIndex,COMPOSIT_2105)
m:SetSaveIap(nValue)

m:SelectIap(m.userSelectItem)
m:ExitType(IapExitType.EXIT_CHOICE)
m:Close()

end
FORM_IAP_SETTING.C52095_OnClick = function( m )
m:ExitType(IapExitType.EXIT_CANCEL)
--m:InputFinished()
m:Close()
end
