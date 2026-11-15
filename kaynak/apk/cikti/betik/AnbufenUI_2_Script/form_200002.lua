NEW_FORM_SINGLELIST= { }
NEW_FORM_SINGLELIST.Main = function( m )
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
local SetList = function(m, id, offset)
	local str = m:GetDrawInfo(m.offset + offset)
	if nil ~= str then
		UI_Engine.SetText(m.formIndex, id, str)
	else
		UI_Engine.SetText(m.formIndex, id, "")
	end
end

local ClickList = function(m, offset)
	m:OnSelectList(offset)
	m:InputFinished()
end
NEW_FORM_SINGLELIST.C50074_OnClick = function( m )
ClickList(m, m.userSelectItem)
end
NEW_FORM_SINGLELIST.C50074_OnUpdate = function( m )
SetList(m, UI2_COMPOSIT_74, 0)
end
NEW_FORM_SINGLELIST.C50075_OnClick = function( m )
ClickList(m, m.userSelectItem)
end
NEW_FORM_SINGLELIST.C50075_OnUpdate = function( m )
SetList(m, UI2_COMPOSIT_75, 1)
end
NEW_FORM_SINGLELIST.C50076_OnClick = function( m )
ClickList(m, m.userSelectItem)
end
NEW_FORM_SINGLELIST.C50076_OnUpdate = function( m )
SetList(m, UI2_COMPOSIT_76, 2)
end
NEW_FORM_SINGLELIST.C50077_OnClick = function( m )
ClickList(m, m.userSelectItem)
end
NEW_FORM_SINGLELIST.C50077_OnUpdate = function( m )
SetList(m, UI2_COMPOSIT_77, 3)
end
NEW_FORM_SINGLELIST.C50078_OnClick = function( m )
ClickList(m, m.userSelectItem)
end
NEW_FORM_SINGLELIST.C50078_OnUpdate = function( m )
SetList(m, UI2_COMPOSIT_78, 4)
end
NEW_FORM_SINGLELIST.C50079_OnClick = function( m )
ClickList(m, m.userSelectItem)
end
NEW_FORM_SINGLELIST.C50079_OnUpdate = function( m )
SetList(m, UI2_COMPOSIT_79, 5)
end
NEW_FORM_SINGLELIST.C50081_OnClick = function( m )
m:InputFinished()
--m:Close()
end
