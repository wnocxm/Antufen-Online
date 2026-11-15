NEW_FORM_SKILLSELECT= { }
NEW_FORM_SKILLSELECT.Main = function( m )
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
	local img, name, learn, ret = m:GetDrawInfo(m.offset + offset)
	if img ~= nil then
		if ret == true then
			UI_Engine.SetSurfaceImg(m.formIndex, id, img, 0)
			UI_Engine.SetText(m.formIndex, id, name, 1)
			UI_Engine.SetText(m.formIndex, id, learn, 2)
		else
			UI_Engine.SetSurfaceImg(m.formIndex, id, img, 0, 0, true)
			UI_Engine.SetText(m.formIndex, id, name, 1)
			UI_Engine.SetText(m.formIndex, id, learn, 2)
		end
	end
end
NEW_FORM_SKILLSELECT.C50154_OnClick = function( m )
m:OnClick(m.userSelectItem)
end
NEW_FORM_SKILLSELECT.C50154_OnUpdate = function( m )
UpdateText(m, UI2_COMPOSIT_154, 0)
end
NEW_FORM_SKILLSELECT.C50155_OnClick = function( m )
m:OnClick(m.userSelectItem)
end
NEW_FORM_SKILLSELECT.C50155_OnUpdate = function( m )
UpdateText(m, UI2_COMPOSIT_155, 1)
end
NEW_FORM_SKILLSELECT.C50156_OnClick = function( m )
m:OnClick(m.userSelectItem)
end
NEW_FORM_SKILLSELECT.C50156_OnUpdate = function( m )
UpdateText(m, UI2_COMPOSIT_156, 2)
end
NEW_FORM_SKILLSELECT.C50157_OnClick = function( m )
m:OnClick(m.userSelectItem)
end
NEW_FORM_SKILLSELECT.C50157_OnUpdate = function( m )
UpdateText(m, UI2_COMPOSIT_157, 3)
end
NEW_FORM_SKILLSELECT.C50158_OnClick = function( m )
m:OnClick(m.userSelectItem)
end
NEW_FORM_SKILLSELECT.C50158_OnUpdate = function( m )
UpdateText(m, UI2_COMPOSIT_158, 4)
end
NEW_FORM_SKILLSELECT.C50159_OnClick = function( m )
m:OnClick(m.userSelectItem)
end
NEW_FORM_SKILLSELECT.C50159_OnUpdate = function( m )
UpdateText(m, UI2_COMPOSIT_159, 5)
end
NEW_FORM_SKILLSELECT.C50153_OnClick = function( m )
--m:InputFinished()
m:Close()
end
