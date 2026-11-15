NEW_FORM_CFSSELECT= { }
NEW_FORM_CFSSELECT.Main = function( m )
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
local UpdateText = function(m, id, offset)
	local str = m:GetDrawInfo(m.offset + offset)
	if str ~= nil then
		UI_Engine.SetText(m.formIndex, id, str)
	else
		UI_Engine.SetText(m.formIndex, id, "")
	end
end
NEW_FORM_CFSSELECT.C50563_OnClick = function( m )
m:Close()
end
NEW_FORM_CFSSELECT.C50557_OnClick = function( m )
m:OnClickList(m.userSelectItem)
end
NEW_FORM_CFSSELECT.C50557_OnUpdate = function( m )
UpdateText(m, UI2_COMPOSIT_557, 0)
end
NEW_FORM_CFSSELECT.C50558_OnClick = function( m )
m:OnClickList(m.userSelectItem)
end
NEW_FORM_CFSSELECT.C50558_OnUpdate = function( m )
UpdateText(m, UI2_COMPOSIT_558, 1)
end
NEW_FORM_CFSSELECT.C50559_OnClick = function( m )
m:OnClickList(m.userSelectItem)
end
NEW_FORM_CFSSELECT.C50559_OnUpdate = function( m )
UpdateText(m, UI2_COMPOSIT_559, 2)
end
NEW_FORM_CFSSELECT.C50560_OnClick = function( m )
m:OnClickList(m.userSelectItem)
end
NEW_FORM_CFSSELECT.C50560_OnUpdate = function( m )
UpdateText(m, UI2_COMPOSIT_560, 3)
end
NEW_FORM_CFSSELECT.C50561_OnClick = function( m )
m:OnClickList(m.userSelectItem)
end
NEW_FORM_CFSSELECT.C50561_OnUpdate = function( m )
UpdateText(m, UI2_COMPOSIT_561, 4)
end
NEW_FORM_CFSSELECT.C50562_OnClick = function( m )
m:OnClickList(m.userSelectItem)
end
NEW_FORM_CFSSELECT.C50562_OnUpdate = function( m )
UpdateText(m, UI2_COMPOSIT_562, 5)
end
