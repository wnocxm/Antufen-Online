NEW_FORM_DETACH= { }
NEW_FORM_DETACH.Main = function( m )
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
NEW_FORM_DETACH.C50287_OnClick = function( m )
OnClick(m,UI1_COMPOSIT_DETACH_EQUIP)
end
NEW_FORM_DETACH.C50288_OnClick = function( m )
OnClick(m,UI1_COMPOSIT_DETACH_RUNITEM)
end
NEW_FORM_DETACH.C50289_OnClick = function( m )
OnClick(m,UI1_COMPOSIT_DETACH_ASSISITEM)
end
NEW_FORM_DETACH.C50290_OnClick = function( m )
OnClick(m,UI1_COMPOSIT_DETACH_RESULT)
end
NEW_FORM_DETACH.C50291_OnClick = function( m )
OnClick(m,UI1_COMPOSIT_DETACH_BUTTON)
end
NEW_FORM_DETACH.C50299_OnClick = function( m )
OnClick(m,UI1_COMPOSIT_DETACH_CLOSE)
end
NEW_FORM_DETACH.C50301_OnClick = function( m )
OnClick(m,UI1_COMPOSIT_DETACH_BUTTON_BUY)
end
