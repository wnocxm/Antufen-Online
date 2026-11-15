NEW_FORM_SMRITI= { }
NEW_FORM_SMRITI.Main = function( m )
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
local OnClick = function(m,nCompositID)
	m:OnClick(nCompositID)
end

local OnDraw = function(m)
	m:Draw()
end
NEW_FORM_SMRITI.C50264_OnClick = function( m )
OnClick(m,UI1_COMPOSIT_SMRITI_ICON_EQUIP)
end
NEW_FORM_SMRITI.C50265_OnClick = function( m )
OnClick(m,UI1_COMPOSIT_SMRITI_ICON_RUNITEM)
end
NEW_FORM_SMRITI.C50266_OnClick = function( m )
OnClick(m,UI1_COMPOSIT_SMRITI_ICON_ITEM)
end
NEW_FORM_SMRITI.C50267_OnClick = function( m )
OnClick(m,UI1_COMPOSIT_SMRITI_ICON_ASSIST_ITEM)
end
NEW_FORM_SMRITI.C50280_OnClick = function( m )
OnClick(m,UI1_COMPOSIT_SMRITI_ICON_RESULT)
end
NEW_FORM_SMRITI.C50275_OnClick = function( m )
OnClick(m,UI1_COMPOSIT_SMRITI_BUTTON)
end
NEW_FORM_SMRITI.C50278_OnClick = function( m )
m:Close()
end
NEW_FORM_SMRITI.C50281_OnClick = function( m )
OnClick(m,UI1_COMPOSIT_SMRITI_BUTTON_BUY)
end
