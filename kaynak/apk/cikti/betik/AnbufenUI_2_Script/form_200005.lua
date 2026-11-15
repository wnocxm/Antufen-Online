NEW_FORM_SKILLLEARN= { }
NEW_FORM_SKILLLEARN.Main = function( m )
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
local SetInfo = function(m)
	local img, name, des = m:GetDrawInfo()
	if img ~= nil then
		UI_Engine.SetSurfaceImg(m.formIndex, UI2_COMPOSIT_163, img)
		UI_Engine.SetText(m.formIndex, UI2_COMPOSIT_326, name)
		UI_Engine.SetText(m.formIndex, UI2_COMPOSIT_166, des)
	end
end
NEW_FORM_SKILLLEARN.C50165_OnClick = function( m )
m:OnClickBtn()
end
NEW_FORM_SKILLLEARN.C50162_OnClick = function( m )
m:Close()
end
NEW_FORM_SKILLLEARN.C50161_OnLoad = function( m )
SetInfo(m)
end
